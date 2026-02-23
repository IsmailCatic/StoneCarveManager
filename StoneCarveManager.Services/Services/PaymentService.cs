using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using Stripe;
using System;
using System.Collections.Generic;
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
            // 1. Get payment intent from Stripe
            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(request.PaymentIntentId, cancellationToken: cancellationToken);

            // 2. Get payment from database
            var payment = await _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.User)
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == request.PaymentIntentId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException("Payment not found");

            // ============================================
            // AUTO-CONFIRM FOR TEST MODE (Development Only)
            // 
            // ⚠️ IMPORTANT: Remove this block before production deployment!
            // In production, customers will enter real card details through
            // a proper Stripe payment form (e.g., flutter_stripe package)
            // ============================================
            if (paymentIntent.Status == "requires_payment_method" || 
                paymentIntent.Status == "requires_confirmation")
            {
                try
                {
                    // Attach Stripe's test card to the payment intent
                    var updateOptions = new PaymentIntentUpdateOptions
                    {
                        PaymentMethod = "pm_card_visa" // Stripe's official test card
                    };
                    paymentIntent = await service.UpdateAsync(paymentIntent.Id, updateOptions, cancellationToken: cancellationToken);
                    
                    // Now confirm the payment
                    var confirmOptions = new PaymentIntentConfirmOptions
                    {
                        PaymentMethod = "pm_card_visa"
                    };
                    
                    paymentIntent = await service.ConfirmAsync(
                        request.PaymentIntentId, 
                        confirmOptions, 
                        cancellationToken: cancellationToken
                    );
                    
                    Console.WriteLine($"✅ [Payment] Auto-confirmed test payment: {paymentIntent.Id} -> {paymentIntent.Status}");
                }
                catch (StripeException ex)
                {
                    Console.WriteLine($"❌ [Payment] Auto-confirm failed: {ex.Message}");
                    payment.Status = "failed";
                    payment.FailureReason = $"Auto-confirm failed: {ex.Message}";
                    await _context.SaveChangesAsync(cancellationToken);
                    return MapToPaymentResponse(payment);
                }
            }
            // ============================================

            // 3. Update payment status based on Stripe's final status
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
                payment.FailureReason = paymentIntent.LastPaymentError?.Message ?? "Payment method required";
            }
            else
            {
                // For any other status that's not successful
                payment.Status = "failed";
                payment.FailureReason = paymentIntent.LastPaymentError?.Message ?? $"Payment status: {paymentIntent.Status}";
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

        public async Task<PagedResult<PaymentResponse>> GetPaymentsAsync(
            PaymentSearchObject search,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.User)
                .AsQueryable();

            // Apply filters
            if (!string.IsNullOrWhiteSpace(search.Status))
                query = query.Where(p => p.Status == search.Status);

            if (!string.IsNullOrWhiteSpace(search.Method))
                query = query.Where(p => p.Method == search.Method);

            if (search.StartDate.HasValue)
                query = query.Where(p => p.CreatedAt >= search.StartDate.Value);

            if (search.EndDate.HasValue)
                query = query.Where(p => p.CreatedAt <= search.EndDate.Value);

            // Full-text search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(p =>
                    p.Order.OrderNumber.Contains(search.FTS) ||
                    (p.TransactionId != null && p.TransactionId.Contains(search.FTS)) ||
                    p.Order.User.Email.Contains(search.FTS) ||
                    (p.Order.User.FirstName + " " + p.Order.User.LastName).Contains(search.FTS));
            }

            // Order by most recent first
            query = query.OrderByDescending(p => p.CreatedAt);

            // Calculate total count
            var totalCount = await query.CountAsync(cancellationToken);

            // Apply pagination
            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    query = query
                        .Skip(search.Page.Value * search.PageSize.Value)
                        .Take(search.PageSize.Value);
                }
            }

            var payments = await query.ToListAsync(cancellationToken);
            var items = payments.Select(MapToPaymentResponse).ToList();

            return new PagedResult<PaymentResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        public async Task<PaymentResponse> IssueRefundAsync(
            RefundRequest request,
            CancellationToken cancellationToken = default)
        {
            // Get the payment
            var payment = await _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.User)
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == request.PaymentIntentId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException("Payment not found");

            if (payment.Status != "succeeded")
                throw new InvalidOperationException("Can only refund succeeded payments");

            // Create Stripe refund
            var refundService = new RefundService();
            var refundOptions = new RefundCreateOptions
            {
                PaymentIntent = request.PaymentIntentId,
                Amount = request.Amount.HasValue ? (long)(request.Amount.Value * 100) : null, // null = full refund
                Reason = request.Reason switch
                {
                    "duplicate" => "duplicate",
                    "fraudulent" => "fraudulent",
                    "requested_by_customer" => "requested_by_customer",
                    _ => "requested_by_customer"
                },
                Metadata = new Dictionary<string, string>
                {
                    { "order_id", payment.OrderId.ToString() },
                    { "order_number", payment.Order.OrderNumber }
                }
            };

            if (string.IsNullOrEmpty(StripeConfiguration.ApiKey))
                throw new Exception("Stripe API key is not set!");


            try
            {
                var refund = await refundService.CreateAsync(refundOptions, cancellationToken: cancellationToken);

                // Update payment status
                payment.Status = "refunded";
                payment.CompletedAt = DateTime.UtcNow;
                payment.FailureReason = $"Refunded: {request.Reason}";

                // Update order status to cancelled
                payment.Order.Status = DatabaseOrderStatus.Cancelled;

                await _context.SaveChangesAsync(cancellationToken);

                return MapToPaymentResponse(payment);
            }
            catch (StripeException ex)
            {
                throw new InvalidOperationException($"Stripe refund failed: {ex.Message}", ex);
            }
        }

        public async Task<PaymentResponse> RetryPaymentAsync(
            int orderId,
            CancellationToken cancellationToken = default)
        {
            var payment = await _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.User)
                .FirstOrDefaultAsync(p => p.OrderId == orderId, cancellationToken);

            if (payment == null)
                throw new KeyNotFoundException("Payment not found");

            if (payment.Status == "succeeded")
                throw new InvalidOperationException("Payment has already succeeded");

            // Create new payment intent
            var service = new PaymentIntentService();
            var amountInCents = (long)(payment.Amount * 100);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = "bam",
                PaymentMethodTypes = new List<string> { "card" },
                Description = $"Retry payment for Order {payment.Order.OrderNumber}",
                Metadata = new Dictionary<string, string>
                {
                    { "order_id", payment.OrderId.ToString() },
                    { "order_number", payment.Order.OrderNumber },
                    { "retry", "true" }
                },
                ReceiptEmail = payment.Order.User.Email
            };

            var paymentIntent = await service.CreateAsync(options, cancellationToken: cancellationToken);

            // Update payment with new payment intent
            payment.StripePaymentIntentId = paymentIntent.Id;
            payment.Status = "pending";
            payment.FailureReason = null;
            payment.CreatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);

            return MapToPaymentResponse(payment);
        }

        public async Task<PaymentStatisticsResponse> GetPaymentStatisticsAsync(
            DateTime? startDate,
            DateTime? endDate,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments.AsQueryable();

            if (startDate.HasValue)
                query = query.Where(p => p.CreatedAt >= startDate.Value);

            if (endDate.HasValue)
                query = query.Where(p => p.CreatedAt <= endDate.Value);

            var payments = await query.ToListAsync(cancellationToken);

            var successfulPayments = payments.Where(p => p.Status == "succeeded").ToList();
            var totalRevenue = successfulPayments.Sum(p => p.Amount);
            var refundedAmount = payments.Where(p => p.Status == "refunded").Sum(p => p.Amount);

            var revenueByMethod = successfulPayments
                .GroupBy(p => p.Method)
                .ToDictionary(g => g.Key, g => g.Sum(p => p.Amount));

            return new PaymentStatisticsResponse
            {
                TotalRevenue = totalRevenue,
                SuccessfulCount = successfulPayments.Count,
                FailedCount = payments.Count(p => p.Status == "failed"),
                PendingCount = payments.Count(p => p.Status == "pending"),
                RefundedAmount = refundedAmount,
                RevenueByMethod = revenueByMethod
            };
        }

        private PaymentResponse MapToPaymentResponse(Database.Entities.Payment payment)
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
                CompletedAt = payment.CompletedAt,
                CustomerName = $"{payment.Order.User.FirstName} {payment.Order.User.LastName}",
                CustomerEmail = payment.Order.User.Email
            };
        }

        // WEBHOOK metod - OPCIONALAN (ne treba za lokalni razvoj)
        public async Task<bool> HandleStripeWebhookAsync(string json, string signature, CancellationToken cancellationToken = default)
        {
            // Ova metoda može ostati prazna ili vratiti true
            // Ne koristi se u lokalnom razvoju
            return await Task.FromResult(true);
        }
    }
}
