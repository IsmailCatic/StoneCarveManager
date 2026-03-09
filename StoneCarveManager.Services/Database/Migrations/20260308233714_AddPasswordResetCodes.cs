using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class AddPasswordResetCodes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "OrderItems",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Orders",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.CreateTable(
                name: "PasswordResetCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    Code = table.Column<string>(type: "nvarchar(6)", maxLength: 6, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsUsed = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PasswordResetCodes", x => x.Id);
                });

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7246));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7245));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7239));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7288));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -3, -303 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7360));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -3, -302 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7359));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -3, -301 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7358));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -2, -203 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7295));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -2, -202 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7294));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -2, -201 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7293));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -103 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7293));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -102 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7292));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -101 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7291));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, 1000000 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 8, 23, 37, 13, 303, DateTimeKind.Utc).AddTicks(7291));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "a1b9257d-6585-4b47-a58e-174f55249699", new DateTime(2026, 3, 8, 23, 37, 12, 633, DateTimeKind.Utc).AddTicks(4029), "AQAAAAIAAYagAAAAEFcWSZG13LfNE3tJjzgcWzhJMlmWmXU3T6RkMI2iGctr1fiM1Fj7mcLAfy1z5QxiDg==", "802fbf89-918d-444a-ba20-988a8456f58e" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -303,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "d611f8bc-0dc7-4c72-b56b-86df2911d589", "AQAAAAIAAYagAAAAEG2LyAC+sdIDw6iGHmUiEA2jWsYlA9mVB6LF8eO7oAiYVCMFoGmZ2MDXFClm9RCz7A==", "69855ec0-5dff-42cf-b70b-793e1314e5ad" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -302,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "1a700842-b3ae-4bab-ba46-3296c0443af2", "AQAAAAIAAYagAAAAEJUouIjeZ+WVvymvPQJwQdPCWpZYEB2K7W2zSwxuIAj9j5HwjDTZCdeC5CupkvhDwA==", "fe107997-15f9-4a9c-9b8d-b219637814fa" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -301,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "1623d618-d8ad-4411-afc6-21697b3b87c3", "AQAAAAIAAYagAAAAEFpc4XQgdXVQXPkXmQnmiqI/WwWWPWK/BPSDwXk8qxH/qi4KwK1SnaR4Ai7aOhmjlw==", "0ebd098f-47b3-46cf-84df-8b3a25ecd522" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -203,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "23501cd9-4e99-4a28-afbd-18965c46d767", "AQAAAAIAAYagAAAAEJGTwIBxmuvlFW3XBkWqGC9u4DthtCJj1UQTfqfVjtBuxlbARL3p1WD+/7jLkFbFeA==", "213a0a67-1918-4d3f-9b5e-bf7e100f5325" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -202,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "f123d2f5-13cc-4e72-a067-c865666cf538", "AQAAAAIAAYagAAAAEGjgoTochQdillJeY6zM9vkhxdXtQFqbxKJTPAmRCw66IaqwEUOBH1nH7IwwxZBosw==", "2ac98917-b9d7-4d06-822c-eca57a299a9f" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -201,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "fa32f634-cfff-4957-bb4d-8c8c8d184330", "AQAAAAIAAYagAAAAEBQ/sAO8unHEEYSnPeyqp3h/emIX5ASkVWaETbgF0vfkBuoolsb953z+hmS+2uUJhw==", "b561b5e7-f5ed-4742-b3c9-0f286dc8cf9a" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -103,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "a11a2e12-d14c-44f2-95c2-c1632d54d021", "AQAAAAIAAYagAAAAEC5CqRr4Fv1508KN0GsRcf5+XeJbJ3NdDwSznJPUPx6UqkZZjju5C7AMCd6fSkT9EQ==", "e1d97a60-e3e7-4355-9270-9e4b27ea7190" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -102,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "84d7f7d0-811a-4725-bd04-8d6963014ee3", "AQAAAAIAAYagAAAAEMqzGtSpyawTtxgDQCJNDL2qT9098f7Go74Lx5b+HeAS65FrRnF++3GjuNnSmlVLkw==", "7646e1d5-cddd-489a-a5a3-3d2f509d4f1d" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -101,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "d7cb02eb-22f8-4892-b9ba-c36e8dc0645f", "AQAAAAIAAYagAAAAEHD+oF3Iy1+6vxSCD4Ihzs6qZPYzt7C9lOqvhwuqMTb0TyydxUJtf3O04D7OSXNNtw==", "078a92b7-ec7a-4b6e-8cd8-74cf1bb87972" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: 1000000,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "ff6ceee2-21b6-43fa-bdc8-6a64383f65b8", new DateTime(2026, 3, 8, 23, 37, 12, 694, DateTimeKind.Utc).AddTicks(7206), "AQAAAAIAAYagAAAAEAAS7AZCOYdnRwGUNiQk60Cl2iGXI9/62RtXW0VsKbfMDgbff4GPXZKjQ883aBFoTw==", "a521d286-90ce-4241-8af7-a80a25c08922" });

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "Id",
                keyValue: 9,
                column: "ProductId",
                value: 10);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "Id",
                keyValue: 10,
                column: "ProductId",
                value: 11);

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 1, 10, 9, 0, 0, 0, DateTimeKind.Utc), "Panel designs approved. Cutting and polishing in progress." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 1, 15, 15, 0, 0, 0, DateTimeKind.Utc), "Panels completed and dispatched." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 1, 20, 16, 0, 0, 0, DateTimeKind.Utc), "Delivered and installed on schedule." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 2, 5, 10, 0, 0, 0, DateTimeKind.Utc), "Balustrade design finalized. Fabrication has begun." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "ChangedAt", "Comment", "NewStatus" },
                values: new object[] { new DateTime(2026, 2, 18, 14, 0, 0, 0, DateTimeKind.Utc), "Three balustrade sections delivered and installed.", "Delivered" });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "ChangedAt", "ChangedByUserId", "Comment", "NewStatus", "OldStatus", "OrderId" },
                values: new object[] { new DateTime(2026, 3, 5, 9, 0, 0, 0, DateTimeKind.Utc), -202, "High relief panel design approved. Carving in progress.", "Processing", "Pending", 8 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PasswordResetCodes");

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -3,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2623));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -2,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2622));

            migrationBuilder.UpdateData(
                table: "AspNetRoles",
                keyColumn: "Id",
                keyValue: -1,
                column: "CreatedAt",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2618));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -999 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2666));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -3, -303 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2674));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -3, -302 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2673));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -3, -301 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2673));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -2, -203 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2672));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -2, -202 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2671));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -2, -201 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2670));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -103 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2670));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -102 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2669));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, -101 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2668));

            migrationBuilder.UpdateData(
                table: "AspNetUserRoles",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { -1, 1000000 },
                column: "DateAssigned",
                value: new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2667));

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -999,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "7a7ce143-ea29-4bed-959f-bb9694dbef28", new DateTime(2026, 3, 3, 1, 33, 3, 20, DateTimeKind.Utc).AddTicks(8981), "AQAAAAIAAYagAAAAEAA+Yu5aeedj0iqQw2yi7EqLlnAKyywkSa5pDxRiC7ptNrWwkkU3uae7RX3YI1UjOg==", "449fbed4-e142-4569-b205-083ebb05b425" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -303,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "3450b932-9ef4-41a6-b024-2f3d144eac96", "AQAAAAIAAYagAAAAEJ8jcYoDbogolcUqkUtQ0M8wMHwcG5Xih0m7+tqUsQwYdpC4N6X0v+L7Qlqg4nnlGQ==", "0c28282a-6814-43d0-af1a-8478476e567d" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -302,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "6d2e9062-8e0d-4c9b-b3a3-96f556737466", "AQAAAAIAAYagAAAAEOEnjNpmeupx57OXznwSOHdvZlQL55D2MtZhTbRPIICXAoaDTsxCz/zjRE6ooGXFrw==", "33af892d-8433-4bb7-a4d1-069e5d94c943" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -301,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "37968a93-e041-4b7c-bbd8-f0c091123a13", "AQAAAAIAAYagAAAAEGZnl+VVr7AaElVqmqtOKyQp6ZjrpN5Tyb32cpDaxBA8EpTAItk9RTH0B2rCYfXahg==", "1ac35815-21b8-475b-ab79-0411c6d3f5f1" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -203,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "049bee3f-a807-4594-9d08-767e8fe19ee6", "AQAAAAIAAYagAAAAEKrMWzsniVb0vocOR1lDsX/+qR4NFZz+sV4o/XUCu6i+bqxI1g1X1lKcfa/OMg3cJw==", "8ae2fd02-0de5-42df-883c-b6999c7e589c" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -202,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "9e834732-ca06-4b2d-9405-fce815cfd2eb", "AQAAAAIAAYagAAAAEBUGuz7Vdk7nvYNVKRoJA9rc5Ao+nv7M53ILNtaxgoYLxml/p7UyGT7+gEzLmq/cTw==", "127bb299-6177-44cf-a086-b14209746331" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -201,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "d3657181-0ec7-42a5-a73b-b6caec0e22b0", "AQAAAAIAAYagAAAAEH5yYJQ5/Gw+cA20qqcSrmzA5g7pxZkOxtxtQirZdzMlw+RdJUdHndmR+7Uyj53fFQ==", "783dc09a-3a86-4386-b972-b43d7e884ff9" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -103,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "ed8fe91e-744b-479a-b38e-e79d693857e6", "AQAAAAIAAYagAAAAEA+/tDSD/KnWGZGt/F+qSMVcjscwtke8okMOIhDOQ3/I5kzx1Rn38gKY8ua1xrMylQ==", "3212350d-92fc-4131-8cf6-6cbedaa54f3e" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -102,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "bd6fec5e-5477-4b74-8f18-1afaf3dc4430", "AQAAAAIAAYagAAAAEDqIUCCeKxRDZVWy3Sk5qPjhByKrxzvgnTQnjZ8ZtGC/KPsYbfa0CPxzi1w4WTCxSA==", "d7eced62-9304-457e-ad56-c8a7da2d2215" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: -101,
                columns: new[] { "ConcurrencyStamp", "PasswordHash", "SecurityStamp" },
                values: new object[] { "ba84cbf2-b725-400f-8b47-00ae6dac8b6a", "AQAAAAIAAYagAAAAEMIMrCxbVt6YnOl7m2zqVYTCRQSiplRaAx2nl/70bEYQxamRs+IcLU1opq+eYpRVwg==", "553d667f-b9c0-4401-8ea9-df43b4a0882f" });

            migrationBuilder.UpdateData(
                table: "AspNetUsers",
                keyColumn: "Id",
                keyValue: 1000000,
                columns: new[] { "ConcurrencyStamp", "CreatedAt", "PasswordHash", "SecurityStamp" },
                values: new object[] { "dfa48b45-c825-4c7d-a67b-0d4f33f9b9ab", new DateTime(2026, 3, 3, 1, 33, 3, 80, DateTimeKind.Utc).AddTicks(402), "AQAAAAIAAYagAAAAEL0+rUkkpEE8h8+RNL4QVRgptoRr8wqL6YIM2u/0IJwsfbjgxExmdEJk1vh+uLZKHQ==", "23057e6e-09f5-4439-8d23-da93f4959ea9" });

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "Id",
                keyValue: 9,
                column: "ProductId",
                value: 5);

            migrationBuilder.UpdateData(
                table: "OrderItems",
                keyColumn: "Id",
                keyValue: 10,
                column: "ProductId",
                value: 6);

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 10,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 1, 9, 8, 0, 0, 0, DateTimeKind.Utc), "Payment confirmed. Panel cutting has started." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 11,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 1, 18, 9, 0, 0, 0, DateTimeKind.Utc), "Both panels packed and dispatched." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 12,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 1, 20, 13, 0, 0, 0, DateTimeKind.Utc), "Delivered and signed for by customer." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 13,
                columns: new[] { "ChangedAt", "Comment" },
                values: new object[] { new DateTime(2026, 2, 4, 8, 30, 0, 0, DateTimeKind.Utc), "Payment confirmed. Balustrade sections being cut from limestone stock." });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 14,
                columns: new[] { "ChangedAt", "Comment", "NewStatus" },
                values: new object[] { new DateTime(2026, 2, 16, 7, 0, 0, 0, DateTimeKind.Utc), "All three sections complete. Loaded for delivery.", "Shipped" });

            migrationBuilder.UpdateData(
                table: "OrderStatusHistories",
                keyColumn: "Id",
                keyValue: 15,
                columns: new[] { "ChangedAt", "ChangedByUserId", "Comment", "NewStatus", "OldStatus", "OrderId" },
                values: new object[] { new DateTime(2026, 2, 18, 14, 30, 0, 0, DateTimeKind.Utc), -201, "Delivered to terrace site. Customer confirmed receipt.", "Delivered", "Shipped", 7 });

            migrationBuilder.InsertData(
                table: "OrderStatusHistories",
                columns: new[] { "Id", "ChangedAt", "ChangedByUserId", "Comment", "NewStatus", "OldStatus", "OrderId" },
                values: new object[] { 16, new DateTime(2026, 3, 3, 9, 0, 0, 0, DateTimeKind.Utc), -202, "Payment confirmed. Limestone block sourced, carving underway.", "Processing", "Pending", 8 });

            migrationBuilder.InsertData(
                table: "Orders",
                columns: new[] { "Id", "AdminNotes", "AssignedEmployeeId", "AttachmentUrl", "CompletedAt", "CustomerNotes", "DeliveryAddress", "DeliveryCity", "DeliveryCountry", "DeliveryDate", "DeliveryZipCode", "EstimatedCompletionDate", "OrderDate", "OrderNumber", "OrderType", "ServiceProductId", "Status", "TotalAmount", "UserId" },
                values: new object[] { 18, null, null, null, null, "The installation I need is to be done well and thers 40 panels to be installed at a tall height.", "Sjeverni Logor bb", "Mostar", null, new DateTime(2026, 3, 31, 0, 0, 0, 0, DateTimeKind.Utc), "88000", null, new DateTime(2026, 3, 2, 16, 8, 21, 0, DateTimeKind.Utc), "ORD-20260302160821266-B04BAE", "service_request", 10, "Processing", 299.00m, -302 });

            migrationBuilder.InsertData(
                table: "OrderItems",
                columns: new[] { "Id", "OrderId", "ProductId", "Quantity", "UnitPrice" },
                values: new object[] { 11, 18, 10, 1, 299.00m });

            migrationBuilder.InsertData(
                table: "OrderStatusHistories",
                columns: new[] { "Id", "ChangedAt", "ChangedByUserId", "Comment", "NewStatus", "OldStatus", "OrderId" },
                values: new object[] { 17, new DateTime(2026, 3, 2, 16, 30, 0, 0, DateTimeKind.Utc), -201, "Payment confirmed. Installation service request accepted.", "Processing", "Pending", 18 });
        }
    }
}
