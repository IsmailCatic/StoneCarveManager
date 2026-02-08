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
            // Dohvati košaricu
            var cart = await _cartService.GetCartByUserIdAsync(userId, cancellationToken);

            if (cart == null || cart.Items.Count == 0)
                throw new InvalidOperationException("Cart is empty");

            // Kreiraj sažetak
            var items = cart.Items.Select(item => new CheckoutItemResponse
            {
                ProductId = item.ProductId,
                ProductName = item.ProductName,
                ProductImageUrl = item.ProductImageUrl,
                UnitPrice = item.UnitPrice,
                Quantity = item.Quantity,
                Total = item.Total
            }).ToList();

            var subtotal = items.Sum(i => i.Total);
            var discount = 0m; // TODO: Implement discount logic
            var deliveryFee = CalculateDeliveryFee(subtotal);
            var total = subtotal - discount + deliveryFee;

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
            // 1. Dohvati košaricu
            var cartResponse = await _cartService.GetCartByUserIdAsync(userId, cancellationToken);

            if (cartResponse == null || cartResponse.Items.Count == 0)
                throw new InvalidOperationException("Cart is empty");

            // 2. Validacija zaliha (provjeri da li su svi proizvodi još uvijek dostupni)
            foreach (var item in cartResponse.Items)
            {
                if (!item.IsInStock)
                    throw new InvalidOperationException($"Product '{item.ProductName}' is no longer in stock");
            }

            // 3. Kreiraj Order iz Cart-a
            var order = await CreateOrderFromCartAsync(userId, cartResponse, request, cancellationToken);

            // 4. Kreiraj Payment Intent
            var paymentIntentRequest = new CreatePaymentIntentRequest
            {
                OrderId = order.Id,
                PaymentMethod = request.PaymentMethod
            };

            var paymentIntent = await _paymentService.CreatePaymentIntentAsync(userId, paymentIntentRequest, cancellationToken);

            // 5. Vrati checkout response
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

        public async Task<OrderResponse> CompleteCheckoutAsync(string paymentIntentId, CancellationToken cancellationToken = default)
        {
            // 1. Dohvati payment po PaymentIntentId
            var payment = await _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.User)
                .Include(p => p.Order)
                    .ThenInclude(o => o.OrderItems)
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntentId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException("Payment not found");

            // 2. Provjeri da li je pla?anje uspješno
            if (payment.Status != "succeeded")
                throw new InvalidOperationException($"Payment is not successful. Status: {payment.Status}");

            // 3. Ažuriraj order status
            payment.Order.Status = DatabaseOrderStatus.Processing;
            await _context.SaveChangesAsync(cancellationToken);

            // 4. Isprazni košaricu korisnika
            await _cartService.ClearCartAsync(payment.Order.UserId, cancellationToken);

            // 5. Smanji stock quantity za svaki proizvod
            await UpdateProductStockAsync(payment.Order.OrderItems, cancellationToken);

            // 6. Vrati order response
            return _mapper.Map<OrderResponse>(payment.Order);
        }

        // Helper methods
        private async Task<Order> CreateOrderFromCartAsync(
            int userId,
            CartResponse cart,
            CheckoutRequest request,
            CancellationToken cancellationToken)
        {
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

        private async Task UpdateProductStockAsync(ICollection<OrderItem> orderItems, CancellationToken cancellationToken)
        {
            foreach (var item in orderItems)
            {
                var product = await _context.Products.FindAsync(new object[] { item.ProductId }, cancellationToken);
                if (product != null)
                {
                    product.StockQuantity -= item.Quantity;

                    if (product.StockQuantity < 0)
                        product.StockQuantity = 0; // Prevent negative stock
                }
            }

            await _context.SaveChangesAsync(cancellationToken);
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
