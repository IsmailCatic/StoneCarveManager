using FluentValidation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.IServices;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CartController : ControllerBase
    {
        private readonly ICartService _cartService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IValidator<AddToCartRequest> _addToCartValidator;
        private readonly IValidator<UpdateCartItemRequest> _updateCartItemValidator;

        public CartController(
            ICartService cartService, 
            ICurrentUserService currentUserService,
            IValidator<AddToCartRequest> addToCartValidator,
            IValidator<UpdateCartItemRequest> updateCartItemValidator)
        {
            _cartService = cartService;
            _currentUserService = currentUserService;
            _addToCartValidator = addToCartValidator;
            _updateCartItemValidator = updateCartItemValidator;
        }

        [HttpGet]
        public async Task<IActionResult> GetCart(CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var cart = await _cartService.GetCartByUserIdAsync(userId, cancellationToken);
            return Ok(cart);
        }

        [HttpPost("items")]
        public async Task<IActionResult> AddToCart([FromBody] AddToCartRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _addToCartValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var userId = _currentUserService.GetUserId();
            var cartItem = await _cartService.AddToCartAsync(userId, request, cancellationToken);
            return Ok(cartItem);
        }

        [HttpPut("items/{cartItemId}")]
        public async Task<IActionResult> UpdateCartItem(int cartItemId, [FromBody] UpdateCartItemRequest request, CancellationToken cancellationToken)
        {
            var validationResult = await _updateCartItemValidator.ValidateAsync(request, cancellationToken);
            if (!validationResult.IsValid)
                return BadRequest(new { errors = validationResult.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }) });

            var userId = _currentUserService.GetUserId();
            var cartItem = await _cartService.UpdateCartItemAsync(userId, cartItemId, request, cancellationToken);
            return Ok(cartItem);
        }

        [HttpDelete("items/{cartItemId}")]
        public async Task<IActionResult> RemoveFromCart(int cartItemId, CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var result = await _cartService.RemoveFromCartAsync(userId, cartItemId, cancellationToken);
            
            if (!result)
                return NotFound(new { message = "Cart item not found" });
            
            return NoContent();
        }

        [HttpDelete("clear")]
        public async Task<IActionResult> ClearCart(CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var result = await _cartService.ClearCartAsync(userId, cancellationToken);
            
            if (!result)
                return NotFound(new { message = "Cart not found" });
            
            return NoContent();
        }

        [HttpPost("recalculate")]
        public async Task<IActionResult> RecalculateCart(CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var cart = await _cartService.RecalculateCartAsync(userId, cancellationToken);
            return Ok(cart);
        }
    }
}
