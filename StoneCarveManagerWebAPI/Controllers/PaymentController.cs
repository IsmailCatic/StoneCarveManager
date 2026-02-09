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
        private readonly ICurrentUserService _currentUserService;

        public PaymentController(IPaymentService paymentService, ICurrentUserService currentUserService)
        {
            _paymentService = paymentService;
            _currentUserService = currentUserService;
        }

        [HttpPost("create-intent")]
        [Authorize]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
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
