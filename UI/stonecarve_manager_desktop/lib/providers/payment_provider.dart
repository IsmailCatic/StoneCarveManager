import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/payment.dart';
import 'package:stonecarve_manager_flutter/models/search_result.dart';
import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class PaymentProvider extends BaseProvider<Payment> {
  static const String baseUrl = 'http://localhost:5021/api';

  PaymentProvider() : super('Payment');

  @override
  Payment fromJson(data) {
    return Payment.fromJson(data);
  }

  /// Get all payments with filtering
  Future<SearchResult<Payment>> getPayments([
    PaymentSearchObject? search,
  ]) async {
    search ??= PaymentSearchObject(retrieveAll: true);

    var url = '$baseUrl/Payment';
    final queryParams = search.toQueryParameters();
    if (queryParams.isNotEmpty) {
      url +=
          '?${Uri(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString()))).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    print('[PaymentProvider] Response status: ${response.statusCode}');
    print('[PaymentProvider] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('[PaymentProvider] Parsed data: $data');

      // Debug each payment item
      if (data['items'] != null) {
        for (var item in data['items']) {
          print(
            '[PaymentProvider] Payment #${item['id']}: status=${item['status']}, method=${item['method']}, amount=${item['amount']}',
          );
        }
      }

      return SearchResult<Payment>(
        items:
            (data['items'] as List?)
                ?.map((item) => Payment.fromJson(item))
                .toList() ??
            [],
        totalCount: data['totalCount'] ?? 0,
      );
    }

    throw Exception('Failed to load payments');
  }

  /// Get payment by ID
  Future<Payment> getPaymentById(int paymentId) async {
    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/Payment/$paymentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load payment');
  }

  /// Get payment by order ID
  Future<Payment?> getPaymentByOrderId(int orderId) async {
    try {
      final headers = AuthProvider.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Payment/order/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Payment.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      // 404 means no payment exists
      return null;
    }
  }

  /// Issue refund
  Future<Payment> issueRefund(RefundRequest request) async {
    final headers = AuthProvider.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/Payment/refund'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to issue refund');
  }

  /// Retry failed payment
  Future<Payment> retryPayment(int orderId) async {
    final headers = AuthProvider.getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/Payment/retry/$orderId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to retry payment');
  }

  /// Get payment statistics
  Future<PaymentStatistics> getPaymentStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var url = '$baseUrl/Payment/statistics';
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final headers = AuthProvider.getAuthHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return PaymentStatistics.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load payment statistics');
  }
}
