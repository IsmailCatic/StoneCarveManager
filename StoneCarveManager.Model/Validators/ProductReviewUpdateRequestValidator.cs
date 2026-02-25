using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ProductReviewUpdateRequestValidator : AbstractValidator<ProductReviewUpdateRequest>
    {
        public ProductReviewUpdateRequestValidator()
        {
            When(x => x.Rating.HasValue, () =>
                RuleFor(x => x.Rating).InclusiveBetween(1, 5).WithMessage("Rating must be between 1 and 5."));

            When(x => x.Comment != null, () =>
                RuleFor(x => x.Comment).Length(5, 1000).WithMessage("Comment must be between 5 and 1000 characters."));
        }
    }
}
