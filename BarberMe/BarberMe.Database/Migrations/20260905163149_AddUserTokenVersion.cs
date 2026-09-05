using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddUserTokenVersion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TokenVersion",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                column: "PasswordHash",
                value: "$2a$11$1wpG1zEd3NVs1RCO9Cr3Ce4Ab1x9vS3v5bGBSZPMxEVkF2zmwAZQa");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 2,
                column: "PasswordHash",
                value: "$2a$11$1wpG1zEd3NVs1RCO9Cr3Ce4Ab1x9vS3v5bGBSZPMxEVkF2zmwAZQa");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 3,
                column: "PasswordHash",
                value: "$2a$11$1wpG1zEd3NVs1RCO9Cr3Ce4Ab1x9vS3v5bGBSZPMxEVkF2zmwAZQa");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TokenVersion",
                table: "Users");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 1,
                column: "PasswordHash",
                value: "$2a$11$3imUFH1O5lE9g7XuS3hZOOUVPwdRz4yQjbw/4pyzVIeXf/ZHTbBUu");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 2,
                column: "PasswordHash",
                value: "$2a$11$3imUFH1O5lE9g7XuS3hZOOUVPwdRz4yQjbw/4pyzVIeXf/ZHTbBUu");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserId",
                keyValue: 3,
                column: "PasswordHash",
                value: "$2a$11$3imUFH1O5lE9g7XuS3hZOOUVPwdRz4yQjbw/4pyzVIeXf/ZHTbBUu");
        }
    }
}
