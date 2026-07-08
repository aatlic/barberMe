using BarberMe.Model.Exceptions;
using Microsoft.AspNetCore.Http;

namespace BarberMe.Services.Helpers
{
    public static class ImageValidator
    {
        private const long MaxFileSize = 5 * 1024 * 1024; // 5 MB

        private static readonly string[] AllowedExtensions =
        {
            ".jpg", ".jpeg", ".png", ".webp"
        };

        private static readonly string[] AllowedContentTypes =
        {
            "image/jpeg", "image/png", "image/webp"
        };

        public static void Validate(IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new BusinessException("Image file is required.");

            if (file.Length > MaxFileSize)
                throw new BusinessException("Image size must not exceed 5 MB.");

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();

            if (!AllowedExtensions.Contains(extension))
                throw new BusinessException("Only JPG, PNG and WEBP images are allowed.");

            if (!AllowedContentTypes.Contains(file.ContentType.ToLowerInvariant()))
                throw new BusinessException("Invalid image content type.");

            ValidateMagicBytes(file, extension);
        }

        private static void ValidateMagicBytes(IFormFile file, string extension)
        {
            using var stream = file.OpenReadStream();

            var buffer = new byte[12];
            var bytesRead = stream.Read(buffer, 0, buffer.Length);

            if (bytesRead < 4)
                throw new BusinessException("Invalid image file.");

            var isValid = extension switch
            {
                ".jpg" or ".jpeg" => IsJpeg(buffer),
                ".png" => IsPng(buffer),
                ".webp" => IsWebp(buffer),
                _ => false
            };

            if (!isValid)
                throw new BusinessException("Invalid image file content.");
        }

        private static bool IsJpeg(byte[] bytes)
        {
            return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
        }

        private static bool IsPng(byte[] bytes)
        {
            return bytes[0] == 0x89 &&
                   bytes[1] == 0x50 &&
                   bytes[2] == 0x4E &&
                   bytes[3] == 0x47 &&
                   bytes[4] == 0x0D &&
                   bytes[5] == 0x0A &&
                   bytes[6] == 0x1A &&
                   bytes[7] == 0x0A;
        }

        private static bool IsWebp(byte[] bytes)
        {
            return bytes[0] == 0x52 &&
                   bytes[1] == 0x49 &&
                   bytes[2] == 0x46 &&
                   bytes[3] == 0x46 &&
                   bytes[8] == 0x57 &&
                   bytes[9] == 0x45 &&
                   bytes[10] == 0x42 &&
                   bytes[11] == 0x50;
        }
    }
}