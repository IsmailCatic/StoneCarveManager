using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StoneCarveManager.Services.IServices;
using StoneCarveManager.Services.Services;

namespace StoneCarveManagerWebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AnalyticsController : ControllerBase
    {
        private readonly IBusinessAnalyticsService _service;
        public AnalyticsController(IBusinessAnalyticsService service) 
        { 
            _service = service; 
        }

        [HttpGet("top-products")]
        public async Task<IActionResult> GetTopProducts([FromQuery] int topN = 5)
        { 
            return Ok(await _service.GetTopProductsAsync(topN));
        }

        [HttpGet("user-count")]
        public async Task<IActionResult> GetUserCount()
        { 
            return Ok(await _service.GetUserCountAsync()); 
        }

        [HttpGet("total-income")]
        public async Task<IActionResult> GetTotalIncome([FromQuery] DateTime? from, [FromQuery] DateTime? to)
        { 
            return Ok(await _service.GetTotalIncomeAsync(from, to)); 
        }

        [HttpGet("daily-income")]
        public async Task<IActionResult> GetIncomePerDay([FromQuery] DateTime? from, [FromQuery] DateTime? to)
        {
            return Ok(await _service.GetIncomePerDayAsync(from, to));
        }

    }
}
