using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class RoleUpdateRequestValidator : AbstractValidator<RoleUpdateRequest>
    {
        public RoleUpdateRequestValidator()
        {
            When(x => x.Name != null, () =>
                RuleFor(x => x.Name).Length(2, 100).WithMessage("Role name must be between 2 and 100 characters."));

            When(x => x.Description != null, () =>
                RuleFor(x => x.Description).MaximumLength(500).WithMessage("Description cannot exceed 500 characters."));
        }
    }
}
