using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddBlogCategoryMetaFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "BlogCategories",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                table: "BlogCategories",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "BlogCategories",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 28, 18, 29, 43, 600, DateTimeKind.Utc).AddTicks(8411));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 28, 18, 29, 43, 600, DateTimeKind.Utc).AddTicks(8410));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 28, 18, 29, 43, 600, DateTimeKind.Utc).AddTicks(8403));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 1, 28, 18, 29, 43, 600, DateTimeKind.Utc).AddTicks(8542));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "c595d310-feec-4bc5-8015-2b11fb07c431", new DateTime(2026, 1, 28, 18, 29, 43, 501, DateTimeKind.Utc).AddTicks(9388), "AQAAAAIAAYagAAAAEIwPa/GA5LXsqJ8act5fgxkqrO+8yaRE+IKdkT1zdvqBvf+TrwyzeLhCBqmitggFww==", "57783032-84c5-4094-953b-3ad1bd260fac" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "BlogCategories");

            migrationBuilder.DropColumn(
                name: "IsActive",
                table: "BlogCategories");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "BlogCategories");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 28, 17, 41, 41, 100, DateTimeKind.Utc).AddTicks(1536));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 28, 17, 41, 41, 100, DateTimeKind.Utc).AddTicks(1535));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 28, 17, 41, 41, 100, DateTimeKind.Utc).AddTicks(1529));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 1, 28, 17, 41, 41, 100, DateTimeKind.Utc).AddTicks(1667));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "4748188a-d10b-4116-91d8-4e9cfebb28be", new DateTime(2026, 1, 28, 17, 41, 40, 975, DateTimeKind.Utc).AddTicks(8873), "AQAAAAIAAYagAAAAELscP6IhVjSUgSa/64lDbHgX3W0mVcAlB11382S911pY15DLcinfvlIMatXZk+02vw==", "546eaa82-91b8-44c6-8653-c6e34b5f62ce" });
        }
    }
}
