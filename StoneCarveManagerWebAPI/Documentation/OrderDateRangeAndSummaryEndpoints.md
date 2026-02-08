# Order API - Date Range and Monthly Summary Endpoints

## Overview
These new endpoints provide optimized ways to retrieve and analyze order data for performance and business intelligence purposes.

---

## 1. Get Orders by Date Range

### Endpoint
```
GET /api/Order/by-date-range?startDate={startDate}&endDate={endDate}
```

### Purpose
Retrieve orders within a specific time period with all related data (items, progress images, reviews).

### Query Parameters
- `startDate` (DateTime, required): Start date (inclusive) - e.g., `2024-01-01`
- `endDate` (DateTime, required): End date (inclusive) - e.g., `2024-03-31`

### Response
Returns a list of `OrderResponse` objects with:
- Full order details
- Order items with product information
- Progress images with uploader details
- Customer reviews (if any)

### Example Request
```
GET /api/Order/by-date-range?startDate=2024-01-01&endDate=2024-01-31
```

### Example Response
```json
[
  {
    "id": 1,
    "orderDate": "2024-01-15T10:30:00Z",
    "orderNumber": "ORD-20240115103000123-ABC123",
    "status": 1,
    "totalAmount": 1500.00,
    "customerNotes": "Please use marble",
    "userId": 5,
    "clientName": "John Doe",
    "orderItems": [...],
    "progressImages": [...],
    "review": null
  }
]
```

### Use Cases
- Display orders for a specific week/month/quarter
- Generate reports for custom date ranges
- Better performance when filtering large datasets
- Export orders for specific periods

---

## 2. Get Monthly Summary

### Endpoint
```
GET /api/Order/monthly-summary?year={year}
```

### Purpose
Get pre-aggregated business intelligence data grouped by month for a specific year.

### Query Parameters
- `year` (int, required): Year to analyze - e.g., `2024`

### Response
Returns an `OrderMonthlySummaryResponse` object with:
- **Year**: The requested year
- **Months**: Array of monthly summaries containing:
  - `month`: Month number (1-12)
  - `monthName`: Month name (e.g., "January")
  - `orderCount`: Total number of orders in that month
  - `totalRevenue`: Sum of all order amounts for that month
  - `orders`: Full list of orders for that month (ordered by date descending)
- **YearTotal**: Overall statistics:
  - `orderCount`: Total orders for the entire year
  - `totalRevenue`: Total revenue for the entire year

### Example Request
```
GET /api/Order/monthly-summary?year=2024
```

### Example Response
```json
{
  "year": 2024,
  "months": [
    {
      "month": 1,
      "monthName": "January",
      "orderCount": 15,
      "totalRevenue": 45000.00,
      "orders": [
        {
          "id": 23,
          "orderDate": "2024-01-28T14:20:00Z",
          "orderNumber": "ORD-20240128142000456-XYZ789",
          "status": 2,
          "totalAmount": 3200.00,
          ...
        },
        ...
      ]
    },
    {
      "month": 2,
      "monthName": "February",
      "orderCount": 18,
      "totalRevenue": 52000.00,
      "orders": [...]
    },
    ...
  ],
  "yearTotal": {
    "orderCount": 180,
    "totalRevenue": 540000.00
  }
}
```

### Use Cases
- **Dashboard Analytics**: Display monthly sales trends
- **Revenue Charts**: Show revenue by month for visualization
- **Business Reports**: Generate annual performance reports
- **Trend Analysis**: Compare month-over-month growth
- **Performance Tracking**: Monitor order volumes and revenue patterns

---

## Performance Benefits

### Why Date Range Filtering?
- Reduces database load by limiting query scope
- Faster response times with large datasets
- Prevents overwhelming the client with too much data
- Enables pagination-like behavior without complex offset logic

### Why Pre-Aggregated Monthly Summary?
- **Single Query**: All calculations done server-side
- **Reduces Frontend Load**: No need to calculate sums/counts in JavaScript
- **Consistent Data**: Server ensures accurate calculations
- **Ready for Charts**: Data structure perfect for chart libraries (Chart.js, Recharts, etc.)

---

## Implementation Details

### Database Queries
Both endpoints:
- Use EF Core's `Include()` for eager loading related data
- Apply filtering at the database level (WHERE clauses)
- Return fully mapped DTOs with all navigation properties

### Included Related Data
- User information (customer details)
- Order items with product details
- Progress images with uploader info
- Product reviews (if available)

### Ordering
- Date range: Orders by `OrderDate` descending (newest first)
- Monthly summary: Months by number ascending (January to December)
  - Orders within each month by date descending

---

## Frontend Integration Examples

### React Example - Date Range
```javascript
const fetchOrdersByDateRange = async (startDate, endDate) => {
  const response = await fetch(
    `/api/Order/by-date-range?startDate=${startDate}&endDate=${endDate}`
  );
  return await response.json();
};

// Usage
const orders = await fetchOrdersByDateRange('2024-01-01', '2024-01-31');
```

### React Example - Monthly Summary with Chart
```javascript
import { Line } from 'react-chartjs-2';

const fetchMonthlySummary = async (year) => {
  const response = await fetch(`/api/Order/monthly-summary?year=${year}`);
  return await response.json();
};

// Usage in component
const summary = await fetchMonthlySummary(2024);

const chartData = {
  labels: summary.months.map(m => m.monthName),
  datasets: [{
    label: 'Revenue',
    data: summary.months.map(m => m.totalRevenue),
    borderColor: 'rgb(75, 192, 192)',
  }]
};

return <Line data={chartData} />;
```

---

## Error Handling

Both endpoints return:
- **200 OK**: Successfully retrieved data (even if empty array/months)
- **400 Bad Request**: Invalid date format or missing required parameters
- **500 Internal Server Error**: Database or server issues

---

## Notes

- All dates are in UTC
- Empty months (no orders) will not appear in the monthly summary
- The monthly summary loads all orders for the year into memory before grouping - suitable for typical business scales (hundreds/thousands of orders per year)
- For extremely high-volume systems, consider adding database-level aggregation

---

## Testing

### Test Date Range Endpoint
```bash
# PowerShell
$startDate = "2024-01-01"
$endDate = "2024-12-31"
Invoke-RestMethod -Uri "https://localhost:7xxx/api/Order/by-date-range?startDate=$startDate&endDate=$endDate"
```

### Test Monthly Summary Endpoint
```bash
# PowerShell
Invoke-RestMethod -Uri "https://localhost:7xxx/api/Order/monthly-summary?year=2024"
```
