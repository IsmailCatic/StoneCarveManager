using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class OrderUpdateRequestValidator : AbstractValidator<OrderUpdateRequest>
    {
        public OrderUpdateRequestValidator()
        {
            When(x => x.AssignedEmployeeId.HasValue, () =>
                RuleFor(x => x.AssignedEmployeeId).GreaterThan(0).WithMessage("Assigned employee ID must be greater than 0."));

            When(x => x.CustomerNotes != null, () =>
                RuleFor(x => x.CustomerNotes).MaximumLength(2000).WithMessage("Customer notes cannot exceed 2000 characters."));

            When(x => x.AdminNotes != null, () =>
                RuleFor(x => x.AdminNotes).MaximumLength(2000).WithMessage("Admin notes cannot exceed 2000 characters."));

            When(x => x.AttachmentUrl != null, () =>
                RuleFor(x => x.AttachmentUrl).MaximumLength(500));

            When(x => x.DeliveryAddress != null, () =>
                RuleFor(x => x.DeliveryAddress).MaximumLength(500));

            When(x => x.DeliveryCity != null, () =>
                RuleFor(x => x.DeliveryCity).MaximumLength(100));

            When(x => x.DeliveryZipCode != null, () =>
                RuleFor(x => x.DeliveryZipCode).MaximumLength(20));

            When(x => x.Items != null, () =>
                RuleForEach(x => x.Items).SetValidator(new OrderItemUpdateRequestValidator()));
        }
    }
}
