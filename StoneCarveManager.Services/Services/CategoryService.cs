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
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class CategoryService
         : BaseCRUDService<CategoryResponse, CategorySearchObject, Category, CategoryInsertRequest, CategoryUpdateRequest>,
           ICategoryService
    {
        public CategoryService(AppDbContext context, IMapper mapper)
            : base(context, mapper)
        {
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
    }
}
