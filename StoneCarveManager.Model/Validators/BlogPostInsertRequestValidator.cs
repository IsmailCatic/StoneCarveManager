using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class BlogPostInsertRequestValidator : AbstractValidator<BlogPostInsertRequest>
    {
        public BlogPostInsertRequestValidator()
        {
            RuleFor(x => x.Title)
                .NotEmpty().WithMessage("Title is required.")
                .Length(5, 200).WithMessage("Title must be between 5 and 200 characters.");

            RuleFor(x => x.Content)
                .NotEmpty().WithMessage("Content is required.")
                .Length(10, 10000).WithMessage("Content must be between 10 and 10000 characters.");

            When(x => x.Summary != null, () =>
                RuleFor(x => x.Summary).MaximumLength(500).WithMessage("Summary cannot exceed 500 characters."));

            When(x => x.FeaturedImageUrl != null, () =>
                RuleFor(x => x.FeaturedImageUrl).MaximumLength(500));

            RuleFor(x => x.AuthorId)
                .Must(id => id == -999 || id > 0).WithMessage("Author is required.");

            RuleFor(x => x.CategoryId)
                .NotEqual(0).WithMessage("Category is required.");
        }
    }
}
