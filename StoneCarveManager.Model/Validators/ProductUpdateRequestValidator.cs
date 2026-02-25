using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class ProductUpdateRequestValidator : AbstractValidator<ProductUpdateRequest>
    {
        public ProductUpdateRequestValidator()
        {
            When(x => x.Name != null, () =>
                RuleFor(x => x.Name).Length(2, 200).WithMessage("Product name must be between 2 and 200 characters."));

            When(x => x.Description != null, () =>
                RuleFor(x => x.Description).MaximumLength(2000).WithMessage("Description cannot exceed 2000 characters."));

            When(x => x.Price.HasValue, () =>
                RuleFor(x => x.Price).GreaterThan(0).WithMessage("Price must be greater than 0."));

            When(x => x.StockQuantity.HasValue, () =>
                RuleFor(x => x.StockQuantity).GreaterThanOrEqualTo(0).WithMessage("Stock quantity cannot be negative."));

            When(x => x.Dimensions != null, () =>
                RuleFor(x => x.Dimensions).MaximumLength(100));

            When(x => x.Weight.HasValue, () =>
                RuleFor(x => x.Weight).GreaterThanOrEqualTo(0).WithMessage("Weight cannot be negative."));

            When(x => x.EstimatedDays.HasValue, () =>
                RuleFor(x => x.EstimatedDays).InclusiveBetween(1, 365).WithMessage("Estimated days must be between 1 and 365."));

            When(x => x.CategoryId.HasValue, () =>
                RuleFor(x => x.CategoryId).GreaterThan(0).WithMessage("Category ID must be greater than 0."));

            When(x => x.MaterialId.HasValue, () =>
                RuleFor(x => x.MaterialId).GreaterThan(0).WithMessage("Material ID must be greater than 0."));

            When(x => x.ProductState != null, () =>
                RuleFor(x => x.ProductState).MaximumLength(50));

            When(x => x.PortfolioDescription != null, () =>
                RuleFor(x => x.PortfolioDescription).MaximumLength(4000));

            When(x => x.ClientChallenge != null, () =>
                RuleFor(x => x.ClientChallenge).MaximumLength(2000));

            When(x => x.OurSolution != null, () =>
                RuleFor(x => x.OurSolution).MaximumLength(2000));

            When(x => x.ProjectOutcome != null, () =>
                RuleFor(x => x.ProjectOutcome).MaximumLength(2000));

            When(x => x.Location != null, () =>
                RuleFor(x => x.Location).MaximumLength(200));

            When(x => x.CompletionYear.HasValue, () =>
                RuleFor(x => x.CompletionYear)
                    .InclusiveBetween(1900, DateTime.Now.Year + 10)
                    .WithMessage($"Completion year must be between 1900 and {DateTime.Now.Year + 10}."));

            When(x => x.ProjectDuration.HasValue, () =>
                RuleFor(x => x.ProjectDuration).GreaterThan(0).WithMessage("Project duration must be greater than 0."));

            When(x => x.TechniquesUsed != null, () =>
                RuleFor(x => x.TechniquesUsed).MaximumLength(500));
        }
    }
}
