using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddRefundTrackingToPayments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "RefundAmount",
                table: "Payments",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RefundReason",
                table: "Payments",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RefundedAt",
                table: "Payments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 28, 1, 3, 38, 952, DateTimeKind.Utc).AddTicks(2774));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 28, 1, 3, 38, 952, DateTimeKind.Utc).AddTicks(2773));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 28, 1, 3, 38, 952, DateTimeKind.Utc).AddTicks(2766));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 28, 1, 3, 38, 952, DateTimeKind.Utc).AddTicks(2809));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "2ea08669-6101-4c8d-969d-0d9847ec0755", new DateTime(2026, 2, 28, 1, 3, 38, 892, DateTimeKind.Utc).AddTicks(4389), "AQAAAAIAAYagAAAAEJmuBm/yAGCVyNLtSC/JmFBMfNo64dS1SVqGu0uwaPquyzDmV0mtuE4kB6b1KH+oSA==", "641ff6f9-a858-4cfe-957b-7f1c794ec6d4" });

            migrationBuilder.AddCheckConstraint(
                name: "CK_Payment_RefundAmount",
                table: "Payments",
                sql: "[RefundAmount] IS NULL OR ([RefundAmount] >= 0 AND [RefundAmount] <= [Amount])");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Payment_RefundAmount",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "RefundAmount",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "RefundReason",
                table: "Payments");

            migrationBuilder.DropColumn(
                name: "RefundedAt",
                table: "Payments");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1546));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1545));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1539));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1576));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "29f0e868-1416-43b0-906e-c1b133943fdb", new DateTime(2026, 2, 25, 23, 6, 53, 205, DateTimeKind.Utc).AddTicks(4512), "AQAAAAIAAYagAAAAEFfDfXjOo400CRu2ZPNVfS9MjLj5nvjBwUmDSmzKTHA+JzxYbjCx8+fYZXto0uF3Sg==", "7d122519-a0e2-44d6-93fe-63619f01f917" });
        }
    }
}
