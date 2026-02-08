using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Services.IServices;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("userid")?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                throw new UnauthorizedAccessException("User not authenticated");

            return userId;
        }

        [HttpPost("create-intent")]
        [Authorize]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request, CancellationToken cancellationToken)
        {
            var userId = GetCurrentUserId();
            var paymentIntent = await _paymentService.CreatePaymentIntentAsync(userId, request, cancellationToken);
            return Ok(paymentIntent);
        }

        [HttpPost("confirm")]
        [Authorize]
        public async Task<IActionResult> ConfirmPayment([FromBody] ConfirmPaymentRequest request, CancellationToken cancellationToken)
        {
            var payment = await _paymentService.ConfirmPaymentAsync(request, cancellationToken);
            return Ok(payment);
        }

        [HttpGet("order/{orderId}")]
        [Authorize]
        public async Task<IActionResult> GetPaymentByOrderId(int orderId, CancellationToken cancellationToken)
        {
            var payment = await _paymentService.GetPaymentByOrderIdAsync(orderId, cancellationToken);
            return Ok(payment);
        }

        [HttpGet("{paymentId}")]
        [Authorize]
        public async Task<IActionResult> GetPaymentById(int paymentId, CancellationToken cancellationToken)
        {
            var payment = await _paymentService.GetPaymentByIdAsync(paymentId, cancellationToken);
            return Ok(payment);
        }
    }
}
