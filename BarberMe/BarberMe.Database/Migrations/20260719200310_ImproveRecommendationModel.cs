using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class ImproveRecommendationModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Recommendations_Services_ServiceId",
                table: "Recommendations");

            migrationBuilder.DropIndex(
                name: "IX_Recommendations_UserId",
                table: "Recommendations");

            migrationBuilder.DropIndex(
                name: "IX_RecommendationFeedbacks_RecommendationId",
                table: "RecommendationFeedbacks");

            migrationBuilder.RenameColumn(
                name: "ServiceId",
                table: "Recommendations",
                newName: "BarberServiceId");

            migrationBuilder.RenameIndex(
                name: "IX_Recommendations_ServiceId",
                table: "Recommendations",
                newName: "IX_Recommendations_BarberServiceId");

            migrationBuilder.AlterColumn<decimal>(
                name: "Score",
                table: "Recommendations",
                type: "decimal(5,4)",
                nullable: false,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)");

            migrationBuilder.CreateIndex(
                name: "IX_Recommendations_UserId_BarberServiceId_CreatedAt",
                table: "Recommendations",
                columns: new[] { "UserId", "BarberServiceId", "CreatedAt" });

            migrationBuilder.AddCheckConstraint(
                name: "CK_Recommendation_Score",
                table: "Recommendations",
                sql: "[Score] >= 0 AND [Score] <= 1");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationFeedbacks_RecommendationId",
                table: "RecommendationFeedbacks",
                column: "RecommendationId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Recommendations_BarberServices_BarberServiceId",
                table: "Recommendations",
                column: "BarberServiceId",
                principalTable: "BarberServices",
                principalColumn: "BarberServiceId",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Recommendations_BarberServices_BarberServiceId",
                table: "Recommendations");

            migrationBuilder.DropIndex(
                name: "IX_Recommendations_UserId_BarberServiceId_CreatedAt",
                table: "Recommendations");

            migrationBuilder.DropCheckConstraint(
                name: "CK_Recommendation_Score",
                table: "Recommendations");

            migrationBuilder.DropIndex(
                name: "IX_RecommendationFeedbacks_RecommendationId",
                table: "RecommendationFeedbacks");

            migrationBuilder.RenameColumn(
                name: "BarberServiceId",
                table: "Recommendations",
                newName: "ServiceId");

            migrationBuilder.RenameIndex(
                name: "IX_Recommendations_BarberServiceId",
                table: "Recommendations",
                newName: "IX_Recommendations_ServiceId");

            migrationBuilder.AlterColumn<decimal>(
                name: "Score",
                table: "Recommendations",
                type: "decimal(18,2)",
                nullable: false,
                oldClrType: typeof(decimal),
                oldType: "decimal(5,4)");

            migrationBuilder.CreateIndex(
                name: "IX_Recommendations_UserId",
                table: "Recommendations",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationFeedbacks_RecommendationId",
                table: "RecommendationFeedbacks",
                column: "RecommendationId");

            migrationBuilder.AddForeignKey(
                name: "FK_Recommendations_Services_ServiceId",
                table: "Recommendations",
                column: "ServiceId",
                principalTable: "Services",
                principalColumn: "ServiceId",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
