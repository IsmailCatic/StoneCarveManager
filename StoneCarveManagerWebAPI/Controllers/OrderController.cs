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
    [Authorize]
    public class OrderController : ControllerBase
    {
        private readonly IOrderService _orderService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IValidator<OrderInsertRequest> _insertValidator;
        private readonly IValidator<OrderUpdateRequest> _updateValidator;
        private readonly IValidator<CustomOrderInsertRequest> _customOrderValidator;
        private readonly IValidator<UpdateOrderStatusRequest> _statusUpdateValidator;

        public OrderController(
            IOrderService orderService, 
            ICurrentUserService currentUserService,
            IValidator<OrderInsertRequest> insertValidator,
            IValidator<OrderUpdateRequest> updateValidator,
            IValidator<CustomOrderInsertRequest> customOrderValidator,
            IValidator<UpdateOrderStatusRequest> statusUpdateValidator)
        {
            _orderService = orderService;
            _currentUserService = currentUserService;
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
            _customOrderValidator = customOrderValidator;
            _statusUpdateValidator = statusUpdateValidator;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] OrderSearchObject search)
        {
            var isAdmin = User.IsInRole(Roles.Admin);
            var isEmployee = User.IsInRole(Roles.Employee);

            if (!isAdmin && !isEmployee)
            {
                search.UserId = _currentUserService.GetUserId();
            }

            var result = await _orderService.GetAsync(search);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var order = await _orderService.GetByIdAsync(id);

            if (order == null)
                return NotFound(new { message = "Order not found" });

            var userId = _currentUserService.GetUserId();
            var isAdmin = User.IsInRole(Roles.Admin);
            var isEmployee = User.IsInRole(Roles.Employee);

            if (order.UserId != userId && !isAdmin && !isEmployee)
            {
                return Forbid();
            }

            return Ok(order);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] OrderInsertRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _insertValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var order = await _orderService.CreateAsync(request);
            return Ok(order);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> Update(int id, [FromBody] OrderUpdateRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _updateValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var order = await _orderService.UpdateAsync(id, request);
            return Ok(order);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> Delete(int id)
        {
            await _orderService.DeleteAsync(id);
            return NoContent();
        }

        [HttpPost("custom")]
        public async Task<IActionResult> CreateCustomOrder([FromBody] CustomOrderInsertRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _customOrderValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var order = await _orderService.CreateCustomOrderAsync(request, cancellationToken);
            return Ok(order);
        }

        [HttpGet("custom-orders")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> GetCustomOrders(CancellationToken cancellationToken)
        {
            var result = await _orderService.GetCustomOrdersAsync(cancellationToken);
            return Ok(new { items = result });
        }

        [HttpPut("{orderId}/status")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> UpdateOrderStatus(
            int orderId, 
            [FromBody] UpdateOrderStatusRequest request, 
            CancellationToken cancellationToken)
        {
            var validationResult = await _statusUpdateValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var order = await _orderService.UpdateOrderStatusAsync(orderId, request.NewStatus, request.Comment, cancellationToken);
            return Ok(order);
        }

        [HttpPost("{orderId}/progress-images")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> UploadProgressImage(
            int orderId, 
            [FromForm] OrderProgressImageUploadRequest request, 
            CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            request.UploadedByUserId = userId;

            var result = await _orderService.AddOrderProgressImageAsync(orderId, request, cancellationToken);
            return Ok(result);
        }

        [HttpDelete("progress-images/{imageId}")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> DeleteProgressImage(int imageId, CancellationToken cancellationToken)
        {
            var deleted = await _orderService.DeleteOrderProgressImageAsync(imageId, cancellationToken);
            if (!deleted)
                return NotFound(new { message = "Progress image not found" });

            return NoContent();
        }
    }
}
