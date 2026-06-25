using AutoMapper;
using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

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
            var list = await _context.Recommendations
                .Include(x => x.Service)
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.Score)
                .ToListAsync();

            return _mapper.Map<List<RecommendationResponse>>(list);
        }

        public async Task AddFeedback(
            int recommendationId,
            int rating,
            string? comment)
        {
            var entity = new RecommendationFeedback
            {
                RecommendationId = recommendationId,
                Rating = rating,
                Comment = comment
            };

            _context.RecommendationFeedbacks.Add(entity);

            await _context.SaveChangesAsync();
        }
    }
}