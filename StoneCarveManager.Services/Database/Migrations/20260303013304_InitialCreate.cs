using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AspNetRoles",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUsers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    IsBlocked = table.Column<bool>(type: "bit", nullable: false),
                    ProfileImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    LastLoginAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "datetime2", nullable: true),
                    UserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedUserName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    NormalizedEmail = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    EmailConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SecurityStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ConcurrencyStamp = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumberConfirmed = table.Column<bool>(type: "bit", nullable: false),
                    TwoFactorEnabled = table.Column<bool>(type: "bit", nullable: false),
                    LockoutEnd = table.Column<DateTimeOffset>(type: "datetimeoffset", nullable: true),
                    LockoutEnabled = table.Column<bool>(type: "bit", nullable: false),
                    AccessFailedCount = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUsers", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "BlogCategories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogCategories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ParentCategoryId = table.Column<int>(type: "int", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Categories_Categories_ParentCategoryId",
                        column: x => x.ParentCategoryId,
                        principalTable: "Categories",
                        principalColumn: "Id");
                });

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

            migrationBuilder.CreateTable(
                name: "Materials",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    PricePerUnit = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false, defaultValue: "m²"),
                    QuantityInStock = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Materials", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AspNetRoleClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetRoleClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserClaims",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ClaimType = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ClaimValue = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserClaims", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserLogins",
                columns: table => new
                {
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderKey = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ProviderDisplayName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserLogins", x => new { x.LoginProvider, x.ProviderKey });
                    table.ForeignKey(
                        name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserRoles",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    DateAssigned = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserRoles", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "AspNetRoles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AspNetUserTokens",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    LoginProvider = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AspNetUserTokens", x => new { x.UserId, x.LoginProvider, x.Name });
                    table.ForeignKey(
                        name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Carts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Carts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Carts_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "BlogPosts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Summary = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    FeaturedImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsPublished = table.Column<bool>(type: "bit", nullable: false),
                    IsTutorial = table.Column<bool>(type: "bit", nullable: false),
                    ViewCount = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    PublishedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    AuthorId = table.Column<int>(type: "int", nullable: false),
                    CategoryId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BlogPosts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BlogPosts_AspNetUsers_AuthorId",
                        column: x => x.AuthorId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BlogPosts_BlogCategories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "BlogCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    StockQuantity = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Dimensions = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Weight = table.Column<decimal>(type: "decimal(10,2)", nullable: true),
                    EstimatedDays = table.Column<int>(type: "int", nullable: false, defaultValue: 7),
                    IsInPortfolio = table.Column<bool>(type: "bit", nullable: false),
                    ViewCount = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CategoryId = table.Column<int>(type: "int", nullable: true),
                    MaterialId = table.Column<int>(type: "int", nullable: true),
                    ProductState = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: false, defaultValue: "draft"),
                    PortfolioDescription = table.Column<string>(type: "nvarchar(4000)", maxLength: 4000, nullable: true),
                    ClientChallenge = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    OurSolution = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    ProjectOutcome = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    Location = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    CompletionYear = table.Column<int>(type: "int", nullable: true),
                    ProjectDuration = table.Column<int>(type: "int", nullable: true),
                    TechniquesUsed = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Products_Categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "Categories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Products_Materials_MaterialId",
                        column: x => x.MaterialId,
                        principalTable: "Materials",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

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

            migrationBuilder.CreateTable(
                name: "CartItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Quantity = table.Column<int>(type: "int", nullable: false, defaultValue: 1),
                    AddedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CustomNotes = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CartId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CartItems", x => x.Id);
                    table.CheckConstraint("CK_CartItem_Quantity", "[Quantity] > 0");
                    table.ForeignKey(
                        name: "FK_CartItems_Carts_CartId",
                        column: x => x.CartId,
                        principalTable: "Carts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CartItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "FavoriteProducts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AddedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FavoriteProducts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_FavoriteProducts_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FavoriteProducts_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderDate = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    OrderNumber = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    CustomerNotes = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    AdminNotes = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    AttachmentUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    EstimatedCompletionDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    AssignedEmployeeId = table.Column<int>(type: "int", nullable: true),
                    ServiceProductId = table.Column<int>(type: "int", nullable: true),
                    OrderType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    DeliveryAddress = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    DeliveryCity = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    DeliveryZipCode = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    DeliveryCountry = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DeliveryDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Orders_AspNetUsers_AssignedEmployeeId",
                        column: x => x.AssignedEmployeeId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Orders_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Orders_Products_ServiceProductId",
                        column: x => x.ServiceProductId,
                        principalTable: "Products",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ProductImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    AltText = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    IsPrimary = table.Column<bool>(type: "bit", nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ProductImages_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Discount = table.Column<decimal>(type: "decimal(18,2)", nullable: false, defaultValue: 0m),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderItems", x => x.Id);
                    table.CheckConstraint("CK_OrderItem_Discount", "[Discount] >= 0");
                    table.CheckConstraint("CK_OrderItem_Quantity", "[Quantity] > 0");
                    table.CheckConstraint("CK_OrderItem_UnitPrice", "[UnitPrice] >= 0");
                    table.ForeignKey(
                        name: "FK_OrderItems_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItems_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "OrderProgressImages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UploadedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    UploadedByUserId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderProgressImages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_OrderProgressImages_AspNetUsers_UploadedByUserId",
                        column: x => x.UploadedByUserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_OrderProgressImages_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrderStatusHistories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OldStatus = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    NewStatus = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ChangedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    ChangedByUserId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderStatusHistories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_OrderStatusHistories_AspNetUsers_ChangedByUserId",
                        column: x => x.ChangedByUserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_OrderStatusHistories_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Payments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Method = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    TransactionId = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    StripePaymentIntentId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    FailureReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    RefundAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    RefundReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    RefundedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    OrderId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Payments", x => x.Id);
                    table.CheckConstraint("CK_Payment_Amount", "[Amount] > 0");
                    table.CheckConstraint("CK_Payment_RefundAmount", "[RefundAmount] IS NULL OR ([RefundAmount] >= 0 AND [RefundAmount] <= [Amount])");
                    table.ForeignKey(
                        name: "FK_Payments_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ProductReviews",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Rating = table.Column<int>(type: "int", nullable: false),
                    Comment = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: true),
                    OrderId = table.Column<int>(type: "int", nullable: true),
                    IsApproved = table.Column<bool>(type: "bit", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductReviews", x => x.Id);
                    table.CheckConstraint("CK_ProductReview_Rating", "[Rating] >= 1 AND [Rating] <= 5");
                    table.ForeignKey(
                        name: "FK_ProductReviews_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ProductReviews_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_ProductReviews_Products_ProductId",
                        column: x => x.ProductId,
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "AspNetRoles",
                columns: new[] { "Id", "ConcurrencyStamp", "CreatedAt", "Description", "IsActive", "Name", "NormalizedName" },
                values: new object[,]
                {
                    { -3, null, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2623), "Registered customer — browse catalogue, place orders and write reviews.", true, "User", "USER" },
                    { -2, null, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2622), "Workshop staff — process orders, upload progress images and manage inventory.", true, "Employee", "EMPLOYEE" },
                    { -1, null, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2618), "Full system access — manage users, products, orders and content.", true, "Admin", "ADMIN" }
                });

            migrationBuilder.InsertData(
                table: "AspNetUsers",
                columns: new[] { "Id", "AccessFailedCount", "ConcurrencyStamp", "CreatedAt", "DateOfBirth", "Email", "EmailConfirmed", "FirstName", "IsActive", "IsBlocked", "LastLoginAt", "LastName", "LockoutEnabled", "LockoutEnd", "NormalizedEmail", "NormalizedUserName", "PasswordHash", "PhoneNumber", "PhoneNumberConfirmed", "ProfileImageUrl", "SecurityStamp", "TwoFactorEnabled", "UserName" },
                values: new object[,]
                {
                    { -999, 0, "7a7ce143-ea29-4bed-959f-bb9694dbef28", new DateTime(2026, 3, 3, 1, 33, 3, 20, DateTimeKind.Utc).AddTicks(8981), null, "ismail.catic@edu.fit.ba", true, "Ismail", true, false, null, "Catic", false, null, "ISMAIL.CATIC@EDU.FIT.BA", "ISMAIL.CATIC@EDU.FIT.BA", "AQAAAAIAAYagAAAAEAA+Yu5aeedj0iqQw2yi7EqLlnAKyywkSa5pDxRiC7ptNrWwkkU3uae7RX3YI1UjOg==", null, false, null, "449fbed4-e142-4569-b205-083ebb05b425", false, "ismail.catic@edu.fit.ba" },
                    { -303, 0, "3450b932-9ef4-41a6-b024-2f3d144eac96", new DateTime(2024, 1, 18, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(1995, 11, 3, 0, 0, 0, 0, DateTimeKind.Utc), "user3@stonecarve.com", true, "Dario", true, false, null, "Šimić", false, null, "USER3@STONECARVE.COM", "USER3@STONECARVE.COM", "AQAAAAIAAYagAAAAEJ8jcYoDbogolcUqkUtQ0M8wMHwcG5Xih0m7+tqUsQwYdpC4N6X0v+L7Qlqg4nnlGQ==", null, false, null, "0c28282a-6814-43d0-af1a-8478476e567d", false, "user3@stonecarve.com" },
                    { -302, 0, "6d2e9062-8e0d-4c9b-b3a3-96f556737466", new DateTime(2024, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(1988, 7, 15, 0, 0, 0, 0, DateTimeKind.Utc), "user2@stonecarve.com", true, "Petra", true, false, null, "Knežević", false, null, "USER2@STONECARVE.COM", "USER2@STONECARVE.COM", "AQAAAAIAAYagAAAAEOEnjNpmeupx57OXznwSOHdvZlQL55D2MtZhTbRPIICXAoaDTsxCz/zjRE6ooGXFrw==", null, false, null, "33af892d-8433-4bb7-a4d1-069e5d94c943", false, "user2@stonecarve.com" },
                    { -301, 0, "37968a93-e041-4b7c-bbd8-f0c091123a13", new DateTime(2024, 1, 10, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(1990, 4, 22, 0, 0, 0, 0, DateTimeKind.Utc), "user1@stonecarve.com", true, "Ivan", true, false, null, "Babić", false, null, "USER1@STONECARVE.COM", "USER1@STONECARVE.COM", "AQAAAAIAAYagAAAAEGZnl+VVr7AaElVqmqtOKyQp6ZjrpN5Tyb32cpDaxBA8EpTAItk9RTH0B2rCYfXahg==", null, false, null, "1ac35815-21b8-475b-ab79-0411c6d3f5f1", false, "user1@stonecarve.com" },
                    { -203, 0, "049bee3f-a807-4594-9d08-767e8fe19ee6", new DateTime(2024, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), null, "employee3@stonecarve.com", true, "Tomislav", true, false, null, "Blažević", false, null, "EMPLOYEE3@STONECARVE.COM", "EMPLOYEE3@STONECARVE.COM", "AQAAAAIAAYagAAAAEKrMWzsniVb0vocOR1lDsX/+qR4NFZz+sV4o/XUCu6i+bqxI1g1X1lKcfa/OMg3cJw==", null, false, null, "8ae2fd02-0de5-42df-883c-b6999c7e589c", false, "employee3@stonecarve.com" },
                    { -202, 0, "9e834732-ca06-4b2d-9405-fce815cfd2eb", new DateTime(2024, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), null, "employee2@stonecarve.com", true, "Maja", true, false, null, "Horvat", false, null, "EMPLOYEE2@STONECARVE.COM", "EMPLOYEE2@STONECARVE.COM", "AQAAAAIAAYagAAAAEBUGuz7Vdk7nvYNVKRoJA9rc5Ao+nv7M53ILNtaxgoYLxml/p7UyGT7+gEzLmq/cTw==", null, false, null, "127bb299-6177-44cf-a086-b14209746331", false, "employee2@stonecarve.com" },
                    { -201, 0, "d3657181-0ec7-42a5-a73b-b6caec0e22b0", new DateTime(2024, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), null, "employee1@stonecarve.com", true, "Luka", true, false, null, "Jurić", false, null, "EMPLOYEE1@STONECARVE.COM", "EMPLOYEE1@STONECARVE.COM", "AQAAAAIAAYagAAAAEH5yYJQ5/Gw+cA20qqcSrmzA5g7pxZkOxtxtQirZdzMlw+RdJUdHndmR+7Uyj53fFQ==", null, false, null, "783dc09a-3a86-4386-b972-b43d7e884ff9", false, "employee1@stonecarve.com" },
                    { -103, 0, "ed8fe91e-744b-479a-b38e-e79d693857e6", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, "admin3@stonecarve.com", true, "Sara", true, false, null, "Novak", false, null, "ADMIN3@STONECARVE.COM", "ADMIN3@STONECARVE.COM", "AQAAAAIAAYagAAAAEA+/tDSD/KnWGZGt/F+qSMVcjscwtke8okMOIhDOQ3/I5kzx1Rn38gKY8ua1xrMylQ==", null, false, null, "3212350d-92fc-4131-8cf6-6cbedaa54f3e", false, "admin3@stonecarve.com" },
                    { -102, 0, "bd6fec5e-5477-4b74-8f18-1afaf3dc4430", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, "admin2@stonecarve.com", true, "Marko", true, false, null, "Petrić", false, null, "ADMIN2@STONECARVE.COM", "ADMIN2@STONECARVE.COM", "AQAAAAIAAYagAAAAEDqIUCCeKxRDZVWy3Sk5qPjhByKrxzvgnTQnjZ8ZtGC/KPsYbfa0CPxzi1w4WTCxSA==", null, false, null, "d7eced62-9304-457e-ad56-c8a7da2d2215", false, "admin2@stonecarve.com" },
                    { -101, 0, "ba84cbf2-b725-400f-8b47-00ae6dac8b6a", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), null, "admin1@stonecarve.com", true, "Ana", true, false, null, "Kovač", false, null, "ADMIN1@STONECARVE.COM", "ADMIN1@STONECARVE.COM", "AQAAAAIAAYagAAAAEMIMrCxbVt6YnOl7m2zqVYTCRQSiplRaAx2nl/70bEYQxamRs+IcLU1opq+eYpRVwg==", null, false, null, "553d667f-b9c0-4401-8ea9-df43b4a0882f", false, "admin1@stonecarve.com" },
                    { 1000000, 0, "dfa48b45-c825-4c7d-a67b-0d4f33f9b9ab", new DateTime(2026, 3, 3, 1, 33, 3, 80, DateTimeKind.Utc).AddTicks(402), null, "admin@edu.fit.ba", true, "Admin", true, false, null, "Admin", false, null, "ADMIN@EDU.FIT.BA", "ADMIN@EDU.FIT.BA", "AQAAAAIAAYagAAAAEL0+rUkkpEE8h8+RNL4QVRgptoRr8wqL6YIM2u/0IJwsfbjgxExmdEJk1vh+uLZKHQ==", null, false, null, "23057e6e-09f5-4439-8d23-da93f4959ea9", false, "admin@edu.fit.ba" }
                });

            migrationBuilder.InsertData(
                table: "BlogCategories",
                columns: new[] { "Id", "CreatedAt", "IsActive", "Name", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 28, 18, 34, 48, 0, DateTimeKind.Utc), true, "History", null },
                    { 2, new DateTime(2026, 1, 28, 18, 35, 19, 0, DateTimeKind.Utc), true, "Materials", null },
                    { 3, new DateTime(2026, 1, 28, 18, 37, 1, 0, DateTimeKind.Utc), true, "Techniques", null },
                    { 5, new DateTime(2026, 1, 28, 18, 37, 17, 0, DateTimeKind.Utc), true, "Intermediates", null },
                    { 6, new DateTime(2026, 1, 28, 18, 37, 24, 0, DateTimeKind.Utc), true, "Advanced", null }
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "CreatedAt", "Description", "ImageUrl", "IsActive", "Name", "ParentCategoryId", "UpdatedAt" },
                values: new object[,]
                {
                    { 2, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Outdoor stone decorations for gardens and parks", "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/33b6aa98-6812-47f0-a6a5-4a1753ef5470.jpg", true, "Garden Decorations", null, null },
                    { 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Decorative stone water fountains", "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/360eb5b6-e82a-4a94-a40e-f8ddbec1120a.jpg", true, "Fountains", null, null },
                    { 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Columns, arches, balustrades and other architectural pieces", "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/c0d4d177-d2cf-4ae2-88b2-a7a5b42e9670.jpg", true, "Architectural Elements", null, null },
                    { 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Decorative relief carved elements", "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/d3e561a3-e4a8-4a58-b724-44147ecfe9d7.jpg", true, "Relief Carvings", null, null }
                });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 1, "Browse our Custom Carvings catalogue and tap 'Request Custom Order'. Describe your idea, upload any reference images or sketches, and submit. One of our craftsmen will contact you within 24 hours to discuss details, provide a quote, and agree on a timeline. No payment is required until you approve the final design.", "Ordering", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "How do I place a custom order?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "DisplayOrder", "IsActive", "Question", "UpdatedAt" },
                values: new object[,]
                {
                    { 2, "Modifications can be accommodated if the order is still in 'Pending' status. Once carving has begun ('Processing' status), structural changes are no longer possible, though minor adjustments to finish or engraving may still be feasible. Contact us immediately through the app's order detail screen and we will do our best to help.", "Ordering", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, true, "Can I modify an order after it has been placed?", null },
                    { 3, "Production times vary by product. Simple pieces such as text engravings or small bird baths take 5–10 days. Medium-complexity items like wall fountains or garden benches take 10–15 days. Large architectural elements and custom commissions typically require 3–6 weeks. Estimated completion dates are displayed on each product page and confirmed in your order confirmation.", "Ordering", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, true, "How long does production take?", null }
                });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 4, "We accept credit and debit cards via Stripe (Visa, Mastercard, Amex), bank transfers, and cash on collection. All card payments are processed securely through Stripe and we never store your card details. For large custom orders over €2,000 we require a 30% deposit at the time of order confirmation.", "Payments", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "What payment methods do you accept?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "DisplayOrder", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 5, "Yes. All card transactions are processed by Stripe, a PCI-DSS Level 1 certified payment provider. We never see or store your full card number. Payments in the app are protected by TLS encryption.", "Payments", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, true, "Is my payment information secure?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 6, "Yes. We deliver within a 150 km radius of our workshop. Delivery fees are calculated at checkout based on distance and the weight of your order. For very large or fragile pieces, delivery is carried out by our own team using a padded van — we do not use third-party couriers for stone items. Collection from our workshop is always free.", "Delivery", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Do you offer delivery?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "DisplayOrder", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 7, "All stone pieces are wrapped in thick moving blankets and secured with ratchet straps on a custom-built wooden pallet or in a reinforced crate for fragile items. We take full responsibility for the piece until it is safely in your hands. On delivery, please inspect the item in the presence of our driver and note any damage on the delivery receipt before signing.", "Delivery", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, true, "How is my piece packaged for delivery?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 8, "We recommend an annual clean with warm water and a soft brush, followed by the application of a breathable silicone-based stone sealer. Avoid acidic cleaners (vinegar, bleach), pressure washing at close range, and salt-based de-icers near the piece in winter. For water features, drain and disconnect pumps before the first frost each autumn.", "Materials", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "How do I care for my outdoor stone sculpture?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "DisplayOrder", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 9, "Black granite is the most durable choice for all-weather outdoor installation, being frost-resistant and virtually impervious to staining. Limestone and travertine are popular for gardens and age beautifully, but require periodic sealing. White marble is best kept indoors or in sheltered outdoor settings, as it is more susceptible to acid rain and surface etching over time.", "Materials", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 1, true, "Which stone is best for outdoor use?", null });

            migrationBuilder.InsertData(
                table: "Faqs",
                columns: new[] { "Id", "Answer", "Category", "CreatedAt", "IsActive", "Question", "UpdatedAt" },
                values: new object[] { 10, "Stock items in undamaged condition may be returned within 14 days of delivery for a full refund, minus the delivery cost. Because custom-made pieces are produced to your unique specifications, they are non-refundable unless they arrive damaged or significantly differ from the agreed design. If your item arrives damaged, please photograph it immediately and contact us within 48 hours — we will arrange a replacement or refund as appropriate.", "Returns", new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "What is your returns and refunds policy?", null });

            migrationBuilder.InsertData(
                table: "Materials",
                columns: new[] { "Id", "CreatedAt", "Description", "ImageUrl", "IsActive", "IsAvailable", "Name", "PricePerUnit", "QuantityInStock", "Unit", "UpdatedAt" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Premium quality white marble, perfect for detailed sculptures", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/f94d05e3-8fe7-49cc-a683-2d1d43fc2540.jpg", true, true, "White Marble", 180.00m, 50, "m²", null },
                    { 2, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Durable black granite with polished finish", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/c6c6aa69-848f-4dfd-983b-1ed1a76f8084.jpg", true, true, "Black Granite", 220.00m, 35, "m²", null },
                    { 3, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Natural beige limestone, ideal for outdoor projects", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/aaa1fa10-a93d-4616-bbcc-7b11e69852d5.jpg", true, true, "Limestone", 120.00m, 80, "m²", null },
                    { 4, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Warm-toned sandstone with unique texture", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/a3b7406c-3c2c-46ec-ac3f-563242c0b66b.jpg", true, true, "Sandstone", 95.00m, 60, "m²", null },
                    { 5, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Classic cream-colored travertine stone", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/af8d25c3-e8df-4026-85db-55fc29536634.jpg", true, true, "Travertine", 150.00m, 40, "m²", null },
                    { 6, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Rare translucent onyx for luxury projects", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/f3e0fb4d-e655-4a6e-a95d-c5de0f0e6f4c.jpg", true, true, "Onyx", 350.00m, 10, "m²", null },
                    { 8, new DateTime(2026, 2, 28, 21, 53, 34, 0, DateTimeKind.Utc), "Blue limestone sourced from Herzegovina", "https://stonecarvemanagerstorage.blob.core.windows.net/material-images/10d3a1da-7fd0-4fe5-8fc4-80a09e76efd5.jpg", true, true, "Blue limestone", 33.00m, 100, "pcs", null }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "Id", "CategoryId", "ClientChallenge", "CompletionYear", "CreatedAt", "Description", "Dimensions", "EstimatedDays", "IsInPortfolio", "Location", "MaterialId", "Name", "OurSolution", "PortfolioDescription", "Price", "ProductState", "ProjectDuration", "ProjectOutcome", "TechniquesUsed", "UpdatedAt", "Weight" },
                values: new object[,]
                {
                    { 10, null, null, null, new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Restoring damaged or aged stone work", null, 10, false, null, null, "Restoration", null, null, 750.00m, "service", null, null, null, null, null },
                    { 11, null, null, null, new DateTime(2024, 4, 5, 0, 0, 0, 0, DateTimeKind.Utc), "Creating custom stone pieces from client specifications", null, 30, false, null, null, "Custom Design & Fabrication", null, null, 2500.00m, "service", null, null, null, null, null },
                    { 12, null, null, null, new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Utc), "Installing stone products (countertops, monuments, architectural elements)", null, 5, false, null, null, "Installation", null, null, 250.00m, "service", null, null, null, null, null },
                    { 13, null, null, null, new DateTime(2024, 4, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Design consultation and material selection", null, 1, false, null, null, "Consultation", null, null, 150.00m, "service", null, null, null, null, null },
                    { 14, null, null, null, new DateTime(2024, 4, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Ongoing care and maintenance of stone installations", null, 1, false, null, null, "Maintenance", null, null, 980.00m, "service", null, null, null, null, null },
                    { 23, null, null, null, new DateTime(2026, 3, 2, 16, 8, 21, 0, DateTimeKind.Utc), "The installation I need is to be done well and thers 40 panels to be installed at a tall height.", null, 5, false, null, null, "Installation - 20260302", null, null, 250.00m, "custom_order", null, null, null, null, null }
                });

            migrationBuilder.InsertData(
                table: "AspNetUserRoles",
                columns: new[] { "RoleId", "UserId", "DateAssigned" },
                values: new object[,]
                {
                    { -1, -999, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2666) },
                    { -3, -303, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2674) },
                    { -3, -302, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2673) },
                    { -3, -301, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2673) },
                    { -2, -203, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2672) },
                    { -2, -202, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2671) },
                    { -2, -201, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2670) },
                    { -1, -103, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2670) },
                    { -1, -102, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2669) },
                    { -1, -101, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2668) },
                    { -1, 1000000, new DateTime(2026, 3, 3, 1, 33, 3, 670, DateTimeKind.Utc).AddTicks(2667) }
                });

            migrationBuilder.InsertData(
                table: "BlogPosts",
                columns: new[] { "Id", "AuthorId", "CategoryId", "Content", "CreatedAt", "FeaturedImageUrl", "IsActive", "IsPublished", "IsTutorial", "PublishedAt", "Summary", "Title", "UpdatedAt", "ViewCount" },
                values: new object[,]
                {
                    { 7, -999, 1, "Stone Carving for Beginners: A Complete Introduction to the Craft\n\nStone carving is one of the oldest and most respected art forms in human history. From ancient temples to modern architectural details, carved stone has shaped cultures, cities, and artistic traditions for thousands of years.\n\nIf you're curious about starting stone carving, this guide will help you understand the basics, tools, materials, and mindset needed to begin.\n\nWhy Choose Stone Carving?\n\nStone carving combines craftsmanship, patience, and creativity. Unlike many modern materials, stone is permanent. When you carve into it, you are shaping something that can last centuries.\n\nFor beginners, stone carving offers:\nA deep connection to traditional craftsmanship\nA rewarding, hands-on creative process\nThe ability to create architectural and decorative elements\nA skill that can evolve into professional work", new DateTime(2026, 1, 31, 15, 57, 58, 0, DateTimeKind.Utc), null, true, true, true, new DateTime(2026, 1, 31, 15, 57, 59, 0, DateTimeKind.Utc), "A blog post targeted at people who are looking to start up stone carving.", "Stone carving for beginners", null, 2 },
                    { 8, -999, 1, "Stone Carving: Choosing the Right Stone\n\nChoosing the right stone is one of the most important steps in stone carving, especially for beginners. The type of stone you select will affect not only the carving process, but also the tools required, the level of detail you can achieve, and the final durability of your artwork.\n\nUnderstanding Stone Hardness\n\nStones vary greatly in hardness, and this determines how easy they are to carve. Softer stones are ideal for beginners because they respond well to basic hand tools and allow mistakes to be corrected more easily. Harder stones require more experience, stronger tools, and greater physical effort.\n\nSoapstone is one of the most popular choices for beginners. It is soft, smooth, and easy to shape, making it perfect for learning basic carving techniques. It also comes in various natural colors, adding visual interest to finished pieces.", new DateTime(2026, 2, 1, 17, 8, 15, 0, DateTimeKind.Utc), null, true, true, false, new DateTime(2026, 2, 1, 17, 8, 15, 0, DateTimeKind.Utc), null, "Choosing the right stone", null, 6 },
                    { 12, -999, 1, "Carving a Stone Column: A Step-by-Step Tutorial\n\nStone columns have defined architecture for thousands of years. From classical temples to modern villas, a carved column represents strength, structure, and craftsmanship.\n\nIf you are interested in carving a stone column, this tutorial will guide you through the essential steps, tools, and considerations needed to approach the project properly.\n\nStep 1: Choose the Right Stone\n\nBefore carving begins, selecting the correct material is critical.\n\nFor beginners or intermediate carvers:\nLimestone – easier to carve, consistent texture\nSandstone – workable and durable\nMarble – elegant but slightly harder to shape\n\nAvoid granite unless you have advanced tools and experience.\n\nStep 2: Plan the Column Design\n\nDecide what type of column you are creating and sketch your design with exact measurements.\n\nStep 3: Rough Shaping the Shaft\n\nStart by marking the circular outline on the top and bottom of the stone block. Using a point chisel and mallet, remove excess corners and gradually shape the stone into a rough cylinder.\n\nStep 4: Refining the Shape\n\nSwitch to a tooth chisel to smooth and refine the cylindrical surface. If carving flutes, measure and divide the circumference evenly.\n\nStep 5: Carving the Base and Capital\n\nThe base and capital define the character of the column. Always carve decorative elements after the main structure is balanced.\n\nStep 6: Surface Finishing\n\nUse flat chisels to remove tool marks, smooth with rasps or sanding stones, and apply a finish appropriate to the style.\n\nStep 7: Safety and Structural Considerations\n\nStone columns are heavy. Always work on stable ground, use proper lifting support, and wear eye protection.", new DateTime(2026, 2, 24, 21, 2, 19, 0, DateTimeKind.Utc), null, true, true, true, new DateTime(2026, 2, 25, 19, 8, 47, 0, DateTimeKind.Utc), null, "Carving a stone column", null, 6 }
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "CreatedAt", "Description", "ImageUrl", "IsActive", "Name", "ParentCategoryId", "UpdatedAt" },
                values: new object[] { 7, new DateTime(2026, 2, 20, 0, 38, 29, 0, DateTimeKind.Utc), "Stone Column of all types and designs", "https://stonecarvemanagerstorage.blob.core.windows.net/category-images/06aee848-a7ed-4ced-9a3b-8b7f463afee6.jpg", true, "Stone Columns", 4, null });

            migrationBuilder.InsertData(
                table: "Orders",
                columns: new[] { "Id", "AdminNotes", "AssignedEmployeeId", "AttachmentUrl", "CompletedAt", "CustomerNotes", "DeliveryAddress", "DeliveryCity", "DeliveryCountry", "DeliveryDate", "DeliveryZipCode", "EstimatedCompletionDate", "OrderDate", "OrderNumber", "OrderType", "ServiceProductId", "Status", "TotalAmount", "UserId" },
                values: new object[,]
                {
                    { 1, "Delivered on time. Customer very satisfied.", -201, null, new DateTime(2024, 2, 18, 0, 0, 0, 0, DateTimeKind.Utc), "Please ensure the wall fountains have a smooth, polished finish.", "Splitska 5", "Sarajevo", "Bosnia and Herzegovina", new DateTime(2024, 2, 18, 0, 0, 0, 0, DateTimeKind.Utc), "71000", new DateTime(2024, 2, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 2, 1, 10, 0, 0, 0, DateTimeKind.Utc), "ORD-2024-001", "standard", null, "Delivered", 1840.00m, -301 },
                    { 2, "Collected in person from workshop.", -202, null, new DateTime(2024, 3, 22, 0, 0, 0, 0, DateTimeKind.Utc), "Garden bench for a shaded courtyard. Standard finish is fine.", "Kneza Domagoja 12", "Mostar", "Bosnia and Herzegovina", new DateTime(2024, 3, 22, 0, 0, 0, 0, DateTimeKind.Utc), "88000", new DateTime(2024, 3, 25, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 3, 10, 11, 30, 0, 0, DateTimeKind.Utc), "ORD-2024-002", "standard", null, "Delivered", 750.00m, -302 },
                    { 3, "Delivered by our team with crane assist. Installation guidance provided on-site.", -201, null, new DateTime(2024, 5, 16, 0, 0, 0, 0, DateTimeKind.Utc), "The fountain will be the centrepiece of a new courtyard. Please include the pump and fitting instructions.", "Bulevar Mese Selimovica 44", "Tuzla", "Bosnia and Herzegovina", new DateTime(2024, 5, 16, 0, 0, 0, 0, DateTimeKind.Utc), "75000", new DateTime(2024, 5, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 4, 5, 9, 0, 0, 0, DateTimeKind.Utc), "ORD-2024-003", "standard", null, "Delivered", 2500.00m, -303 },
                    { 4, "Capital carving is underway. Will update client by end of week.", -202, null, null, "Classical Corinthian column for a home library. Pedestal base would be appreciated if feasible.", "Splitska 5", "Sarajevo", "Bosnia and Herzegovina", null, "71000", new DateTime(2025, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 11, 15, 14, 0, 0, 0, DateTimeKind.Utc), "ORD-2024-004", "standard", null, "Processing", 3200.00m, -301 },
                    { 5, null, null, null, null, "Wall fountain for an outdoor terrace. Would prefer the lion head to face left instead of right if possible.", "Kneza Domagoja 12", "Mostar", "Bosnia and Herzegovina", null, "88000", new DateTime(2025, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2025, 1, 20, 16, 45, 0, 0, DateTimeKind.Utc), "ORD-2025-001", "standard", null, "Pending", 980.00m, -302 },
                    { 6, "Panels cut and polished to spec. Delivered without issue.", -203, null, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Both panels are for a new living room feature wall. Please ensure edges are smooth.", "Bulevar Mese Selimovica 44", "Tuzla", "Bosnia and Herzegovina", new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "75000", new DateTime(2026, 1, 22, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 8, 9, 30, 0, 0, DateTimeKind.Utc), "ORD-2026-001", "standard", null, "Delivered", 840.00m, -303 },
                    { 7, "All three sections finished to a consistent honed finish. Delivered and installed.", -201, null, new DateTime(2026, 2, 18, 0, 0, 0, 0, DateTimeKind.Utc), "Three balustrade sections for a garden terrace. Matching finish to existing stonework if possible.", "Splitska 5", "Sarajevo", "Bosnia and Herzegovina", new DateTime(2026, 2, 18, 0, 0, 0, 0, DateTimeKind.Utc), "71000", new DateTime(2026, 2, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 2, 3, 11, 0, 0, 0, DateTimeKind.Utc), "ORD-2026-002", "standard", null, "Delivered", 1260.00m, -301 },
                    { 8, "Relief carving in progress. Background work completed, figures being detailed.", -202, null, null, "High relief panel for an entrance hall. Prefer a matte finish.", "Kneza Domagoja 12", "Mostar", "Bosnia and Herzegovina", null, "88000", new DateTime(2026, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 3, 1, 14, 15, 0, 0, DateTimeKind.Utc), "ORD-2026-003", "standard", null, "Processing", 1850.00m, -302 },
                    { 18, null, null, null, null, "The installation I need is to be done well and thers 40 panels to be installed at a tall height.", "Sjeverni Logor bb", "Mostar", null, new DateTime(2026, 3, 31, 0, 0, 0, 0, DateTimeKind.Utc), "88000", null, new DateTime(2026, 3, 2, 16, 8, 21, 0, DateTimeKind.Utc), "ORD-20260302160821266-B04BAE", "service_request", 10, "Processing", 299.00m, -302 }
                });

            migrationBuilder.InsertData(
                table: "ProductImages",
                columns: new[] { "Id", "AltText", "CreatedAt", "ImageUrl", "IsPrimary", "ProductId" },
                values: new object[,]
                {
                    { 11, null, new DateTime(2024, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/683057e3-d7e4-4bfb-b6cc-f651006e13ec.jpg", true, 10 },
                    { 12, null, new DateTime(2024, 4, 5, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/7f3eed6a-d041-483c-9d7c-075684610fa3.jpg", true, 11 },
                    { 13, null, new DateTime(2024, 4, 10, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/custom-order-sketches/e6aabe20-d282-4933-96a3-d99e35213d3f.jpg", true, 12 },
                    { 14, null, new DateTime(2024, 4, 15, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/custom-order-sketches/ae5ccc89-836b-47b0-96b7-6aef332c4ea9.jpg", true, 13 },
                    { 15, null, new DateTime(2024, 4, 20, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/19267379-7a1e-47fb-a7ce-29931f897ad2.png", true, 14 }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "Id", "CategoryId", "ClientChallenge", "CompletionYear", "CreatedAt", "Description", "Dimensions", "EstimatedDays", "IsInPortfolio", "Location", "MaterialId", "Name", "OurSolution", "PortfolioDescription", "Price", "ProductState", "ProjectDuration", "ProjectOutcome", "StockQuantity", "TechniquesUsed", "UpdatedAt", "Weight" },
                values: new object[,]
                {
                    { 1, 2, null, null, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Beautiful hand-carved small crest in white marble, perfect for garden decoration", "30cm x 40cm x 2cm", 14, true, null, 1, "Small Crest", null, null, 1250.00m, "active", null, null, 4, null, null, 85.5m },
                    { 2, 2, null, null, new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Elegant curved stone bench for gardens and parks", "180cm x 60cm x 45cm", 10, false, null, 2, "Garden Bench", null, null, 750.00m, "active", null, null, 5, null, null, 200.0m },
                    { 3, 3, null, null, new DateTime(2024, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), "Three-tier decorative water fountain in travertine", "150cm diameter x 200cm height", 30, true, null, 5, "Tiered Fountain", null, null, 2500.00m, "active", null, null, 1, null, null, 350.0m },
                    { 4, 3, "The client needed two matching fountain units that would complement an existing marble feature wall without overpowering it. Smooth, polished surfaces were specified to match the surrounding stonework.", 2024, new DateTime(2024, 2, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Elegant wall-mounted fountain with lion head design", "60cm x 40cm x 30cm", 12, true, "Sarajevo, Bosnia and Herzegovina", 1, "Wall Fountain", "Both fountains were carved from the same block of white Carrara marble to ensure an exact colour and grain match. Surfaces were hand-polished to a mirror finish and fitted with concealed pump housings.", "Two wall-mounted lion-head fountains commissioned as a matched pair for a private garden in Sarajevo. The pieces were designed to flank an outdoor seating area and integrate with existing white marble stonework.", 980.00m, "portfolio", 17, "Delivered on schedule and installed in a single day. The client noted the fountains exceeded expectations and reported strong positive feedback from guests.", 4, "Hand-carving, matched-block selection, mirror-polish finishing, concealed pump fitting", null, 55.0m },
                    { 5, 4, "The client needed balustrade sections that matched the tone and texture of existing stone already laid on the terrace. Standard off-the-shelf options were either the wrong material or finish.", 2026, new DateTime(2024, 2, 25, 0, 0, 0, 0, DateTimeKind.Utc), "Decorative balustrade section (per meter)", "100cm x 15cm x 80cm", 8, true, "Sarajevo, Bosnia and Herzegovina", 3, "Stone Balustrade", "We sourced matching limestone from the same quarry region as the existing stone and applied a consistent honed finish across all three sections, ensuring visual continuity.", "Three limestone balustrade sections crafted for a garden terrace in Sarajevo, designed to complement the client's existing honed stonework and provide a classical border to a raised planting area.", 420.00m, "portfolio", 15, "All three sections were delivered and installed in a single visit. The finish match was exact and the client confirmed the new sections are indistinguishable from the original stonework.", 20, "Limestone cutting, honed surface finishing, precision jointing", null, 65.0m },
                    { 6, 4, "The client required a statement piece for a double-height entrance hall — something that conveyed craftsmanship and permanence. The design had to be original, not adapted from a template.", 2026, new DateTime(2024, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Majestic high relief carved from limestone", "90cm x 70cm x 50cm", 21, true, "Mostar, Bosnia and Herzegovina", 3, "High Relief Panel", "Our master carver produced an original design sketch in consultation with the client, then executed the full relief in three stages: background removal, mid-ground roughing, and final figure detailing with a matte finish.", "A high relief limestone panel commissioned for the entrance hall of a private villa in Mostar. The design draws on classical Baroque motifs with a custom figurative centrepiece requested by the client.", 1850.00m, "portfolio", 31, "The panel was installed as the focal wall of the entrance hall and received significant attention during a subsequent architectural feature on the property.", 2, "High relief carving, figure sculpting, matte surface finishing, limestone work", null, 120.0m },
                    { 8, 5, null, null, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Hand-carved geometric relief panel ideal for interior decoration", "30x30x2.5 cm", 7, true, null, 1, "Geometric Wall Panel", null, null, 400.00m, "active", null, null, 15, null, null, 3500.0m },
                    { 9, 5, null, null, new DateTime(2024, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), "Decorative floral bas-relief panel suitable for villas and gardens", "40x30x3 cm", 6, true, null, 1, "Floral Stone Relief Panel", null, null, 440.00m, "active", null, null, 10, null, null, 5500.0m }
                });

            migrationBuilder.InsertData(
                table: "BlogImages",
                columns: new[] { "Id", "AltText", "BlogPostId", "DisplayOrder", "ImageUrl", "UploadedAt" },
                values: new object[,]
                {
                    { 2, null, 7, 0, "https://stonecarvemanagerstorage.blob.core.windows.net/blog-images/351171f7-410a-4bb6-a18d-fe48d35bed0e.png", new DateTime(2026, 1, 31, 15, 58, 30, 0, DateTimeKind.Utc) },
                    { 3, null, 8, 0, "https://stonecarvemanagerstorage.blob.core.windows.net/blog-images/1690b32e-4b56-43bd-bd24-c0a43dbab965.jpg", new DateTime(2026, 2, 1, 17, 10, 41, 0, DateTimeKind.Utc) },
                    { 5, null, 12, 0, "https://stonecarvemanagerstorage.blob.core.windows.net/blog-images/4443b185-0b08-43b6-97f5-6e2843e369a8.jpg", new DateTime(2026, 2, 24, 21, 3, 6, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.InsertData(
                table: "FavoriteProducts",
                columns: new[] { "Id", "AddedAt", "ProductId", "UserId" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 10, 5, 9, 0, 0, 0, DateTimeKind.Utc), 3, -301 },
                    { 3, new DateTime(2024, 11, 3, 14, 0, 0, 0, DateTimeKind.Utc), 1, -302 },
                    { 4, new DateTime(2024, 12, 10, 16, 0, 0, 0, DateTimeKind.Utc), 4, -302 },
                    { 5, new DateTime(2024, 11, 18, 10, 0, 0, 0, DateTimeKind.Utc), 2, -303 },
                    { 6, new DateTime(2025, 1, 8, 9, 30, 0, 0, DateTimeKind.Utc), 5, -303 }
                });

            migrationBuilder.InsertData(
                table: "OrderItems",
                columns: new[] { "Id", "OrderId", "ProductId", "Quantity", "UnitPrice" },
                values: new object[,]
                {
                    { 1, 1, 1, 1, 1200.00m },
                    { 2, 1, 4, 2, 320.00m },
                    { 3, 2, 2, 1, 750.00m },
                    { 4, 3, 3, 1, 2500.00m },
                    { 6, 5, 4, 1, 980.00m },
                    { 7, 6, 8, 1, 400.00m },
                    { 8, 6, 9, 1, 440.00m },
                    { 9, 7, 5, 3, 420.00m },
                    { 10, 8, 6, 1, 1850.00m },
                    { 11, 18, 10, 1, 299.00m }
                });

            migrationBuilder.InsertData(
                table: "OrderProgressImages",
                columns: new[] { "Id", "Description", "ImageUrl", "OrderId", "UploadedAt", "UploadedByUserId" },
                values: new object[,]
                {
                    { 1, "Lower basin rough-cut complete. Acanthus leaf border work has started.", "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/18eb1959-f371-4f85-9926-33029d09b8b3.jpg", 3, new DateTime(2024, 4, 20, 12, 0, 0, 0, DateTimeKind.Utc), -201 },
                    { 2, "All three tiers carved and polished. Ready for final assembly check.", "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/788f94ff-e47d-4a8b-99c8-26abcc9fbb29.jpg", 3, new DateTime(2024, 5, 10, 10, 0, 0, 0, DateTimeKind.Utc), -201 },
                    { 3, "Column shaft turned and fluted. Capital carving begins next week.", "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/67443ec5-1508-42e7-b88e-3f203f16a8fb.jpg", 4, new DateTime(2024, 12, 5, 11, 0, 0, 0, DateTimeKind.Utc), -202 },
                    { 4, "Panel outline and major forms blocked in. Detailing in progress.", "https://stonecarvemanagerstorage.blob.core.windows.net/order-progress/4a9567a3-80a1-4f14-94a2-37c6c9017f15.jpg", 8, new DateTime(2026, 3, 15, 10, 30, 0, 0, DateTimeKind.Utc), -202 }
                });

            migrationBuilder.InsertData(
                table: "OrderStatusHistories",
                columns: new[] { "Id", "ChangedAt", "ChangedByUserId", "Comment", "NewStatus", "OldStatus", "OrderId" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 2, 3, 8, 0, 0, 0, DateTimeKind.Utc), -201, "Order confirmed and carving has started.", "Processing", "Pending", 1 },
                    { 2, new DateTime(2024, 2, 16, 7, 0, 0, 0, DateTimeKind.Utc), -201, "Pieces are finished and loaded for delivery.", "Shipped", "Processing", 1 },
                    { 3, new DateTime(2024, 2, 18, 14, 0, 0, 0, DateTimeKind.Utc), -201, "Delivered to customer. Signed receipt obtained.", "Delivered", "Shipped", 1 },
                    { 4, new DateTime(2024, 3, 12, 9, 0, 0, 0, DateTimeKind.Utc), -202, "Order accepted. Bench fabrication underway.", "Processing", "Pending", 2 },
                    { 5, new DateTime(2024, 3, 22, 11, 0, 0, 0, DateTimeKind.Utc), -202, "Customer collected from workshop in person.", "Delivered", "Processing", 2 },
                    { 6, new DateTime(2024, 4, 8, 8, 0, 0, 0, DateTimeKind.Utc), -201, "Fountain blocks received from quarry. Carving has begun.", "Processing", "Pending", 3 },
                    { 7, new DateTime(2024, 5, 14, 7, 30, 0, 0, DateTimeKind.Utc), -201, "All three tiers complete and loaded on delivery van.", "Shipped", "Processing", 3 },
                    { 8, new DateTime(2024, 5, 16, 15, 0, 0, 0, DateTimeKind.Utc), -201, "Fountain delivered and placed in courtyard. Installation guidance given.", "Delivered", "Shipped", 3 },
                    { 9, new DateTime(2024, 11, 18, 8, 0, 0, 0, DateTimeKind.Utc), -202, "Marble block sourced. Column shaft roughing in progress.", "Processing", "Pending", 4 },
                    { 10, new DateTime(2026, 1, 9, 8, 0, 0, 0, DateTimeKind.Utc), -203, "Payment confirmed. Panel cutting has started.", "Processing", "Pending", 6 },
                    { 11, new DateTime(2026, 1, 18, 9, 0, 0, 0, DateTimeKind.Utc), -203, "Both panels packed and dispatched.", "Shipped", "Processing", 6 },
                    { 12, new DateTime(2026, 1, 20, 13, 0, 0, 0, DateTimeKind.Utc), -203, "Delivered and signed for by customer.", "Delivered", "Shipped", 6 },
                    { 13, new DateTime(2026, 2, 4, 8, 30, 0, 0, DateTimeKind.Utc), -201, "Payment confirmed. Balustrade sections being cut from limestone stock.", "Processing", "Pending", 7 },
                    { 14, new DateTime(2026, 2, 16, 7, 0, 0, 0, DateTimeKind.Utc), -201, "All three sections complete. Loaded for delivery.", "Shipped", "Processing", 7 },
                    { 15, new DateTime(2026, 2, 18, 14, 30, 0, 0, DateTimeKind.Utc), -201, "Delivered to terrace site. Customer confirmed receipt.", "Delivered", "Shipped", 7 },
                    { 16, new DateTime(2026, 3, 3, 9, 0, 0, 0, DateTimeKind.Utc), -202, "Payment confirmed. Limestone block sourced, carving underway.", "Processing", "Pending", 8 },
                    { 17, new DateTime(2026, 3, 2, 16, 30, 0, 0, DateTimeKind.Utc), -201, "Payment confirmed. Installation service request accepted.", "Processing", "Pending", 18 }
                });

            migrationBuilder.InsertData(
                table: "Payments",
                columns: new[] { "Id", "Amount", "CompletedAt", "CreatedAt", "FailureReason", "Method", "OrderId", "RefundAmount", "RefundReason", "RefundedAt", "Status", "StripePaymentIntentId", "TransactionId" },
                values: new object[,]
                {
                    { 1, 1840.00m, new DateTime(2024, 2, 1, 10, 6, 0, 0, DateTimeKind.Utc), new DateTime(2024, 2, 1, 10, 5, 0, 0, DateTimeKind.Utc), null, "stripe", 1, null, null, null, "succeeded", "pi_seed_001_ORD2024001", "txn_seed_001" },
                    { 2, 750.00m, new DateTime(2024, 3, 22, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2024, 3, 22, 11, 0, 0, 0, DateTimeKind.Utc), null, "cash", 2, null, null, null, "succeeded", null, null },
                    { 3, 2500.00m, new DateTime(2024, 4, 5, 9, 6, 0, 0, DateTimeKind.Utc), new DateTime(2024, 4, 5, 9, 5, 0, 0, DateTimeKind.Utc), null, "stripe", 3, null, null, null, "succeeded", "pi_seed_003_ORD2024003", "txn_seed_003" },
                    { 4, 3200.00m, new DateTime(2024, 11, 15, 14, 6, 0, 0, DateTimeKind.Utc), new DateTime(2024, 11, 15, 14, 5, 0, 0, DateTimeKind.Utc), null, "stripe", 4, null, null, null, "succeeded", "pi_seed_004_ORD2024004", "txn_seed_004" },
                    { 5, 840.00m, new DateTime(2026, 1, 8, 9, 36, 0, 0, DateTimeKind.Utc), new DateTime(2026, 1, 8, 9, 35, 0, 0, DateTimeKind.Utc), null, "stripe", 6, null, null, null, "succeeded", "pi_seed_006_ORD2026001", "txn_seed_006" },
                    { 6, 1260.00m, new DateTime(2026, 2, 3, 11, 6, 0, 0, DateTimeKind.Utc), new DateTime(2026, 2, 3, 11, 5, 0, 0, DateTimeKind.Utc), null, "stripe", 7, null, null, null, "succeeded", "pi_seed_007_ORD2026002", "txn_seed_007" },
                    { 7, 1850.00m, new DateTime(2026, 3, 1, 14, 21, 0, 0, DateTimeKind.Utc), new DateTime(2026, 3, 1, 14, 20, 0, 0, DateTimeKind.Utc), null, "stripe", 8, null, null, null, "succeeded", "pi_seed_008_ORD2026003", "txn_seed_008" },
                    { 8, 299.00m, new DateTime(2026, 3, 2, 16, 8, 26, 0, DateTimeKind.Utc), new DateTime(2026, 3, 2, 16, 8, 25, 0, DateTimeKind.Utc), null, "stripe", 18, null, null, null, "succeeded", "pi_seed_018_ORD20260302B04BAE", "txn_seed_018" }
                });

            migrationBuilder.InsertData(
                table: "ProductImages",
                columns: new[] { "Id", "AltText", "CreatedAt", "ImageUrl", "IsPrimary", "ProductId" },
                values: new object[] { 1, null, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/af11f526-260b-456c-8afa-1d9fbf5f8e54.JPG", true, 1 });

            migrationBuilder.InsertData(
                table: "ProductImages",
                columns: new[] { "Id", "AltText", "CreatedAt", "DisplayOrder", "ImageUrl", "IsPrimary", "ProductId" },
                values: new object[] { 2, null, new DateTime(2024, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), 1, "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/ebc2f104-f7e7-4a08-92e5-8aada25e0e08.JPG", false, 1 });

            migrationBuilder.InsertData(
                table: "ProductImages",
                columns: new[] { "Id", "AltText", "CreatedAt", "ImageUrl", "IsPrimary", "ProductId" },
                values: new object[,]
                {
                    { 3, null, new DateTime(2024, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/660a5aaa-2f46-44fa-bd0b-b97f770a9353.webp", true, 2 },
                    { 4, null, new DateTime(2024, 2, 10, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/87629a89-0417-4661-bc00-c4985d0e200e.jpg", true, 3 },
                    { 5, null, new DateTime(2024, 2, 15, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/f73a90f2-ab76-495c-aa6b-3d68a3555bab.jpg", true, 4 },
                    { 6, null, new DateTime(2024, 2, 25, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/19267379-7a1e-47fb-a7ce-29931f897ad2.png", true, 5 },
                    { 7, null, new DateTime(2024, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/2b641699-ad41-4c22-8ed3-bd7c4008146c.webp", true, 6 },
                    { 9, null, new DateTime(2024, 3, 1, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/12c27cff-40da-4702-938f-e97100cc259f.JPG", true, 8 },
                    { 10, null, new DateTime(2024, 3, 5, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/4f0a0d8b-5ae3-4981-9b3d-0a6e06300925.jpg", true, 9 }
                });

            migrationBuilder.InsertData(
                table: "ProductReviews",
                columns: new[] { "Id", "Comment", "CreatedAt", "IsApproved", "OrderId", "ProductId", "Rating", "UpdatedAt", "UserId" },
                values: new object[,]
                {
                    { 1, "Absolutely stunning piece. The level of detail in the carving is remarkable — you can see every chisel mark was deliberate. Arrived well-packed with no damage. Will definitely order again.", new DateTime(2024, 2, 20, 10, 0, 0, 0, DateTimeKind.Utc), true, 1, 1, 5, null, -301 },
                    { 3, "The bench is everything I hoped for. The black granite is imposing and elegant, and the carved details add a classical touch that perfectly complements our courtyard. Solid, heavy, and built to last generations.", new DateTime(2024, 3, 28, 9, 0, 0, 0, DateTimeKind.Utc), true, 2, 2, 5, null, -302 },
                    { 4, "This fountain is a true work of art. The travertine has a natural, rustic quality that photographs beautifully. The team delivered it personally, helped position it, and even walked us through the pump setup. Exceptional service from start to finish.", new DateTime(2024, 5, 22, 14, 0, 0, 0, DateTimeKind.Utc), true, 3, 3, 5, null, -303 }
                });

            migrationBuilder.InsertData(
                table: "Products",
                columns: new[] { "Id", "CategoryId", "ClientChallenge", "CompletionYear", "CreatedAt", "Description", "Dimensions", "EstimatedDays", "IsInPortfolio", "Location", "MaterialId", "Name", "OurSolution", "PortfolioDescription", "Price", "ProductState", "ProjectDuration", "ProjectOutcome", "StockQuantity", "TechniquesUsed", "UpdatedAt", "Weight" },
                values: new object[] { 7, 7, null, null, new DateTime(2024, 2, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Classical Corinthian column in white marble", "250cm height x 40cm diameter", 25, true, null, 1, "Stone Column", null, null, 3200.00m, "active", null, null, 6, null, null, 280.0m });

            migrationBuilder.InsertData(
                table: "FavoriteProducts",
                columns: new[] { "Id", "AddedAt", "ProductId", "UserId" },
                values: new object[] { 2, new DateTime(2024, 10, 20, 11, 0, 0, 0, DateTimeKind.Utc), 7, -301 });

            migrationBuilder.InsertData(
                table: "OrderItems",
                columns: new[] { "Id", "OrderId", "ProductId", "Quantity", "UnitPrice" },
                values: new object[] { 5, 4, 7, 1, 3200.00m });

            migrationBuilder.InsertData(
                table: "ProductImages",
                columns: new[] { "Id", "AltText", "CreatedAt", "ImageUrl", "IsPrimary", "ProductId" },
                values: new object[] { 8, null, new DateTime(2024, 2, 20, 0, 0, 0, 0, DateTimeKind.Utc), "https://stonecarvemanagerstorage.blob.core.windows.net/product-images/3586d760-5536-4a8d-b94c-86e76e5eaa1d.jpg", true, 7 });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoleClaims_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoles_IsActive",
                table: "AspNetRoles",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetRoles_Name",
                table: "AspNetRoles",
                column: "Name",
                unique: true,
                filter: "[Name] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "RoleNameIndex",
                table: "AspNetRoles",
                column: "NormalizedName",
                unique: true,
                filter: "[NormalizedName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserClaims_UserId",
                table: "AspNetUserClaims",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserLogins_UserId",
                table: "AspNetUserLogins",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_DateAssigned",
                table: "AspNetUserRoles",
                column: "DateAssigned");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUserRoles_UserId",
                table: "AspNetUserRoles",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "EmailIndex",
                table: "AspNetUsers",
                column: "NormalizedEmail");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_CreatedAt",
                table: "AspNetUsers",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_Email",
                table: "AspNetUsers",
                column: "Email",
                unique: true,
                filter: "[Email] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_IsActive",
                table: "AspNetUsers",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "UserNameIndex",
                table: "AspNetUsers",
                column: "NormalizedUserName",
                unique: true,
                filter: "[NormalizedUserName] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_BlogImages_BlogPostId",
                table: "BlogImages",
                column: "BlogPostId");

            migrationBuilder.CreateIndex(
                name: "IX_BlogPosts_AuthorId",
                table: "BlogPosts",
                column: "AuthorId");

            migrationBuilder.CreateIndex(
                name: "IX_BlogPosts_CategoryId",
                table: "BlogPosts",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_BlogPosts_CreatedAt",
                table: "BlogPosts",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_BlogPosts_IsPublished",
                table: "BlogPosts",
                column: "IsPublished");

            migrationBuilder.CreateIndex(
                name: "IX_BlogPosts_IsTutorial",
                table: "BlogPosts",
                column: "IsTutorial");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_CartId",
                table: "CartItems",
                column: "CartId");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_CartId_ProductId",
                table: "CartItems",
                columns: new[] { "CartId", "ProductId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_ProductId",
                table: "CartItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Carts_UserId",
                table: "Carts",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Categories_IsActive",
                table: "Categories",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_Categories_Name",
                table: "Categories",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Categories_ParentCategoryId",
                table: "Categories",
                column: "ParentCategoryId");

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

            migrationBuilder.CreateIndex(
                name: "IX_FavoriteProducts_ProductId",
                table: "FavoriteProducts",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_FavoriteProducts_UserId",
                table: "FavoriteProducts",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_FavoriteProducts_UserId_ProductId",
                table: "FavoriteProducts",
                columns: new[] { "UserId", "ProductId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Materials_IsActive",
                table: "Materials",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_Materials_IsAvailable",
                table: "Materials",
                column: "IsAvailable");

            migrationBuilder.CreateIndex(
                name: "IX_Materials_Name",
                table: "Materials",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_OrderId",
                table: "OrderItems",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_ProductId",
                table: "OrderItems",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderProgressImages_OrderId",
                table: "OrderProgressImages",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderProgressImages_UploadedByUserId",
                table: "OrderProgressImages",
                column: "UploadedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_AssignedEmployeeId",
                table: "Orders",
                column: "AssignedEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_OrderDate",
                table: "Orders",
                column: "OrderDate");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_OrderNumber",
                table: "Orders",
                column: "OrderNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Orders_ServiceProductId",
                table: "Orders",
                column: "ServiceProductId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_Status",
                table: "Orders",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_UserId",
                table: "Orders",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderStatusHistories_ChangedAt",
                table: "OrderStatusHistories",
                column: "ChangedAt");

            migrationBuilder.CreateIndex(
                name: "IX_OrderStatusHistories_ChangedByUserId",
                table: "OrderStatusHistories",
                column: "ChangedByUserId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderStatusHistories_OrderId",
                table: "OrderStatusHistories",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_CreatedAt",
                table: "Payments",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_OrderId",
                table: "Payments",
                column: "OrderId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Payments_Status",
                table: "Payments",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Payments_TransactionId",
                table: "Payments",
                column: "TransactionId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductImages_DisplayOrder",
                table: "ProductImages",
                column: "DisplayOrder");

            migrationBuilder.CreateIndex(
                name: "IX_ProductImages_IsPrimary",
                table: "ProductImages",
                column: "IsPrimary");

            migrationBuilder.CreateIndex(
                name: "IX_ProductImages_ProductId",
                table: "ProductImages",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductReviews_CreatedAt",
                table: "ProductReviews",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_ProductReviews_IsApproved",
                table: "ProductReviews",
                column: "IsApproved");

            migrationBuilder.CreateIndex(
                name: "IX_ProductReviews_OrderId",
                table: "ProductReviews",
                column: "OrderId",
                unique: true,
                filter: "[OrderId] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_ProductReviews_ProductId",
                table: "ProductReviews",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductReviews_Rating",
                table: "ProductReviews",
                column: "Rating");

            migrationBuilder.CreateIndex(
                name: "IX_ProductReviews_UserId",
                table: "ProductReviews",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_CategoryId",
                table: "Products",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_CreatedAt",
                table: "Products",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_Products_MaterialId",
                table: "Products",
                column: "MaterialId");

            migrationBuilder.CreateIndex(
                name: "IX_Products_Name",
                table: "Products",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_Products_Price",
                table: "Products",
                column: "Price");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AspNetRoleClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserClaims");

            migrationBuilder.DropTable(
                name: "AspNetUserLogins");

            migrationBuilder.DropTable(
                name: "AspNetUserRoles");

            migrationBuilder.DropTable(
                name: "AspNetUserTokens");

            migrationBuilder.DropTable(
                name: "BlogImages");

            migrationBuilder.DropTable(
                name: "CartItems");

            migrationBuilder.DropTable(
                name: "Faqs");

            migrationBuilder.DropTable(
                name: "FavoriteProducts");

            migrationBuilder.DropTable(
                name: "OrderItems");

            migrationBuilder.DropTable(
                name: "OrderProgressImages");

            migrationBuilder.DropTable(
                name: "OrderStatusHistories");

            migrationBuilder.DropTable(
                name: "Payments");

            migrationBuilder.DropTable(
                name: "ProductImages");

            migrationBuilder.DropTable(
                name: "ProductReviews");

            migrationBuilder.DropTable(
                name: "AspNetRoles");

            migrationBuilder.DropTable(
                name: "BlogPosts");

            migrationBuilder.DropTable(
                name: "Carts");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "BlogCategories");

            migrationBuilder.DropTable(
                name: "AspNetUsers");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.DropTable(
                name: "Materials");
        }
    }
}
