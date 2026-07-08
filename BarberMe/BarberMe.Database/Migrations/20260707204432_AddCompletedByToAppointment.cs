using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddCompletedByToAppointment : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CompletedById",
                table: "Appointments",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_CompletedById",
                table: "Appointments",
                column: "CompletedById");

            migrationBuilder.AddForeignKey(
                name: "FK_Appointments_Users_CompletedById",
                table: "Appointments",
                column: "CompletedById",
                principalTable: "Users",
                principalColumn: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Appointments_Users_CompletedById",
                table: "Appointments");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_CompletedById",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "CompletedById",
                table: "Appointments");
        }
    }
}
