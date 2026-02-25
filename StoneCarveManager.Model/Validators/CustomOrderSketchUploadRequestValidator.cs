using FluentValidation;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class CustomOrderSketchUploadRequestValidator : AbstractValidator<CustomOrderSketchUploadRequest>
    {
        public CustomOrderSketchUploadRequestValidator()
        {
            RuleFor(x => x.File)
                .NotNull().WithMessage("Sketch file is required.")
                .Must(file => file != null && file.Length > 0).WithMessage("File cannot be empty.")
                .Must(file => file == null || file.Length <= 15 * 1024 * 1024).WithMessage("File size cannot exceed 15MB.")
                .Must(file => file == null || IsValidFileType(file.ContentType)).WithMessage("Only image files (JPEG, PNG) and PDF are allowed.");

            When(x => x.Description != null, () =>
                RuleFor(x => x.Description).MaximumLength(500).WithMessage("Description cannot exceed 500 characters."));
        }

        private bool IsValidFileType(string contentType)
        {
            var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "application/pdf" };
            return allowedTypes.Contains(contentType.ToLower());
        }
    }
}
