using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.Database.Entities;
using StoneCarveManager.Services.IServices;
using System;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class OrderService
        : BaseCRUDService<OrderResponse, OrderSearchObject, Order, OrderInsertRequest, OrderUpdateRequest>,
          IOrderService
    {
        private readonly IFileService _fileService;
        private readonly ICurrentUserService _currentUserService;

        public OrderService(AppDbContext context, IMapper mapper, IFileService fileService, ICurrentUserService currentUserService)
            : base(context, mapper)
        {
            _fileService = fileService;
            _currentUserService = currentUserService;
        }

        /// <summary>
        /// Create a custom order without a predefined product
        /// Automatically creates a custom product and order item
        /// </summary>
        public async Task<OrderResponse> CreateCustomOrderAsync(
            CustomOrderInsertRequest request, 
            CancellationToken cancellationToken = default)
        {
            // 1. Validate category exists
            var category = await _context.Categories.FindAsync(new object[] { request.CategoryId }, cancellationToken);
            if (category == null)
                throw new InvalidOperationException($"Category with ID {request.CategoryId} does not exist.");

            // 2. Validate material exists
            var material = await _context.Materials.FindAsync(new object[] { request.MaterialId }, cancellationToken);
            if (material == null)
                throw new InvalidOperationException($"Material with ID {request.MaterialId} does not exist.");

            var userId = _currentUserService.GetUserId();

            // 3. Create a custom product for this order
            var customProduct = new Product
            {
                Name = $"Custom {category.Name} - {DateTime.UtcNow:yyyyMMdd}",
                Description = request.Description,
                Price = request.EstimatedPrice ?? material.PricePerUnit, // Use estimated or calculate from material
                StockQuantity = 0, // Custom products are not in stock
                Dimensions = request.Dimensions,
                EstimatedDays = 30, // Default for custom work, can be adjusted by admin later
                CategoryId = request.CategoryId,
                MaterialId = request.MaterialId,
                ProductState = "custom_order",
                IsActive = true,
                IsInPortfolio = false, // Not in portfolio yet (can be added after completion)
                CreatedAt = DateTime.UtcNow
            };

            _context.Products.Add(customProduct);
            await _context.SaveChangesAsync(cancellationToken);

            // 4. Create the order
            var order = new Order
            {
                UserId = userId,
                OrderNumber = GenerateOrderNumber(),
                OrderDate = DateTime.UtcNow,
                Status = Database.Entities.OrderStatus.Pending, // Custom orders start as Pending
                CustomerNotes = request.CustomerNotes,
                DeliveryAddress = request.DeliveryAddress,
                DeliveryCity = request.DeliveryCity,
                DeliveryZipCode = request.DeliveryZipCode,
                DeliveryDate = request.DeliveryDate,
                TotalAmount = customProduct.Price
            };

            _context.Orders.Add(order);

            // 5. Create order item linking to the custom product
            var orderItem = new OrderItem
            {
                Order = order,
                ProductId = customProduct.Id,
                Quantity = 1, // Custom orders typically have quantity 1
                UnitPrice = customProduct.Price,
                Discount = 0m
            };

            _context.OrderItems.Add(orderItem);

            // 6. Save reference images if provided
            if (request.ReferenceImageUrls != null && request.ReferenceImageUrls.Any())
            {
                foreach (var imageUrl in request.ReferenceImageUrls)
                {
                    var productImage = new ProductImage
                    {
                        ProductId = customProduct.Id,
                        ImageUrl = imageUrl,
                        AltText = "Customer reference image",
                        IsPrimary = false,
                        DisplayOrder = 0
                    };
                    _context.ProductImages.Add(productImage);
                }
            }

            await _context.SaveChangesAsync(cancellationToken);

            // 7. Return the created order with all details
            return await GetByIdAsync(order.Id);
        }

        // OVERRIDE CreateAsync - KRITIČNO ZA MAPIRANJE!
        public override async Task<OrderResponse> CreateAsync(OrderInsertRequest request)
        {
            var entity = new Order();
            MapInsertToEntity(entity, request);

            entity.UserId = _currentUserService.GetUserId();


            // You can use this userId if needed, for example to log who created the order
            // or to override the UserId from request if needed

            await BeforeInsert(entity, request);

            _context.Orders.Add(entity);
            await _context.SaveChangesAsync();

            // KLJUČNO: Učitaj sve navigacije nakon insert-a
            var entityWithNavs = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.ProgressImages)
                    .ThenInclude(pi => pi.UploadedByUser)
                .Include(o => o.StatusHistory)
                    .ThenInclude(sh => sh.ChangedByUser)
                .Include(o => o.Review)
                .FirstOrDefaultAsync(o => o.Id == entity.Id);

            return _mapper.Map<OrderResponse>(entityWithNavs!);
        }

        public override async Task<OrderResponse?> UpdateAsync(int id, OrderUpdateRequest request)
        {
            // Ovo iz base: nađi entitet, mapiraj promjene iz requesta, SaveChanges itd.
            var entity = await _context.Orders.FindAsync(id);
            if (entity == null)
                return null;

            // Mapiraj primitivne property-je iz requesta u entity (ili koristi MapUpdateToEntity ako imaš)
            // (ili zovi svoju mapiraj metodu ako je već postoji)
            request.Adapt(entity);


            await _context.SaveChangesAsync();

            // --- OVO JE KLJUČNO ---
            // Sada ponovo učitaj order sa svim navigacijama!
            var entityWithNavs = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.ProgressImages).ThenInclude(pi => pi.UploadedByUser)
                .Include(o => o.StatusHistory)
                    .ThenInclude(sh => sh.ChangedByUser)
                .Include(o => o.Review)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (entityWithNavs == null)
                return null;

            // Mapiraj DTO (Mapster ili AutoMapper)
            return _mapper.Map<OrderResponse>(entityWithNavs); // ili entityWithNavs.Adapt<OrderResponse>() za Mapster
        }

        public override async Task<PagedResult<OrderResponse>> GetAsync(OrderSearchObject search)
         {
            var query = _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.ProgressImages)
                    .ThenInclude(pi => pi.UploadedByUser)
                .Include(o => o.StatusHistory)
                    .ThenInclude(sh => sh.ChangedByUser)
                .Include(o => o.Review)
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
            var items = list.Select(o => _mapper.Map<OrderResponse>(o)).ToList();
            //var items = list.Adapt<List<OrderResponse>>(); // <-- OVO JE ISPAVNO ZA MAPSTER

            return new PagedResult<OrderResponse>
            {
                Items = items,
                TotalCount = totalCount
            };
         }

            // GetById sa progres slikama
         public override async Task<OrderResponse?> GetByIdAsync(int id)
            {
                var order = await _context.Orders
                    .Include(o => o.User)
                    .Include(o => o.OrderItems)
                        .ThenInclude(oi => oi.Product)
                    .Include(o => o.ProgressImages)
                        .ThenInclude(pi => pi.UploadedByUser)
                    .Include(o => o.StatusHistory)
                        .ThenInclude(sh => sh.ChangedByUser)
                    .Include(o => o.Review)
                    .FirstOrDefaultAsync(o => o.Id == id);

                if (order == null)
                    return null;

                return _mapper.Map<OrderResponse>(order);
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
                query = query.Where(o => o.Status == (Database.Entities.OrderStatus)search.Status.Value);

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
                    entity.TotalAmount += oi.Quantity * oi.UnitPrice; // Fix: Calculate total
                }
            }

            return entity;
        }

        protected override async Task BeforeInsert(Order entity, OrderInsertRequest request)
        {

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


            // read again w user
            var piWithUser = await _context.OrderProgressImages
                .Include(p => p.UploadedByUser)
                .FirstOrDefaultAsync(p => p.Id == progressImage.Id, cancellationToken);

            return _mapper.Map<OrderProgressImageResponse>(piWithUser);

            //return _mapper.Map<OrderProgressImageResponse>(progressImage);
        }

        public async Task<bool> DeleteOrderProgressImageAsync(int id, CancellationToken cancellationToken = default)
        {
            var pi = await _context.OrderProgressImages.FindAsync(new object[] { id }, cancellationToken);
            if (pi == null)
                return false;

            // Delete blob using file service if ImageUrl is not null/empty
            if (!string.IsNullOrWhiteSpace(pi.ImageUrl))
            {
                try
                {
                    await _fileService.DeleteAsync(pi.ImageUrl, "order-progress", cancellationToken);
                }
                catch
                {
                    // Log or ignore blob delete failures; continue to remove DB record
                }
            }

            _context.OrderProgressImages.Remove(pi);
            await _context.SaveChangesAsync(cancellationToken);

            return true;
        }

        public async Task<List<OrderResponse>> GetOrdersByDateRangeAsync(
            DateTime startDate, 
            DateTime endDate, 
            CancellationToken cancellationToken = default)
        {
            var orders = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.ProgressImages)
                    .ThenInclude(pi => pi.UploadedByUser)
                .Include(o => o.Review)
                .Where(o => o.OrderDate >= startDate && o.OrderDate <= endDate)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync(cancellationToken);

            return orders.Select(o => _mapper.Map<OrderResponse>(o)).ToList();
        }

        public async Task<OrderMonthlySummaryResponse> GetMonthlySummaryAsync(
            int year, 
            CancellationToken cancellationToken = default)
        {
            var orders = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.ProgressImages)
                    .ThenInclude(pi => pi.UploadedByUser)
                .Include(o => o.Review)
                .Where(o => o.OrderDate.Year == year)
                .OrderByDescending(o => o.OrderDate)
                .ToListAsync(cancellationToken);

            var orderResponses = orders.Select(o => _mapper.Map<OrderResponse>(o)).ToList();

            var monthlyGroups = orderResponses
                .GroupBy(o => o.OrderDate.Month)
                .Select(g => new MonthSummary
                {
                    Month = g.Key,
                    OrderCount = g.Count(),
                    TotalRevenue = g.Sum(o => o.TotalAmount),
                    Orders = g.OrderByDescending(o => o.OrderDate).ToList()
                })
                .OrderBy(m => m.Month)
                .ToList();

            return new OrderMonthlySummaryResponse
            {
                Year = year,
                Months = monthlyGroups,
                YearTotal = new YearTotalSummary
                {
                    OrderCount = orderResponses.Count,
                    TotalRevenue = orderResponses.Sum(o => o.TotalAmount)
                }
            };
        }

        /// <summary>
        /// Update order status and create OrderStatusHistory entry
        /// Only for Admin/Employee use
        /// </summary>
        public async Task<OrderResponse?> UpdateOrderStatusAsync(
            int orderId, 
            Model.Requests.OrderStatus newStatus, 
            string? comment = null,
            CancellationToken cancellationToken = default)
        {
            var order = await _context.Orders
                .Include(o => o.StatusHistory)
                .FirstOrDefaultAsync(o => o.Id == orderId, cancellationToken);
            
            if (order == null)
                return null;
            
            // Get current user (admin/employee who is changing status)
            var currentUserId = _currentUserService.GetUserId();
            var oldStatus = order.Status;
            
            // Don't create history if status hasn't changed
            if ((int)oldStatus == (int)newStatus)
            {
                return await GetByIdAsync(orderId);
            }
            
            // Update order status (cast to Database.Entities.OrderStatus)
            order.Status = (Database.Entities.OrderStatus)(int)newStatus;
            
            // Create status history record
            var statusHistory = new OrderStatusHistory
            {
                OrderId = orderId,
                OldStatus = oldStatus,
                NewStatus = (Database.Entities.OrderStatus)(int)newStatus,
                Comment = comment,
                ChangedAt = DateTime.UtcNow,
                ChangedByUserId = currentUserId
            };
            
            _context.OrderStatusHistories.Add(statusHistory);
            
            // If delivered, set completion date
            if (newStatus == Model.Requests.OrderStatus.Delivered && !order.CompletedAt.HasValue)
            {
                order.CompletedAt = DateTime.UtcNow;
            }
            
            await _context.SaveChangesAsync(cancellationToken);
            
            // Return updated order with all navigations including new status history
            return await GetByIdAsync(orderId);
        }

        /// <summary>
        /// Upload a reference sketch/image for custom order
        /// Uploads to Azure Blob Storage container "custom-order-sketches"
        /// </summary>
        public async Task<string> UploadCustomOrderSketchAsync(
            CustomOrderSketchUploadRequest request,
            CancellationToken cancellationToken = default)
        {
            // Validate file
            if (request.File == null || request.File.Length == 0)
                throw new ArgumentException("File is required");

            // Validate file type
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".pdf" };
            var extension = Path.GetExtension(request.File.FileName).ToLowerInvariant();
            
            if (!allowedExtensions.Contains(extension))
                throw new ArgumentException("Only JPG, PNG, and PDF files are allowed");

            // Validate file size (max 10MB)
            if (request.File.Length > 10 * 1024 * 1024)
                throw new ArgumentException("File size must be less than 10MB");

            // Upload to Azure Blob Storage
            var imageUrl = await _fileService.UploadAsync(
                request.File,
                "custom-order-sketches",  // ✅ Container name
                null,                      // Auto-generate filename
                cancellationToken
            );

            return imageUrl;
        }

        /// <summary>
        /// Delete a custom order sketch from Azure Blob Storage
        /// </summary>
        public async Task<bool> DeleteCustomOrderSketchAsync(
            string url,
            CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(url))
                return false;

            try
            {
                await _fileService.DeleteAsync(url, "custom-order-sketches", cancellationToken);
                return true;
            }
            catch
            {
                // Log error if needed
                return false;
            }
        }

        private string GenerateOrderNumber()
        {
            return $"ORD-{DateTime.UtcNow:yyyyMMddHHmmssfff}-{Guid.NewGuid().ToString().Substring(0, 6).ToUpper()}";
        }
    }
}