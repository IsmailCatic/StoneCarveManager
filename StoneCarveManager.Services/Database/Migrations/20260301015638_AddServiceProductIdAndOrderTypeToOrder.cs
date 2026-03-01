using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddServiceProductIdAndOrderTypeToOrder : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "OrderType",
                table: "Orders",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "ServiceProductId",
                table: "Orders",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 1, 56, 37, 737, DateTimeKind.Utc).AddTicks(7010));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 1, 56, 37, 737, DateTimeKind.Utc).AddTicks(7008));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 1, 56, 37, 737, DateTimeKind.Utc).AddTicks(7001));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 1, 1, 56, 37, 737, DateTimeKind.Utc).AddTicks(7078));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "aa654782-0120-44ce-b9a9-930fa85f8f74", new DateTime(2026, 3, 1, 1, 56, 37, 671, DateTimeKind.Utc).AddTicks(3365), "AQAAAAIAAYagAAAAEKPT1lii5BEDDUo45Uhl/YtHe2kYZ2ChL2lvwWH/4WpGwmbxV4GeoaSapqJXEPurFg==", "7e579d46-2fa1-4a96-87a5-98d7f067e37d" });

            migrationBuilder.CreateIndex(
                name: "IX_Orders_ServiceProductId",
                table: "Orders",
                column: "ServiceProductId");

            migrationBuilder.AddForeignKey(
                name: "FK_Orders_Products_ServiceProductId",
                table: "Orders",
                column: "ServiceProductId",
                principalTable: "Products",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Orders_Products_ServiceProductId",
                table: "Orders");

            migrationBuilder.DropIndex(
                name: "IX_Orders_ServiceProductId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "OrderType",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ServiceProductId",
                table: "Orders");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 28, 23, 43, 49, 284, DateTimeKind.Utc).AddTicks(3615));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 28, 23, 43, 49, 284, DateTimeKind.Utc).AddTicks(3613));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 28, 23, 43, 49, 284, DateTimeKind.Utc).AddTicks(3605));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 28, 23, 43, 49, 284, DateTimeKind.Utc).AddTicks(3743));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "736cc5f6-e303-41d1-939f-1ea949848347", new DateTime(2026, 2, 28, 23, 43, 49, 211, DateTimeKind.Utc).AddTicks(1721), "AQAAAAIAAYagAAAAEFn7iHDDpLMCSakc1UxKB2LGjxI+Pma7102NOnZv82quAiTPA3kDGUv/N9felRQbsg==", "332b7927-b3d1-4abd-bee2-51f8a1bf300e" });
        }
    }
}
