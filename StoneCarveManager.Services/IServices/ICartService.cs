using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface ICartService
    {
        Task<CartResponse> GetCartByUserIdAsync(int userId, CancellationToken cancellationToken = default);
        Task<CartItemResponse> AddToCartAsync(int userId, AddToCartRequest request, CancellationToken cancellationToken = default);
        Task<CartItemResponse> UpdateCartItemAsync(int userId, int cartItemId, UpdateCartItemRequest request, CancellationToken cancellationToken = default);
        Task<bool> RemoveFromCartAsync(int userId, int cartItemId, CancellationToken cancellationToken = default);
        Task<bool> ClearCartAsync(int userId, CancellationToken cancellationToken = default);
        Task<CartResponse> RecalculateCartAsync(int userId, CancellationToken cancellationToken = default);
    }
}
