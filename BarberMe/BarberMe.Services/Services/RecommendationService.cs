using BarberMe.Database.Context;
using BarberMe.Database.Models;
using BarberMe.Model.Enum;
using BarberMe.Model.Exceptions;
using BarberMe.Model.Requests.RecommendationFeedback;
using BarberMe.Model.Responses.Recommendation;
using BarberMe.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BarberMe.Services.Services
{
    public class RecommendationService : IRecommendationService
    {
        private const int MaximumRecommendations = 5;

        private readonly BarberMeDbContext _context;
        private readonly ICurrentUserService _currentUserService;

        public RecommendationService(
            BarberMeDbContext context,
            ICurrentUserService currentUserService)
        {
            _context = context;
            _currentUserService = currentUserService;
        }

        public async Task<List<RecommendationResponse>> GetRecommendationsAsync()
        {
            var userId = _currentUserService.UserId;

            if (userId <= 0)
            {
                throw new UnauthorizedException("User is not authenticated.");
            }

            var userExists = await _context.Users
                .AsNoTracking()
                .AnyAsync(x =>
                    x.UserId == userId &&
                    x.IsActive);

            if (!userExists)
            {
                throw new UnauthorizedException("The authenticated user does not exist or is inactive.");
            }

            /*
             * Only completed appointments represent services that the client
             * actually consumed. Cancelled, pending and confirmed appointments
             * must not influence personal preferences.
             */
            var completedAppointments = await _context.Appointments
                .AsNoTracking()
                .Include(x => x.BarberService)
                .Include(x => x.Review)
                .Where(x =>
                    x.ClientId == userId &&
                    x.AppointmentStatusId ==
                        (int)AppointmentStatusType.Completed)
                .ToListAsync();

            /*
             * Only offers whose service and barber are currently active
             * may be recommended.
             */
            var availableBarberServices = await _context.BarberServices
                .AsNoTracking()
                .Include(x => x.Service)
                .Include(x => x.Barber)
                .Where(x =>
                    x.Service.IsActive &&
                    x.Barber.IsActive)
                .ToListAsync();

            if (availableBarberServices.Count == 0)
            {
                await RemoveUnusedRecommendationsAsync(userId);

                return new List<RecommendationResponse>();
            }

            /*
             * PERSONAL SIGNAL 1:
             * Number of times the client used each general service.
             */
            var serviceUsageCounts = completedAppointments
                .GroupBy(x => x.BarberService.ServiceId)
                .ToDictionary(
                    x => x.Key,
                    x => x.Count());

            /*
             * PERSONAL SIGNAL 2:
             * Number of times the client booked each barber.
             */
            var barberUsageCounts = completedAppointments
                .GroupBy(x => x.BarberId)
                .ToDictionary(
                    x => x.Key,
                    x => x.Count());

            /*
             * PERSONAL SIGNAL 3:
             * Number of times the client booked the exact BarberService.
             */
            var barberServiceUsageCounts = completedAppointments
                .GroupBy(x => x.BarberServiceId)
                .ToDictionary(
                    x => x.Key,
                    x => x.Count());

            /*
             * PERSONAL SIGNAL 4:
             * Client's average review for each general service.
             */
            var personalServiceRatings = completedAppointments
                .Where(x => x.Review != null)
                .GroupBy(x => x.BarberService.ServiceId)
                .ToDictionary(
                    x => x.Key,
                    x => x.Average(a => a.Review!.Rating));

            /*
             * GLOBAL SIGNAL 1:
             * Popularity of every BarberService among all clients.
             */
            var globalPopularityCounts = await _context.Appointments
                .AsNoTracking()
                .Where(x => x.AppointmentStatusId == (int)AppointmentStatusType.Completed)
                .GroupBy(x => x.BarberServiceId)
                .Select(x => new
                {
                    BarberServiceId = x.Key,
                    Count = x.Count()
                })
                .ToDictionaryAsync(
                    x => x.BarberServiceId,
                    x => x.Count);

            /*
             * GLOBAL SIGNAL 2:
             * Average review for every BarberService.
             */
            var globalRatings = await _context.Reviews
                .AsNoTracking()
                .GroupBy(x => x.Appointment.BarberServiceId)
                .Select(x => new
                {
                    BarberServiceId = x.Key,
                    AverageRating = x.Average(r => r.Rating)
                })
                .ToDictionaryAsync(
                    x => x.BarberServiceId,
                    x => x.AverageRating);

            var maximumServiceUsage =
                serviceUsageCounts.Values.DefaultIfEmpty(0).Max();

            var maximumBarberUsage =
                barberUsageCounts.Values.DefaultIfEmpty(0).Max();

            var maximumBarberServiceUsage =
                barberServiceUsageCounts.Values.DefaultIfEmpty(0).Max();

            var maximumGlobalPopularity =
                globalPopularityCounts.Values.DefaultIfEmpty(0).Max();

            var hasPersonalHistory = completedAppointments.Count > 0;

            var calculatedRecommendations =
                new List<CalculatedRecommendation>();

            foreach (var barberService in availableBarberServices)
            {
                var servicePreference = NormalizeCount(
                    serviceUsageCounts.GetValueOrDefault(
                        barberService.ServiceId),
                    maximumServiceUsage);

                var barberPreference = NormalizeCount(
                    barberUsageCounts.GetValueOrDefault(
                        barberService.BarberId),
                    maximumBarberUsage);

                var exactOfferPreference = NormalizeCount(
                    barberServiceUsageCounts.GetValueOrDefault(
                        barberService.BarberServiceId),
                    maximumBarberServiceUsage);

                var personalRating = NormalizeRating(
                    personalServiceRatings.GetValueOrDefault(
                        barberService.ServiceId));

                var popularity = NormalizeCount(
                    globalPopularityCounts.GetValueOrDefault(
                        barberService.BarberServiceId),
                    maximumGlobalPopularity);

                var globalRating = NormalizeRating(
                    globalRatings.GetValueOrDefault(
                        barberService.BarberServiceId));

                decimal score;

                if (hasPersonalHistory)
                {
                    /*
                     * Personalized Content-Based score:
                     *
                     * 35% previously used service
                     * 25% preferred barber
                     * 15% previously used exact offer
                     * 15% personal rating
                     *  5% global popularity
                     *  5% global rating
                     */
                    score =
                        servicePreference * 0.35m +
                        barberPreference * 0.25m +
                        exactOfferPreference * 0.15m +
                        personalRating * 0.15m +
                        popularity * 0.05m +
                        globalRating * 0.05m;
                }
                else
                {
                    /*
                     * Cold-start score for a client without history.
                     */
                    score =
                        popularity * 0.60m +
                        globalRating * 0.40m;
                }

                /*
                 * A new application may have no completed appointments or
                 * reviews at all. Giving every candidate a small baseline
                 * allows the client to receive initial recommendations.
                 */
                if (score == 0)
                {
                    score = 0.10m;
                }

                score = Math.Round(Math.Clamp(score, 0m, 1m), 4);

                var explanation = BuildExplanation(
                    barberService,
                    hasPersonalHistory,
                    servicePreference,
                    barberPreference,
                    exactOfferPreference,
                    personalRating,
                    popularity,
                    globalRating);

                calculatedRecommendations.Add(
                    new CalculatedRecommendation
                    {
                        BarberService = barberService,
                        Score = score,
                        Explanation = explanation
                    });
            }

            var bestRecommendations = calculatedRecommendations
                .OrderByDescending(x => x.Score)
                .ThenBy(x => x.BarberService.Price)
                .ThenBy(x => x.BarberService.BarberServiceId)
                .Take(MaximumRecommendations)
                .ToList();

            /*
             * Previous recommendations without feedback are temporary and
             * may safely be replaced by newly calculated results.
             *
             * Recommendations that already have feedback are preserved as
             * historical data.
             */
            await RemoveUnusedRecommendationsAsync(userId);

            var recommendationEntities = bestRecommendations
                .Select(x => new Recommendation
                {
                    UserId = userId,
                    BarberServiceId =
                        x.BarberService.BarberServiceId,
                    Score = x.Score,
                    Explanation = x.Explanation,
                    CreatedAt = DateTime.UtcNow
                })
                .ToList();

            _context.Recommendations.AddRange(recommendationEntities);

            await _context.SaveChangesAsync();

            var response = recommendationEntities
                .Select(entity =>
                {
                    var calculated = bestRecommendations
                        .First(x =>
                            x.BarberService.BarberServiceId ==
                            entity.BarberServiceId);

                    var barberService = calculated.BarberService;

                    return new RecommendationResponse
                    {
                        RecommendationId = entity.RecommendationId,

                        BarberServiceId = barberService.BarberServiceId,

                        ServiceId = barberService.ServiceId,

                        ServiceName = barberService.Service.Name,

                        BarberId = barberService.BarberId,

                        BarberName = $"{barberService.Barber.FirstName} {barberService.Barber.LastName}",

                        Price = barberService.Price,

                        DurationMinutes = barberService.DurationMinutes,

                        Score = entity.Score,

                        Explanation = entity.Explanation,

                        CreatedAt = entity.CreatedAt
                    };
                })
                .OrderByDescending(x => x.Score)
                .ToList();

            return response;
        }

        public async Task<RecommendationFeedbackResponse> AddFeedbackAsync(
                int recommendationId,
                RecommendationFeedbackInsertRequest request)
        {
            if (recommendationId <= 0)
            {
                throw new BusinessException("Recommendation is required.");
            }

            if (request == null)
            {
                throw new BusinessException("Feedback request is required.");
            }

            if (request.Rating < 1 || request.Rating > 5)
            {
                throw new BusinessException("Rating must be between 1 and 5.");
            }

            var userId = _currentUserService.UserId;

            if (userId <= 0)
            {
                throw new UnauthorizedException("User is not authenticated.");
            }

            var recommendation = await _context.Recommendations
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.RecommendationId == recommendationId);

            if (recommendation == null)
            {
                throw new NotFoundException("Recommendation does not exist.");
            }

            if (recommendation.UserId != userId)
            {
                throw new UnauthorizedException("You are not allowed to give feedback for this recommendation.");
            }

            var feedbackAlreadyExists =
                await _context.RecommendationFeedbacks
                    .AnyAsync(x => x.RecommendationId == recommendationId);

            if (feedbackAlreadyExists)
            {
                throw new BusinessException("Feedback has already been submitted for this recommendation.");
            }

            var feedback = new RecommendationFeedback
            {
                RecommendationId = recommendationId,
                Rating = request.Rating,
                Comment = string.IsNullOrWhiteSpace(
                    request.Comment)
                    ? null
                    : request.Comment.Trim(),
                CreatedAt = DateTime.UtcNow
            };

            _context.RecommendationFeedbacks.Add(feedback);

            await _context.SaveChangesAsync();

            return new RecommendationFeedbackResponse
            {
                RecommendationId = feedback.RecommendationId,

                Rating = feedback.Rating,

                Comment = feedback.Comment,

                CreatedAt = feedback.CreatedAt
            };
        }

        private async Task RemoveUnusedRecommendationsAsync(int userId)
        {
            var removableRecommendations =
                await _context.Recommendations
                    .Where(x =>
                        x.UserId == userId &&
                        !x.Feedbacks.Any())
                    .ToListAsync();

            if (removableRecommendations.Count == 0)
            {
                return;
            }

            _context.Recommendations.RemoveRange(removableRecommendations);
        }

        private static decimal NormalizeCount(
            int value,
            int maximumValue)
        {
            if (value <= 0 || maximumValue <= 0)
            {
                return 0m;
            }

            return Math.Clamp((decimal)value / maximumValue, 0m, 1m);
        }

        private static decimal NormalizeRating(double rating)
        {
            if (rating <= 0)
            {
                return 0m;
            }

            return Math.Clamp((decimal)rating / 5m, 0m, 1m);
        }

        private static string BuildExplanation(
            BarberService barberService,
            bool hasPersonalHistory,
            decimal servicePreference,
            decimal barberPreference,
            decimal exactOfferPreference,
            decimal personalRating,
            decimal popularity,
            decimal globalRating)
        {
            var barberName = $"{barberService.Barber.FirstName} {barberService.Barber.LastName}";

            var serviceName = barberService.Service.Name;

            if (!hasPersonalHistory)
            {
                if (globalRating >= popularity &&
                    globalRating > 0)
                {
                    return  $"Recommended because {serviceName} with {barberName} is highly rated by clients.";
                }

                if (popularity > 0)
                {
                    return $"Recommended because {serviceName} with {barberName} is popular among clients.";
                }

                return $"Recommended as an available service for new clients.";
            }

            var strongestSignal = new[]
            {
                new
                {
                    Name = "service",
                    Value = servicePreference
                },
                new
                {
                    Name = "barber",
                    Value = barberPreference
                },
                new
                {
                    Name = "exactOffer",
                    Value = exactOfferPreference
                },
                new
                {
                    Name = "personalRating",
                    Value = personalRating
                },
                new
                {
                    Name = "popularity",
                    Value = popularity
                },
                new
                {
                    Name = "globalRating",
                    Value = globalRating
                }
            }
            .OrderByDescending(x => x.Value)
            .First();

            return strongestSignal.Name switch
            {
                "exactOffer" =>
                    $"Recommended because you have previously booked {serviceName} with {barberName}.",

                "service" =>
                    $"Recommended because you frequently book {serviceName}.",

                "barber" =>
                    $"Recommended because you frequently book appointments with {barberName}.",

                "personalRating" =>
                    $"Recommended because you previously gave high ratings to {serviceName}.",

                "globalRating" =>
                    $"Recommended because clients gave high ratings to {serviceName} with {barberName}.",

                "popularity" =>
                    $"Recommended because {serviceName} with {barberName} is popular among clients.",
                _ =>
                    $"Recommended based on your previous appointments."
            };
        }

        private sealed class CalculatedRecommendation
        {
            public BarberService BarberService { get; init; } = null!;

            public decimal Score { get; init; }
            
            public string Explanation { get; init; } = string.Empty;
        }
    }
}