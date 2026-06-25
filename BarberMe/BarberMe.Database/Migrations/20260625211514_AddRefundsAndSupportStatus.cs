using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BarberMe.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddRefundsAndSupportStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Refund_Payments_PaymentId",
                table: "Refund");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Refund",
                table: "Refund");

            migrationBuilder.RenameTable(
                name: "Refund",
                newName: "Refunds");

            migrationBuilder.RenameIndex(
                name: "IX_Refund_PaymentId",
                table: "Refunds",
                newName: "IX_Refunds_PaymentId");

            migrationBuilder.AlterColumn<int>(
                name: "Status",
                table: "SupportRequests",
                type: "int",
                maxLength: 30,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(30)",
                oldMaxLength: 30);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Refunds",
                table: "Refunds",
                column: "RefundId");

            migrationBuilder.AddForeignKey(
                name: "FK_Refunds_Payments_PaymentId",
                table: "Refunds",
                column: "PaymentId",
                principalTable: "Payments",
                principalColumn: "PaymentId",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Refunds_Payments_PaymentId",
                table: "Refunds");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Refunds",
                table: "Refunds");

            migrationBuilder.RenameTable(
                name: "Refunds",
                newName: "Refund");

            migrationBuilder.RenameIndex(
                name: "IX_Refunds_PaymentId",
                table: "Refund",
                newName: "IX_Refund_PaymentId");

            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "SupportRequests",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int",
                oldMaxLength: 30);

            migrationBuilder.AddPrimaryKey(
                name: "PK_Refund",
                table: "Refund",
                column: "RefundId");

            migrationBuilder.AddForeignKey(
                name: "FK_Refund_Payments_PaymentId",
                table: "Refund",
                column: "PaymentId",
                principalTable: "Payments",
                principalColumn: "PaymentId",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
