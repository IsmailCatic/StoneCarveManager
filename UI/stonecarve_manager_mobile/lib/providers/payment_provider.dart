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

      print('[PaymentProvider] Creating payment intent for order $orderId');

      final headers = await AuthProvider.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/Payment/create-intent'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('[PaymentProvider] Response status: ${response.statusCode}');
      print('[PaymentProvider] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentIntent.fromJson(data);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      print('[PaymentProvider] Error creating payment intent: $e');
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

      print('[PaymentProvider] Confirming payment for order $orderId');

      final headers = await AuthProvider.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/Payment/confirm'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print('[PaymentProvider] Confirm response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Payment.fromJson(data);
      } else {
        throw Exception('Failed to confirm payment: ${response.body}');
      }
    } catch (e) {
      print('[PaymentProvider] Error confirming payment: $e');
      rethrow;
    }
  }

  /// Get payment by order ID
  static Future<Payment?> getPaymentByOrderId(int orderId) async {
    try {
      print('[PaymentProvider] Getting payment for order $orderId');

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
      print('[PaymentProvider] Error getting payment: $e');
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
      print('[PaymentProvider] Error getting payment by ID: $e');
      rethrow;
    }
  }
}
