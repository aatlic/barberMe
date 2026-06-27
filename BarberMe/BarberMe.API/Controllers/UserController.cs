using BarberMe.Model.Requests.Auth;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Auth;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using BarberMe.Services.Services;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _service;

        public UsersController(IUserService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<PagedResponse<UserResponse>> Get([FromQuery] UserSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<UserResponse>> Insert(UserInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            if (!result)
                return NotFound(false);

            return Ok(true);
        }

        [HttpPost("login")]
        public async Task<ActionResult<LoginResponse>> Login(LoginRequest request)
        {
            var result = await _service.Login(request);
            return Ok(result);
        }

        [HttpPost("register")]
        public async Task<ActionResult<UserResponse>> Register(RegisterRequest request)
        {
            var result = await _service.Register(request);
            return Ok(result);
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
        {
            await _service.ForgotPassword(request);
            return Ok();
        }

        [HttpPut("{userId}/change-password")]
        public async Task<IActionResult> ChangePassword(int userId, ChangePasswordRequest request)
        {
            await _service.ChangePassword(userId, request);
            return Ok();
        }

        [HttpPost("{userId}/upload-profile-image")]
        public async Task<ActionResult<string>> UploadProfileImage(
            int userId,
            [FromForm] UploadProfileImageRequest request)
        {
            var result = await _service.UploadProfileImage(userId, request);
            return Ok(result);
        }
    }
}