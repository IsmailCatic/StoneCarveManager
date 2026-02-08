using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class StripePaymentImplementation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "StripePaymentIntentId",
                table: "Payments",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 17, 13, 51, 305, DateTimeKind.Utc).AddTicks(4590));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 17, 13, 51, 305, DateTimeKind.Utc).AddTicks(4589));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 17, 13, 51, 305, DateTimeKind.Utc).AddTicks(4578));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 2, 17, 13, 51, 305, DateTimeKind.Utc).AddTicks(4633));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "91163c19-48d3-46e6-88b1-ac771ebfb298", new DateTime(2026, 2, 2, 17, 13, 51, 245, DateTimeKind.Utc).AddTicks(6419), "AQAAAAIAAYagAAAAEFLsZfJviNHNpC9DZh8+8bwmkm6tAbay/hFRHM/gMdP3TlsXrLrjx6phZF8waorSTA==", "221a289a-6874-45b4-84f2-6ba32394b0c7" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "StripePaymentIntentId",
                table: "Payments");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 12, 5, 52, 347, DateTimeKind.Utc).AddTicks(1656));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 12, 5, 52, 347, DateTimeKind.Utc).AddTicks(1655));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 2, 12, 5, 52, 347, DateTimeKind.Utc).AddTicks(1650));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 2, 12, 5, 52, 347, DateTimeKind.Utc).AddTicks(1691));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "d7fe127c-4b0c-4398-961a-6ca4acb59359", new DateTime(2026, 2, 2, 12, 5, 52, 288, DateTimeKind.Utc).AddTicks(3966), "AQAAAAIAAYagAAAAEDSZdOBdZ13SNoVRga6zGtZn/pGnl9+bvyrtqdXmPHvtXPyJRPemSvpxT7YF1CnLIw==", "7656b395-392a-432a-97ab-e0b376e74586" });
        }
    }
}
