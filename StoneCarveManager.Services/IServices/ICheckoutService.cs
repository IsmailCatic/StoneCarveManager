using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface ICheckoutService
    {
        Task<CheckoutSummaryResponse> GetCheckoutSummaryAsync(int userId, CancellationToken cancellationToken = default);
        Task<CheckoutResponse> ProcessCheckoutAsync(int userId, CheckoutRequest request, CancellationToken cancellationToken = default);
        Task<OrderResponse> CompleteCheckoutAsync(string paymentIntentId, CancellationToken cancellationToken = default);
    }
}
