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
            // But if provided, must be > 0
            When(x => x.EmployeeId.HasValue, () =>
            {
                RuleFor(x => x.EmployeeId.Value)
                    .GreaterThan(0)
                    .WithMessage("Employee ID must be greater than 0");
            });
        }
    }
}
