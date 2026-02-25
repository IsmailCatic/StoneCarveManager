using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class CategoryInsertRequestValidator : AbstractValidator<CategoryInsertRequest>
    {
        public CategoryInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Category name is required.")
                .Length(2, 100).WithMessage("Category name must be between 2 and 100 characters.");

            RuleFor(x => x.Description)
                .NotEmpty().WithMessage("Description is required.")
                .MaximumLength(500).WithMessage("Description cannot exceed 500 characters.");

            When(x => x.ImageUrl != null, () =>
                RuleFor(x => x.ImageUrl).MaximumLength(500));

            When(x => x.ParentCategoryId.HasValue, () =>
                RuleFor(x => x.ParentCategoryId).GreaterThan(0).WithMessage("Parent category ID must be greater than 0."));
        }
    }
}
