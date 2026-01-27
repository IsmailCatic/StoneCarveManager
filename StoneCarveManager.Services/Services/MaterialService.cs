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
    public class MaterialService
        : BaseCRUDService<MaterialResponse, MaterialSearchObject, Material, MaterialInsertRequest, MaterialUpdateRequest>,
          IMaterialService
    {
        public MaterialService(AppDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Material> ApplyFilter(IQueryable<Material> query, MaterialSearchObject? search)
        {
            if (search == null)
                return query;

            // FTS search
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(m =>
                    m.Name.Contains(search.FTS) ||
                    m.Description.Contains(search.FTS) ||
                    m.Unit.Contains(search.FTS));
            }

            // Filter by IsActive
            if (search.IsActive.HasValue)
            {
                query = query.Where(m => m.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Material entity, MaterialInsertRequest request)
        {
            var exists = await _context.Materials
                .AnyAsync(m => m.Name.ToLower() == request.Name.ToLower());

            if (exists)
            {
                throw new InvalidOperationException($"Material '{request.Name}' already exists.");
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Material entity, MaterialUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != entity.Name)
            {
                var exists = await _context.Materials
                    .AnyAsync(m => m.Name.ToLower() == request.Name.ToLower() && m.Id != entity.Id);

                if (exists)
                {
                    throw new InvalidOperationException($"Material '{request.Name}' already exists.");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Material entity)
        {
            var hasProducts = await _context.Products.AnyAsync(p => p.MaterialId == entity.Id);

            if (hasProducts)
            {
                throw new InvalidOperationException($"Cannot delete material '{entity.Name}' because it has products.");
            }

            await base.BeforeDelete(entity);
        }
    }
}
