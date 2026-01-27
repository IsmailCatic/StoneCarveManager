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
    public class RoleService
        : BaseCRUDService<RoleResponse, RoleSearchObject, Role, RoleInsertRequest, RoleUpdateRequest>,
          IRoleService
    {
        public RoleService(AppDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        protected override IQueryable<Role> ApplyFilter(IQueryable<Role> query, RoleSearchObject? search)
        {
            if (search == null)
                return query;

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(r =>
                    r.Name.Contains(search.FTS) ||
                    r.Description.Contains(search.FTS));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(r => r.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Role entity, RoleInsertRequest request)
        {
            // Ensure role name is unique (case-insensitive)
            var exists = await _context.Roles
                .AnyAsync(r => r.Name.ToLower() == request.Name.ToLower());

            if (exists)
                throw new InvalidOperationException($"Role '{request.Name}' already exists.");

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Role entity, RoleUpdateRequest request)
        {
            if (!string.IsNullOrWhiteSpace(request.Name) && request.Name != entity.Name)
            {
                var exists = await _context.Roles
                    .AnyAsync(r => r.Name.ToLower() == request.Name.ToLower() && r.Id != entity.Id);

                if (exists)
                    throw new InvalidOperationException($"Role '{request.Name}' already exists.");
            }

            await base.BeforeUpdate(entity, request);
        }

        protected override async Task BeforeDelete(Role entity)
        {
            // Prevent deletion when users are assigned to this role
            var hasUsers = await _context.Set<UserRole>()
                .AnyAsync(ur => ur.RoleId == entity.Id);

            if (hasUsers)
                throw new InvalidOperationException($"Cannot delete role '{entity.Name}' because users are assigned to it.");

            await base.BeforeDelete(entity);
        }
    }
}