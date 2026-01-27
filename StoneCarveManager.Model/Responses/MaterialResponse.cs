using System;

namespace StoneCarveManager.Model.Responses
{
    public class MaterialResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public decimal PricePerUnit { get; set; }
        public string Unit { get; set; } = string.Empty;
        public int QuantityInStock { get; set; }
        public bool IsAvailable { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public int ProductCount { get; set; }
    }
}
