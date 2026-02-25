using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class UserProfileImageUploadRequestValidator : AbstractValidator<UserProfileImageUploadRequest>
    {
        public UserProfileImageUploadRequestValidator()
        {
            RuleFor(x => x.File)
                .NotNull().WithMessage("Profile image file is required.")
                .Must(file => file != null && file.Length > 0).WithMessage("File cannot be empty.")
                .Must(file => file == null || file.Length <= 5 * 1024 * 1024).WithMessage("File size cannot exceed 5MB.")
                .Must(file => file == null || IsValidImageType(file.ContentType)).WithMessage("Only image files (JPEG, PNG, GIF, WebP) are allowed.");

            When(x => x.AltText != null, () =>
                RuleFor(x => x.AltText).MaximumLength(200).WithMessage("Alt text cannot exceed 200 characters."));
        }

        private bool IsValidImageType(string contentType)
        {
            var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp" };
            return allowedTypes.Contains(contentType.ToLower());
        }
    }
}
