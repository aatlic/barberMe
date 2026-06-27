using Microsoft.AspNetCore.Http;

namespace BarberMe.Model.Requests.User
{
    public class UploadProfileImageRequest
    {
        public IFormFile File { get; set; } = null!;
    }
}
