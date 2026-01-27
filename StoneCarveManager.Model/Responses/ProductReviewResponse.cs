using System;

namespace StoneCarveManager.Model.Responses
{
    public class ProductReviewResponse
    {
        public int Id { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int UserId { get; set; }
        public string? UserName { get; set; }
        public int? ProductId { get; set; }
        public string? ProductName { get; set; }
        public int? OrderId { get; set; }
        public bool IsApproved { get; set; }
    }
}
