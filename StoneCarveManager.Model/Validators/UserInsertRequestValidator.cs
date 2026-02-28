using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static StoneCarveManager.Model.Requests.UserRequests;

namespace StoneCarveManager.Model.Validators
{
    public class UserInsertRequestValidator : AbstractValidator<UserInsertRequest>
    {
        public UserInsertRequestValidator()
        {
            RuleFor(x => x.FirstName)
                .NotEmpty().WithMessage("First name is required.")
                .MaximumLength(50);

            RuleFor(x => x.LastName)
                .NotEmpty().WithMessage("Last name is required.")
                .MaximumLength(50);

            RuleFor(x => x.Email)
                .NotEmpty().WithMessage("Email is required.")
                .EmailAddress().WithMessage("Invalid email format.");

            RuleFor(x => x.Password)
                .NotEmpty().WithMessage("Password is required.")
                .MinimumLength(6).WithMessage("Password must be at least 6 characters.");

            RuleFor(x => x.Roles)
                .NotEmpty().WithMessage("At least one role is required.")
                .Must(roles => roles != null && roles.Any()).WithMessage("At least one role must be specified.");
        }
    }
}
