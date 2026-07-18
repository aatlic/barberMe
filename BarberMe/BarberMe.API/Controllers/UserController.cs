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
        private readonly IWebHostEnvironment _environment;

        public UsersController(
            IUserService service,
            IWebHostEnvironment environment)
        {
            _service = service;
            _environment = environment;
        }

        [HttpGet]
        [Authorize(Roles = Roles.Admin)]
        public async Task<PagedResponse<UserResponse>> Get([FromQuery] UserSearchObject search)
        {
            return await _service.GetAsync(search);
        }

        [HttpGet("{id:int}")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpGet("me")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<UserResponse>> GetCurrent()
        {
            var result = await _service.GetCurrentAsync();
            return Ok(result);
        }

        [HttpPost]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<UserResponse>> Insert(UserInsertRequest request)
        {
            var result = await _service.InsertAsync(request);
            return Ok(result);
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<UserResponse>> Update(
            int id,
            UserUpdateRequest request)
        {
            var result = await _service.UpdateAsync(id, request);
            return Ok(result);
        }

        [HttpPut("me")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<UserResponse>> UpdateCurrent(UserProfileUpdateRequest request)
        {
            var result = await _service.UpdateCurrentAsync(request);

            return Ok(result);
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<bool>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id);

            return Ok(result);
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<ActionResult<LoginResponse>> Login(
            LoginRequest request)
        {
            var result = await _service.Login(request);
            return Ok(result);
        }

        [AllowAnonymous]
        [HttpPost("register")]
        public async Task<ActionResult<UserResponse>> Register(
            RegisterRequest request)
        {
            var result = await _service.Register(request);
            return Ok(result);
        }

        [AllowAnonymous]
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
        {
            var temporaryPassword =
                await _service.ForgotPassword(request);

            if (_environment.IsDevelopment() &&
                temporaryPassword != null)
            {
                return Ok(new
                {
                    message =
                        "A temporary password has been generated.",
                    temporaryPassword
                });
            }

            return Ok(new
            {
                message =
                    "If an account with that email exists, instructions have been sent."
            });
        }

        [HttpPut("me/change-password")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<IActionResult> ChangePassword(
            ChangePasswordRequest request)
        {
            await _service.ChangePassword(request);
            return Ok();
        }

        [HttpPost("me/profile-image")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Barber},{Roles.Client}")]
        public async Task<ActionResult<string>> UploadProfileImage(
            [FromForm] UploadProfileImageRequest request)
        {
            var result = await _service.UploadProfileImage(request);
            return Ok(result);
        }

        [HttpPut("{id:int}/lock")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> LockUser(int id)
        {
            await _service.LockUserAsync(id);

            return Ok(new
            {
                message = "User account has been locked successfully."
            });
        }

        [HttpPut("{id:int}/unlock")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> UnlockUser(int id)
        {
            await _service.UnlockUserAsync(id);

            return Ok(new
            {
                message = "User account has been unlocked successfully."
            });
        }
        [HttpGet("generate-password")]
        [Authorize(Roles = Roles.Admin)]
        public ActionResult<object> GeneratePassword()
        {
            var password = _service.GenerateInitialPassword();

            return Ok(new
            {
                password
            });
        }

        [HttpPost("{id:int}/copy")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<ActionResult<UserResponse>> CopyEmployee(
            int id,
            CopyEmployeeRequest request)
        {
            var result = await _service.CopyEmployeeAsync(
                id,
                request);

            return Ok(result);
        }

        [HttpPut("{id:int}/deactivate")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> DeactivateUser(int id)
        {
            await _service.DeactivateUserAsync(id);

            return Ok(new
            {
                message = "User has been deactivated successfully."
            });
        }

        [HttpPut("{id:int}/activate")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> ActivateUser(int id)
        {
            await _service.ActivateUserAsync(id);

            return Ok(new
            {
                message = "User has been activated successfully."
            });
        }
    }
}