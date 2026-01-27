using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Model.Validators
{
    public class UserUpdateRequestValidator :AbstractValidator<Requests.UserRequests.UserUpdateRequest>
    {
        public UserUpdateRequestValidator()
        {
            When(x => x.FirstName != null, () =>
                RuleFor(x => x.FirstName).MaximumLength(50));

            When(x => x.LastName != null, () =>
                RuleFor(x => x.LastName).MaximumLength(50));

            When(x => x.Email != null, () =>
                RuleFor(x => x.Email).EmailAddress().WithMessage("Invalid email format."));

            //When(x => x.DateOfBirth != null, () =>
            //    RuleFor(x => x.DateOfBirth.Value).LessThan(DateOnly.FromDateTime(DateTime.Today)));

        }

    }
}
