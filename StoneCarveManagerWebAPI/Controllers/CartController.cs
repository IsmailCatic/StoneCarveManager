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

        public CartController(ICartService cartService, ICurrentUserService currentUserService)
        {
            _cartService = cartService;
            _currentUserService = currentUserService;
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
            var userId = _currentUserService.GetUserId();
            var cartItem = await _cartService.AddToCartAsync(userId, request, cancellationToken);
            return Ok(cartItem);
        }

        [HttpPut("items/{cartItemId}")]
        public async Task<IActionResult> UpdateCartItem(int cartItemId, [FromBody] UpdateCartItemRequest request, CancellationToken cancellationToken)
        {
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
                return NotFound();
            
            return NoContent();
        }

        [HttpDelete("clear")]
        public async Task<IActionResult> ClearCart(CancellationToken cancellationToken)
        {
            var userId = _currentUserService.GetUserId();
            var result = await _cartService.ClearCartAsync(userId, cancellationToken);
            
            if (!result)
                return NotFound();
            
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
