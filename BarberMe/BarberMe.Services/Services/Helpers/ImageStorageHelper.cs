using Microsoft.AspNetCore.Http;

namespace BarberMe.Services.Helpers
{
    public static class ImageStorageHelper
    {
        public static async Task<string> SaveImageAsync(
            IFormFile file,
            string folderName)
        {
            var folder = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "images",
                folderName);

            Directory.CreateDirectory(folder);

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var fileName = $"{Guid.NewGuid()}{extension}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream);

            return $"images/{folderName}/{fileName}";
        }

        public static void DeleteImageIfExists(string? relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
                return;

            var fullPath = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                relativePath);

            if (File.Exists(fullPath))
                File.Delete(fullPath);
        }
    }
}