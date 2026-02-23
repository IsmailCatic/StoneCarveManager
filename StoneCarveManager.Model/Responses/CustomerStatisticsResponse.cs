namespace StoneCarveManager.Model.Responses
{
    public class CustomerStatisticsResponse
    {
        public int TotalCustomers { get; set; }
        public int NewCustomers { get; set; }
        public int ReturningCustomers { get; set; }
        public decimal AverageLifetimeValue { get; set; }
        public decimal AverageOrdersPerCustomer { get; set; }
    }
}
