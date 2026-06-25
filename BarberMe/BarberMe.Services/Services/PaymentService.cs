using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Model.Responses.Payment;
using BarberMe.Services.Interfaces;

namespace BarberMe.Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public PaymentService(
            BarberMeDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<PaymentResponse> CreatePayment(int appointmentId)
        {
            throw new NotImplementedException();
        }

        public async Task<bool> ConfirmPayment(int paymentId)
        {
            throw new NotImplementedException();
        }
    }
}