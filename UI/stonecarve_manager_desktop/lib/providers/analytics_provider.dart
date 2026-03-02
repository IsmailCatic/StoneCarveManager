import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/analytics.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class AnalyticsProvider {
  static const String baseUrl = 'http://localhost:5021/api';

  /// Get comprehensive dashboard statistics
  Future<DashboardStatistics> getDashboardStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = '$baseUrl/Analytics/dashboard';
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return DashboardStatistics.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load dashboard statistics');
  }

  /// Get revenue by payment method
  Future<List<RevenueByMethod>> getRevenueByPaymentMethod({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = '$baseUrl/Analytics/revenue-by-method';
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((item) => RevenueByMethod.fromJson(item))
          .toList();
    }

    throw Exception('Failed to load revenue by method');
  }

  /// Get revenue trend over time
  Future<List<RevenueTrend>> getRevenueTrend({
    required DateTime startDate,
    required DateTime endDate,
    String groupBy = 'day', // day, week, month
    bool skipDateFilter =
        false, // When true, calls legacy endpoint without date filters
  }) async {
    // ALWAYS use legacy endpoint since /revenue-trend has data filtering issues
    // If skipDateFilter is true, call without any date parameters (All Time)
    if (skipDateFilter) {
      print(
        '[AnalyticsProvider.getRevenueTrend] 🌍 ALL TIME MODE - No date filters',
      );
      return _getRevenueTrendFromLegacyEndpointNoFilter();
    }

    // Use legacy endpoint WITH date filters for specific date ranges
    print('[AnalyticsProvider.getRevenueTrend] ═══════════════════════');
    print(
      '[AnalyticsProvider.getRevenueTrend] 📅 Using LEGACY endpoint with dates:',
    );
    print(
      '[AnalyticsProvider.getRevenueTrend]    Start: ${startDate.toIso8601String()}',
    );
    print(
      '[AnalyticsProvider.getRevenueTrend]    End: ${endDate.toIso8601String()}',
    );
    print(
      '[AnalyticsProvider.getRevenueTrend] 🔗 Using /daily-income endpoint',
    );
    print('[AnalyticsProvider.getRevenueTrend] ═══════════════════════');

    return _getRevenueTrendFromLegacyEndpoint(startDate, endDate);
  }

  /// Fallback to legacy daily-income endpoint
  Future<List<RevenueTrend>> _getRevenueTrendFromLegacyEndpoint(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final url =
        '$baseUrl/Analytics/daily-income?from=${startDate.toIso8601String()}&to=${endDate.toIso8601String()}';

    print('[AnalyticsProvider.getRevenueTrend] ⚙️ FALLBACK to legacy endpoint');
    print('[AnalyticsProvider.getRevenueTrend] 🔗 Legacy URL: $url');
    print(
      '[AnalyticsProvider.getRevenueTrend]    from: ${startDate.toIso8601String()}',
    );
    print(
      '[AnalyticsProvider.getRevenueTrend]    to: ${endDate.toIso8601String()}',
    );

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;

      // Map legacy DailyIncomeEntry format to RevenueTrend
      final result = decoded.map((item) {
        return RevenueTrend(
          date: DateTime.parse(item['date']),
          revenue: (item['amount'] as num).toDouble(),
          orderCount: 0, // Legacy endpoint doesn't provide this
        );
      }).toList();

      print(
        '[AnalyticsProvider.getRevenueTrend] ✅ Using legacy endpoint data: ${result.length} entries',
      );
      if (result.isNotEmpty) {
        print(
          '[AnalyticsProvider.getRevenueTrend]    First: ${result.first.date.toIso8601String()} = \$${result.first.revenue}',
        );
        print(
          '[AnalyticsProvider.getRevenueTrend]    Last: ${result.last.date.toIso8601String()} = \$${result.last.revenue}',
        );
      }
      return result;
    }

    throw Exception(
      'Failed to load legacy daily income: ${response.statusCode} ${response.body}',
    );
  }

  /// Get revenue trend without date filters (ALL TIME) - like old analytics screen
  Future<List<RevenueTrend>>
  _getRevenueTrendFromLegacyEndpointNoFilter() async {
    final url = '$baseUrl/Analytics/daily-income';

    print(
      '[AnalyticsProvider.getRevenueTrend] 🌍 NO DATE FILTER - Getting ALL historical data',
    );
    print('[AnalyticsProvider.getRevenueTrend] 🔗 Legacy URL: $url');

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    print(
      '[AnalyticsProvider.getRevenueTrend] Response status: ${response.statusCode}',
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List;
      print(
        '[AnalyticsProvider.getRevenueTrend] ✅ Got ${decoded.length} entries (ALL TIME)',
      );

      // Map legacy DailyIncomeEntry format to RevenueTrend
      final result = decoded.map((item) {
        return RevenueTrend(
          date: DateTime.parse(item['date']),
          revenue: (item['amount'] as num).toDouble(),
          orderCount: 0, // Legacy endpoint doesn't provide this
        );
      }).toList();

      if (result.isNotEmpty) {
        print(
          '[AnalyticsProvider.getRevenueTrend]    First: ${result.first.date.toIso8601String()} = \$${result.first.revenue}',
        );
        print(
          '[AnalyticsProvider.getRevenueTrend]    Last: ${result.last.date.toIso8601String()} = \$${result.last.revenue}',
        );
      }
      return result;
    }

    throw Exception(
      'Failed to load all-time daily income: ${response.statusCode} ${response.body}',
    );
  }

  /// Get top products
  Future<List<TopProduct>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 10,
  }) async {
    var url = '$baseUrl/Analytics/top-products';
    final params = <String, String>{'limit': limit.toString()};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    url += '?${Uri(queryParameters: params).query}';

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((item) => TopProduct.fromJson(item))
          .toList();
    }

    throw Exception('Failed to load top products');
  }

  /// Get category performance
  Future<List<CategoryPerformance>> getCategoryPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = '$baseUrl/Analytics/category-performance';
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((item) => CategoryPerformance.fromJson(item))
          .toList();
    }

    throw Exception('Failed to load category performance');
  }

  /// Get customer statistics
  Future<CustomerStatistics> getCustomerStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = '$baseUrl/Analytics/customer-stats';
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return CustomerStatistics.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load customer statistics');
  }

  /// Get top customers
  Future<List<TopCustomer>> getTopCustomers({int limit = 10}) async {
    final url = '$baseUrl/Analytics/top-customers?limit=$limit';

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((item) => TopCustomer.fromJson(item))
          .toList();
    }

    throw Exception('Failed to load top customers');
  }

  /// Get review statistics
  Future<ReviewStatistics> getReviewStatistics() async {
    final url = '$baseUrl/Analytics/review-stats';

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return ReviewStatistics.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load review statistics');
  }

  /// Get employee performance
  Future<List<EmployeePerformance>> getEmployeePerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = '$baseUrl/Analytics/employee-performance';
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((item) => EmployeePerformance.fromJson(item))
          .toList();
    }

    throw Exception('Failed to load employee performance');
  }
}
