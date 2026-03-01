using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class FaqInsertRequestValidator : AbstractValidator<FaqInsertRequest>
    {
        public FaqInsertRequestValidator()
        {
            RuleFor(x => x.Question)
                .NotEmpty().WithMessage("Question is required.")
                .Length(5, 500).WithMessage("Question must be between 5 and 500 characters.");

            RuleFor(x => x.Answer)
                .NotEmpty().WithMessage("Answer is required.")
                .Length(5, 4000).WithMessage("Answer must be between 5 and 4000 characters.");

            When(x => x.Category != null, () =>
                RuleFor(x => x.Category).MaximumLength(100).WithMessage("Category cannot exceed 100 characters."));

            RuleFor(x => x.DisplayOrder)
                .GreaterThanOrEqualTo(0).WithMessage("Display order cannot be negative.");
        }
    }
}
