using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class FixSupportRequestStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddCheckConstraint(
                name: "CK_SupportRequest_Status",
                table: "SupportRequests",
                sql: "[Status] IN (1, 2, 3)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_SupportRequest_Status",
                table: "SupportRequests");
        }
    }
}
