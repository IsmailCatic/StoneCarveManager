using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ProductReviewInsertRequestValidator : AbstractValidator<ProductReviewInsertRequest>
    {
        public ProductReviewInsertRequestValidator()
        {
            RuleFor(x => x.Rating)
                .InclusiveBetween(1, 5).WithMessage("Rating must be between 1 and 5.");

            RuleFor(x => x.Comment)
                .NotEmpty().WithMessage("Comment is required.")
                .Length(5, 1000).WithMessage("Comment must be between 5 and 1000 characters.");

            RuleFor(x => x.UserId)
                .GreaterThan(0).WithMessage("User ID is required.");

            RuleFor(x => x)
                .Must(x => x.ProductId.HasValue || x.OrderId.HasValue)
                .WithMessage("Either Product ID or Order ID must be provided.");
        }
    }
}
