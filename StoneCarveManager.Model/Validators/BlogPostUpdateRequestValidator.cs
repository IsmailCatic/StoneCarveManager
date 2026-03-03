using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class BlogPostUpdateRequestValidator : AbstractValidator<BlogPostUpdateRequest>
    {
        public BlogPostUpdateRequestValidator()
        {
            When(x => x.Title != null, () =>
                RuleFor(x => x.Title).Length(5, 200).WithMessage("Title must be between 5 and 200 characters."));

            When(x => x.Content != null, () =>
                RuleFor(x => x.Content).Length(10, 10000).WithMessage("Content must be between 10 and 10000 characters."));

            When(x => x.Summary != null, () =>
                RuleFor(x => x.Summary).MaximumLength(500).WithMessage("Summary cannot exceed 500 characters."));

            When(x => x.FeaturedImageUrl != null, () =>
                RuleFor(x => x.FeaturedImageUrl).MaximumLength(500));

            When(x => x.AuthorId.HasValue, () =>
                RuleFor(x => x.AuthorId).NotEqual(0).WithMessage("Author ID must be valid."));

            When(x => x.CategoryId.HasValue, () =>
                RuleFor(x => x.CategoryId).NotEqual(0).WithMessage("Category ID must be valid."));
        }
    }
}
