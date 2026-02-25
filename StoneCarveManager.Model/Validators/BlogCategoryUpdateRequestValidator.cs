using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class BlogCategoryUpdateRequestValidator : AbstractValidator<BlogCategoryUpdateRequest>
    {
        public BlogCategoryUpdateRequestValidator()
        {
            When(x => x.Name != null, () =>
                RuleFor(x => x.Name).Length(2, 100).WithMessage("Category name must be between 2 and 100 characters."));
        }
    }
}
