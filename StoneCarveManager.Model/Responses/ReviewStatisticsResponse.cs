using System.Collections.Generic;

namespace StoneCarveManager.Model.Responses
{
    public class ReviewStatisticsResponse
    {
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public int ApprovedReviews { get; set; }
        public int PendingReviews { get; set; }
        public Dictionary<int, int> RatingDistribution { get; set; } = new(); // 1-5 star counts
        public double ApprovalRate { get; set; }
    }
}
