using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class RoleInsertRequestValidator : AbstractValidator<RoleInsertRequest>
    {
        public RoleInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Role name is required.")
                .Length(2, 100).WithMessage("Role name must be between 2 and 100 characters.");

            When(x => x.Description != null, () =>
                RuleFor(x => x.Description).MaximumLength(500).WithMessage("Description cannot exceed 500 characters."));
        }
    }
}
