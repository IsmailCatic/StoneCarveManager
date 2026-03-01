using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace StoneCarveManager.Model.Requests
{
    /// <summary>
    /// Request model for service-based orders.
    /// The customer selects a catalog service product (e.g. "Grave Engraving")
    /// and provides job-specific requirements. Category and material are resolved
    /// automatically from the service product.
    /// </summary>
    public class ServiceOrderInsertRequest
    {
        /// <summary>
        /// ID of the catalog service product the customer is requesting.
        /// </summary>
        [Required]
        public int ServiceProductId { get; set; }

        /// <summary>
        /// Detailed requirements / job description provided by the customer.
        /// </summary>
        [Required]
        [StringLength(4000, MinimumLength = 10)]
        public string Requirements { get; set; } = string.Empty;

        /// <summary>
        /// Dimensions specification (e.g. "120cm x 60cm x 15cm").
        /// </summary>
        [StringLength(200)]
        public string? Dimensions { get; set; }

        /// <summary>
        /// Additional customer notes.
        /// </summary>
        [StringLength(2000)]
        public string? CustomerNotes { get; set; }

        /// <summary>
        /// Reference image URLs uploaded separately before submitting the request.
        /// </summary>
        public List<string> ReferenceImageUrls { get; set; } = new();

        public string? DeliveryAddress { get; set; }
        public string? DeliveryCity { get; set; }
        public string? DeliveryZipCode { get; set; }
        public string? DeliveryCountry { get; set; }
        public DateTime? DeliveryDate { get; set; }
    }
}
