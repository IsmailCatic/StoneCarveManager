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
    public class BlogPostService
        : BaseCRUDService<BlogPostResponse, BlogPostSearchObject, BlogPost, BlogPostInsertRequest, BlogPostUpdateRequest>,
          IBlogPostService
    {
        private readonly IFileService _fileService;
        public BlogPostService(AppDbContext context, IMapper mapper, IFileService fileService   )
            : base(context, mapper)
        {
            _fileService = fileService;
        }

        public override async Task<PagedResult<BlogPostResponse>> GetAsync(BlogPostSearchObject search)
        {
            var query = _context.BlogPosts
                .Include(bp => bp.Images)
                .Include(bp => bp.Category)
                .AsQueryable();

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
            var items = list.Select(bp => _mapper.Map<BlogPostResponse>(bp)).ToList();

            return new PagedResult<BlogPostResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        // Get by ID + slike
        public override async Task<BlogPostResponse?> GetByIdAsync(int id)
        {
            var blogPost = await _context.BlogPosts
                .Include(bp => bp.Images)
                .Include(bp => bp.Category)
                .FirstOrDefaultAsync(bp => bp.Id == id);

            if (blogPost == null)
                return null;

            return _mapper.Map<BlogPostResponse>(blogPost);
        }

        public async Task<BlogImageResponse> AddBlogImageAsync(int blogPostId, BlogImageUploadRequest request, CancellationToken cancellationToken)
        {
            var blogPost = await _context.BlogPosts.Include(bp => bp.Images).FirstOrDefaultAsync(bp => bp.Id == blogPostId, cancellationToken);
            if (blogPost == null) throw new KeyNotFoundException("Blog post not found");

            var imageUrl = await _fileService.UploadAsync(request.File, "blog-images");

            var entity = new BlogImage
            {
                ImageUrl = imageUrl,
                AltText = request.AltText,
                DisplayOrder = request.DisplayOrder,
                BlogPostId = blogPostId,
                UploadedAt = DateTime.UtcNow
            };

            _context.BlogImages.Add(entity);
            await _context.SaveChangesAsync(cancellationToken);

            return new BlogImageResponse
            {
                Id = entity.Id,
                ImageUrl = entity.ImageUrl,
                AltText = entity.AltText,
                DisplayOrder = entity.DisplayOrder,
                UploadedAt = entity.UploadedAt,
                BlogPostId = entity.BlogPostId
            };
        }

        protected override IQueryable<BlogPost> ApplyFilter(IQueryable<BlogPost> query, BlogPostSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(bp =>
                    bp.Title.Contains(search.FTS) ||
                    bp.Content.Contains(search.FTS) ||
                    (bp.Summary != null && bp.Summary.Contains(search.FTS)));
            }

            // Filter by IsPublished
            if (search.IsPublished.HasValue)
            {
                query = query.Where(bp => bp.IsPublished == search.IsPublished.Value);
            }

            // Filter by AuthorId
            if (search.AuthorId.HasValue)
            {
                query = query.Where(bp => bp.AuthorId == search.AuthorId.Value);
            }

            if (search.CategoryId.HasValue)
                query = query.Where(bp => bp.CategoryId == search.CategoryId.Value);

            return query;
        }

        protected override async Task BeforeInsert(BlogPost entity, BlogPostInsertRequest request)
        {
            // Validate author exists
            var authorExists = await _context.Users.AnyAsync(u => u.Id == request.AuthorId);
            if (!authorExists)
            {
                throw new InvalidOperationException($"Author with ID {request.AuthorId} does not exist.");
            }

            // Set PublishedAt if publishing
            if (request.IsPublished)
            {
                entity.PublishedAt = DateTime.UtcNow;
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(BlogPost entity, BlogPostUpdateRequest request)
        {
            // Validate author exists if updating
            if (request.AuthorId.HasValue)
            {
                var authorExists = await _context.Users.AnyAsync(u => u.Id == request.AuthorId.Value);
                if (!authorExists)
                {
                    throw new InvalidOperationException($"Author with ID {request.AuthorId} does not exist.");
                }
            }

            // Set PublishedAt if newly publishing
            if (request.IsPublished.HasValue && request.IsPublished.Value && !entity.IsPublished)
            {
                entity.PublishedAt = DateTime.UtcNow;
            }

            await base.BeforeUpdate(entity, request);
        }

        public async Task<bool> IncrementViewCountAsync(int blogPostId)
        {
            var blogPost = await _context.BlogPosts.FindAsync(blogPostId);
            if (blogPost == null)
                return false;

            blogPost.ViewCount++;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> PublishAsync(int blogPostId)
        {
            var blogPost = await _context.BlogPosts.FindAsync(blogPostId);
            if (blogPost == null)
                return false;

            if (!blogPost.IsPublished)
            {
                blogPost.IsPublished = true;
                blogPost.PublishedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }

            return true;
        }
    }
}
