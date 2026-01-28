using Microsoft.EntityFrameworkCore;
using StoneCarveManager.Model.Responses.Analytics;
using StoneCarveManager.Services.Database.Context;
using StoneCarveManager.Services.IServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace StoneCarveManager.Services.Services
{
    public class BusinessAnalyticsService : IBusinessAnalyticsService // IBusinessAnalyticsService interfejs po želji
    {
        private readonly AppDbContext _context;
        public BusinessAnalyticsService(AppDbContext context) { _context = context; }

        // 1. Najprodavaniji proizvodi (po broju prodaja)
        public async Task<List<TopProductResponse>> GetTopProductsAsync(int topN = 5, CancellationToken cancellationToken = default)
        {
            return await _context.OrderItems
                .GroupBy(oi => oi.ProductId)
                .Select(g => new TopProductResponse
                {
                    ProductId = g.Key,
                    ProductName = g.Select(x => x.Product.Name).FirstOrDefault(),
                    SoldQuantity = g.Sum(x => x.Quantity),
                    TotalIncome = g.Sum(x => x.Quantity * x.UnitPrice - x.Discount)
                })
                .OrderByDescending(x => x.SoldQuantity)
                .Take(topN)
                .ToListAsync(cancellationToken);
        }

        // 2. Broj korisnika
        public async Task<int> GetUserCountAsync(CancellationToken cancellationToken = default)
        {
            return await _context.Users.CountAsync(cancellationToken);
        }

        // 3. Ukupni prihodi
        public async Task<decimal> GetTotalIncomeAsync(DateTime? from = null, DateTime? to = null, CancellationToken cancellationToken = default)
        {
            var orders = _context.Orders.AsQueryable();
            if (from.HasValue) orders = orders.Where(o => o.OrderDate >= from.Value);
            if (to.HasValue) orders = orders.Where(o => o.OrderDate <= to.Value);
            return await orders.SumAsync(o => o.TotalAmount, cancellationToken);
        }

        // 4. Dnevni prosjek
        public async Task<decimal> GetDailyAverageIncomeAsync(DateTime? from = null, DateTime? to = null, CancellationToken cancellationToken = default)
        {
            var orders = _context.Orders.AsQueryable();
            if (from.HasValue) orders = orders.Where(o => o.OrderDate >= from.Value);
            if (to.HasValue) orders = orders.Where(o => o.OrderDate <= to.Value);
            var total = await orders.SumAsync(o => o.TotalAmount, cancellationToken);
            var minOrderDate = await _context.Orders.MinAsync(o => o.OrderDate, cancellationToken);
            var days = (to ?? DateTime.Now) - (from ?? minOrderDate);
            var numDays = days.TotalDays > 0 ? days.TotalDays : 1;
            return (decimal)(total / (decimal)numDays);
        }

        // 5. Prihodi po danu (za grafikone)
        public async Task<List<DailyIncomeResponse>> GetIncomePerDayAsync(DateTime? from = null, DateTime? to = null, CancellationToken cancellationToken = default)
        {
            return await _context.Orders
                .Where(o => (!from.HasValue || o.OrderDate >= from.Value) && (!to.HasValue || o.OrderDate <= to.Value))
                .GroupBy(o => o.OrderDate.Date)
                .Select(g => new DailyIncomeResponse
                {
                    Date = g.Key,
                    Amount = g.Sum(o => o.TotalAmount)
                })
                .OrderBy(g => g.Date)
                .ToListAsync(cancellationToken);
        }
    }

   
}
