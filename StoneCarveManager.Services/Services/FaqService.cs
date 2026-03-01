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
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class FaqService
        : BaseCRUDService<FaqResponse, FaqSearchObject, Faq, FaqInsertRequest, FaqUpdateRequest>,
          IFaqService
    {
        public FaqService(AppDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Faq> ApplyFilter(IQueryable<Faq> query, FaqSearchObject search)
        {
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(f =>
                    f.Question.Contains(search.FTS) ||
                    f.Answer.Contains(search.FTS) ||
                    (f.Category != null && f.Category.Contains(search.FTS)));
            }

            if (!string.IsNullOrWhiteSpace(search.Category))
                query = query.Where(f => f.Category == search.Category);

            if (search.IsActive.HasValue)
                query = query.Where(f => f.IsActive == search.IsActive.Value);

            return query;
        }

        public override async Task<PagedResult<FaqResponse>> GetAsync(FaqSearchObject search)
        {
            var query = _context.Set<Faq>().AsQueryable();

            query = ApplyFilter(query, search);

            // Always sort by category then display order for consistent grouping
            query = query.OrderBy(f => f.Category).ThenBy(f => f.DisplayOrder).ThenBy(f => f.Id);

            int? totalCount = await query.CountAsync();

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue && search.PageSize.HasValue)
                    query = query.Skip(search.Page.Value * search.PageSize.Value)
                                 .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            var items = list.Select(f => _mapper.Map<FaqResponse>(f)).ToList();

            return new PagedResult<FaqResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
        }

        protected override async Task BeforeInsert(Faq entity, FaqInsertRequest request)
        {
            var duplicate = await _context.Set<Faq>()
                .AnyAsync(f => f.Question.ToLower() == request.Question.ToLower());

            if (duplicate)
                throw new InvalidOperationException($"An FAQ with the question '{request.Question}' already exists.");

            await base.BeforeInsert(entity, request);
        }

        protected override void MapUpdateToEntity(Faq entity, FaqUpdateRequest request)
        {
            if (request.Question != null)
                entity.Question = request.Question;

            if (request.Answer != null)
                entity.Answer = request.Answer;

            if (request.Category != null)
                entity.Category = request.Category;

            if (request.DisplayOrder.HasValue)
                entity.DisplayOrder = request.DisplayOrder.Value;

            if (request.IsActive.HasValue)
                entity.IsActive = request.IsActive.Value;

            entity.UpdatedAt = DateTime.UtcNow;
        }

        /// <summary>
        /// Increments ViewCount and returns the updated FAQ.
        /// </summary>
        public async Task<FaqResponse?> TrackViewAsync(int id, CancellationToken cancellationToken = default)
        {
            var faq = await _context.Set<Faq>().FindAsync(new object[] { id }, cancellationToken);

            if (faq == null)
                return null;

            faq.ViewCount++;
            await _context.SaveChangesAsync(cancellationToken);

            return _mapper.Map<FaqResponse>(faq);
        }
    }
}
