using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.ProductStateMachine;

namespace StoneCarveManager.Services.Services
{
    public class ProductService
        : BaseCRUDService<ProductResponse, ProductSearchObject, Product, ProductInsertRequest, ProductUpdateRequest>,
          IProductService
    {
        private readonly IFileService _fileService;
        private readonly ILogger<ProductService> _logger;
        public BaseProductState BaseProductState { get; set; }

        public ProductService(AppDbContext context, IMapper mapper, IFileService fileService, BaseProductState baseProductState, ILogger<ProductService> logger)
            : base(context, mapper)
        {
            _fileService = fileService;
            BaseProductState = baseProductState;
            _logger = logger;
        }

        public override async Task<ProductResponse> CreateAsync(ProductInsertRequest request)
        {
            var state = BaseProductState.CreateState("initial");
            return state.Insert(request);
        }

        public override async Task<ProductResponse?> UpdateAsync(int id, ProductUpdateRequest request)
        {
            var entity = await _context.Products.FindAsync(id);
            if (entity == null)
                return null;

            var state = BaseProductState.CreateState(entity.ProductState);
            return state.Update(id, request);
        }

        public ProductResponse Activate(int id)
        {
            var entity = _context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            var state = BaseProductState.CreateState(entity.ProductState);
            return state.Activate(id);
        }

        public ProductResponse Hide(int id)
        {
            var entity = _context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            var state = BaseProductState.CreateState(entity.ProductState);
            return state.Hide(id);
        }

        public ProductResponse MakeService(int id)
        {
            var entity = _context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            var state = BaseProductState.CreateState(entity.ProductState);
            return state.MakeService(id);
        }

        public ProductResponse AddToPortfolio(int id)
        {
            var entity = _context.Products.Find(id);
            if (entity == null)
                throw new KeyNotFoundException($"Product with ID {id} not found");

            var state = BaseProductState.CreateState(entity.ProductState);
            return state.AddToPortfolio(id);
        }

        public List<string> AllowedActions(int id)
        {
            _logger.LogInformation($"Allowed actions called for: {id}");

            if (id <= 0)
            {
                var state = BaseProductState.CreateState("initial");
                return state.AllowedActions(null);
            }
            else
            {
                var entity = _context.Products.Find(id);
                if (entity == null)
                    throw new KeyNotFoundException($"Product with ID {id} not found");

                var state = BaseProductState.CreateState(entity.ProductState);
                return state.AllowedActions(entity);
            }
        }

        public override async Task<PagedResult<ProductResponse>> GetAsync(ProductSearchObject search)
        {
            var query = _context.Products
                .Include(p => p.Images)
                .Include(p => p.Reviews)
                .Include(p => p.Category)  // Include Category for CategoryName filtering
                .AsQueryable();

            // Apply filter & paginaciju kao u bazi
            query = ApplyFilter(query, search);

            // ? Uvijek ra?unaj total count
            int? totalCount = await query.CountAsync();

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

            // Filter by CategoryName (for portfolio filtering)
            if (!string.IsNullOrWhiteSpace(search.CategoryName))
            {
                query = query.Where(p => p.Category.Name == search.CategoryName);
            }

            // Filter by MaterialId
            if (search.MaterialId.HasValue)
            {
                query = query.Where(p => p.MaterialId == search.MaterialId.Value);
            }

            // Filter by ProductState (equals)
            if (!string.IsNullOrWhiteSpace(search.ProductState))
            {
                query = query.Where(p => p.ProductState == search.ProductState);
            }

            // Filter by ProductState (not equals - exclude)
            if (!string.IsNullOrWhiteSpace(search.ProductStateExclude))
            {
                query = query.Where(p => p.ProductState != search.ProductStateExclude);
            }

            // Filter by CompletionYear (for portfolio filtering)
            if (search.CompletionYear.HasValue)
            {
                query = query.Where(p => p.CompletionYear == search.CompletionYear.Value);
            }

            // Filter by Price Range
            if (search.MinPrice.HasValue)
            {
                query = query.Where(p => p.Price >= search.MinPrice.Value);
            }

            if (search.MaxPrice.HasValue)
            {
                query = query.Where(p => p.Price <= search.MaxPrice.Value);
            }

            // Apply Sorting
            if (!string.IsNullOrWhiteSpace(search.SortBy))
            {
                query = search.SortBy.ToLower() switch
                {
                    "price_asc" => query.OrderBy(p => p.Price),
                    "price_desc" => query.OrderByDescending(p => p.Price),
                    "name_asc" => query.OrderBy(p => p.Name),
                    "name_desc" => query.OrderByDescending(p => p.Name),
                    "newest" => query.OrderByDescending(p => p.CreatedAt),
                    "oldest" => query.OrderBy(p => p.CreatedAt),
                    "popular" => query.OrderByDescending(p => p.ViewCount),
                    _ => query.OrderBy(p => p.Id) // Default sorting
                };
            }
            else
            {
                // Default sorting: newest first
                query = query.OrderByDescending(p => p.CreatedAt);
            }

            return query;
        }

        protected override async Task BeforeInsert(Product entity, ProductInsertRequest request)
        {
            // Validate category exists if provided
            if (request.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.Id == request.CategoryId.Value);
                if (!categoryExists)
                {
                    throw new InvalidOperationException($"Category with ID {request.CategoryId} does not exist.");
                }
            }

            // Validate material exists if provided
            if (request.MaterialId.HasValue)
            {
                var materialExists = await _context.Materials.AnyAsync(m => m.Id == request.MaterialId.Value);
                if (!materialExists)
                {
                    throw new InvalidOperationException($"Material with ID {request.MaterialId} does not exist.");
                }
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
