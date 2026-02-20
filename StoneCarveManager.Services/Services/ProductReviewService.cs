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
    public class ProductReviewService
        : BaseCRUDService<ProductReviewResponse, ProductReviewSearchObject, ProductReview, ProductReviewInsertRequest, ProductReviewUpdateRequest>,
          IProductReviewService
    {
        public ProductReviewService(AppDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public async Task<ProductReviewResponse> InsertAsync(ProductReviewInsertRequest request)
        {
            var entity = _mapper.Map<ProductReview>(request);
            entity.CreatedAt = DateTime.UtcNow;

            _context.ProductReviews.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati puni response sa User nazivom itd.
            entity = await _context.ProductReviews
                .Include(x => x.User)
                .Include(x => x.Product)
                .Include(x => x.Order)
                .FirstAsync(x => x.Id == entity.Id);

            return _mapper.Map<ProductReviewResponse>(entity);
        }

        public async Task<List<ProductReviewResponse>> GetByProductIdAsync(int productId)
        {
            var list = await _context.ProductReviews
                .Include(x => x.User)
                .Where(x => x.ProductId == productId && x.IsApproved)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return list.Select(x => MapToResponse(x)).ToList();
        }

        public async Task<ProductReviewResponse?> GetByOrderIdAsync(int orderId)
        {
            var entity = await _context.ProductReviews
                .Include(x => x.User)
                .Include(x => x.Product)
                .FirstOrDefaultAsync(x => x.OrderId == orderId);

            return entity == null ? null : MapToResponse(entity);
        }

        public async Task<PagedResult<ProductReviewResponse>> GetAsync(ProductReviewSearchObject search)
        {
            var query = _context.ProductReviews
                .Include(x => x.User)
                .Include(x => x.Product)
                .Include(x => x.Order)
                .AsQueryable();

            // Primijeni filtere
            query = ApplyFilter(query, search);

            // ? Uvijek ra?unaj total count
            int? totalCount = await query.CountAsync();

            // Pagination
            if (search != null && !search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value)
                                 .Take(search.PageSize.Value);
                }
            }

            var list = await query.OrderByDescending(x => x.CreatedAt).ToListAsync();
            var items = list.Select(MapToResponse).ToList();

            return new PagedResult<ProductReviewResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        public async Task<bool> ApproveReviewAsync(int id)
        {
            var entity = await _context.ProductReviews.FindAsync(id);
            if (entity == null)
                return false;

            entity.IsApproved = true;
            entity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RejectReviewAsync(int id)
        {
            var entity = await _context.ProductReviews.FindAsync(id);
            if (entity == null)
                return false;

            entity.IsApproved = false;
            entity.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return true;
        }

        // Mapiraj response, dodaš ovdje po potrebi (i custom flagove/VerifiedPurchase)
        private ProductReviewResponse MapToResponse(ProductReview entity)
        {
            return new ProductReviewResponse
            {
                Id = entity.Id,
                Rating = entity.Rating,
                Comment = entity.Comment,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                UserId = entity.UserId,
                UserName = $"{entity.User?.FirstName} {entity.User?.LastName}".Trim(), // ? Vra?a ime i prezime
                ProductId = entity.ProductId,
                ProductName = entity.Product?.Name,
                OrderId = entity.OrderId,
                IsApproved = entity.IsApproved
            };
        }


        protected override IQueryable<ProductReview> ApplyFilter(IQueryable<ProductReview> query, ProductReviewSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(pr => pr.Comment.Contains(search.FTS));
            }

            // Filter by ProductId
            if (search.ProductId.HasValue)
            {
                query = query.Where(pr => pr.ProductId == search.ProductId.Value);
            }

            // Filter by UserId
            if (search.UserId.HasValue)
            {
                query = query.Where(pr => pr.UserId == search.UserId.Value);
            }

            // Filter by IsApproved
            if (search.IsApproved.HasValue)
            {
                query = query.Where(pr => pr.IsApproved == search.IsApproved.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(ProductReview entity, ProductReviewInsertRequest request)
        {
            // Validate user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
            if (!userExists)
            {
                throw new InvalidOperationException($"User with ID {request.UserId} does not exist.");
            }

            // Validate product exists if provided
            if (request.ProductId.HasValue)
            {
                var productExists = await _context.Products.AnyAsync(p => p.Id == request.ProductId.Value);
                if (!productExists)
                {
                    throw new InvalidOperationException($"Product with ID {request.ProductId} does not exist.");
                }
            }

            // Validate order exists if provided
            if (request.OrderId.HasValue)
            {
                var orderExists = await _context.Orders.AnyAsync(o => o.Id == request.OrderId.Value);
                if (!orderExists)
                {
                    throw new InvalidOperationException($"Order with ID {request.OrderId} does not exist.");
                }
            }

            await base.BeforeInsert(entity, request);
        }

        //public async Task<bool> ApproveReviewAsync(int reviewId)
        //{
        //    var review = await _context.ProductReviews.FindAsync(reviewId);
        //    if (review == null)
        //        return false;

        //    review.IsApproved = true;
        //    review.UpdatedAt = DateTime.UtcNow;
        //    await _context.SaveChangesAsync();
        //    return true;
        //}

        //public async Task<bool> RejectReviewAsync(int reviewId)
        //{
        //    var review = await _context.ProductReviews.FindAsync(reviewId);
        //    if (review == null)
        //        return false;

        //    review.IsApproved = false;
        //    review.UpdatedAt = DateTime.UtcNow;
        //    await _context.SaveChangesAsync();
        //    return true;
        //}
    }
}
