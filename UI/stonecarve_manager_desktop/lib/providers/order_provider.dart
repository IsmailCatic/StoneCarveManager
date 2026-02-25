import 'dart:convert';

import 'package:http/http.dart' as http;
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

  Future<Order> updateOrder(int id, Order order) async {
    return await update(id, order.toJson());
  }

  Future<List<Order>> getAllOrders() async {
    var result = await get();
    return result.items ?? [];
  }

  Future<bool> deleteProgressImage(int imageId) async {
    var url = "http://localhost:5021/api/Order/progress-images/$imageId";
    var response = await http.delete(Uri.parse(url), headers: createHeaders());
    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception("Failed to delete progress image: ${response.body}");
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

    var url = "http://localhost:5021/api/Order/$orderId/progress-images";
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
      Uri.parse('http://localhost:5021/api/Order/$orderId/status'),
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
      throw Exception('Failed to update order status: ${response.body}');
    }
  }

  /// Get all custom orders (Admin/Employee only)
  /// Orders where product.productState == "custom_order"
  Future<List<Order>> getCustomOrders() async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('http://localhost:5021/api/Order/custom-orders'),
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
      throw Exception('Failed to load custom orders: ${response.body}');
    }
  }

  /// Upload a reference sketch/image for a custom order
  /// Returns the URL of the uploaded image
  Future<String> uploadCustomOrderSketch(String filePath) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final url = 'http://localhost:5021/api/Order/custom/upload-sketch';
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
      throw Exception('Failed to upload sketch: ${response.body}');
    }
  }

  /// Delete a custom order sketch by URL
  Future<bool> deleteCustomOrderSketch(String url) async {
    final token = AuthProvider.token;
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse(
        'http://localhost:5021/api/Order/custom/delete-sketch?url=$url',
      ),
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
      throw Exception('Failed to delete sketch: ${response.body}');
    }
  }
}
