import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
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
}
