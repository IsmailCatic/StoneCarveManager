using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddBlogCategory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CategoryId",
                table: "BlogPosts",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "BlogCategories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogCategories", x => x.Id);
                });

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

            migrationBuilder.CreateIndex(
                name: "IX_BlogPosts_CategoryId",
                table: "BlogPosts",
                column: "CategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_BlogPosts_BlogCategories_CategoryId",
                table: "BlogPosts",
                column: "CategoryId",
                principalTable: "BlogCategories",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BlogPosts_BlogCategories_CategoryId",
                table: "BlogPosts");

            migrationBuilder.DropTable(
                name: "BlogCategories");

            migrationBuilder.DropIndex(
                name: "IX_BlogPosts_CategoryId",
                table: "BlogPosts");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                table: "BlogPosts");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 20, 22, 33, 989, DateTimeKind.Utc).AddTicks(9719));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 20, 22, 33, 989, DateTimeKind.Utc).AddTicks(9718));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 20, 22, 33, 989, DateTimeKind.Utc).AddTicks(9712));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 1, 26, 20, 22, 33, 989, DateTimeKind.Utc).AddTicks(9777));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "59e4b4a6-4550-4cb8-a148-16ec3b19b831", new DateTime(2026, 1, 26, 20, 22, 33, 930, DateTimeKind.Utc).AddTicks(4916), "AQAAAAIAAYagAAAAEI/nvLW8jZVVHWcWi+wBIbWkDP6bCBM3WrRFIDNY/tPMqXjyA4SmnhreQz6ghn3jMQ==", "b9f3077e-e645-44b1-980d-d7742d64391a" });
        }
    }
}
