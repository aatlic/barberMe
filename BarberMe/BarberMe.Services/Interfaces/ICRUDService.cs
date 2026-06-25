namespace BarberMe.API.Interfaces
{
    public interface ICRUDService<TResponse, TSearch, TInsert, TUpdate>
        : IService<TResponse, TSearch>
    {
        Task<TResponse> InsertAsync(TInsert request);

        Task<TResponse?> UpdateAsync(int id, TUpdate request);

        Task<bool> DeleteAsync(int id);
    }
}
