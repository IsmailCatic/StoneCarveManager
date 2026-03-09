import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';
import 'package:stonecarve_manager_mobile/models/custom_order_request.dart';
import 'package:stonecarve_manager_mobile/models/service_order_request.dart';
import 'package:stonecarve_manager_mobile/config/api_config.dart';

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


    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );


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
    var url = "${ApiConfig.apiBaseUrl}Order/$orderId/progress-images";
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
    var url = "${ApiConfig.apiBaseUrl}Order/$id/mark-completed";
    var response = await http.patch(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      return fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to mark order as completed: ${response.body}");
    }
  }

  Future<Review?> getOrderReview(int orderId) async {
    var url = "${ApiConfig.apiBaseUrl}Order/$orderId/review";
    var response = await http.get(Uri.parse(url), headers: createHeaders());
    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch review: ${response.body}");
    }
  }

  Future<Review> addOrderReview(int orderId, Review review) async {
    var url = "${ApiConfig.apiBaseUrl}Order/$orderId/review";
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

  /// Get all orders for current user — uses /my-orders endpoint (user-scoped, matching desktop)
  static Future<List<Order>> getMyOrders({
    int? status,
    int page = 1,
    int pageSize = 100,
  }) async {
    final headers = await AuthProvider.getAuthHeaders();

    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (status != null) queryParams['status'] = status.toString();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/Order/my-orders',
    ).replace(queryParameters: queryParams);


    final response = await http.get(uri, headers: headers);


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

  /// Get active orders (Pending=0, Processing=1, Shipped=2)
  /// Fetches from /my-orders and filters by status range on the client
  static Future<List<Order>> getMyActiveOrders() async {
    final all = await getMyOrders();
    final active = all.where((o) => o.status >= 0 && o.status <= 2).toList();
    return active;
  }

  /// Get order history (Delivered=3, Cancelled=4, Returned=5)
  /// Fetches from /my-orders and filters by status range on the client
  static Future<List<Order>> getMyOrderHistory() async {
    final all = await getMyOrders();
    final history = all.where((o) => o.status >= 3 && o.status <= 5).toList();
    return history;
  }

  /// Get single order details
  static Future<Order> getMyOrderById(int orderId) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse('${BaseProvider.baseUrl}/api/Order/$orderId');


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

  // ============================================
  // CUSTOM ORDER METHODS
  // ============================================

  /// Upload custom order sketch/reference image
  /// Returns the URL of the uploaded image
  Future<String> uploadCustomSketch(File file, {String? description}) async {
    var url = "${ApiConfig.apiBaseUrl}Order/custom/upload-sketch";
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add auth header
    request.headers.addAll(createHeaders());

    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    // Add description if provided
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }


    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);


    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      var imageUrl = data['url'] as String;

      // Handle spaces in URL
      imageUrl = imageUrl.replaceAll(' ', '%20');

      // If URL is relative, prefix with base URL
      if (!imageUrl.startsWith('http')) {
        // Remove leading slash if present to avoid double slashes
        if (imageUrl.startsWith('/')) {
          imageUrl = imageUrl.substring(1);
        }
        imageUrl = '${ApiConfig.baseUrl}/$imageUrl';
      }

      return imageUrl;
    } else {
      throw Exception("Failed to upload sketch: ${response.body}");
    }
  }

  /// Create custom order
  /// First uploads all sketches, then creates the custom order with URLs
  static Future<Order> createCustomOrder(
    CustomOrderRequest request,
    List<File> sketchFiles,
  ) async {
    final headers = await AuthProvider.getAuthHeaders();
    final provider = OrderProvider();

    try {

      // 1. Upload all sketches first
      final uploadedUrls = <String>[];
      for (int i = 0; i < sketchFiles.length; i++) {
        final file = sketchFiles[i];
        final url = await provider.uploadCustomSketch(file);
        uploadedUrls.add(url);
      }


      // 2. Create request with uploaded URLs
      final requestWithUrls = CustomOrderRequest(
        categoryId: request.categoryId,
        materialId: request.materialId,
        dimensions: request.dimensions,
        description: request.description,
        customerNotes: request.customerNotes,
        referenceImageUrls: uploadedUrls,
        estimatedPrice: request.estimatedPrice,
        deliveryAddress: request.deliveryAddress,
        deliveryCity: request.deliveryCity,
        deliveryZipCode: request.deliveryZipCode,
        deliveryDate: request.deliveryDate,
      );

      // 3. Create custom order
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}Order/custom');


      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestWithUrls.toJson()),
      );


      if (response.statusCode == 201 || response.statusCode == 200) {
        final order = Order.fromJson(jsonDecode(response.body));
        return order;
      } else {
        throw Exception('Failed to create custom order: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create service request
  /// Uploads images first, then POSTs to /api/Order/service-request
  static Future<Order> createServiceRequest(
    ServiceOrderRequest request,
    List<File> imageFiles,
  ) async {
    final headers = await AuthProvider.getAuthHeaders();
    final provider = OrderProvider();

    try {

      // 1. Upload images
      final uploadedUrls = <String>[];
      for (int i = 0; i < imageFiles.length; i++) {
        final url = await provider.uploadCustomSketch(imageFiles[i]);
        uploadedUrls.add(url);
      }

      // 2. Build request with uploaded URLs
      final requestWithUrls = ServiceOrderRequest(
        serviceProductId: request.serviceProductId,
        requirements: request.requirements,
        dimensions: request.dimensions,
        customerNotes: request.customerNotes,
        referenceImageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
        deliveryAddress: request.deliveryAddress,
        deliveryCity: request.deliveryCity,
        deliveryZipCode: request.deliveryZipCode,
        preferredDate: request.preferredDate,
      );

      // 3. POST to service-request endpoint
      final uri = Uri.parse('${ApiConfig.apiBaseUrl}Order/service-request');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestWithUrls.toJson()),
      );


      if (response.statusCode == 201 || response.statusCode == 200) {
        final order = Order.fromJson(jsonDecode(response.body));
        return order;
      } else {
        throw Exception('Failed to submit service request: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
