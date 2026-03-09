using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using DatabaseOrderStatus = StoneCarveManager.Services.Database.Entities.OrderStatus;

namespace StoneCarveManager.Services.Services
{
    public class CheckoutService : ICheckoutService
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;
        private readonly ICartService _cartService;
        private readonly IPaymentService _paymentService;

        public CheckoutService(
            AppDbContext context,
            IMapper mapper,
            ICartService cartService,
            IPaymentService paymentService)
        {
            _context = context;
            _mapper = mapper;
            _cartService = cartService;
            _paymentService = paymentService;
        }

        public async Task<CheckoutSummaryResponse> GetCheckoutSummaryAsync(int userId, CancellationToken cancellationToken = default)
        {
            var cart = await _cartService.GetCartByUserIdAsync(userId, cancellationToken);

            if (cart == null || cart.Items.Count == 0)
                throw new InvalidOperationException("Cart is empty");

            var items = cart.Items.Select(item => new CheckoutItemResponse
            {
                ProductId = item.ProductId,
                ProductName = item.ProductName,
                ProductImageUrl = item.ProductImageUrl,
                UnitPrice = item.UnitPrice,
                Quantity = item.Quantity,
                Total = item.Total
            }).ToList();

            // Use cart.Subtotal consistently (same base as CreateOrderFromCartAsync)
            var subtotal = cart.Subtotal;
            var discount = cart.TotalDiscount;
            var deliveryFee = CalculateDeliveryFee(subtotal);
            var total = cart.Total + deliveryFee;

            return new CheckoutSummaryResponse
            {
                Items = items,
                Subtotal = subtotal,
                Discount = discount,
                DeliveryFee = deliveryFee,
                Total = total,
                TotalItems = items.Sum(i => i.Quantity)
            };
        }

        public async Task<CheckoutResponse> ProcessCheckoutAsync(int userId, CheckoutRequest request, CancellationToken cancellationToken = default)
        {
            // 1. Get cart
            var cartResponse = await _cartService.GetCartByUserIdAsync(userId, cancellationToken);

            if (cartResponse == null || cartResponse.Items.Count == 0)
                throw new InvalidOperationException("Cart is empty");

            // 2. Use a transaction so the order + stock reservation are rolled back if payment intent creation fails
            await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

            try
            {
                // 3. Reserve stock atomically — validates availability and decrements in one step.
                //    This prevents two concurrent checkouts from buying the same last item.
                await ReserveStockAsync(cartResponse.Items, cancellationToken);

                // 4. Create order from cart
                var order = await CreateOrderFromCartAsync(userId, cartResponse, request, cancellationToken);

                // 5. Create Stripe Payment Intent
                var paymentIntentRequest = new CreatePaymentIntentRequest
                {
                    OrderId = order.Id,
                    PaymentMethod = request.PaymentMethod
                };

                var paymentIntent = await _paymentService.CreatePaymentIntentAsync(userId, paymentIntentRequest, cancellationToken);

                // 6. Commit — order, stock reservation, and payment record are saved
                await transaction.CommitAsync(cancellationToken);

                return new CheckoutResponse
                {
                    OrderId = order.Id,
                    OrderNumber = order.OrderNumber,
                    TotalAmount = order.TotalAmount,
                    PaymentIntentId = paymentIntent.PaymentIntentId,
                    ClientSecret = paymentIntent.ClientSecret,
                    PaymentStatus = paymentIntent.Status
                };
            }
            catch
            {
                // Roll back order, stock decrement, and payment DB record if anything fails
                await transaction.RollbackAsync(cancellationToken);
                throw;
            }
        }

        public async Task<OrderResponse> CompleteCheckoutAsync(string paymentIntentId, CancellationToken cancellationToken = default)
        {
            var payment = await _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.User)
                .Include(p => p.Order)
                    .ThenInclude(o => o.OrderItems)
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntentId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException("Payment not found");

            if (payment.Status != "succeeded")
                throw new InvalidOperationException($"Payment is not successful. Status: {payment.Status}");

            // Update order status
            payment.Order.Status = DatabaseOrderStatus.Processing;
            await _context.SaveChangesAsync(cancellationToken);

            // Clear user cart
            await _cartService.ClearCartAsync(payment.Order.UserId, cancellationToken);

            // Stock was already reserved during ProcessCheckoutAsync — no decrement here.

            return _mapper.Map<OrderResponse>(payment.Order);
        }

        // Helper methods

        /// <summary>
        /// Reserve stock for all items at checkout time.
        /// Validates each product has sufficient stock and decrements atomically within the current transaction.
        /// Throws InvalidOperationException if any product has insufficient stock.
        /// </summary>
        private async Task ReserveStockAsync(System.Collections.Generic.List<CartItemResponse> items, CancellationToken cancellationToken)
        {
            foreach (var item in items)
            {
                var product = await _context.Products.FindAsync(new object[] { item.ProductId }, cancellationToken);

                if (product == null)
                    throw new InvalidOperationException($"Product with ID {item.ProductId} no longer exists.");

                if (product.StockQuantity < item.Quantity)
                    throw new InvalidOperationException(
                        $"Insufficient stock for '{product.Name}'. Requested: {item.Quantity}, Available: {product.StockQuantity}");

                product.StockQuantity -= item.Quantity;
            }

            await _context.SaveChangesAsync(cancellationToken);
        }

        private async Task<Order> CreateOrderFromCartAsync(
            int userId,
            CartResponse cart,
            CheckoutRequest request,
            CancellationToken cancellationToken)
        {
            // cart.Subtotal = zbroj (cijena × koli?ina) prije popusta
            // cart.Total    = zbroj ukupnih cijena artikala (nakon popusta, bez troškova dostave)
            // Trošak dostave se ovdje jednom izra?unava na temelju zbroja cijena proizvoda.
            var deliveryFee = CalculateDeliveryFee(cart.Subtotal);
            var totalAmount = cart.Total + deliveryFee;

            var order = new Order
            {
                UserId = userId,
                OrderNumber = GenerateOrderNumber(),
                OrderDate = DateTime.UtcNow,
                Status = DatabaseOrderStatus.Pending,
                TotalAmount = totalAmount,
                DeliveryAddress = request.DeliveryAddress,
                DeliveryCity = request.DeliveryCity,
                DeliveryZipCode = request.DeliveryZipCode,
                CustomerNotes = request.CustomerNotes,
                OrderItems = cart.Items.Select(item => new OrderItem
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice,
                    Discount = item.Discount
                }).ToList()
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync(cancellationToken);

            return order;
        }

        private decimal CalculateDeliveryFee(decimal subtotal)
        {
            // Besplatna dostava za narudžbe preko 100 KM
            if (subtotal >= 100)
                return 0m;

            // Ina?e, fiksna dostava 10 KM
            return 10m;
        }

        private string GenerateOrderNumber()
        {
            return $"ORD-{DateTime.UtcNow:yyyyMMddHHmmssfff}-{Guid.NewGuid().ToString().Substring(0, 6).ToUpper()}";
        }
    }
}
