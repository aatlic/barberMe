using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddShopWorkingHours : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ShopWorkingHours",
                columns: table => new
                {
                    ShopWorkingHoursId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DayOfWeek = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    IsWorking = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ShopWorkingHours", x => x.ShopWorkingHoursId);
                });

            migrationBuilder.InsertData(
                table: "ShopWorkingHours",
                columns: new[] { "ShopWorkingHoursId", "DayOfWeek", "EndTime", "IsWorking", "StartTime" },
                values: new object[,]
                {
                    { 1, 1, new TimeSpan(0, 20, 0, 0, 0), true, new TimeSpan(0, 8, 0, 0, 0) },
                    { 2, 2, new TimeSpan(0, 20, 0, 0, 0), true, new TimeSpan(0, 8, 0, 0, 0) },
                    { 3, 3, new TimeSpan(0, 20, 0, 0, 0), true, new TimeSpan(0, 8, 0, 0, 0) },
                    { 4, 4, new TimeSpan(0, 20, 0, 0, 0), true, new TimeSpan(0, 8, 0, 0, 0) },
                    { 5, 5, new TimeSpan(0, 20, 0, 0, 0), true, new TimeSpan(0, 8, 0, 0, 0) },
                    { 6, 6, new TimeSpan(0, 16, 0, 0, 0), true, new TimeSpan(0, 8, 0, 0, 0) },
                    { 7, 0, new TimeSpan(0, 0, 0, 0, 0), false, new TimeSpan(0, 0, 0, 0, 0) }
                });

            migrationBuilder.CreateIndex(
                name: "IX_ShopWorkingHours_DayOfWeek",
                table: "ShopWorkingHours",
                column: "DayOfWeek",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ShopWorkingHours");
        }
    }
}
