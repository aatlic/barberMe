using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class FixWorkingHoursDayOfWeek : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Appointments_Users_CompletedById",
                table: "Appointments");

            migrationBuilder.UpdateData(
                table: "WorkingHours",
                keyColumn: "WorkingHoursId",
                keyValue: 7,
                column: "DayOfWeek",
                value: 0);

            migrationBuilder.AddForeignKey(
                name: "FK_Appointments_Users_CompletedById",
                table: "Appointments",
                column: "CompletedById",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Appointments_Users_CompletedById",
                table: "Appointments");

            migrationBuilder.UpdateData(
                table: "WorkingHours",
                keyColumn: "WorkingHoursId",
                keyValue: 7,
                column: "DayOfWeek",
                value: 7);

            migrationBuilder.AddForeignKey(
                name: "FK_Appointments_Users_CompletedById",
                table: "Appointments",
                column: "CompletedById",
                principalTable: "Users",
                principalColumn: "UserId");
        }
    }
}
