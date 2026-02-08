using System;
using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses
{
    public class OrderMonthlySummaryResponse
    {
        public int Year { get; set; }
        public List<MonthSummary> Months { get; set; } = new();
        public YearTotalSummary YearTotal { get; set; } = new();
    }

    public class MonthSummary
    {
        public int Month { get; set; }
        public string MonthName => new DateTime(2000, Month, 1).ToString("MMMM");
        public int OrderCount { get; set; }
        public decimal TotalRevenue { get; set; }
        public List<OrderResponse> Orders { get; set; } = new();
    }

    public class YearTotalSummary
    {
        public int OrderCount { get; set; }
        public decimal TotalRevenue { get; set; }
    }
}
