import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/utils/api_config.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';
import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/order.dart';
import 'package:stonecarve_manager_flutter/models/order_update_request.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

  Future<Order> createOrder(Order order) async {
    return await insert(order.toJson());
  }

  /// Delete an order by ID (Admin only)
  Future<void> deleteOrder(int id) async {
    final url = "${ApiConfig.apiUrl}/Order/$id";
    final response = await http.delete(
      Uri.parse(url),
      headers: createHeaders(),
    );
    if (response.statusCode != 204) {
      throw HttpErrorHandler.createException(response, 'delete order');
    }
  }

  Future<Order> updateOrder(int id, Order order) async {
    return await update(id, order.toJson());
  }

  Future<Order> getOrderById(int id) async {
    var url = "${ApiConfig.apiUrl}/Order/$id";
    var response = await http.get(Uri.parse(url), headers: createHeaders());

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      throw HttpErrorHandler.createException(response, 'load order');
    }
  }

  Future<List<Order>> getAllOrders() async {
    var result = await get();
    return result.items ?? [];
  }

  Future<bool> deleteProgressImage(int imageId) async {
    var url = "${ApiConfig.apiUrl}/Order/progress-images/$imageId";
    var response = await http.delete(Uri.parse(url), headers: createHeaders());
    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw HttpErrorHandler.createException(response, 'delete progress image');
    }
  }

  Future<ProgressImage> uploadProgressImage(
    int orderId,
    String filePath, {
    String? description,
    int? uploadedByUserId,
  }) async {
    print('=== UPLOAD PROGRESS IMAGE DEBUG ===');
    print('Order ID: $orderId');
    print('File path: $filePath');
    print('Description: $description');
    print('Uploaded by user ID: $uploadedByUserId');

    var url = "${ApiConfig.apiUrl}/Order/$orderId/progress-images";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(createHeaders());

    // Detect correct MIME type based on file extension
    String? contentType;
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'png':
        contentType = 'image/png';
        break;
      case 'gif':
        contentType = 'image/gif';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: contentType != null
            ? http.MediaType.parse(contentType)
            : null,
      ),
    );
    if (description != null) {
      request.fields['description'] = description;
    }
    if (uploadedByUserId != null) {
      request.fields['uploadedByUserId'] = uploadedByUserId.toString();
    }

    print('Sending request to: $url');
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (isValidResponse(response)) {
      final jsonData = jsonDecode(response.body);
      print('Parsed JSON: $jsonData');

      // Backend returns OrderProgressImageResponse, not Order
      final progressImage = ProgressImage.fromJson(jsonData);
      print(
        'Created ProgressImage: ${progressImage.id}, ${progressImage.imageUrl}',
      );
      return progressImage;
    } else {
      print('ERROR: ${response.body}');
      throw HttpErrorHandler.createException(response, 'upload progress image');
    }
  }

  Future<Order> markOrderCompleted(int id) async {
    var url = "${ApiConfig.apiUrl}/Order/$id/mark-completed";
    var response = await http.patch(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw HttpErrorHandler.createException(
        response,
        'mark order as completed',
      );
    }
  }

  /// Set (or update) a price quote for a custom/service order.
  /// Uses the standard PUT /api/Order/{id} endpoint with the quotedPrice field.
  Future<Order> setQuote(int orderId, double price) async {
    final url = "${ApiConfig.apiUrl}/Order/$orderId";
    final body = jsonEncode({'quotedPrice': price});
    final response = await http.put(
      Uri.parse(url),
      headers: createHeaders(),
      body: body,
    );
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw HttpErrorHandler.createException(response, 'set order quote');
    }
  }

  Future<Review?> getOrderReview(int orderId) async {
    var url = "${ApiConfig.apiUrl}/Order/$orderId/review";
    var response = await http.get(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw HttpErrorHandler.createException(response, 'fetch order review');
    }
  }

  Future<Review> addOrderReview(int orderId, Review review) async {
    var url = "${ApiConfig.apiUrl}/Order/$orderId/review";
    var response = await http.post(
      Uri.parse(url),
      headers: createHeaders(),
      body: jsonEncode(review.toJson()),
    );
    if (isValidResponse(response)) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw HttpErrorHandler.createException(response, 'add order review');
    }
  }

  /// Update order status (Admin/Employee only)
  Future<Order> updateOrderStatus(
    int orderId,
    int newStatus, {
    String? comment,
  }) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final request = UpdateOrderStatusRequest(
      newStatus: newStatus,
      comment: comment,
    );

    final response = await http.put(
      Uri.parse('${ApiConfig.apiUrl}/Order/$orderId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Access denied - Admin/Employee only');
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw HttpErrorHandler.createException(response, 'update order status');
    }
  }

  /// Get all custom orders (Admin/Employee only)
  /// Orders where product.productState == "custom_order"
  Future<List<Order>> getCustomOrders({int? status}) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    var url = '${ApiConfig.apiUrl}/Order/custom-orders';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final items = jsonData['items'] as List?;
      return items?.map((e) => Order.fromJson(e)).toList() ?? [];
    } else if (response.statusCode == 403) {
      throw Exception('Access denied - Admin/Employee only');
    } else {
      throw HttpErrorHandler.createException(response, 'load custom orders');
    }
  }

  /// Upload a reference sketch/image for a custom order
  /// Returns the URL of the uploaded image
  Future<String> uploadCustomOrderSketch(String filePath) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final url = '${ApiConfig.apiUrl}/Order/custom/upload-sketch';
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    // Detect correct MIME type based on file extension
    String? contentType;
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'png':
        contentType = 'image/png';
        break;
      case 'gif':
        contentType = 'image/gif';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: contentType != null
            ? http.MediaType.parse(contentType)
            : null,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['url'] as String;
    } else {
      throw HttpErrorHandler.createException(
        response,
        'upload custom order sketch',
      );
    }
  }

  /// Delete a custom order sketch by URL
  Future<bool> deleteCustomOrderSketch(String url) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse('${ApiConfig.apiUrl}/Order/custom/delete-sketch?url=$url'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw HttpErrorHandler.createException(
        response,
        'delete custom order sketch',
      );
    }
  }

  /// Assign employee to order (Admin only)
  Future<Order> assignEmployee(int orderId, int? employeeId) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.patch(
      Uri.parse('${ApiConfig.apiUrl}/Order/$orderId/assign-employee'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'employeeId': employeeId}),
    );

    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 403) {
      throw Exception('Access denied - Admin only');
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else if (response.statusCode == 400) {
      throw HttpErrorHandler.createException(
        response,
        'validate employee assignment',
      );
    } else {
      throw HttpErrorHandler.createException(
        response,
        'assign employee to order',
      );
    }
  }

  /// Get my assigned orders
  Future<List<Order>> getMyOrders({int? status}) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    var url = '${ApiConfig.apiUrl}/Order/my-orders?page=1&pageSize=100';
    if (status != null) {
      url += '&status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final items = jsonData['items'] as List?;
      return items?.map((e) => Order.fromJson(e)).toList() ?? [];
    } else if (response.statusCode == 403) {
      throw Exception('Access denied');
    } else {
      throw HttpErrorHandler.createException(response, 'load my orders');
    }
  }

  /// Get custom orders with filters (extended)
  Future<List<Order>> getCustomOrdersFiltered({
    int? status,
    bool? assignedToMe,
    bool? unassignedOnly,
  }) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    var url = '${ApiConfig.apiUrl}/Order/custom-orders?page=0&pageSize=100';
    if (status != null) url += '&status=$status';
    if (assignedToMe == true) url += '&assignedToMe=true';
    if (unassignedOnly == true) url += '&unassignedOnly=true';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final items = jsonData['items'] as List?;
      return items?.map((e) => Order.fromJson(e)).toList() ?? [];
    } else {
      throw HttpErrorHandler.createException(
        response,
        'load filtered custom orders',
      );
    }
  }
}
