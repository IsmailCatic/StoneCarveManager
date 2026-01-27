using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;

namespace StoneCarveManager.Services.Services
{
    public class ProductImageService
        : BaseCRUDService<ProductImageResponse, ProductImageSearchObject, ProductImage, ProductImageInsertRequest, ProductImageUpdateRequest>,
          IProductImageService
    {
        public ProductImageService(AppDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<ProductImage> ApplyFilter(IQueryable<ProductImage> query, ProductImageSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(pi =>
                    pi.ImageUrl.Contains(search.FTS) ||
                    (pi.AltText != null && pi.AltText.Contains(search.FTS)));
            }

            // Filter by ProductId
            if (search.ProductId.HasValue)
            {
                query = query.Where(pi => pi.ProductId == search.ProductId.Value);
            }

            // Filter by IsPrimary
            if (search.IsPrimary.HasValue)
            {
                query = query.Where(pi => pi.IsPrimary == search.IsPrimary.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(ProductImage entity, ProductImageInsertRequest request)
        {
            // Validate product exists
            var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId);
            if (!productExists)
            {
                throw new InvalidOperationException($"Product with ID {request.ProductId} does not exist.");
            }

            // If setting as primary, unset other primary images for this product
            if (request.IsPrimary)
            {
                var existingPrimary = await _context.ProductImages
                    .Where(pi => pi.ProductId == request.ProductId && pi.IsPrimary)
                    .ToListAsync();

                foreach (var img in existingPrimary)
                {
                    img.IsPrimary = false;
                }
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(ProductImage entity, ProductImageUpdateRequest request)
        {
            // Validate product exists if updating
            if (request.ProductId.HasValue)
            {
                var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId.Value);
                if (!productExists)
                {
                    throw new InvalidOperationException($"Product with ID {request.ProductId} does not exist.");
                }
            }

            // If setting as primary, unset other primary images for this product
            if (request.IsPrimary.HasValue && request.IsPrimary.Value)
            {
                var productId = request.ProductId ?? entity.ProductId;
                var existingPrimary = await _context.ProductImages
                    .Where(pi => pi.ProductId == productId && pi.IsPrimary && pi.Id != entity.Id)
                    .ToListAsync();

                foreach (var img in existingPrimary)
                {
                    img.IsPrimary = false;
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        public async Task<bool> SetPrimaryImageAsync(int productImageId)
        {
            var productImage = await _context.ProductImages.FindAsync(productImageId);
            if (productImage == null)
                return false;

            // Unset other primary images for this product
            var existingPrimary = await _context.ProductImages
                .Where(pi => pi.ProductId == productImage.ProductId && pi.IsPrimary && pi.Id != productImageId)
                .ToListAsync();

            foreach (var img in existingPrimary)
            {
                img.IsPrimary = false;
            }

            productImage.IsPrimary = true;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
