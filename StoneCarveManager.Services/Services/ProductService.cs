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
    public class ProductService
        : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductInsertRequest, ProductUpdateRequest>,
          IProductService
    {
        private readonly IFileService _fileService;
        public ProductService(AppDbContext context, IMapper mapper, IFileService fileService    )
            : base(context, mapper)
        {
            _fileService = fileService;
        }

        public override async Task<PagedResult<ProductResponse>> GetAsync(ProductSearchObject search)
        {
            var query = _context.Products
                .Include(p => p.Images)
                .Include(p => p.Reviews)
                .AsQueryable();

            // Apply filter & paginaciju kao u bazi
            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
                totalCount = await query.CountAsync();

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                    query = query.Skip(search.Page.Value * search.PageSize.Value)
                                 .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            var items = list.Select(p => _mapper.Map<ProductResponse>(p)).ToList();

            return new PagedResult<ProductResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        // OVERRIDE ZA GET BY ID (jedan proizvod sa slikama, kategorijom itd.)
        public override async Task<ProductResponse?> GetByIdAsync(int id)
        {
            var product = await _context.Products
                .Include(p => p.Images)
                .Include(p => p.Reviews)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null)
                return null;

            return _mapper.Map<ProductResponse>(product);
        }



        public async Task<ProductImageResponse> AddProductImageAsync(int productId, ProductImageUploadRequest request, CancellationToken cancellationToken)
        {
            var product = await _context.Products.Include(p => p.Images)
                                                 .FirstOrDefaultAsync(p => p.Id == productId, cancellationToken);
            if (product == null)
                throw new KeyNotFoundException("Product not found");

            var imageUrl = await _fileService.UploadAsync(request.File, "product-images", null, cancellationToken);

            if (request.IsPrimary)
            {
                // Reset all other images to not primary
                foreach (var img in product.Images)
                    img.IsPrimary = false;
            }

            var entity = new ProductImage
            {
                ImageUrl = imageUrl,
                AltText = request.AltText,
                IsPrimary = request.IsPrimary,
                DisplayOrder = request.DisplayOrder,
                ProductId = productId,
                CreatedAt = DateTime.UtcNow
            };

            _context.ProductImages.Add(entity);
            await _context.SaveChangesAsync(cancellationToken);

            // Map to response
            return new ProductImageResponse
            {
                Id = entity.Id,
                ImageUrl = entity.ImageUrl,
                AltText = entity.AltText,
                IsPrimary = entity.IsPrimary,
                DisplayOrder = entity.DisplayOrder,
                CreatedAt = entity.CreatedAt,
                ProductId = entity.ProductId,
                ProductName = product.Name
            };
        }

        public async Task DeleteProductImageAsync(int productId, int imageId, CancellationToken cancellationToken)
        {
            var image = await _context.ProductImages.FirstOrDefaultAsync(x => x.Id == imageId && x.ProductId == productId, cancellationToken);
            if (image == null)
                throw new KeyNotFoundException("Image not found");

            await _fileService.DeleteAsync(image.ImageUrl, "product-images", cancellationToken);

            _context.ProductImages.Remove(image);
            await _context.SaveChangesAsync(cancellationToken);
        }

        protected override IQueryable<Product> ApplyFilter(IQueryable<Product> query, ProductSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(p =>
                    p.Name.Contains(search.FTS) ||
                    p.Description.Contains(search.FTS));
            }

            // Filter by CategoryId
            if (search.CategoryId.HasValue)
            {
                query = query.Where(p => p.CategoryId == search.CategoryId.Value);
            }

            // Filter by MaterialId
            if (search.MaterialId.HasValue)
            {
                query = query.Where(p => p.MaterialId == search.MaterialId.Value);
            }

            // Filter by IsActive
            if (search.IsActive.HasValue)
            {
                query = query.Where(p => p.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Product entity, ProductInsertRequest request)
        {
            // Validate category exists
            var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists)
            {
                throw new InvalidOperationException($"Category with ID {request.CategoryId} does not exist.");
            }

            // Validate material exists
            var materialExists = await _context.Materials.AnyAsync(m => m.Id == request.MaterialId);
            if (!materialExists)
            {
                throw new InvalidOperationException($"Material with ID {request.MaterialId} does not exist.");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Product entity, ProductUpdateRequest request)
        {
            // Validate category exists if updating
            if (request.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId.Value);
                if (!categoryExists)
                {
                    throw new InvalidOperationException($"Category with ID {request.CategoryId} does not exist.");
                }
            }

            // Validate material exists if updating
            if (request.MaterialId.HasValue)
            {
                var materialExists = await _context.Materials.AnyAsync(m => m.Id == request.MaterialId.Value);
                if (!materialExists)
                {
                    throw new InvalidOperationException($"Material with ID {request.MaterialId} does not exist.");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Product entity)
        {
            var hasOrders = await _context.OrderItems.AnyAsync(oi => oi.ProductId == entity.Id);

            if (hasOrders)
            {
                throw new InvalidOperationException($"Cannot delete product '{entity.Name}' because it has associated orders.");
            }

            await base.BeforeDelete(entity);
        }

        public async Task<bool> IncrementViewCountAsync(int productId)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null)
                return false;

            product.ViewCount++;
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
