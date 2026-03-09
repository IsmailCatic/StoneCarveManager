import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/models/payment.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';

class PaymentProvider {
  static String get baseUrl => BaseProvider.baseUrl;

  /// Create payment intent for an order
  static Future<PaymentIntent> createPaymentIntent({
    required int orderId,
    String paymentMethod = 'stripe',
    String? customerEmail,
    String? customerName,
  }) async {
    try {
      final request = CreatePaymentIntentRequest(
        orderId: orderId,
        paymentMethod: paymentMethod,
        customerEmail: customerEmail,
        customerName: customerName,
      );


      final headers = await AuthProvider.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/Payment/create-intent'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentIntent.fromJson(data);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm payment after user enters card details
  static Future<Payment> confirmPayment({
    required String paymentIntentId,
    required int orderId,
  }) async {
    try {
      final request = ConfirmPaymentRequest(
        paymentIntentId: paymentIntentId,
        orderId: orderId,
      );


      final headers = await AuthProvider.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/Payment/confirm'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to confirm payment: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment by order ID
  static Future<Payment?> getPaymentByOrderId(int orderId) async {
    try {

      final headers = await AuthProvider.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/Payment/order/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No payment found
      } else {
        throw Exception('Failed to get payment: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get payment by payment ID
  static Future<Payment> getPaymentById(int paymentId) async {
    try {
      final headers = await AuthProvider.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/Payment/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to get payment: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all payments for the current user (with optional filters)
  static Future<List<Payment>> getMyPayments({
    String? status,
    int? page,
    int? pageSize,
  }) async {
    try {

      final headers = await AuthProvider.getAuthHeaders();

      // Build query parameters
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) {
        queryParams['Status'] = status;
      }
      if (page != null) {
        queryParams['Page'] = page.toString();
      }
      if (pageSize != null) {
        queryParams['PageSize'] = pageSize.toString();
      }

      final uri = Uri.parse(
        '$baseUrl/api/Payment/my-payments',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: headers);


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Backend returns PagedResult<PaymentResponse>
        // Check if it has 'items' array or is directly an array
        final List<dynamic> paymentsJson;
        if (data is Map && data.containsKey('items')) {
          paymentsJson = data['items'] as List<dynamic>;
        } else if (data is List) {
          paymentsJson = data;
        } else {
          throw Exception('Unexpected response format');
        }

        return paymentsJson
            .map((json) => Payment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get payments: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
