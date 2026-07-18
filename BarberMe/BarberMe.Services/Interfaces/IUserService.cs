using BarberMe.Model.Requests.Auth;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Responses.Auth;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;

namespace BarberMe.Services.Interfaces
{
    public interface IUserService :
                ICRUDService<
                    UserResponse,
                    UserSearchObject,
                    UserInsertRequest,
                    UserUpdateRequest>
    {
        Task<LoginResponse> Login(LoginRequest request);

        Task<UserResponse> Register(RegisterRequest request);

        Task<string?> ForgotPassword(ForgotPasswordRequest request);

        Task ChangePassword(ChangePasswordRequest request);

        Task<string> UploadProfileImage(UploadProfileImageRequest request);

        Task<UserResponse> GetCurrentAsync();
        Task<UserResponse> UpdateCurrentAsync(UserProfileUpdateRequest request);
        Task LockUserAsync(int id);
        Task UnlockUserAsync(int id);
        string GenerateInitialPassword();
        Task<UserResponse> CopyEmployeeAsync(
            int sourceEmployeeId,
            CopyEmployeeRequest request);

        Task DeactivateUserAsync(int id);
        Task ActivateUserAsync(int id);
    }
}
