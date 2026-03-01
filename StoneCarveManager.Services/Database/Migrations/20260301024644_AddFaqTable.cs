using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddFaqTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Faqs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Question = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Answer = table.Column<string>(type: "nvarchar(4000)", maxLength: 4000, nullable: false),
                    Category = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    ViewCount = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Faqs", x => x.Id);
                });

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

            migrationBuilder.CreateIndex(
                name: "IX_Faqs_Category",
                table: "Faqs",
                column: "Category");

            migrationBuilder.CreateIndex(
                name: "IX_Faqs_DisplayOrder",
                table: "Faqs",
                column: "DisplayOrder");

            migrationBuilder.CreateIndex(
                name: "IX_Faqs_IsActive",
                table: "Faqs",
                column: "IsActive");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Faqs");

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
        }
    }
}
