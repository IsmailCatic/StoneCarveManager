using StoneCarveManager.Model.Responses;

namespace StoneCarveManager.Services.IServices
{
    public interface IRecommenderService
    {
        /// <summary>
        /// Returns a list of recommended products similar to the given product,
        /// based on category, material, price range, and average rating.
        /// </summary>
        Task<List<ProductResponse>> GetRecommendedProductsAsync(int productId, int count = 6, CancellationToken cancellationToken = default);
    }
}
