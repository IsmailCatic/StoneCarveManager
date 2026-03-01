using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IPaymentService
    {
        Task<PaymentIntentResponse> CreatePaymentIntentAsync(int userId, CreatePaymentIntentRequest request, CancellationToken cancellationToken = default);
        Task<PaymentResponse> ConfirmPaymentAsync(ConfirmPaymentRequest request, CancellationToken cancellationToken = default);
        Task<PaymentResponse> GetPaymentByOrderIdAsync(int orderId, CancellationToken cancellationToken = default);
        Task<PaymentResponse> GetPaymentByIdAsync(int paymentId, CancellationToken cancellationToken = default);
        Task<bool> HandleStripeWebhookAsync(string json, string signature, CancellationToken cancellationToken = default);
        
        // New methods for admin
        Task<PagedResult<PaymentResponse>> GetPaymentsAsync(PaymentSearchObject search, CancellationToken cancellationToken = default);
        Task<PagedResult<PaymentResponse>> GetMyPaymentsAsync(int userId, PaymentSearchObject search, CancellationToken cancellationToken = default);
        Task<PaymentResponse> IssueRefundAsync(RefundRequest request, CancellationToken cancellationToken = default);
        Task<PaymentResponse> RetryPaymentAsync(int orderId, CancellationToken cancellationToken = default);
        Task<PaymentStatisticsResponse> GetPaymentStatisticsAsync(DateTime? startDate, DateTime? endDate, CancellationToken cancellationToken = default);
    }
}
