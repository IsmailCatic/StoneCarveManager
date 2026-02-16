import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';

class ReviewProvider {
  /// Get review for a specific order
  static Future<Review?> getOrderReview(int orderId) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse('${BaseProvider.baseUrl}/api/Order/$orderId/review');

    print('[ReviewProvider] Fetching review for order $orderId');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return null;
      }
      return Review.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load review: ${response.body}');
    }
  }

  /// Add review for an order
  static Future<Review> addOrderReview({
    required int orderId,
    required int rating,
    required String comment,
    int? productId,
  }) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse('${BaseProvider.baseUrl}/api/Order/$orderId/review');

    // Note: Server expects userId but should extract it from JWT token
    // We send -999 as placeholder (backend should override from token)
    final body = jsonEncode({
      'rating': rating,
      'comment': comment,
      'userId': -999, // Backend will override from JWT
      'productId': productId,
      'orderId': orderId,
      'isApproved': true,
    });

    print('[ReviewProvider] Adding review for order $orderId: $body');

    final response = await http.post(uri, headers: headers, body: body);

    print(
      '[ReviewProvider] Response: ${response.statusCode} - ${response.body}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Review.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add review: ${response.body}');
    }
  }

  /// Get all reviews for a product
  static Future<List<Review>> getProductReviews(int productId) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/Product/$productId/reviews',
    );

    print('[ReviewProvider] Fetching reviews for product $productId');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((json) => Review.fromJson(json)).toList();
      } else if (data is Map && data['items'] != null) {
        return (data['items'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load product reviews: ${response.body}');
    }
  }

  /// Get all customer reviews (all products)
  static Future<List<Review>> getAllCustomerReviews() async {
    final headers = await AuthProvider.getAuthHeaders();

    try {
      // Get all products with their reviews
      final productsUri = Uri.parse('${BaseProvider.baseUrl}/api/Product');
      final productsResponse = await http.get(productsUri, headers: headers);

      if (productsResponse.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      final productsData = jsonDecode(productsResponse.body);
      final products = (productsData['items'] as List);

      // Collect all reviews from all products
      List<Review> allReviews = [];

      for (var product in products) {
        if (product['reviews'] != null && product['reviews'] is List) {
          final reviews = (product['reviews'] as List)
              .map((json) => Review.fromJson(json))
              .toList();
          allReviews.addAll(reviews);
        }
      }

      // Sort by date (newest first)
      allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('[ReviewProvider] Loaded ${allReviews.length} total reviews');

      return allReviews;
    } catch (e) {
      print('[ReviewProvider] Error fetching all reviews: $e');
      throw Exception('Failed to load customer reviews: $e');
    }
  }
}
