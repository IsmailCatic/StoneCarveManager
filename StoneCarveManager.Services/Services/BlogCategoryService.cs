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
    public class BlogCategoryService
        : BaseCRUDService<BlogCategoryResponse, BlogCategorySearchObject, BlogCategory, BlogCategoryInsertRequest, BlogCategoryUpdateRequest>,
          IBlogCategoryService
    {
        public BlogCategoryService(AppDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<BlogCategory> ApplyFilter(IQueryable<BlogCategory> query, BlogCategorySearchObject? search)
        {
            if (search == null) return query;

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(bc => bc.Name.Contains(search.FTS));
            }

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(bc => bc.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(bc => bc.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public override async Task<BlogCategoryResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.BlogCategories
                .Include(bc => bc.BlogPosts)
                .FirstOrDefaultAsync(bc => bc.Id == id);

            if (entity == null) return null;

            var resp = _mapper.Map<BlogCategoryResponse>(entity);
            resp.PostCount = entity.BlogPosts?.Count ?? 0;
            return resp;
        }

        public override async Task<PagedResult<BlogCategoryResponse>> GetAsync(BlogCategorySearchObject search)
        {
            var query = _context.BlogCategories
                .Include(bc => bc.BlogPosts)
                .AsQueryable();

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
            var items = list.Select(bc =>
            {
                var r = _mapper.Map<BlogCategoryResponse>(bc);
                r.PostCount = bc.BlogPosts?.Count ?? 0;
                return r;
            }).ToList();

            return new PagedResult<BlogCategoryResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        protected override async Task BeforeInsert(BlogCategory entity, BlogCategoryInsertRequest request)
        {
            var exists = await _context.BlogCategories.AnyAsync(bc => bc.Name.ToLower() == request.Name.ToLower());
            if (exists)
                throw new InvalidOperationException($"Blog category '{request.Name}' already exists.");

            entity.CreatedAt = DateTime.UtcNow;

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(BlogCategory entity, BlogCategoryUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != entity.Name)
            {
                var exists = await _context.BlogCategories.AnyAsync(bc => bc.Name.ToLower() == request.Name.ToLower() && bc.Id != entity.Id);
                if (exists)
                    throw new InvalidOperationException($"Blog category '{request.Name}' already exists.");
            }

            if (request.Name != null)
                entity.UpdatedAt = DateTime.UtcNow;

            await base.BeforeUpdate(entity, request);
        }
    }
}