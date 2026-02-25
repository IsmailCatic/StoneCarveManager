using StoneCarveManager.Model.Requests;
using StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.Responses.StoneCarveManager.Model.Responses;
using StoneCarveManager.Model.SearchObjects;
using StoneCarveManager.Services.Base;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IOrderService
       : ICRUDService<OrderResponse, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        /// Create a custom order without a predefined product
        /// Automatically creates a custom product based on user specifications
        Task<OrderResponse> CreateCustomOrderAsync(CustomOrderInsertRequest request, CancellationToken cancellationToken = default);
        Task<List<OrderResponse>> GetCustomOrdersAsync(CancellationToken cancellationToken = default);
        Task<string> UploadCustomOrderSketchAsync(CustomOrderSketchUploadRequest request, CancellationToken cancellationToken = default);
        Task<bool> DeleteCustomOrderSketchAsync(string url, CancellationToken cancellationToken = default);
        Task<OrderProgressImageResponse> AddOrderProgressImageAsync(int orderId, OrderProgressImageUploadRequest request, CancellationToken cancellationToken = default);
        Task<bool> DeleteOrderProgressImageAsync(int id, CancellationToken cancellationToken = default);
        Task<List<OrderResponse>> GetOrdersByDateRangeAsync(DateTime startDate, DateTime endDate, CancellationToken cancellationToken = default);
        Task<OrderMonthlySummaryResponse> GetMonthlySummaryAsync(int year, CancellationToken cancellationToken = default);
        
        /// Update order status and automatically create OrderStatusHistory entry
        /// Admin/Employee only
        Task<OrderResponse?> UpdateOrderStatusAsync(int orderId, Model.Requests.OrderStatus newStatus, string? comment = null, CancellationToken cancellationToken = default);
    }
}
