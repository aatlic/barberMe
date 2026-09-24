using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AllowMultipleWorkingPeriodsPerDay : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_WorkingHours_BarberId_DayOfWeek",
                table: "WorkingHours");

            migrationBuilder.CreateIndex(
                name: "IX_WorkingHours_BarberId_DayOfWeek",
                table: "WorkingHours",
                columns: new[] { "BarberId", "DayOfWeek" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_WorkingHours_BarberId_DayOfWeek",
                table: "WorkingHours");

            migrationBuilder.CreateIndex(
                name: "IX_WorkingHours_BarberId_DayOfWeek",
                table: "WorkingHours",
                columns: new[] { "BarberId", "DayOfWeek" },
                unique: true);
        }
    }
}
