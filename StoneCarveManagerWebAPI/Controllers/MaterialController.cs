using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.IServices;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManagerWebAPI.Controllers
{
    public class MaterialController
        : BaseCRUDController<MaterialResponse, MaterialSearchObject, MaterialInsertRequest, MaterialUpdateRequest>
    {
        private readonly IMaterialService _materialService;

        public MaterialController(IMaterialService service) : base(service)
        {
            _materialService = service;
        }

        /// <summary>
        /// Upload material image
        /// Replaces existing image if present
        /// </summary>
        /// <param name="id">Material ID</param>
        /// <param name="request">Image upload request</param>
        /// <param name="cancellationToken"></param>
        /// <returns>URL of uploaded image</returns>
        [HttpPost("{id}/image")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> UploadImage(
            int id,
            [FromForm] MaterialImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var imageUrl = await _materialService.UploadMaterialImageAsync(id, request, cancellationToken);
                return Ok(new { imageUrl });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Delete material image
        /// Sets ImageUrl to null
        /// </summary>
        /// <param name="id">Material ID</param>
        /// <param name="cancellationToken"></param>
        [HttpDelete("{id}/image")]
        [Authorize(Roles = "Admin,Employee")]
        public async Task<IActionResult> DeleteImage(
            int id,
            CancellationToken cancellationToken = default)
        {
            var deleted = await _materialService.DeleteMaterialImageAsync(id, cancellationToken);
            
            if (!deleted)
                return NotFound(new { message = "Material not found or no image to delete" });
            
            return NoContent();
        }
    }
}
