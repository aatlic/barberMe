using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Responses.Payment;
using BarberMe.Services.Interfaces;
using BarberMe.Model.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class RefundService : IRefundService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public RefundService(
            BarberMeDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<RefundResponse> InsertAsync(RefundInsertRequest request)
        {
            if (request.PaymentId <= 0)
                throw new BusinessException("Payment is required.");

            if (request.Amount <= 0)
                throw new BusinessException("Refund amount must be greater than zero.");

            var payment = await _context.Payments
                .FirstOrDefaultAsync(x => x.PaymentId == request.PaymentId);

            if (payment == null)
                throw new NotFoundException("Payment does not exist.");

            if (request.Amount > payment.Amount)
                throw new BusinessException("Refund amount cannot be greater than the payment amount.");

            var refundExists = await _context.Refunds
                .AnyAsync(x => x.PaymentId == request.PaymentId);

            if (refundExists)
                throw new BusinessException("A refund has already been created for this payment.");

            var entity = _mapper.Map<Refund>(request);

            entity.CreatedAt = DateTime.UtcNow;

            _context.Refunds.Add(entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<RefundResponse>(entity);
        }
    }
}