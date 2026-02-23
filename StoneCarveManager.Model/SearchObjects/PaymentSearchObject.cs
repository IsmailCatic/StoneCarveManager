using System;

namespace StoneCarveManager.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public string? Status { get; set; }
        public string? Method { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
