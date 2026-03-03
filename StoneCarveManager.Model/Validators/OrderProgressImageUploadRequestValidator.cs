using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class OrderProgressImageUploadRequestValidator : AbstractValidator<OrderProgressImageUploadRequest>
    {
        public OrderProgressImageUploadRequestValidator()
        {
            RuleFor(x => x.File)
                .NotNull().WithMessage("Image file is required.")
                .Must(file => file != null && file.Length > 0).WithMessage("File cannot be empty.")
                .Must(file => file == null || file.Length <= 10 * 1024 * 1024).WithMessage("File size cannot exceed 10MB.")
                .Must(file => file == null || IsValidImageType(file.ContentType)).WithMessage("Only image files (JPEG, PNG, GIF, WebP) are allowed.");

            When(x => x.Description != null, () =>
                RuleFor(x => x.Description).MaximumLength(500).WithMessage("Description cannot exceed 500 characters."));

            When(x => x.UploadedByUserId.HasValue, () =>
                RuleFor(x => x.UploadedByUserId).NotEqual(0).WithMessage("Uploaded by user ID must be valid."));
        }

        private bool IsValidImageType(string contentType)
        {
            var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp" };
            return allowedTypes.Contains(contentType.ToLower());
        }
    }
}
