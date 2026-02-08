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
        Task<OrderProgressImageResponse> AddOrderProgressImageAsync(int orderId, OrderProgressImageUploadRequest request, CancellationToken cancellationToken = default);

        // Delete an order progress image by id. Returns true if deleted, false if not found.
        Task<bool> DeleteOrderProgressImageAsync(int id, CancellationToken cancellationToken = default);

        // Get orders filtered by date range for better performance
        Task<List<OrderResponse>> GetOrdersByDateRangeAsync(DateTime startDate, DateTime endDate, CancellationToken cancellationToken = default);

        // Get monthly summary with pre-aggregated data
        Task<OrderMonthlySummaryResponse> GetMonthlySummaryAsync(int year, CancellationToken cancellationToken = default);
    }
}
