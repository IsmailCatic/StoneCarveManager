using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class MakeOrderItemProductIdNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "ProductId",
                table: "OrderItems",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 2, 18, 44, 19, 219, DateTimeKind.Utc).AddTicks(4305));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 2, 18, 44, 19, 219, DateTimeKind.Utc).AddTicks(4304));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 2, 18, 44, 19, 219, DateTimeKind.Utc).AddTicks(4297));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 2, 18, 44, 19, 219, DateTimeKind.Utc).AddTicks(4364));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "cf80cd50-a454-41c0-aa99-7e8aebca32b0", new DateTime(2026, 3, 2, 18, 44, 19, 61, DateTimeKind.Utc).AddTicks(6197), "AQAAAAIAAYagAAAAEIUb9DxsOj9XAr6NPs9+0HVWJSCjjWx/+Y+jTa4589V3QPf3vEsh5dNDeWfGFcbi1g==", "0045d555-e82b-439c-8fab-8622d9b5de61" });

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "CreatedAt", "DateOfBirth", "Email", "EmailConfirmed", "FirstName", "IsActive", "IsBlocked", "LastLoginAt", "LastName", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "ProfileImageUrl", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { 1000000, 0, "de3c9654-49d5-4c3e-af2c-2ed7d3e6510b", new DateTime(2026, 3, 2, 18, 44, 19, 160, DateTimeKind.Utc).AddTicks(5514), null, "admin@edu.fit.ba", true, "Admin", true, false, null, "Admin", false, null, "ADMIN@EDU.FIT.BA", "ADMIN@EDU.FIT.BA", "AQAAAAIAAYagAAAAEEbGXIDYMTJDOtCM9WP5o1dsB3b9a/8M5GQrzZhpkbzsmfQyiAffC/h5hnQyI4Zfag==", null, false, null, "306d38e6-6326-4bcb-b05c-6b69163d7abe", false, "admin@edu.fit.ba" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: 1000000);

            migrationBuilder.AlterColumn<int>(
                name: "ProductId",
                table: "OrderItems",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

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
    }
}
