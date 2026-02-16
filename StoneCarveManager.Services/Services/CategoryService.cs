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
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class CategoryService
         : BaseCRUDService<CategoryResponse, CategorySearchObject, Category, CategoryInsertRequest, CategoryUpdateRequest>,
           ICategoryService
    {
        private readonly IFileService _fileService;

        public CategoryService(AppDbContext context, IMapper mapper, IFileService fileService)
            : base(context, mapper)
        {
            _fileService = fileService;
        }

        // ✅ Override filter logic
        protected override IQueryable<Category> ApplyFilter(IQueryable<Category> query, CategorySearchObject search)
        {
            // FTS (Full-Text Search) - traži po svim poljima
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(c =>
                    c.Name.Contains(search.FTS) ||
                    c.Description.Contains(search.FTS));
            }

            // Filter by Name
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(c => c.Name.Contains(search.Name));
            }

            // Filter by IsActive
            if (search.IsActive.HasValue)
            {
                query = query.Where(c => c.IsActive == search.IsActive.Value);
            }

            // Include product count if requested
            if (search.IncludeProductCount)
            {
                query = query.Include(c => c.Products);
            }

            return query;
        }

        // ✅ Override BeforeInsert - validation logic
        protected override async Task BeforeInsert(Category entity, CategoryInsertRequest request)
        {
            // Check if category with same name exists
            var exists = await _context.Categories
                .AnyAsync(c => c.Name.ToLower() == request.Name.ToLower());

            if (exists)
            {
                throw new InvalidOperationException($"Category '{request.Name}' already exists.");
            }

            await base.BeforeInsert(entity, request);
        }

        // ✅ Override BeforeUpdate - validation logic
        protected override async Task BeforeUpdate(Category entity, CategoryUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != entity.Name)
            {
                var exists = await _context.Categories
                    .AnyAsync(c => c.Name.ToLower() == request.Name.ToLower() && c.Id != entity.Id);

                if (exists)
                {
                    throw new InvalidOperationException($"Category '{request.Name}' already exists.");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        // ✅ Override BeforeDelete - prevent deletion if category has products
        protected override async Task BeforeDelete(Category entity)
        {
            var hasProducts = await _context.Products.AnyAsync(p => p.CategoryId == entity.Id);

            if (hasProducts)
            {
                throw new InvalidOperationException($"Cannot delete category '{entity.Name}' because it has products.");
            }

            await base.BeforeDelete(entity);
        }

        /// <summary>
        /// Upload category image to Azure Blob Storage
        /// Replaces existing image if present
        /// </summary>
        public async Task<string> UploadCategoryImageAsync(
            int categoryId,
            CategoryImageUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            var category = await _context.Categories.FindAsync(new object[] { categoryId }, cancellationToken);
            
            if (category == null)
                throw new KeyNotFoundException($"Category with ID {categoryId} not found.");

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
            if (!string.IsNullOrWhiteSpace(category.ImageUrl))
            {
                try
                {
                    await _fileService.DeleteAsync(category.ImageUrl, "category-images", cancellationToken);
                }
                catch
                {
                    // Log error but continue with upload
                }
            }

            // Upload new image
            var imageUrl = await _fileService.UploadAsync(
                request.File,
                "category-images",  // ✅ Container name
                null,                // Auto-generate filename
                cancellationToken
            );

            // Update category record
            category.ImageUrl = imageUrl;
            category.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync(cancellationToken);

            return imageUrl;
        }

        /// <summary>
        /// Delete category image from Azure Blob Storage
        /// </summary>
        public async Task<bool> DeleteCategoryImageAsync(
            int categoryId,
            CancellationToken cancellationToken = default)
        {
            var category = await _context.Categories.FindAsync(new object[] { categoryId }, cancellationToken);
            
            if (category == null)
                return false;

            if (string.IsNullOrWhiteSpace(category.ImageUrl))
                return false;

            try
            {
                await _fileService.DeleteAsync(category.ImageUrl, "category-images", cancellationToken);
                
                category.ImageUrl = null;
                category.UpdatedAt = DateTime.UtcNow;
                
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
