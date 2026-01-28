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
        public int SoldQuantity { get; set; }
        public decimal TotalIncome { get; set; }
    }
}
