using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Constants;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.RecommendationFeedbacl;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class RecommendationService : IRecommendationService
    {
        private readonly BarberMeDbContext _context;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;

        public RecommendationService(
            BarberMeDbContext context,
            IMapper mapper,
            ICurrentUserService currentUserService)
        {
            _context = context;
            _mapper = mapper;
            _currentUserService = currentUserService;
        }

        public async Task<List<RecommendationResponse>> GetRecommendations()
        {
            var userId = _currentUserService.UserId;

            var list = await _context.Recommendations
                .Include(x => x.Service)
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.Score)
                .ToListAsync();

            return _mapper.Map<List<RecommendationResponse>>(list);
        }

        public async Task AddFeedback(int recommendationId, RecommendationFeedbackInsertRequest request)
        {
            if (recommendationId <= 0)
                throw new BusinessException("Recommendation is required.");

            if (request.Rating < 1 || request.Rating > 5)
                throw new BusinessException("Rating must be between 1 and 5.");

            var recommendation = await _context.Recommendations
                .FirstOrDefaultAsync(x => x.RecommendationId == recommendationId);

            if (recommendation == null)
                throw new NotFoundException("Recommendation does not exist.");

            if (_currentUserService.Role == Roles.Client &&
                recommendation.UserId != _currentUserService.UserId)
            {
                throw new UnauthorizedException("You are not allowed to give feedback for this recommendation.");
            }

            var alreadyExists = await _context.RecommendationFeedbacks
                .AnyAsync(x => x.RecommendationId == recommendationId);

            if (alreadyExists)
                throw new BusinessException("Feedback has already been submitted for this recommendation.");

            var entity = _mapper.Map<RecommendationFeedback>(request);

            entity.RecommendationId = recommendationId;

            _context.RecommendationFeedbacks.Add(entity);

            await _context.SaveChangesAsync();
        }
    }
}