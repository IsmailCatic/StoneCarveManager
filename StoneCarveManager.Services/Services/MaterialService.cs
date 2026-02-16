using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class MaterialService
        : BaseCRUDService<MaterialResponse, MaterialSearchObject, Material, MaterialInsertRequest, MaterialUpdateRequest>,
          IMaterialService
    {
        private readonly IFileService _fileService;

        public MaterialService(AppDbContext context, IMapper mapper, IFileService fileService)
            : base(context, mapper)
        {
            _fileService = fileService;
        }

        protected override IQueryable<Material> ApplyFilter(IQueryable<Material> query, MaterialSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(m =>
                    m.Name.Contains(search.FTS) ||
                    m.Description.Contains(search.FTS) ||
                    m.Unit.Contains(search.FTS));
            }

            // Filter by IsActive
            if (search.IsActive.HasValue)
            {
                query = query.Where(m => m.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Material entity, MaterialInsertRequest request)
        {
            var exists = await _context.Materials
                .AnyAsync(m => m.Name.ToLower() == request.Name.ToLower());

            if (exists)
            {
                throw new InvalidOperationException($"Material '{request.Name}' already exists.");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Material entity, MaterialUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != entity.Name)
            {
                var exists = await _context.Materials
                    .AnyAsync(m => m.Name.ToLower() == request.Name.ToLower() && m.Id != entity.Id);

                if (exists)
                {
                    throw new InvalidOperationException($"Material '{request.Name}' already exists.");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Material entity)
        {
            var hasProducts = await _context.Products.AnyAsync(p => p.MaterialId == entity.Id);

            if (hasProducts)
            {
                throw new InvalidOperationException($"Cannot delete material '{entity.Name}' because it has products.");
            }

            await base.BeforeDelete(entity);
        }

        /// <summary>
        /// Upload material image to Azure Blob Storage
        /// Replaces existing image if present
        /// </summary>
        public async Task<string> UploadMaterialImageAsync(
            int materialId,
            MaterialImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            var material = await _context.Materials.FindAsync(new object[] { materialId }, cancellationToken);

            if (material == null)
                throw new KeyNotFoundException($"Material with ID {materialId} not found.");

            // Validate file
            if (request.File == null || request.File.Length == 0)
                throw new ArgumentException("File is required");

            // Validate file type
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(request.File.FileName).ToLowerInvariant();

            if (!allowedExtensions.Contains(extension))
                throw new ArgumentException("Only JPG and PNG files are allowed");

            // Validate file size (max 5MB)
            if (request.File.Length > 5 * 1024 * 1024)
                throw new ArgumentException("File size must be less than 5MB");

            // Delete old image if exists
            if (!string.IsNullOrWhiteSpace(material.ImageUrl))
            {
                try
                {
                    await _fileService.DeleteAsync(material.ImageUrl, "material-images", cancellationToken);
                }
                catch
                {
                    // Log error but continue with upload
                }
            }

            // Upload new image
            var imageUrl = await _fileService.UploadAsync(
                request.File,
                "material-images",  // ? Container name
                null,                // Auto-generate filename
                cancellationToken
            );

            // Update material record
            material.ImageUrl = imageUrl;
            material.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync(cancellationToken);

            return imageUrl;
        }

        /// <summary>
        /// Delete material image from Azure Blob Storage
        /// </summary>
        public async Task<bool> DeleteMaterialImageAsync(
            int materialId,
            CancellationToken cancellationToken = default)
        {
            var material = await _context.Materials.FindAsync(new object[] { materialId }, cancellationToken);

            if (material == null)
                return false;

            if (string.IsNullOrWhiteSpace(material.ImageUrl))
                return false;

            try
            {
                await _fileService.DeleteAsync(material.ImageUrl, "material-images", cancellationToken);

                material.ImageUrl = null;
                material.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync(cancellationToken);

                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
