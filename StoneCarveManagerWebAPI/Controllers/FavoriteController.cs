using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Services.IServices;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FavoriteController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;

        public FavoriteController(IFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        [HttpGet("ids")]
        public async Task<ActionResult<List<int>>> GetFavoriteIds(CancellationToken cancellationToken = default)
        {
            try
            {
                var favoriteIds = await _favoriteService.GetUserFavoriteIdsAsync(cancellationToken);
                return Ok(favoriteIds);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

   
        [HttpGet]
        public async Task<ActionResult<List<FavoriteProductResponse>>> GetFavorites(CancellationToken cancellationToken = default)
        {
            try
            {
                var favorites = await _favoriteService.GetUserFavoritesAsync(cancellationToken);
                return Ok(favorites);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

   
        [HttpGet("{productId}")]
        public async Task<ActionResult<bool>> IsFavorite(
            int productId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var isFavorite = await _favoriteService.IsFavoriteAsync(productId, cancellationToken);
                return Ok(isFavorite);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }


        [HttpPost("{productId}")]
        public async Task<IActionResult> AddFavorite(
            int productId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var added = await _favoriteService.AddFavoriteAsync(productId, cancellationToken);

                if (!added)
                    return Ok(new { message = "Product is already in favorites", productId });

                return Ok(new { message = "Product added to favorites", productId });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

    
        [HttpDelete("{productId}")]
        public async Task<IActionResult> RemoveFavorite(
            int productId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var removed = await _favoriteService.RemoveFavoriteAsync(productId, cancellationToken);

                if (!removed)
                    return NotFound(new { message = "Product is not in favorites" });

                return Ok(new { message = "Product removed from favorites", productId });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

   
        [HttpPost("{productId}/toggle")]
        public async Task<ActionResult<bool>> ToggleFavorite(
            int productId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var isNowFavorite = await _favoriteService.ToggleFavoriteAsync(productId, cancellationToken);
                return Ok(new
                {
                    message = isNowFavorite ? "Added to favorites" : "Removed from favorites",
                    isFavorite = isNowFavorite,
                    productId
                });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

        [HttpPost("sync")]
        public async Task<ActionResult<List<int>>> SyncFavorites(
            [FromBody] List<int> localFavoriteIds,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var serverFavorites = await _favoriteService.SyncFavoritesAsync(
                    localFavoriteIds ?? new List<int>(),
                    cancellationToken);

                return Ok(new
                {
                    message = "Favorites synced successfully",
                    favorites = serverFavorites
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }

     
        [HttpDelete]
        public async Task<IActionResult> ClearAllFavorites(CancellationToken cancellationToken = default)
        {
            try
            {
                var count = await _favoriteService.ClearAllFavoritesAsync(cancellationToken);
                return Ok(new
                {
                    message = "All favorites cleared",
                    count
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
        }
    }
}
