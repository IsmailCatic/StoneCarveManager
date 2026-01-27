using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddBlogImagesToBlogPost : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BlogImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AltText = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    BlogPostId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BlogImages_BlogPosts_BlogPostId",
                        column: x => x.BlogPostId,
                        principalTable: "BlogPosts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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

            migrationBuilder.CreateIndex(
                name: "IX_BlogImages_BlogPostId",
                table: "BlogImages",
                column: "BlogPostId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BlogImages");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 20, 7, 33, 125, DateTimeKind.Utc).AddTicks(2213));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 20, 7, 33, 125, DateTimeKind.Utc).AddTicks(2212));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 26, 20, 7, 33, 125, DateTimeKind.Utc).AddTicks(2209));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 1, 26, 20, 7, 33, 125, DateTimeKind.Utc).AddTicks(2243));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "1d902fd1-b487-40bf-bbd0-1d7ba983d8e4", new DateTime(2026, 1, 26, 20, 7, 33, 66, DateTimeKind.Utc).AddTicks(4607), "AQAAAAIAAYagAAAAEL3m/TFbwEPIc5pmeMvFSBG18EeYM/IfCw1veZtAJlDD87HYqLfj+SSorjw2qWZy7g==", "038bcf30-53a5-43ed-95b5-ecd60a85d18d" });
        }
    }
}
