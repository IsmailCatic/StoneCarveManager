using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using Stripe;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using DatabaseOrderStatus = StoneCarveManager.Services.Database.Entities.OrderStatus;

namespace StoneCarveManager.Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;
        private readonly IConfiguration _configuration;

        public PaymentService(AppDbContext context, IMapper mapper, IConfiguration configuration)
        {
            _context = context;
            _mapper = mapper;
            _configuration = configuration;
            
            var stripeSecretKey = _configuration["Stripe:SecretKey"] 
                ?? throw new InvalidOperationException("Stripe SecretKey not configured");
            
            StripeConfiguration.ApiKey = stripeSecretKey;
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(int userId, CreatePaymentIntentRequest request, CancellationToken cancellationToken = default)
        {
            // 1. Dohvati order
            var order = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.Id == request.OrderId && o.UserId == userId, cancellationToken);

            if (order == null)
                throw new KeyNotFoundException($"Order with ID {request.OrderId} not found for user {userId}");

            // 2. Provjeri da li ve? postoji payment
            var existingPayment = await _context.Payments
                .FirstOrDefaultAsync(p => p.OrderId == order.Id, cancellationToken);

            if (existingPayment != null && existingPayment.Status == "succeeded")
                throw new InvalidOperationException("Order is already paid");

            // 3. Kreiraj Stripe Payment Intent
            var amountInCents = (long)(order.TotalAmount * 100);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = "bam",
                PaymentMethodTypes = new List<string> { "card" },
                Description = $"Payment for Order {order.OrderNumber}",
                Metadata = new Dictionary<string, string>
                {
                    { "order_id", order.Id.ToString() },
                    { "order_number", order.OrderNumber },
                    { "user_id", userId.ToString() }
                },
                ReceiptEmail = request.CustomerEmail ?? order.User.Email
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options, cancellationToken: cancellationToken);

            // 4. Kreiraj ili ažuriraj Payment zapis u bazi
            if (existingPayment != null)
            {
                existingPayment.StripePaymentIntentId = paymentIntent.Id;
                existingPayment.Amount = order.TotalAmount;
                existingPayment.Status = "pending";
                existingPayment.Method = request.PaymentMethod;
            }
            else
            {
                var payment = new Payment
                {
                    OrderId = order.Id,
                    Amount = order.TotalAmount,
                    Method = request.PaymentMethod,
                    Status = "pending",
                    StripePaymentIntentId = paymentIntent.Id,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Payments.Add(payment);
            }

            await _context.SaveChangesAsync(cancellationToken);

            return new PaymentIntentResponse
            {
                ClientSecret = paymentIntent.ClientSecret,
                PaymentIntentId = paymentIntent.Id,
                Amount = order.TotalAmount,
                Currency = "bam",
                Status = paymentIntent.Status
            };
        }

        public async Task<PaymentResponse> ConfirmPaymentAsync(ConfirmPaymentRequest request, CancellationToken cancellationToken = default)
        {
            // 1. Dohvati payment intent DIREKTNO iz Stripe-a (bez webhook-a!)
            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(request.PaymentIntentId, cancellationToken: cancellationToken);

            // 2. Ažuriraj payment u bazi
            var payment = await _context.Payments
                .Include(p => p.Order)
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == request.PaymentIntentId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException("Payment not found");

            // 3. Ažuriraj status direktno sa Stripe-a
            payment.Status = paymentIntent.Status;
            payment.TransactionId = paymentIntent.Id;

            if (paymentIntent.Status == "succeeded")
            {
                payment.CompletedAt = DateTime.UtcNow;
                payment.Order.Status = DatabaseOrderStatus.Processing;
            }
            else if (paymentIntent.Status == "canceled")
            {
                payment.Status = "cancelled";
            }
            else if (paymentIntent.Status == "requires_payment_method")
            {
                payment.Status = "failed";
                payment.FailureReason = paymentIntent.LastPaymentError?.Message;
            }

            await _context.SaveChangesAsync(cancellationToken);

            return MapToPaymentResponse(payment);
        }

        public async Task<PaymentResponse> GetPaymentByOrderIdAsync(int orderId, CancellationToken cancellationToken = default)
        {
            var payment = await _context.Payments
                .Include(p => p.Order)
                .FirstOrDefaultAsync(p => p.OrderId == orderId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException($"Payment for order {orderId} not found");

            return MapToPaymentResponse(payment);
        }

        public async Task<PaymentResponse> GetPaymentByIdAsync(int paymentId, CancellationToken cancellationToken = default)
        {
            var payment = await _context.Payments
                .Include(p => p.Order)
                .FirstOrDefaultAsync(p => p.Id == paymentId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException($"Payment with ID {paymentId} not found");

            return MapToPaymentResponse(payment);
        }

        // WEBHOOK metod - OPCIONALAN (ne treba za lokalni razvoj)
        public async Task<bool> HandleStripeWebhookAsync(string json, string signature, CancellationToken cancellationToken = default)
        {
            // Ova metoda može ostati prazna ili vratiti true
            // Ne koristi se u lokalnom razvoju
            return await Task.FromResult(true);
        }

        private PaymentResponse MapToPaymentResponse(Payment payment)
        {
            return new PaymentResponse
            {
                Id = payment.Id,
                OrderId = payment.OrderId,
                OrderNumber = payment.Order.OrderNumber,
                Amount = payment.Amount,
                Currency = "BAM",
                Status = payment.Status,
                Method = payment.Method,
                TransactionId = payment.TransactionId,
                StripePaymentIntentId = payment.StripePaymentIntentId,
                FailureReason = payment.FailureReason,
                CreatedAt = payment.CreatedAt,
                CompletedAt = payment.CompletedAt
            };
        }
    }
}
