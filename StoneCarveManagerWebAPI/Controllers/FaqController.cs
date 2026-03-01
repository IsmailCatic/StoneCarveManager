using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using static StoneCarveManager.Services.Constants;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FaqController
        : BaseCRUDController<FaqResponse, FaqSearchObject, FaqInsertRequest, FaqUpdateRequest>
    {
        private readonly IFaqService _faqService;

        public FaqController(
            IFaqService faqService,
            IValidator<FaqInsertRequest> insertValidator,
            IValidator<FaqUpdateRequest> updateValidator)
            : base(faqService, insertValidator, updateValidator)
        {
            _faqService = faqService;
        }

        // GET /api/Faq — public, no auth required
        // GET /api/Faq/{id} — public, inherited from BaseController

        [HttpPost]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<FaqResponse> Create([FromBody] FaqInsertRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<FaqResponse?> Update(int id, [FromBody] FaqUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        /// <summary>
        /// Tracks a view on a specific FAQ entry. Called by the client when a user expands an FAQ.
        /// </summary>
        [HttpPost("{id}/view")]
        public async Task<IActionResult> TrackView(int id, CancellationToken cancellationToken)
        {
            var result = await _faqService.TrackViewAsync(id, cancellationToken);

            if (result == null)
                return NotFound(new { message = "FAQ not found" });

            return Ok(result);
        }
    }
}
