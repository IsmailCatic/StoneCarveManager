using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddPortfolioFieldsToProduct : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ClientChallenge",
                table: "Products",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CompletionYear",
                table: "Products",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Location",
                table: "Products",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OurSolution",
                table: "Products",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PortfolioDescription",
                table: "Products",
                type: "nvarchar(4000)",
                maxLength: 4000,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ProjectDuration",
                table: "Products",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProjectOutcome",
                table: "Products",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TechniquesUsed",
                table: "Products",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 11, 22, 57, 838, DateTimeKind.Utc).AddTicks(4385));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 11, 22, 57, 838, DateTimeKind.Utc).AddTicks(4384));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 3, 11, 22, 57, 838, DateTimeKind.Utc).AddTicks(4380));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 3, 11, 22, 57, 838, DateTimeKind.Utc).AddTicks(4416));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "0f7514d0-c13b-4a7e-a0e6-1c8475208fb2", new DateTime(2026, 2, 3, 11, 22, 57, 778, DateTimeKind.Utc).AddTicks(1595), "AQAAAAIAAYagAAAAEGAm4grnBBCbjXrhrQNZ3A4zgzb43USFpHxoiSvhm0KCcIAqth5LeabiVkdsOyhtBQ==", "b2ad5d1b-c06c-4663-bf40-d134ff4f8e32" });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 4,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 5,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 6,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 7,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 8,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 9,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });

            migrationBuilder.UpdateData(
                table: "Products",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "ClientChallenge", "CompletionYear", "Location", "OurSolution", "PortfolioDescription", "ProjectDuration", "ProjectOutcome", "TechniquesUsed" },
                values: new object[] { null, null, null, null, null, null, null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ClientChallenge",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "CompletionYear",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "Location",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "OurSolution",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "PortfolioDescription",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "ProjectDuration",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "ProjectOutcome",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "TechniquesUsed",
                table: "Products");

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
    }
}
