using BarberMe.Model.Constants;
using BarberMe.Model.Requests.Auth;
using BarberMe.Model.Requests.User;
using BarberMe.Model.Responses;
using BarberMe.Model.Responses.Auth;
using BarberMe.Model.Responses.User;
using BarberMe.Model.SearchObjects;
using BarberMe.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberMe.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _service;

        public UsersController(IUserService service)
        {
            _service = service;
        }

        [HttpGet]
        [Authorize(Roles = Roles.Admin)]
        public async Task<PagedResponse<UserResponse>> Get([FromQuery] UserSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);

            return Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<UserResponse>> Insert(UserInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);

            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            return Ok(true);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<ActionResult<LoginResponse>> Login(LoginRequest request)
        {
            var result = await _service.Login(request);
            return Ok(result);
        }

        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<ActionResult<UserResponse>> Register(RegisterRequest request)
        {
            var result = await _service.Register(request);
            return Ok(result);
        }

        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
        {
            await _service.ForgotPassword(request);
            return Ok();
        }

        [HttpPut("{userId}/change-password")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<IActionResult> ChangePassword(ChangePasswordRequest request)
        {
            await _service.ChangePassword(request);
            return Ok();
        }

        [HttpPost("{userId}/upload-profile-image")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<string>> UploadProfileImage([FromForm] UploadProfileImageRequest request)
        {
            var result = await _service.UploadProfileImage(request);
            return Ok(result);
        }
    }
}