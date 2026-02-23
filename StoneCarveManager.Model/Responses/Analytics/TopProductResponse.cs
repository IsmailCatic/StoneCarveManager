using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Responses.Analytics
{
    public class TopProductResponse
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = "";
        
        // Legacy property (kept for backward compatibility)
        public int SoldQuantity { get; set; }
        
        // New properties
        public int OrderCount { get; set; }
        public int QuantitySold { get; set; }
        
        // Legacy property (kept for backward compatibility)
        public decimal TotalIncome { get; set; }
        
        // New property
        public decimal TotalRevenue { get; set; }
    }
}
