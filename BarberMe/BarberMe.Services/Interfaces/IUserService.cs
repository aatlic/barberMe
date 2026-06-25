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

        Task ForgotPassword(ForgotPasswordRequest request);

        Task ResetPassword(ResetPasswordRequest request);

        Task ChangePassword(int userId,
                            ChangePasswordRequest request);

        Task<string> UploadProfileImage(
                int userId,
                UploadProfileImageRequest request);
    }
}
