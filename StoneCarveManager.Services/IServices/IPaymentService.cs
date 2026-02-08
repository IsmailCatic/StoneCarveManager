using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
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
    }
}
