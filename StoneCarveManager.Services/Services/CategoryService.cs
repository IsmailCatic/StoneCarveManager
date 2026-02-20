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

        // ✅ Override BeforeInsert - validation logic + hierarchical support
        protected override async Task BeforeInsert(Category entity, CategoryInsertRequest request)
        {
            // Check if category with same name exists
            var exists = await _context.Categories
                .AnyAsync(c => c.Name.ToLower() == request.Name.ToLower());

            if (exists)
            {
                throw new InvalidOperationException($"Category '{request.Name}' already exists.");
            }

            // ✅ Validate parent category exists if ParentCategoryId is provided
            if (request.ParentCategoryId.HasValue)
            {
                var parentExists = await _context.Categories
                    .AnyAsync(c => c.Id == request.ParentCategoryId.Value);

                if (!parentExists)
                {
                    throw new InvalidOperationException($"Parent category with ID {request.ParentCategoryId.Value} does not exist.");
                }
            }

            await base.BeforeInsert(entity, request);
        }

        // ✅ Override BeforeUpdate - validation logic + hierarchical support
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

            // ✅ Validate parent category exists if ParentCategoryId is being updated
            if (request.ParentCategoryId.HasValue)
            {
                // Prevent self-reference
                if (request.ParentCategoryId.Value == entity.Id)
                {
                    throw new InvalidOperationException("Category cannot be its own parent.");
                }

                var parentExists = await _context.Categories
                    .AnyAsync(c => c.Id == request.ParentCategoryId.Value);

                if (!parentExists)
                {
                    throw new InvalidOperationException($"Parent category with ID {request.ParentCategoryId.Value} does not exist.");
                }

                // Prevent circular reference (parent cannot be a child of this category)
                var wouldCreateCircular = await IsCircularReference(entity.Id, request.ParentCategoryId.Value);
                if (wouldCreateCircular)
                {
                    throw new InvalidOperationException("Cannot set parent category: would create circular reference.");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        // ✅ Override BeforeDelete - prevent deletion if category has products or child categories
        protected override async Task BeforeDelete(Category entity)
        {
            var hasProducts = await _context.Categories
                .Where(c => c.Id == entity.Id)
                .Include(c => c.Products)
                .SelectMany(c => c.Products)
                .AnyAsync();

            if (hasProducts)
            {
                throw new InvalidOperationException($"Cannot delete category '{entity.Name}' because it has products.");
            }

            // ✅ Check for child categories
            var hasChildren = await _context.Categories
                .AnyAsync(c => c.ParentCategoryId == entity.Id);

            if (hasChildren)
            {
                throw new InvalidOperationException($"Cannot delete category '{entity.Name}' because it has subcategories.");
            }

            await base.BeforeDelete(entity);
        }

        // ✅ Helper method to check for circular references
        private async Task<bool> IsCircularReference(int categoryId, int proposedParentId)
        {
            var currentParentId = proposedParentId;

            while (currentParentId != null)
            {
                if (currentParentId == categoryId)
                    return true; // Circular reference detected

                var parent = await _context.Categories
                    .Where(c => c.Id == currentParentId)
                    .Select(c => c.ParentCategoryId)
                    .FirstOrDefaultAsync();

                currentParentId = parent ?? 0;
                if (currentParentId == 0) break;
            }

            return false;
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

        // ✅ Override GetAsync to include hierarchical data
        public override async Task<PagedResult<CategoryResponse>> GetAsync(CategorySearchObject search)
        {
            var query = _context.Categories
                .Include(c => c.ParentCategory)
                .Include(c => c.ChildCategories)
                .Include(c => c.Products)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = await query.CountAsync();

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                    query = query.Skip(search.Page.Value * search.PageSize.Value)
                                 .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            var items = list.Select(c => _mapper.Map<CategoryResponse>(c)).ToList();

            return new PagedResult<CategoryResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        // ✅ Override GetByIdAsync to include hierarchical data
        public override async Task<CategoryResponse?> GetByIdAsync(int id)
        {
            var category = await _context.Categories
                .Include(c => c.ParentCategory)
                .Include(c => c.ChildCategories)
                .Include(c => c.Products)
                .FirstOrDefaultAsync(c => c.Id == id);

            if (category == null)
                return null;

            return _mapper.Map<CategoryResponse>(category);
        }
    }
}
