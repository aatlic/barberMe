using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Responses.Payment;

namespace BarberMe.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentResponse> CreatePayment(int appointmentId);

        Task<bool> ConfirmPayment(int paymentId);

        Task HandleWebhookAsync(string json, string stripeSignature);

        Task<RefundResponse> RefundPaymentAsync(
            int paymentId,
            RefundInsertRequest request);
        Task<bool> SimulateSuccessfulPayment(int paymentId);
    }
}
