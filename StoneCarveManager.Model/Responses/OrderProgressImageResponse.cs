using System;

namespace StoneCarveManager.Model.Responses
{
    public class OrderProgressImageResponse
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime UploadedAt { get; set; }
        public int OrderId { get; set; }
        public int? UploadedByUserId { get; set; }
        public string? UploadedByUserName { get; set; }
    }
}