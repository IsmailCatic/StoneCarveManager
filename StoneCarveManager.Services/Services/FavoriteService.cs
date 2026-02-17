using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class FavoriteService : IFavoriteService
    {
        private readonly AppDbContext _context;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;

        public FavoriteService(
            AppDbContext context,
            ICurrentUserService currentUserService,
            IMapper mapper)
        {
            _context = context;
            _currentUserService = currentUserService;
            _mapper = mapper;
        }

        public async Task<List<int>> GetUserFavoriteIdsAsync(CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            var favoriteIds = await _context.FavoriteProducts
                .Where(f => f.UserId == userId)
                .Select(f => f.ProductId)
                .ToListAsync(cancellationToken);

            return favoriteIds;
        }

        public async Task<List<FavoriteProductResponse>> GetUserFavoritesAsync(CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            var favorites = await _context.FavoriteProducts
                .Where(f => f.UserId == userId)
                .Include(f => f.Product)
                    .ThenInclude(p => p.Images)
                .Include(f => f.Product)
                    .ThenInclude(p => p.Category)
                .Include(f => f.Product)
                    .ThenInclude(p => p.Material)
                .OrderByDescending(f => f.AddedAt)
                .ToListAsync(cancellationToken);

            var responses = favorites.Select(f => new FavoriteProductResponse
            {
                Id = f.Id,
                ProductId = f.ProductId,
                UserId = f.UserId,
                AddedAt = f.AddedAt,
                Product = _mapper.Map<ProductResponse>(f.Product)
            }).ToList();

            return responses;
        }

        public async Task<bool> IsFavoriteAsync(int productId, CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            return await _context.FavoriteProducts
                .AnyAsync(f => f.UserId == userId && f.ProductId == productId, cancellationToken);
        }

        public async Task<bool> AddFavoriteAsync(int productId, CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            // Check if product exists
            var productExists = await _context.Products
                .AnyAsync(p => p.Id == productId, cancellationToken);

            if (!productExists)
                throw new KeyNotFoundException($"Product with ID {productId} not found");

            // Check if already exists
            var exists = await _context.FavoriteProducts
                .AnyAsync(f => f.UserId == userId && f.ProductId == productId, cancellationToken);

            if (exists)
                return false; // Already in favorites

            var favorite = new FavoriteProduct
            {
                UserId = userId,
                ProductId = productId,
                AddedAt = DateTime.UtcNow
            };

            _context.FavoriteProducts.Add(favorite);
            await _context.SaveChangesAsync(cancellationToken);

            return true;
        }

        public async Task<bool> RemoveFavoriteAsync(int productId, CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            var favorite = await _context.FavoriteProducts
                .FirstOrDefaultAsync(f => f.UserId == userId && f.ProductId == productId, cancellationToken);

            if (favorite == null)
                return false; // Not in favorites

            _context.FavoriteProducts.Remove(favorite);
            await _context.SaveChangesAsync(cancellationToken);

            return true;
        }

        public async Task<bool> ToggleFavoriteAsync(int productId, CancellationToken cancellationToken = default)
        {
            var isFavorite = await IsFavoriteAsync(productId, cancellationToken);

            if (isFavorite)
            {
                await RemoveFavoriteAsync(productId, cancellationToken);
                return false;
            }
            else
            {
                await AddFavoriteAsync(productId, cancellationToken);
                return true;
            }
        }

        public async Task<List<int>> SyncFavoritesAsync(List<int> localFavoriteIds, CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            // Get current server favorites
            var serverFavorites = await _context.FavoriteProducts
                .Where(f => f.UserId == userId)
                .Select(f => f.ProductId)
                .ToListAsync(cancellationToken);

            // Favorites that are on server but not in local list - remove them
            var toRemove = serverFavorites.Except(localFavoriteIds).ToList();

            // Favorites that are in local list but not on server - add them
            var toAdd = localFavoriteIds.Except(serverFavorites).ToList();

            // Remove old favorites
            if (toRemove.Any())
            {
                var favoritesToRemove = await _context.FavoriteProducts
                    .Where(f => f.UserId == userId && toRemove.Contains(f.ProductId))
                    .ToListAsync(cancellationToken);
                _context.FavoriteProducts.RemoveRange(favoritesToRemove);
            }

            // Add new favorites (only if products exist)
            if (toAdd.Any())
            {
                var existingProductIds = await _context.Products
                    .Where(p => toAdd.Contains(p.Id))
                    .Select(p => p.Id)
                    .ToListAsync(cancellationToken);

                var newFavorites = existingProductIds.Select(productId => new FavoriteProduct
                {
                    UserId = userId,
                    ProductId = productId,
                    AddedAt = DateTime.UtcNow
                }).ToList();

                _context.FavoriteProducts.AddRange(newFavorites);
            }

            await _context.SaveChangesAsync(cancellationToken);

            // Return the updated server list
            return await GetUserFavoriteIdsAsync(cancellationToken);
        }

        public async Task<int> ClearAllFavoritesAsync(CancellationToken cancellationToken = default)
        {
            var userId = _currentUserService.GetUserId();

            var favorites = await _context.FavoriteProducts
                .Where(f => f.UserId == userId)
                .ToListAsync(cancellationToken);

            var count = favorites.Count;

            _context.FavoriteProducts.RemoveRange(favorites);
            await _context.SaveChangesAsync(cancellationToken);

            return count;
        }
    }
}
