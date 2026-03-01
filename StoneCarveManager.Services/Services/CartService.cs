using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class CartService : ICartService
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public CartService(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<CartResponse> GetCartByUserIdAsync(int userId, CancellationToken cancellationToken = default)
        {
            var cart = await GetOrCreateCartAsync(userId, cancellationToken);

            var cartResponse = await BuildCartResponseAsync(cart, cancellationToken);

            return cartResponse;
        }

        public async Task<CartItemResponse> AddToCartAsync(int userId, AddToCartRequest request, CancellationToken cancellationToken = default)
        {
            // Validate product
            var product = await _context.Products.FindAsync(new object[] { request.ProductId }, cancellationToken);
            if (product == null)
                throw new KeyNotFoundException($"Product with ID {request.ProductId} not found");

            // if (!product.IsActive || product.ProductState != "active")
            if (product.ProductState != "active")
                throw new InvalidOperationException("Product is not available for purchase");

            if (product.StockQuantity < request.Quantity)
                throw new InvalidOperationException($"Insufficient stock. Available: {product.StockQuantity}");

            // Get or create cart
            var cart = await GetOrCreateCartAsync(userId, cancellationToken);

            // Check if product already in cart
            var existingItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.CartId == cart.Id && ci.ProductId == request.ProductId, cancellationToken);

            if (existingItem != null)
            {
                // Update quantity
                existingItem.Quantity += request.Quantity;
                existingItem.UpdatedAt = DateTime.UtcNow;
                
                if (!string.IsNullOrWhiteSpace(request.CustomNotes))
                    existingItem.CustomNotes = request.CustomNotes;

                // Validate total quantity
                if (existingItem.Quantity > product.StockQuantity)
                    throw new InvalidOperationException($"Total quantity exceeds available stock ({product.StockQuantity})");
            }
            else
            {
                // Add new item
                existingItem = new CartItem
                {
                    CartId = cart.Id,
                    ProductId = request.ProductId,
                    Quantity = request.Quantity,
                    CustomNotes = request.CustomNotes,
                    AddedAt = DateTime.UtcNow
                };
                _context.CartItems.Add(existingItem);
            }

            cart.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync(cancellationToken);

            // Return updated item with product info
            var cartItem = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .FirstOrDefaultAsync(ci => ci.Id == existingItem.Id, cancellationToken);

            return MapCartItemToResponse(cartItem!);
        }

        public async Task<CartItemResponse> UpdateCartItemAsync(int userId, int cartItemId, UpdateCartItemRequest request, CancellationToken cancellationToken = default)
        {
            var cart = await GetOrCreateCartAsync(userId, cancellationToken);

            var cartItem = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .FirstOrDefaultAsync(ci => ci.Id == cartItemId && ci.CartId == cart.Id, cancellationToken);

            if (cartItem == null)
                throw new KeyNotFoundException($"Cart item with ID {cartItemId} not found in user's cart");

            // Validate stock
            if (request.Quantity > cartItem.Product.StockQuantity)
                throw new InvalidOperationException($"Quantity exceeds available stock ({cartItem.Product.StockQuantity})");

            if (request.Quantity <= 0)
                throw new InvalidOperationException("Quantity must be greater than 0");

            cartItem.Quantity = request.Quantity;
            cartItem.CustomNotes = request.CustomNotes;
            cartItem.UpdatedAt = DateTime.UtcNow;
            cart.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);

            return MapCartItemToResponse(cartItem);
        }

        public async Task<bool> RemoveFromCartAsync(int userId, int cartItemId, CancellationToken cancellationToken = default)
        {
            var cart = await GetOrCreateCartAsync(userId, cancellationToken);

            var cartItem = await _context.CartItems
                .FirstOrDefaultAsync(ci => ci.Id == cartItemId && ci.CartId == cart.Id, cancellationToken);

            if (cartItem == null)
                return false;

            _context.CartItems.Remove(cartItem);
            cart.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }

        public async Task<bool> ClearCartAsync(int userId, CancellationToken cancellationToken = default)
        {
            var cart = await _context.Carts
                .Include(c => c.CartItems)
                .FirstOrDefaultAsync(c => c.UserId == userId, cancellationToken);

            if (cart == null)
                return false;

            _context.CartItems.RemoveRange(cart.CartItems);
            cart.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);
            return true;
        }

        public async Task<CartResponse> RecalculateCartAsync(int userId, CancellationToken cancellationToken = default)
        {
            var cart = await GetOrCreateCartAsync(userId, cancellationToken);
            return await BuildCartResponseAsync(cart, cancellationToken);
        }

        // Helper methods
        private async Task<Cart> GetOrCreateCartAsync(int userId, CancellationToken cancellationToken)
        {
            var cart = await _context.Carts
                .FirstOrDefaultAsync(c => c.UserId == userId, cancellationToken);

            if (cart == null)
            {
                cart = new Cart
                {
                    UserId = userId,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Carts.Add(cart);
                await _context.SaveChangesAsync(cancellationToken);
            }

            return cart;
        }

        private async Task<CartResponse> BuildCartResponseAsync(Cart cart, CancellationToken cancellationToken)
        {
            var cartItems = await _context.CartItems
                .Include(ci => ci.Product)
                    .ThenInclude(p => p.Images)
                .Where(ci => ci.CartId == cart.Id)
                .ToListAsync(cancellationToken);

            var items = cartItems.Select(MapCartItemToResponse).ToList();

            var subtotal = items.Sum(i => i.Subtotal);
            var totalDiscount = items.Sum(i => i.Discount);
            var total = items.Sum(i => i.Total);

            return new CartResponse
            {
                Id = cart.Id,
                UserId = cart.UserId,
                CreatedAt = cart.CreatedAt,
                UpdatedAt = cart.UpdatedAt,
                Items = items,
                Subtotal = subtotal,
                TotalDiscount = totalDiscount,
                Total = total,
                TotalItems = items.Sum(i => i.Quantity)
            };
        }

        private CartItemResponse MapCartItemToResponse(CartItem cartItem)
        {
            var product = cartItem.Product;
            var unitPrice = product.Price;
            var subtotal = unitPrice * cartItem.Quantity;
            var discount = 0m; // TODO: Implement discount logic
            var total = subtotal - discount;

            var primaryImage = product.Images.FirstOrDefault(i => i.IsPrimary)?.ImageUrl
                ?? product.Images.FirstOrDefault()?.ImageUrl;

            return new CartItemResponse
            {
                Id = cartItem.Id,
                CartId = cartItem.CartId,
                ProductId = product.Id,
                ProductName = product.Name,
                ProductImageUrl = primaryImage,
                UnitPrice = unitPrice,
                Quantity = cartItem.Quantity,
                Subtotal = subtotal,
                Discount = discount,
                Total = total,
                AddedAt = cartItem.AddedAt,
                UpdatedAt = cartItem.UpdatedAt,
                CustomNotes = cartItem.CustomNotes,
                IsInStock = product.StockQuantity >= cartItem.Quantity,
                AvailableStock = product.StockQuantity
            };
        }
    }
}
