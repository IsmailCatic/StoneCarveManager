using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ProductImageInsertRequestValidator : AbstractValidator<ProductImageInsertRequest>
    {
        public ProductImageInsertRequestValidator()
        {
            RuleFor(x => x.ImageUrl)
                .NotEmpty().WithMessage("Image URL is required.")
                .MaximumLength(500).WithMessage("Image URL cannot exceed 500 characters.");

            When(x => x.AltText != null, () =>
                RuleFor(x => x.AltText).MaximumLength(200).WithMessage("Alt text cannot exceed 200 characters."));

            RuleFor(x => x.DisplayOrder)
                .GreaterThanOrEqualTo(0).WithMessage("Display order cannot be negative.");

            RuleFor(x => x.ProductId)
                .GreaterThan(0).WithMessage("Product ID is required.");
        }
    }
}
