using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Requests.RecommendationFeedbacl;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using BarberMe.Model.Exceptions;

namespace BarberMe.Services.Services
{
    public class RecommendationService : IRecommendationService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;

        public RecommendationService(
            BarberMeDbContext context,
            IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<RecommendationResponse>> GetRecommendations(int userId)
        {
            if (userId <= 0)
                throw new BusinessException("User is required.");

            var userExists = await _context.Users
                .AnyAsync(x => x.UserId == userId && x.IsActive);

            if (!userExists)
                throw new NotFoundException("User does not exist.");

            var list = await _context.Recommendations
                .Include(x => x.Service)
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.Score)
                .ToListAsync();

            return _mapper.Map<List<RecommendationResponse>>(list);
        }

        public async Task AddFeedback(
    int recommendationId,
    RecommendationFeedbackInsertRequest request)
        {
            if (recommendationId <= 0)
                throw new BusinessException("Recommendation is required.");

            if (request.Rating < 1 || request.Rating > 5)
                throw new BusinessException("Rating must be between 1 and 5.");

            var recommendationExists = await _context.Recommendations
                .AnyAsync(x => x.RecommendationId == recommendationId);

            if (!recommendationExists)
                throw new NotFoundException("Recommendation does not exist.");

            var entity = _mapper.Map<RecommendationFeedback>(request);

            entity.RecommendationId = recommendationId;

            _context.RecommendationFeedbacks.Add(entity);

            await _context.SaveChangesAsync();
        }
    }
}