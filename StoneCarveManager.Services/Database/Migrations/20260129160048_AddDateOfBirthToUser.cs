using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddDateOfBirthToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DateOfBirth",
                table: "AspNetUsers",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 29, 16, 0, 46, 856, DateTimeKind.Utc).AddTicks(3601));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 29, 16, 0, 46, 856, DateTimeKind.Utc).AddTicks(3599));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 29, 16, 0, 46, 856, DateTimeKind.Utc).AddTicks(3597));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 1, 29, 16, 0, 46, 856, DateTimeKind.Utc).AddTicks(3660));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "DateOfBirth", "PasswordHash", "SecurityStamp" },
                values: new object[] { "3bcf7534-f21f-43a8-9f42-990c7b4fb0cc", new DateTime(2026, 1, 29, 16, 0, 46, 757, DateTimeKind.Utc).AddTicks(2497), null, "AQAAAAIAAYagAAAAEG8VQsrrn23WLjyswovV9FoJ2cquTAD9oPtb6wfVgwOCawIr66Z/XD0rYL0YPJSriw==", "73ed3ae4-1921-45ee-b4a5-6e808183c1f0" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DateOfBirth",
                table: "AspNetUsers");

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
    }
}
