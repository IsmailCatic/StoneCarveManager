using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ProductImageUpdateRequestValidator : AbstractValidator<ProductImageUpdateRequest>
    {
        public ProductImageUpdateRequestValidator()
        {
            When(x => x.ImageUrl != null, () =>
                RuleFor(x => x.ImageUrl).MaximumLength(500).WithMessage("Image URL cannot exceed 500 characters."));

            When(x => x.AltText != null, () =>
                RuleFor(x => x.AltText).MaximumLength(200).WithMessage("Alt text cannot exceed 200 characters."));

            When(x => x.DisplayOrder.HasValue, () =>
                RuleFor(x => x.DisplayOrder).GreaterThanOrEqualTo(0).WithMessage("Display order cannot be negative."));

            When(x => x.ProductId.HasValue, () =>
                RuleFor(x => x.ProductId).GreaterThan(0).WithMessage("Product ID must be greater than 0."));
        }
    }
}
