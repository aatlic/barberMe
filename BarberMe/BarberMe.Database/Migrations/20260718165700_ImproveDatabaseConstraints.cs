using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class ImproveDatabaseConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_Services_Name",
                table: "Services",
                column: "Name",
                unique: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_Service_DefaultDurationMinutes",
                table: "Services",
                sql: "[DefaultDurationMinutes] > 0");

            migrationBuilder.AddCheckConstraint(
                name: "CK_Service_DefaultPrice",
                table: "Services",
                sql: "[DefaultPrice] > 0");

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_Refund_Amount",
                table: "Refunds",
                sql: "[Amount] > 0");

            migrationBuilder.AddCheckConstraint(
                name: "CK_RecommendationFeedback_Rating",
                table: "RecommendationFeedbacks",
                sql: "[Rating] BETWEEN 1 AND 5");

            migrationBuilder.CreateIndex(
                name: "IX_PaymentStatuses_Name",
                table: "PaymentStatuses",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_NotificationTypes_Name",
                table: "NotificationTypes",
                column: "Name",
                unique: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_BarberService_DurationMinutes",
                table: "BarberServices",
                sql: "[DurationMinutes] > 0");

            migrationBuilder.AddCheckConstraint(
                name: "CK_BarberService_Price",
                table: "BarberServices",
                sql: "[Price] > 0");

            migrationBuilder.CreateIndex(
                name: "IX_BarberLevels_Name",
                table: "BarberLevels",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppointmentStatuses_Name",
                table: "AppointmentStatuses",
                column: "Name",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Services_Name",
                table: "Services");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Service_DefaultDurationMinutes",
                table: "Services");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Service_DefaultPrice",
                table: "Services");

            migrationBuilder.DropIndex(
                name: "IX_Roles_Name",
                table: "Roles");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Refund_Amount",
                table: "Refunds");

            migrationBuilder.DropCheckConstraint(
                name: "CK_RecommendationFeedback_Rating",
                table: "RecommendationFeedbacks");

            migrationBuilder.DropIndex(
                name: "IX_PaymentStatuses_Name",
                table: "PaymentStatuses");

            migrationBuilder.DropIndex(
                name: "IX_NotificationTypes_Name",
                table: "NotificationTypes");

            migrationBuilder.DropCheckConstraint(
                name: "CK_BarberService_DurationMinutes",
                table: "BarberServices");

            migrationBuilder.DropCheckConstraint(
                name: "CK_BarberService_Price",
                table: "BarberServices");

            migrationBuilder.DropIndex(
                name: "IX_BarberLevels_Name",
                table: "BarberLevels");

            migrationBuilder.DropIndex(
                name: "IX_AppointmentStatuses_Name",
                table: "AppointmentStatuses");
        }
    }
}
