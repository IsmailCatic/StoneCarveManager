using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class BlogImageUploadRequestValidator : AbstractValidator<BlogImageUploadRequest>
    {
        public BlogImageUploadRequestValidator()
        {
            RuleFor(x => x.File)
                .NotNull().WithMessage("Image file is required.")
                .Must(file => file != null && file.Length > 0).WithMessage("File cannot be empty.")
                .Must(file => file == null || file.Length <= 10 * 1024 * 1024).WithMessage("File size cannot exceed 10MB.")
                .Must(file => file == null || IsValidImageType(file.ContentType)).WithMessage("Only image files (JPEG, PNG, GIF, WebP) are allowed.");

            When(x => x.AltText != null, () =>
                RuleFor(x => x.AltText).MaximumLength(200).WithMessage("Alt text cannot exceed 200 characters."));

            RuleFor(x => x.DisplayOrder)
                .GreaterThanOrEqualTo(0).WithMessage("Display order cannot be negative.");
        }

        private bool IsValidImageType(string contentType)
        {
            var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp" };
            return allowedTypes.Contains(contentType.ToLower());
        }
    }
}
