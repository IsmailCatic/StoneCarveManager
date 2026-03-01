using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddDeliveryCountry : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DeliveryCountry",
                table: "Orders",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 16, 5, 34, 585, DateTimeKind.Utc).AddTicks(9452));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 16, 5, 34, 585, DateTimeKind.Utc).AddTicks(9451));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 16, 5, 34, 585, DateTimeKind.Utc).AddTicks(9446));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 1, 16, 5, 34, 585, DateTimeKind.Utc).AddTicks(9487));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "a5799dfb-203e-4af7-ac22-7d0b9cfc8978", new DateTime(2026, 3, 1, 16, 5, 34, 501, DateTimeKind.Utc).AddTicks(2474), "AQAAAAIAAYagAAAAECiC+3Z075Jcp7669fKqT4ichbBOAA30MeRSCV1PDKdl0DFgsG5lLQSeozXd/zrsNw==", "86365a05-e163-4526-b63c-d8c42fab17bc" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeliveryCountry",
                table: "Orders");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 2, 46, 43, 411, DateTimeKind.Utc).AddTicks(2168));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 2, 46, 43, 411, DateTimeKind.Utc).AddTicks(2167));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 1, 2, 46, 43, 411, DateTimeKind.Utc).AddTicks(2163));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 1, 2, 46, 43, 411, DateTimeKind.Utc).AddTicks(2198));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "3bad3de0-8c5b-48e5-b1dc-bfc8a538e9ec", new DateTime(2026, 3, 1, 2, 46, 43, 352, DateTimeKind.Utc).AddTicks(1273), "AQAAAAIAAYagAAAAEPbftLn6cqf4qA4ej16GjeiiEr7WRXLzbMgTCOZ79u5HnX7Y9PjHdrBlNCSzNDT+9Q==", "b6907108-8ca5-44ae-88f6-f042f084d913" });
        }
    }
}
