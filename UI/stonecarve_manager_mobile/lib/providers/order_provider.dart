import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

  Future<Order> createOrder(Order order) async {
    return await insert(order.toJson());
  }

  static Future<Order> createNewOrder(CreateOrderRequest request) async {
    final url = Uri.parse('${BaseProvider.baseUrl}/api/Order');
    final headers = await AuthProvider.getAuthHeaders();

    print('[OrderProvider] Creating order: ${request.toJson()}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    print('[OrderProvider] Response status: ${response.statusCode}');
    print('[OrderProvider] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<Order> updateOrder(int id, Order order) async {
    return await update(id, order.toJson());
  }

  Future<List<Order>> getAllOrders() async {
    var result = await get();
    return result.items ?? [];
  }

  Future<bool> deleteProgressImage(int imageId) async {
    var url = "${BaseProvider.baseUrl}/api/Order/progress-images/$imageId";
    var response = await http.delete(Uri.parse(url), headers: createHeaders());
    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception("Failed to delete progress image: ${response.body}");
    }
  }

  Future<Order> uploadProgressImage(
    int orderId,
    String filePath, {
    String? description,
    int? uploadedByUserId,
  }) async {
    var url = "http://localhost:5021/api/Order/$orderId/progress-images";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(createHeaders());
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    if (description != null) {
      request.fields['description'] = description;
    }
    if (uploadedByUserId != null) {
      request.fields['uploadedByUserId'] = uploadedByUserId.toString();
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to upload progress image: ${response.body}");
    }
  }

  Future<Order> markOrderCompleted(int id) async {
    var url = "http://localhost:5021/api/Order/$id/mark-completed";
    var response = await http.patch(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to mark order as completed: ${response.body}");
    }
  }

  Future<Review?> getOrderReview(int orderId) async {
    var url = "http://localhost:5021/api/Order/$orderId/review";
    var response = await http.get(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch review: ${response.body}");
    }
  }

  Future<Review> addOrderReview(int orderId, Review review) async {
    var url = "http://localhost:5021/api/Order/$orderId/review";
    var response = await http.post(
      Uri.parse(url),
      headers: createHeaders(),
      body: jsonEncode(review.toJson()),
    );
    if (isValidResponse(response)) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to add review: ${response.body}");
    }
  }

  /// Get all orders for current user
  static Future<List<Order>> getMyOrders({
    int? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 0,
    int pageSize = 20,
  }) async {
    final headers = await AuthProvider.getAuthHeaders();

    var queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (status != null) queryParams['Status'] = status.toString();
    if (dateFrom != null) queryParams['DateFrom'] = dateFrom.toIso8601String();
    if (dateTo != null) queryParams['DateTo'] = dateTo.toIso8601String();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/Order/my-orders',
    ).replace(queryParameters: queryParams);

    print('[OrderProvider] Fetching my orders from: $uri');

    final response = await http.get(uri, headers: headers);

    print('[OrderProvider] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = (data['items'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
      return items;
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

  /// Get active orders (not completed/cancelled)
  static Future<List<Order>> getMyActiveOrders() async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse('${BaseProvider.baseUrl}/api/Order/my-orders/active');

    print('[OrderProvider] Fetching active orders from: $uri');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['items'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load active orders: ${response.body}');
    }
  }

  /// Get order history (completed/cancelled)
  static Future<List<Order>> getMyOrderHistory() async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/Order/my-orders/history',
    );

    print('[OrderProvider] Fetching order history from: $uri');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['items'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load order history: ${response.body}');
    }
  }

  /// Get single order details
  static Future<Order> getMyOrderById(int orderId) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/Order/my-orders/$orderId',
    );

    print('[OrderProvider] Fetching order details from: $uri');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Access denied - order does not belong to you');
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception('Failed to load order details: ${response.body}');
    }
  }
}
