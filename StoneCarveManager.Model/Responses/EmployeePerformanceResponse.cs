namespace StoneCarveManager.Model.Responses
{
    public class EmployeePerformanceResponse
    {
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; } = string.Empty;
        public int AssignedOrders { get; set; }
        public int CompletedOrders { get; set; }
        public double CompletionRate { get; set; }
        public double AverageCompletionDays { get; set; }
        public decimal TotalRevenue { get; set; }
    }
}
