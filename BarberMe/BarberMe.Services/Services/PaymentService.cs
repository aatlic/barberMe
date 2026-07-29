using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Constants;
using BarberMe.Model.Enum;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Payment;
using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Responses.Payment;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Stripe;

namespace BarberMe.Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;
        private readonly StripeSettings _stripeSettings;
        private readonly ICurrentUserService _currentUserService;

        public PaymentService(
            BarberMeDbContext context,
            IMapper mapper,
            IOptions<StripeSettings> stripeOptions,
            ICurrentUserService currentUserService)
        {
            _context = context;
            _mapper = mapper;
            _stripeSettings = stripeOptions.Value;
            _currentUserService = currentUserService;
        }

        public async Task<PaymentResponse> CreatePayment(int appointmentId)
        {
            var appointment = await _context.Appointments
                .Include(x => x.BarberService)
                .Include(x => x.Payment)
                .FirstOrDefaultAsync(x => x.AppointmentId == appointmentId);

            if (appointment == null)
            {
                throw new NotFoundException("Appointment not found.");
            }

            if (appointment.ClientId != _currentUserService.UserId)
            {
                throw new UnauthorizedException(
                    "You are not allowed to pay for this appointment.");
            }

            if (appointment.IsPaid)
            {
                throw new BusinessException(
                    "This appointment has already been paid.");
            }

            if (appointment.AppointmentStatusId ==
                (int)AppointmentStatusType.Cancelled)
            {
                throw new BusinessException(
                    "A cancelled appointment cannot be paid.");
            }

            var amount = appointment.BarberService.Price;

            if (amount <= 0)
            {
                throw new BusinessException(
                    "The appointment amount must be greater than zero.");
            }

            var paymentIntentService = new PaymentIntentService();

            /*
             * Ako već postoji otvoreni PaymentIntent, vraćamo njega.
             * Ne kreiramo novi Stripe PaymentIntent pri svakom kliku.
             */
            if (appointment.Payment != null &&
                appointment.Payment.PaymentStatusId ==
                (int)PaymentStatusType.Pending &&
                !string.IsNullOrWhiteSpace(
                    appointment.Payment.StripePaymentIntentId))
            {
                PaymentIntent existingPaymentIntent;

                try
                {
                    existingPaymentIntent =
                        await paymentIntentService.GetAsync(
                            appointment.Payment.StripePaymentIntentId);
                }
                catch (StripeException ex)
                {
                    throw new BusinessException(
                        $"Stripe payment could not be retrieved: " +
                        $"{ex.StripeError?.Message ?? ex.Message}");
                }

                if (existingPaymentIntent.Status == "succeeded")
                {
                    appointment.Payment.PaymentStatusId =
                        (int)PaymentStatusType.Completed;

                    appointment.Payment.PaidAt ??= DateTime.UtcNow;
                    appointment.IsPaid = true;

                    await _context.SaveChangesAsync();

                    return MapPaymentResponse(
                        appointment.Payment,
                        existingPaymentIntent.ClientSecret);
                }

                /*
                 * Ovi statusi predstavljaju aktivan PaymentIntent koji još uvijek
                 * može biti završen kroz Stripe PaymentSheet.
                 */
                if (existingPaymentIntent.Status is
                    "requires_payment_method" or
                    "requires_confirmation" or
                    "requires_action" or
                    "processing")
                {
                    return MapPaymentResponse(
                        appointment.Payment,
                        existingPaymentIntent.ClientSecret);
                }

                /*
                 * Ako je Stripe PaymentIntent otkazan, postojeći Payment zapis
                 * označavamo kao Failed, a ispod kreiramo novi PaymentIntent.
                 */
                if (existingPaymentIntent.Status == "canceled")
                {
                    appointment.Payment.PaymentStatusId =
                        (int)PaymentStatusType.Failed;
                }
            }

            if (appointment.Payment?.PaymentStatusId ==
                (int)PaymentStatusType.Completed)
            {
                throw new BusinessException(
                    "This appointment has already been paid.");
            }

            var payment = appointment.Payment;

            if (payment == null)
            {
                payment = new Payment
                {
                    AppointmentId = appointment.AppointmentId,
                    Amount = amount,
                    PaymentStatusId = (int)PaymentStatusType.Pending,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Payments.Add(payment);
            }
            else
            {
                /*
                 * Ponovni pokušaj nakon neuspjelog ili otkazanog plaćanja.
                 * Koristimo isti Payment zapis jer Appointment ima jedan Payment.
                 */
                payment.Amount = amount;
                payment.PaymentStatusId = (int)PaymentStatusType.Pending;
                payment.PaidAt = null;
            }

            var amountInMinorUnits = decimal.ToInt64(
                decimal.Round(
                    amount * 100,
                    0,
                    MidpointRounding.AwayFromZero));

            var paymentIntentOptions = new PaymentIntentCreateOptions
            {
                Amount = amountInMinorUnits,
                Currency = _stripeSettings.Currency,

                AutomaticPaymentMethods =
                    new PaymentIntentAutomaticPaymentMethodsOptions
                    {
                        Enabled = true,
                        AllowRedirects = "never"
                    },

                Metadata = new Dictionary<string, string>
        {
            {
                "AppointmentId",
                appointment.AppointmentId.ToString()
            },
            {
                "ClientId",
                appointment.ClientId.ToString()
            }
        },

                Description =
                    $"BarberMe appointment #{appointment.AppointmentId}"
            };

            PaymentIntent paymentIntent;

            try
            {
                paymentIntent = await paymentIntentService.CreateAsync(
                    paymentIntentOptions,
                    new RequestOptions
                    {
                        /*
                         * Stripe neće kreirati dva PaymentIntenta ako se isti
                         * HTTP zahtjev slučajno ponovi.
                         */
                        IdempotencyKey =
                            $"appointment-{appointment.AppointmentId}-payment"
                    });
            }
            catch (StripeException ex)
            {
                throw new BusinessException(
                    $"Stripe payment could not be created: " +
                    $"{ex.StripeError?.Message ?? ex.Message}");
            }

            payment.StripePaymentIntentId = paymentIntent.Id;
            payment.Amount = amount;
            payment.PaymentStatusId = (int)PaymentStatusType.Pending;

            await _context.SaveChangesAsync();

            return MapPaymentResponse(
                payment,
                paymentIntent.ClientSecret);
        }

        private PaymentResponse MapPaymentResponse(
            Payment payment,
            string? clientSecret)
        {
            var response = _mapper.Map<PaymentResponse>(payment);

            response.Status =
                (PaymentStatusType)payment.PaymentStatusId;

            response.ClientSecret = clientSecret;
            response.Currency = _stripeSettings.Currency;

            return response;
        }

        public async Task<bool> ConfirmPayment(int paymentId)
        {
            var payment = await _context.Payments
                .Include(x => x.Appointment)
                .FirstOrDefaultAsync(x => x.PaymentId == paymentId);

            if (payment == null)
                throw new NotFoundException("Payment not found.");

            if (payment.Appointment.ClientId != _currentUserService.UserId)
                throw new UnauthorizedException(
                    "You are not allowed to confirm this payment.");

            if (payment.PaymentStatusId == (int)PaymentStatusType.Completed)
                return true;

            if (string.IsNullOrWhiteSpace(payment.StripePaymentIntentId))
                throw new BusinessException(
                    "Stripe PaymentIntent is missing for this payment.");

            var paymentIntentService = new PaymentIntentService();

            PaymentIntent paymentIntent;

            try
            {
                paymentIntent = await paymentIntentService.GetAsync(
                    payment.StripePaymentIntentId);
            }
            catch (StripeException ex)
            {
                throw new BusinessException(
                    $"Stripe error: {ex.StripeError?.Message ?? ex.Message}");
            }

            if (paymentIntent.Status != "succeeded")
            {
                if (paymentIntent.Status == "canceled")
                {
                    payment.PaymentStatusId =
                        (int)PaymentStatusType.Failed;

                    await _context.SaveChangesAsync();
                }

                throw new BusinessException(
                    $"Payment has not been completed. Stripe status: {paymentIntent.Status}.");
            }

            payment.PaymentStatusId = (int)PaymentStatusType.Completed;
            payment.PaidAt = DateTime.UtcNow;

            payment.Appointment.IsPaid = true;

            await _context.SaveChangesAsync();

            return true;
        }

        public async Task HandleWebhookAsync( string json, string stripeSignature)
        {
            Event stripeEvent;

            try
            {
                stripeEvent = EventUtility.ConstructEvent(
                    json,
                    stripeSignature,
                    _stripeSettings.WebhookSecret);
            }
            catch (StripeException ex)
            {
                throw new BusinessException(
                    $"Invalid Stripe webhook signature: {ex.Message}");
            }

            switch (stripeEvent.Type)
            {
                case EventTypes.PaymentIntentSucceeded:
                    {
                        if (stripeEvent.Data.Object is not PaymentIntent paymentIntent)
                        {
                            throw new BusinessException(
                                "Stripe PaymentIntent data is missing.");
                        }

                        await CompletePaymentAsync(paymentIntent);
                        break;
                    }

                case EventTypes.PaymentIntentPaymentFailed:
                    {
                        if (stripeEvent.Data.Object is not PaymentIntent paymentIntent)
                        {
                            throw new BusinessException(
                                "Stripe PaymentIntent data is missing.");
                        }

                        await FailPaymentAsync(paymentIntent);
                        break;
                    }

                case EventTypes.PaymentIntentCanceled:
                    {
                        if (stripeEvent.Data.Object is not PaymentIntent paymentIntent)
                        {
                            throw new BusinessException(
                                "Stripe PaymentIntent data is missing.");
                        }

                        await FailPaymentAsync(paymentIntent);
                        break;
                    }
            }
        }

        private async Task CompletePaymentAsync(PaymentIntent paymentIntent)
        {
            var payment = await _context.Payments
                .Include(x => x.Appointment)
                .FirstOrDefaultAsync(x =>
                    x.StripePaymentIntentId == paymentIntent.Id);

            if (payment == null)
            {
                throw new NotFoundException($"Payment for Stripe PaymentIntent {paymentIntent.Id} was not found.");
            }

            if (payment.PaymentStatusId == (int)PaymentStatusType.Completed)
            {
                return;
            }

            payment.PaymentStatusId = (int)PaymentStatusType.Completed;

            payment.PaidAt = DateTime.UtcNow;
            payment.Appointment.IsPaid = true;

            await _context.SaveChangesAsync();
        }

        private async Task FailPaymentAsync(PaymentIntent paymentIntent)
        {
            var payment = await _context.Payments
                .FirstOrDefaultAsync(x =>
                    x.StripePaymentIntentId == paymentIntent.Id);

            if (payment == null)
            {
                return;
            }

            if (payment.PaymentStatusId == (int)PaymentStatusType.Completed)
            {
                return;
            }

            payment.PaymentStatusId = (int)PaymentStatusType.Failed;

            await _context.SaveChangesAsync();
        }

        public async Task<RefundResponse> RefundPaymentAsync(
            int paymentId,
            RefundInsertRequest request)
        {
            var payment = await _context.Payments
                .Include(x => x.Appointment)
                .Include(x => x.Refunds)
                .FirstOrDefaultAsync(x => x.PaymentId == paymentId);

            if (payment == null)
            {
                throw new NotFoundException("Payment not found.");
            }

            if (payment.PaymentStatusId != (int)PaymentStatusType.Completed)
            {
                throw new BusinessException("Only completed payments can be refunded.");
            }

            if (!payment.Appointment.IsPaid)
            {
                throw new BusinessException("The appointment is not marked as paid.");
            }

            if (string.IsNullOrWhiteSpace(payment.StripePaymentIntentId))
            {
                throw new BusinessException("Stripe PaymentIntent is missing.");
            }

            if (payment.Refunds.Any())
            {
                throw new BusinessException("This payment has already been refunded.");
            }

            var refundService = new Stripe.RefundService();

            Stripe.Refund stripeRefund;

            try
            {
                var refundOptions = new Stripe.RefundCreateOptions
                {
                    PaymentIntent = payment.StripePaymentIntentId,
                    Reason = "requested_by_customer",
                    Metadata = new Dictionary<string, string>
                    {
                        {
                            "PaymentId",
                            payment.PaymentId.ToString()
                        },
                        {
                            "AppointmentId",
                            payment.AppointmentId.ToString()
                        }
                    }
                };

                if (!string.IsNullOrWhiteSpace(request.Reason))
                {
                    refundOptions.Metadata.Add(
                        "RefundReason",
                        request.Reason.Trim());
                }

                stripeRefund = await refundService.CreateAsync(
                    refundOptions,
                    new RequestOptions
                    {
                        IdempotencyKey = $"payment-{payment.PaymentId}-full-refund"
                    });
            }
            catch (StripeException ex)
            {
                throw new BusinessException(
                    $"Stripe refund could not be created: " +
                    $"{ex.StripeError?.Message ?? ex.Message}");
            }

            if (stripeRefund.Status != "succeeded" &&
                stripeRefund.Status != "pending")
            {
                throw new BusinessException(
                    $"Stripe refund was not accepted. " +
                    $"Status: {stripeRefund.Status}.");
            }

            var refund = new BarberMe.Database.Models.Refund
            {
                PaymentId = payment.PaymentId,
                Amount = payment.Amount,
                Reason = request.Reason?.Trim(),
                StripeRefundId = stripeRefund.Id,
                CreatedAt = DateTime.UtcNow
            };

            _context.Refunds.Add(refund);

            payment.PaymentStatusId = (int)PaymentStatusType.Refunded;

            payment.Appointment.IsPaid = false;

            await _context.SaveChangesAsync();

            return new RefundResponse
            {
                Id = refund.RefundId,
                PaymentId = refund.PaymentId,
                Amount = refund.Amount,
                Reason = refund.Reason,
                StripeRefundId = refund.StripeRefundId,
                CreatedAt = refund.CreatedAt
            };
        }

        public async Task<bool> SimulateSuccessfulPayment(int paymentId)
        {
            var payment = await _context.Payments
                .Include(x => x.Appointment)
                .FirstOrDefaultAsync(x => x.PaymentId == paymentId);

            if (payment == null)
                throw new NotFoundException("Payment not found.");

            if (payment.Appointment.ClientId != _currentUserService.UserId)
                throw new UnauthorizedException(
                    "You are not allowed to pay this appointment.");

            if (payment.PaymentStatusId == (int)PaymentStatusType.Completed)
                return true;

            if (string.IsNullOrWhiteSpace(payment.StripePaymentIntentId))
                throw new BusinessException(
                    "Stripe PaymentIntent is missing.");

            var service = new PaymentIntentService();

            try
            {
                var paymentIntent = await service.ConfirmAsync(
                    payment.StripePaymentIntentId,
                    new PaymentIntentConfirmOptions
                    {
                        PaymentMethod = "pm_card_visa"
                    });

                if (paymentIntent.Status != "succeeded")
                {
                    throw new BusinessException(
                        $"Test payment was not completed. Stripe status: {paymentIntent.Status}.");
                }

                payment.PaymentStatusId = (int)PaymentStatusType.Completed;
                payment.PaidAt = DateTime.UtcNow;
                payment.Appointment.IsPaid = true;

                await _context.SaveChangesAsync();

                return true;
            }
            catch (StripeException ex)
            {
                throw new BusinessException(
                    $"Stripe error: {ex.StripeError?.Message ?? ex.Message}");
            }
        }
    }
}