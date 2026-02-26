using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class MakeProductCategoryMaterialNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "MaterialId",
                table: "Products",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<int>(
                name: "CategoryId",
                table: "Products",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1546));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1545));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1539));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 2, 25, 23, 6, 53, 266, DateTimeKind.Utc).AddTicks(1576));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "29f0e868-1416-43b0-906e-c1b133943fdb", new DateTime(2026, 2, 25, 23, 6, 53, 205, DateTimeKind.Utc).AddTicks(4512), "AQAAAAIAAYagAAAAEFfDfXjOo400CRu2ZPNVfS9MjLj5nvjBwUmDSmzKTHA+JzxYbjCx8+fYZXto0uF3Sg==", "7d122519-a0e2-44d6-93fe-63619f01f917" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "MaterialId",
                table: "Products",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "CategoryId",
                table: "Products",
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
        }
    }
}
