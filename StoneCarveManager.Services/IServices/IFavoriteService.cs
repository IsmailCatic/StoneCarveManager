using StoneCarveManager.Model.Responses;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    /// <summary>
    /// Service for managing user favorite products
    /// </summary>
    public interface IFavoriteService
    {
        /// <summary>
        /// Gets all favorite product IDs for the current user
        /// </summary>
        Task<List<int>> GetUserFavoriteIdsAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Gets all favorite products with details for the current user
        /// </summary>
        Task<List<FavoriteProductResponse>> GetUserFavoritesAsync(CancellationToken cancellationToken = default);

        /// <summary>
        /// Checks if a product is in the current user's favorites
        /// </summary>
        Task<bool> IsFavoriteAsync(int productId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Adds a product to the current user's favorites
        /// </summary>
        /// <returns>True if added, false if already exists</returns>
        Task<bool> AddFavoriteAsync(int productId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Removes a product from the current user's favorites
        /// </summary>
        /// <returns>True if removed, false if not found</returns>
        Task<bool> RemoveFavoriteAsync(int productId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Toggles a product in/out of favorites
        /// </summary>
        /// <returns>True if now favorite, false if removed</returns>
        Task<bool> ToggleFavoriteAsync(int productId, CancellationToken cancellationToken = default);

        /// <summary>
        /// Syncs local favorites with server (for mobile app)
        /// Adds missing favorites from local list, removes extras
        /// </summary>
        Task<List<int>> SyncFavoritesAsync(List<int> localFavoriteIds, CancellationToken cancellationToken = default);

        /// <summary>
        /// Clears all favorites for the current user
        /// </summary>
        Task<int> ClearAllFavoritesAsync(CancellationToken cancellationToken = default);
    }
}
