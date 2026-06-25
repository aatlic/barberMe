using BarberMe.Model.Responses.Payment;

namespace BarberMe.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentResponse> CreatePayment(int appointmentId);

        Task<bool> ConfirmPayment(int paymentId);
    }
}
