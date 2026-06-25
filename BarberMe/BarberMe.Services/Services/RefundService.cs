using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.Refund;
using BarberMe.Model.Responses.Payment;
using BarberMe.Services.Interfaces;

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
            var entity = _mapper.Map<Refund>(request);

            _context.Refunds.Add(entity);

            await _context.SaveChangesAsync();

            return _mapper.Map<RefundResponse>(entity);
        }
    }
}