using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class SeedInitialUserData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "AspNetRoles",
                columns: new[] { "Id", "ConcurrencyStamp", "CreatedAt", "Description", "IsActive", "Name", "NormalizedName" },
                values: new object[,]
                {
                    { -3, null, new DateTime(2026, 1, 19, 21, 2, 2, 230, DateTimeKind.Utc).AddTicks(7879), "", true, "User", "USER" },
                    { -2, null, new DateTime(2026, 1, 19, 21, 2, 2, 230, DateTimeKind.Utc).AddTicks(7878), "", true, "Employee", "EMPLOYEE" },
                    { -1, null, new DateTime(2026, 1, 19, 21, 2, 2, 230, DateTimeKind.Utc).AddTicks(7875), "", true, "Admin", "ADMIN" }
                });

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "CreatedAt", "Email", "EmailConfirmed", "FirstName", "IsActive", "IsBlocked", "LastLoginAt", "LastName", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "ProfileImageUrl", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[] { -999, 0, "32522de0-35fc-4426-93ee-98d6da0d787f", new DateTime(2026, 1, 19, 21, 2, 2, 170, DateTimeKind.Utc).AddTicks(2338), "ismail.catic@edu.fit.ba", true, "Ismail", true, false, null, "Catic", false, null, "ISMAIL.CATIC@EDU.FIT.BA", "ISMAIL.CATIC@EDU.FIT.BA", "AQAAAAIAAYagAAAAEGsepAvevTH2ktEiq0EbIinz6qWBOJRj9ZIA3yyPh9Up0MFyvTz/aT3dI+/yq65x8Q==", null, false, null, "c568ae4f-eb88-40e1-9981-2f03a0776901", false, "ismail.catic@edu.fit.ba" });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId", "DateAssigned" },
                values: new object[] { -1, -999, new DateTime(2026, 1, 19, 21, 2, 2, 230, DateTimeKind.Utc).AddTicks(7901) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3);

            migrationBuilder.DeleteData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2);

            migrationBuilder.DeleteData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 });

            migrationBuilder.DeleteData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1);

            migrationBuilder.DeleteData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999);
        }
    }
}
