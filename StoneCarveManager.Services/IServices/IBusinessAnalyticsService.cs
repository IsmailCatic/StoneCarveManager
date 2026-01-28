using StoneCarveManager.Model.Responses.Analytics;
using StoneCarveManager.Services.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.IServices
{
    public interface IBusinessAnalyticsService
    {
        Task<List<TopProductResponse>> GetTopProductsAsync(int topN = 5, CancellationToken cancellationToken = default);
        Task<int> GetUserCountAsync(CancellationToken cancellationToken = default);
        Task<decimal> GetTotalIncomeAsync(DateTime? from = null, DateTime? to = null, CancellationToken cancellationToken = default);
        Task<decimal> GetDailyAverageIncomeAsync(DateTime? from = null, DateTime? to = null, CancellationToken cancellationToken = default);
        Task<List<DailyIncomeResponse>> GetIncomePerDayAsync(DateTime? from = null, DateTime? to = null, CancellationToken cancellationToken = default);
        // Add any other analytics methods here
    }
}
