using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace StoneCarveManager.Services.Database.Migrations
{
    /// <inheritdoc />
    public partial class UpdateProductStatesToNewSystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Ažuriraj sve proizvode sa "available" u "active"
            migrationBuilder.Sql(@"
                UPDATE Products 
                SET ProductState = 'active' 
                WHERE ProductState = 'available' AND IsActive = 1
            ");

            // Proizvodi koji nisu aktivni postaju "hidden"
            migrationBuilder.Sql(@"
                UPDATE Products 
                SET ProductState = 'hidden' 
                WHERE IsActive = 0
            ");

            // Proizvodi koji su samo u portfoliju (ne prodaju se)
            migrationBuilder.Sql(@"
                UPDATE Products 
                SET ProductState = 'portfolio' 
                WHERE IsInPortfolio = 1 
                  AND StockQuantity = 0
                  AND ProductState NOT IN ('service', 'hidden')
            ");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Vrati nazad na "available"
            migrationBuilder.Sql(@"
                UPDATE Products 
                SET ProductState = 'available' 
                WHERE ProductState IN ('active', 'portfolio', 'service', 'hidden')
            ");
        }
    }
}
