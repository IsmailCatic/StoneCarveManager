using StoneCarveManager.Model.Requests;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.SearchObjects
{
    public class OrderSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }

        public int? AssignedEmployeeId { get; set; }

        public OrderStatus? Status { get; set; }

        public DateTime? DateFrom { get; set; }

        public DateTime? DateTo { get; set; }

        /// <summary>
        /// Filter by product state (e.g., "custom_order")
        /// </summary>
        public string? ProductState { get; set; }

        // Optionally include items or related data flags if needed by mapper
        public bool IncludeItems { get; set; } = false;
    }
}
