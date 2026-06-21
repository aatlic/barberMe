using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddProfileImageAndMoreSeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ProfileImage",
                table: "Users",
                newName: "ProfileImagePath");

            migrationBuilder.RenameColumn(
                name: "Image",
                table: "Services",
                newName: "ImageUrl");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "ProfileImagePath",
                table: "Users",
                newName: "ProfileImage");

            migrationBuilder.RenameColumn(
                name: "ImageUrl",
                table: "Services",
                newName: "Image");
        }
    }
}
