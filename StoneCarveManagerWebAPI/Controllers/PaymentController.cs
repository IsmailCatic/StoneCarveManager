using System.Threading;
using System.Threading.Tasks;
using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IValidator<CreatePaymentIntentRequest> _createPaymentValidator;
        private readonly IValidator<ConfirmPaymentRequest> _confirmPaymentValidator;
        private readonly IValidator<RefundRequest> _refundValidator;

        public PaymentController(
            IPaymentService paymentService,
            ICurrentUserService currentUserService,
            IValidator<CreatePaymentIntentRequest> createPaymentValidator,
            IValidator<ConfirmPaymentRequest> confirmPaymentValidator,
            IValidator<RefundRequest> refundValidator)
        {
            _paymentService = paymentService;
            _currentUserService = currentUserService;
            _createPaymentValidator = createPaymentValidator;
            _confirmPaymentValidator = confirmPaymentValidator;
            _refundValidator = refundValidator;
        }

        [HttpGet]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<PagedResult<PaymentResponse>>> GetAll([FromQuery] PaymentSearchObject search, CancellationToken cancellationToken)
        {
            var result = await _paymentService.GetPaymentsAsync(search, cancellationToken);
            return Ok(result);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<PaymentResponse>> GetById(int id, CancellationToken cancellationToken)
        {
            var payment = await _paymentService.GetPaymentByIdAsync(id, cancellationToken);
            if (payment == null)
                return NotFound(new { message = "Payment not found" });

            return Ok(payment);
        }

        [HttpGet("order/{orderId}")]
        public async Task<ActionResult<PaymentResponse>> GetByOrderId(int orderId, CancellationToken cancellationToken)
        {
            var payment = await _paymentService.GetPaymentByOrderIdAsync(orderId, cancellationToken);
            if (payment == null)
                return NotFound(new { message = "Payment not found for this order" });

            return Ok(payment);
        }

        [HttpPost("create-intent")]
        public async Task<IActionResult> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _createPaymentValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var userId = _currentUserService.GetUserId();
            var result = await _paymentService.CreatePaymentIntentAsync(userId, request, cancellationToken);
            return Ok(result);
        }

        [HttpPost("confirm")]
        public async Task<IActionResult> ConfirmPayment([FromBody] ConfirmPaymentRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _confirmPaymentValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var result = await _paymentService.ConfirmPaymentAsync(request, cancellationToken);
            return Ok(result);
        }

        [HttpPost("refund")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> IssueRefund([FromBody] RefundRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _refundValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var result = await _paymentService.IssueRefundAsync(request, cancellationToken);
            return Ok(result);
        }

        [HttpPost("{orderId}/retry")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> RetryPayment(int orderId, CancellationToken cancellationToken)
        {
            var result = await _paymentService.RetryPaymentAsync(orderId, cancellationToken);
            return Ok(result);
        }

        [HttpGet("statistics")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetStatistics([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate, CancellationToken cancellationToken)
        {
            var stats = await _paymentService.GetPaymentStatisticsAsync(startDate, endDate, cancellationToken);
            return Ok(stats);
        }

        [HttpPost("webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> HandleStripeWebhook(CancellationToken cancellationToken)
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
            var signature = Request.Headers["Stripe-Signature"].ToString();

            var result = await _paymentService.HandleStripeWebhookAsync(json, signature, cancellationToken);

            if (!result)
                return BadRequest(new { message = "Webhook processing failed" });

            return Ok();
        }

        [HttpGet("my-payments")]
        [Authorize]
        public async Task<ActionResult<PagedResult<PaymentResponse>>> GetMyPayments([FromQuery] PaymentSearchObject search, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var result = await _paymentService.GetMyPaymentsAsync(userId, search, cancellationToken);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> DeletePayment(int id, CancellationToken cancellationToken)
        {
            try
            {
                await _paymentService.DeletePaymentAsync(id, cancellationToken);
                return NoContent();
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Payment not found" });
            }
        }
    }
}
