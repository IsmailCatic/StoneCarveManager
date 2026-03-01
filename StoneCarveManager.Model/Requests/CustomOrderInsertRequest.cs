using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    /// <summary>
    /// Request model for custom stone carving orders (no predefined product)
    /// User specifies work type, material, dimensions, and description
    /// </summary>
    public class CustomOrderInsertRequest
    {
        /// <summary>
        /// Optional: ID of a catalog service product this request is based on.
        /// When provided, CategoryId and MaterialId are inferred from the service product
        /// and the order is tagged as OrderType = "service_request".
        /// </summary>
        public int? ServiceProductId { get; set; }

        public int? CategoryId { get; set; }

        /// <summary>
        /// Material to use (Material ID)
        /// </summary>
        public int? MaterialId { get; set; }

        /// <summary>
        /// Dimensions specification (e.g., "120cm x 60cm x 15cm")
        /// </summary>
        [StringLength(200)]
        public string? Dimensions { get; set; }

        /// <summary>
        /// Detailed description of the custom work idea and special requirements
        /// </summary>
        [Required]
        [StringLength(4000)]
        public string Description { get; set; } = string.Empty;

        /// <summary>
        /// Customer's notes about the design, inspiration, or special requests
        /// </summary>
        [StringLength(2000)]
        public string? CustomerNotes { get; set; }

        /// <summary>
        /// List of reference images/sketches URLs (uploaded separately)
        /// </summary>
        public List<string> ReferenceImageUrls { get; set; } = new();

        /// <summary>
        /// Estimated price (can be calculated based on material, dimensions, etc.)
        /// </summary>
        [Range(0, double.MaxValue)]
        public decimal? EstimatedPrice { get; set; }

        /// <summary>
        /// Delivery address information
        /// </summary>
        public string? DeliveryAddress { get; set; }

        public string? DeliveryCity { get; set; }

        public string? DeliveryZipCode { get; set; }

        public string? DeliveryCountry { get; set; }

        public DateTime? DeliveryDate { get; set; }
    }
}
