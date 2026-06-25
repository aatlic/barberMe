using BarberMe.Model.Responses;

namespace BarberMe.API.Interfaces
{
    public interface IService<TResponse, TSearch>
    {
        Task<PagedResponse<TResponse>> GetAsync(TSearch search);

        Task<TResponse?> GetByIdAsync(int id);
    }
}
