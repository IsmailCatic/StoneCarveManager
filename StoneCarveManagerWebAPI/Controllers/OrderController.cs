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
        private readonly IValidator<ServiceOrderInsertRequest> _serviceOrderValidator;

        public OrderController(
            IOrderService orderService, 
            ICurrentUserService currentUserService,
            IValidator<OrderInsertRequest> insertValidator,
            IValidator<OrderUpdateRequest> updateValidator,
            IValidator<CustomOrderInsertRequest> customOrderValidator,
            IValidator<UpdateOrderStatusRequest> statusUpdateValidator,
            IValidator<ServiceOrderInsertRequest> serviceOrderValidator)
        {
            _orderService = orderService;
            _currentUserService = currentUserService;
            _insertValidator = insertValidator;
            _updateValidator = updateValidator;
            _customOrderValidator = customOrderValidator;
            _statusUpdateValidator = statusUpdateValidator;
            _serviceOrderValidator = serviceOrderValidator;
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

        /// <summary>
        /// Create a service request order from a catalog service product.
        /// Category and material are resolved automatically from the service product.
        /// </summary>
        [HttpPost("service-request")]
        public async Task<IActionResult> CreateServiceRequest([FromBody] ServiceOrderInsertRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _serviceOrderValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var order = await _orderService.CreateServiceRequestAsync(request, cancellationToken);
            return Ok(order);
        }

        [HttpGet("custom-orders")]
        [Authorize(Roles = $"{Roles.Admin},{Roles.Employee}")]
        public async Task<IActionResult> GetCustomOrders(
            [FromQuery] int? status = null,
            [FromQuery] bool? assignedToMe = null,
            [FromQuery] bool? unassignedOnly = null,
            [FromQuery] int page = 0,
            [FromQuery] int pageSize = 20,
            CancellationToken cancellationToken = default)
        {
            var search = new OrderSearchObject
            {
                ProductState = "custom_order",
                Status = status.HasValue ? (StoneCarveManager.Model.Requests.OrderStatus?)status.Value : null,
                Page = page,
                PageSize = pageSize
            };

            // Filter: assigned to me
            if (assignedToMe == true)
            {
                var currentUserId = _currentUserService.GetUserId();
                search.AssignedEmployeeId = currentUserId;
            }

            // Filter: unassigned only
            if (unassignedOnly == true)
            {
                search.AssignedEmployeeId = -1; // Special value to indicate "unassigned"
            }

            var result = await _orderService.GetAsync(search);
            return Ok(result);
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

        /// <summary>
        /// Assign employee to order
        /// Admin only
        /// </summary>
        [HttpPatch("{id}/assign-employee")]
        [Authorize(Roles = Roles.Admin)]
        public async Task<IActionResult> AssignEmployee(
            int id, 
            [FromBody] AssignEmployeeRequest request, 
            CancellationToken cancellationToken)
        {
            try
            {
                var order = await _orderService.AssignEmployeeToOrderAsync(id, request.EmployeeId, cancellationToken);
                
                if (order == null)
                    return NotFound(new { message = "Order not found" });

                return Ok(order);
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Get orders assigned to currently logged-in employee, or own orders for regular users
        /// </summary>
        [HttpGet("my-orders")]
        public async Task<IActionResult> GetMyOrders(
            [FromQuery] int? status = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20,
            CancellationToken cancellationToken = default)
        {
            var isAdmin = User.IsInRole(Roles.Admin);
            var isEmployee = User.IsInRole(Roles.Employee);

            if (isAdmin || isEmployee)
            {
                var result = await _orderService.GetMyOrdersAsync(status, page, pageSize, cancellationToken);
                return Ok(result);
            }
            else
            {
                var search = new OrderSearchObject
                {
                    UserId = _currentUserService.GetUserId(),
                    Status = status.HasValue ? (StoneCarveManager.Model.Requests.OrderStatus?)status.Value : null,
                    Page = page - 1,
                    PageSize = pageSize
                };
                var result = await _orderService.GetAsync(search);
                return Ok(result);
            }
        }
    }
}
