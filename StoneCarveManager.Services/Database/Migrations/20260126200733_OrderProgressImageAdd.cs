using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class OrderProgressImageAdd : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderProgressImage_AspNetUsers_UploadedByUserId",
                table: "OrderProgressImage");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderProgressImage_Orders_OrderId",
                table: "OrderProgressImage");

            migrationBuilder.DropPrimaryKey(
                name: "PK_OrderProgressImage",
                table: "OrderProgressImage");

            migrationBuilder.RenameTable(
                name: "OrderProgressImage",
                newName: "OrderProgressImages");

            migrationBuilder.RenameIndex(
                name: "IX_OrderProgressImage_UploadedByUserId",
                table: "OrderProgressImages",
                newName: "IX_OrderProgressImages_UploadedByUserId");

            migrationBuilder.RenameIndex(
                name: "IX_OrderProgressImage_OrderId",
                table: "OrderProgressImages",
                newName: "IX_OrderProgressImages_OrderId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_OrderProgressImages",
                table: "OrderProgressImages",
                column: "Id");

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

            migrationBuilder.AddForeignKey(
                name: "FK_OrderProgressImages_AspNetUsers_UploadedByUserId",
                table: "OrderProgressImages",
                column: "UploadedByUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderProgressImages_Orders_OrderId",
                table: "OrderProgressImages",
                column: "OrderId",
                principalTable: "Orders",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_OrderProgressImages_AspNetUsers_UploadedByUserId",
                table: "OrderProgressImages");

            migrationBuilder.DropForeignKey(
                name: "FK_OrderProgressImages_Orders_OrderId",
                table: "OrderProgressImages");

            migrationBuilder.DropPrimaryKey(
                name: "PK_OrderProgressImages",
                table: "OrderProgressImages");

            migrationBuilder.RenameTable(
                name: "OrderProgressImages",
                newName: "OrderProgressImage");

            migrationBuilder.RenameIndex(
                name: "IX_OrderProgressImages_UploadedByUserId",
                table: "OrderProgressImage",
                newName: "IX_OrderProgressImage_UploadedByUserId");

            migrationBuilder.RenameIndex(
                name: "IX_OrderProgressImages_OrderId",
                table: "OrderProgressImage",
                newName: "IX_OrderProgressImage_OrderId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_OrderProgressImage",
                table: "OrderProgressImage",
                column: "Id");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 21, 16, 40, 16, 550, DateTimeKind.Utc).AddTicks(7067));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 21, 16, 40, 16, 550, DateTimeKind.Utc).AddTicks(7066));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 1, 21, 16, 40, 16, 550, DateTimeKind.Utc).AddTicks(7061));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 1, 21, 16, 40, 16, 550, DateTimeKind.Utc).AddTicks(7094));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "e8a5ff0d-0296-4297-8234-56f2751ead1f", new DateTime(2026, 1, 21, 16, 40, 16, 491, DateTimeKind.Utc).AddTicks(7707), "AQAAAAIAAYagAAAAEEF7WK74+Ek9VUA+KWRbqGDho0gVOkooFu11q/HG3mUV/7M+UYE6Ae76GMiFhJ55tg==", "1230b1f0-67e5-4250-abe0-3220422314fd" });

            migrationBuilder.AddForeignKey(
                name: "FK_OrderProgressImage_AspNetUsers_UploadedByUserId",
                table: "OrderProgressImage",
                column: "UploadedByUserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_OrderProgressImage_Orders_OrderId",
                table: "OrderProgressImage",
                column: "OrderId",
                principalTable: "Orders",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
