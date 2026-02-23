using System;

namespace StoneCarveManager.Model.Responses
{
    public class RevenueTrendResponse
    {
        public DateTime Date { get; set; }
        public decimal Revenue { get; set; }
        public int OrderCount { get; set; }
    }
}
