using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class BlogCategoryInsertRequestValidator : AbstractValidator<BlogCategoryInsertRequest>
    {
        public BlogCategoryInsertRequestValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("Category name is required.")
                .Length(2, 100).WithMessage("Category name must be between 2 and 100 characters.");
        }
    }
}
