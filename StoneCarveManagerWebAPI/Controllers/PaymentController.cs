using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
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

        // ================================
        // NEW ADMIN ENDPOINTS
        // ================================

        [HttpGet]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<ActionResult<PagedResult<PaymentResponse>>> GetAllPayments(
            [FromQuery] string? status,
            [FromQuery] string? method,
            [FromQuery] System.DateTime? startDate,
            [FromQuery] System.DateTime? endDate,
            [FromQuery] int? page,
            [FromQuery] int? pageSize,
            [FromQuery] bool retrieveAll = false,
            CancellationToken cancellationToken = default)
        {
            var searchObject = new PaymentSearchObject
            {
                Status = status,
                Method = method,
                StartDate = startDate,
                EndDate = endDate,
                Page = page,
                PageSize = pageSize,
                RetrieveAll = retrieveAll
            };
            
            var result = await _paymentService.GetPaymentsAsync(searchObject, cancellationToken);
            return Ok(result);
        }

        [HttpPost("refund")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<PaymentResponse>> IssueRefund(
            [FromBody] RefundRequest request,
            CancellationToken cancellationToken = default)
        {
            var payment = await _paymentService.IssueRefundAsync(request, cancellationToken);
            return Ok(payment);
        }

        [HttpPost("retry/{orderId}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<PaymentResponse>> RetryPayment(
            int orderId,
            CancellationToken cancellationToken = default)
        {
            var payment = await _paymentService.RetryPaymentAsync(orderId, cancellationToken);
            return Ok(payment);
        }

        [HttpGet("statistics")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<ActionResult<PaymentStatisticsResponse>> GetPaymentStatistics(
            [FromQuery] System.DateTime? startDate,
            [FromQuery] System.DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var stats = await _paymentService.GetPaymentStatisticsAsync(
                startDate, endDate, cancellationToken
            );
            return Ok(stats);
        }
    }
}
