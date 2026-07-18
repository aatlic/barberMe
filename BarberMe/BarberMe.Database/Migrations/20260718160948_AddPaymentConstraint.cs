using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentConstraint : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddCheckConstraint(
                name: "CK_Payment_Amount",
                table: "Payments",
                sql: "[Amount] > 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Payment_Amount",
                table: "Payments");
        }
    }
}
