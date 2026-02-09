using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Services.IServices;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CheckoutController : ControllerBase
    {
        private readonly ICheckoutService _checkoutService;
        private readonly ICurrentUserService _currentUserService;

        public CheckoutController(ICheckoutService checkoutService, ICurrentUserService currentUserService)
        {
            _checkoutService = checkoutService;
            _currentUserService = currentUserService;
        }

        /// <summary>
        /// Dohvati sažetak checkout-a (pregled košarice prije pla?anja)
        /// </summary>
        [HttpGet("summary")]
        public async Task<IActionResult> GetCheckoutSummary(CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var summary = await _checkoutService.GetCheckoutSummaryAsync(userId, cancellationToken);
            return Ok(summary);
        }

        /// <summary>
        /// Zapo?ni checkout proces - kreira Order i Payment Intent
        /// </summary>
        [HttpPost("process")]
        public async Task<IActionResult> ProcessCheckout([FromBody] CheckoutRequest request, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var checkout = await _checkoutService.ProcessCheckoutAsync(userId, request, cancellationToken);
            return Ok(checkout);
        }

        /// <summary>
        /// Završi checkout nakon uspješnog pla?anja
        /// </summary>
        [HttpPost("complete")]
        public async Task<IActionResult> CompleteCheckout([FromQuery] string paymentIntentId, CancellationToken cancellationToken)
        {
            var order = await _checkoutService.CompleteCheckoutAsync(paymentIntentId, cancellationToken);
            return Ok(order);
        }
    }
}
