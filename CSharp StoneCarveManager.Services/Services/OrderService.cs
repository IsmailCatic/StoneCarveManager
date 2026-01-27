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
    public class OrderService
        : BaseCRUDService<OrderResponse, OrderSearchObject, Order, OrderInsertRequest, OrderUpdateRequest>,
          IOrderService
    {
        private readonly IFileService _fileService;

        public OrderService(AppDbContext context, IMapper mapper, IFileService fileService)
            : base(context, mapper)
        {
            _fileService = fileService;
        }

        protected override IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderSearchObject? search)
        {
            if (search == null)
                return query;

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                query = query.Where(o =>
                    o.OrderNumber.Contains(search.FTS) ||
                    (o.CustomerNotes != null && o.CustomerNotes.Contains(search.FTS)) ||
                    (o.AdminNotes != null && o.AdminNotes.Contains(search.FTS)));
            }

            if (search.UserId.HasValue)
                query = query.Where(o => o.UserId == search.UserId.Value);

            if (search.AssignedEmployeeId.HasValue)
                query = query.Where(o => o.AssignedEmployeeId == search.AssignedEmployeeId.Value);

            if (search.Status.HasValue)
                query = query.Where(o => o.Status == (Services.Database.Entities.OrderStatus)search.Status.Value);

            if (search.DateFrom.HasValue)
                query = query.Where(o => o.OrderDate >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(o => o.OrderDate <= search.DateTo.Value);

            if (search.IncludeItems)
                query = query.Include(o => o.OrderItems);

            return query;
        }

        protected override Order MapInsertToEntity(Order entity, OrderInsertRequest request)
        {
            // Map primitive properties
            entity.UserId = request.UserId;
            entity.AssignedEmployeeId = request.AssignedEmployeeId;
            entity.CustomerNotes = request.CustomerNotes;
            entity.AdminNotes = request.AdminNotes;
            entity.AttachmentUrl = request.AttachmentUrl;
            entity.EstimatedCompletionDate = request.EstimatedCompletionDate;
            entity.DeliveryAddress = request.DeliveryAddress;
            entity.DeliveryCity = request.DeliveryCity;
            entity.DeliveryZipCode = request.DeliveryZipCode;
            entity.DeliveryDate = request.DeliveryDate;

            entity.OrderNumber = GenerateOrderNumber();
            entity.TotalAmount = 0m;

            // Map items
            if (request.Items != null && request.Items.Count > 0)
            {
                foreach (var it in request.Items)
                {
                    var oi = new OrderItem
                    {
                        ProductId = it.ProductId,
                        Quantity = it.Quantity,
                        UnitPrice = it.UnitPrice,
                        Discount = 0m
                    };
                    entity.OrderItems.Add(oi);
                    entity.TotalAmount += oi.Total;
                }
            }

            return entity;
        }

        protected override async Task BeforeInsert(Order entity, OrderInsertRequest request)
        {
            // Validate user exists
            var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
            if (!userExists)
                throw new InvalidOperationException($"User with ID {request.UserId} does not exist.");

            // Validate products exist for each item
            if (request.Items != null)
            {
                foreach (var it in request.Items)
                {
                    var productExists = await _context.Products.AnyAsync(p => p.Id == it.ProductId);
                    if (!productExists)
                        throw new InvalidOperationException($"Product with ID {it.ProductId} does not exist.");
                }
            }

            await base.BeforeInsert(entity, request);
        }

        protected override async Task BeforeUpdate(Order entity, OrderUpdateRequest request)
        {
            // Validate assigned employee if provided
            if (request.AssignedEmployeeId.HasValue)
            {
                var employeeExists = await _context.Users.AnyAsync(u => u.Id == request.AssignedEmployeeId.Value);
                if (!employeeExists)
                    throw new InvalidOperationException($"Assigned employee with ID {request.AssignedEmployeeId.Value} does not exist.");
            }

            // If items are provided, validate products
            if (request.Items != null)
            {
                foreach (var it in request.Items)
                {
                    var productExists = await _context.Products.AnyAsync(p => p.Id == it.ProductId);
                    if (!productExists)
                        throw new InvalidOperationException($"Product with ID {it.ProductId} does not exist.");
                }
            }

            await base.BeforeUpdate(entity, request);
        }

        public async Task<OrderProgressImageResponse> AddOrderProgressImageAsync(int orderId, OrderProgressImageUploadRequest request, CancellationToken cancellationToken = default)
        {
            var order = await _context.Orders
                .Include(o => o.ProgressImages)
                .FirstOrDefaultAsync(o => o.Id == orderId, cancellationToken);

            if (order == null)
                throw new KeyNotFoundException($"Order with ID {orderId} not found.");

            // Upload file using file service (container name 'order-progress' chosen)
            var imageUrl = await _fileService.UploadAsync(request.File, "order-progress", null, cancellationToken);

            var progressImage = new OrderProgressImage
            {
                OrderId = orderId,
                ImageUrl = imageUrl,
                Description = request.Description,
                UploadedAt = DateTime.UtcNow,
                UploadedByUserId = request.UploadedByUserId
            };

            _context.OrderProgressImages.Add(progressImage);
            await _context.SaveChangesAsync(cancellationToken);

            return _mapper.Map<OrderProgressImageResponse>(progressImage);
        }

        private string GenerateOrderNumber()
        {
            return $"ORD-{DateTime.UtcNow:yyyyMMddHHmmssfff}-{Guid.NewGuid().ToString().Substring(0, 6).ToUpper()}";
        }
    }
}