using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManager.Services.Services
{
    public class RecommenderService : IRecommenderService
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public RecommenderService(AppDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<ProductResponse>> GetRecommendedProductsAsync(int productId, int count = 6, CancellationToken cancellationToken = default)
        {
            var targetProduct = await _context.Products
                .Include(p => p.Images)
                .Include(p => p.Reviews)
                .Include(p => p.Category)
                .Include(p => p.Material)
                .FirstOrDefaultAsync(p => p.Id == productId, cancellationToken);

            if (targetProduct == null)
                throw new KeyNotFoundException($"Product with ID {productId} not found.");

            // Only recommend from active products (visible to users)
            var candidates = await _context.Products
                .Include(p => p.Images)
                .Include(p => p.Reviews)
                .Include(p => p.Category)
                .Include(p => p.Material)
                .Where(p => p.Id != productId && p.ProductState == "active")
                .ToListAsync(cancellationToken);

            if (candidates.Count == 0)
                return new List<ProductResponse>();

            // Build vocabulary for one-hot encoding
            var allCategoryIds = candidates
                .Select(p => p.CategoryId)
                .Append(targetProduct.CategoryId)
                .Where(id => id.HasValue)
                .Select(id => id!.Value)
                .Distinct()
                .OrderBy(id => id)
                .ToList();

            var allMaterialIds = candidates
                .Select(p => p.MaterialId)
                .Append(targetProduct.MaterialId)
                .Where(id => id.HasValue)
                .Select(id => id!.Value)
                .Distinct()
                .OrderBy(id => id)
                .ToList();

            // Determine price range for normalization
            var allPrices = candidates.Select(p => (float)p.Price).Append((float)targetProduct.Price).ToList();
            float minPrice = allPrices.Min();
            float maxPrice = allPrices.Max();

            var targetVector = BuildFeatureVector(targetProduct, allCategoryIds, allMaterialIds, minPrice, maxPrice);

            var scored = new List<(Product product, float score)>();

            foreach (var candidate in candidates)
            {
                var vector = BuildFeatureVector(candidate, allCategoryIds, allMaterialIds, minPrice, maxPrice);
                float score = CosineSimilarity(targetVector, vector);
                scored.Add((candidate, score));
            }

            var recommended = scored
                .OrderByDescending(x => x.score)
                .Take(count)
                .Select(x => _mapper.Map<ProductResponse>(x.product))
                .ToList();

            return recommended;
        }

        /// <summary>
        /// Builds a feature vector for a product:
        /// [ ...categoryOneHot, ...materialOneHot, normalizedPrice, normalizedRating ]
        /// </summary>
        private float[] BuildFeatureVector(
            Product product,
            List<int> allCategoryIds,
            List<int> allMaterialIds,
            float minPrice,
            float maxPrice)
        {
            var categoryVector = OneHotEncode(product.CategoryId, allCategoryIds);
            var materialVector = OneHotEncode(product.MaterialId, allMaterialIds);

            float normalizedPrice = NormalizeValue((float)product.Price, minPrice, maxPrice);

            float averageRating = product.Reviews.Count > 0
                ? (float)product.Reviews.Average(r => r.Rating)
                : 0f;
            float normalizedRating = NormalizeValue(averageRating, 0f, 5f);

            return categoryVector
                .Concat(materialVector)
                .Append(normalizedPrice)
                .Append(normalizedRating)
                .ToArray();
        }

        private float[] OneHotEncode(int? value, List<int> vocabulary)
        {
            var vector = new float[vocabulary.Count];
            if (value.HasValue)
            {
                int index = vocabulary.IndexOf(value.Value);
                if (index >= 0)
                    vector[index] = 1f;
            }
            return vector;
        }

        private float NormalizeValue(float value, float min, float max)
        {
            if (Math.Abs(max - min) < 1e-5f)
                return 0f;
            return (value - min) / (max - min);
        }

        private float CosineSimilarity(float[] v1, float[] v2)
        {
            if (v1.Length != v2.Length)
                throw new InvalidOperationException("Feature vectors must have the same length.");

            float dot = 0f;
            float normA = 0f;
            float normB = 0f;

            for (int i = 0; i < v1.Length; i++)
            {
                dot += v1[i] * v2[i];
                normA += v1[i] * v1[i];
                normB += v2[i] * v2[i];
            }

            return dot / ((float)(Math.Sqrt(normA) * Math.Sqrt(normB)) + 1e-5f);
        }
    }
}
