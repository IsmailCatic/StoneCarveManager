using FluentValidation;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StoneCarveManager.Model.Requests;

namespace StoneCarveManager.Model.Validators
{
    public class AssignEmployeeRequestValidator : AbstractValidator<AssignEmployeeRequest>
    {
        public AssignEmployeeRequestValidator()
        {
            // EmployeeId is optional (null = unassign)
            // But if provided, must be valid (allow -999 for seeded admin)
            When(x => x.EmployeeId.HasValue, () =>
            {
                RuleFor(x => x.EmployeeId.Value)
                    .Must(id => id == -999 || id > 0)
                    .WithMessage("Employee ID must be valid");
            });
        }
    }
}
