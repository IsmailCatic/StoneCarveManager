import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';
import 'package:stonecarve_manager_mobile/utils/error_parser.dart';

class ReviewProvider {
  /// Get review for a specific order
  static Future<Review?> getOrderReview(int orderId) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/ProductReview/order/$orderId',
    );

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
      throw Exception(
        AppErrorParser.fromBody(response.body, statusCode: response.statusCode),
      );
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

    final uri = Uri.parse('${BaseProvider.baseUrl}/api/ProductReview');

    final body = jsonEncode({
      'rating': rating,
      'comment': comment,
      'userId': AuthProvider.userId ?? 0,
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
      throw Exception(
        AppErrorParser.fromBody(response.body, statusCode: response.statusCode),
      );
    }
  }

  /// Get all reviews for a product
  static Future<List<Review>> getProductReviews(int productId) async {
    final headers = await AuthProvider.getAuthHeaders();

    final uri = Uri.parse(
      '${BaseProvider.baseUrl}/api/ProductReview/product/$productId',
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
      throw Exception(
        AppErrorParser.fromBody(response.body, statusCode: response.statusCode),
      );
    }
  }

  /// Get all customer reviews (all products)
  static Future<List<Review>> getAllCustomerReviews() async {
    final headers = await AuthProvider.getAuthHeaders();

    try {
      // Use dedicated ProductReview endpoint that returns all reviews with userName
      final uri = Uri.parse('${BaseProvider.baseUrl}/api/ProductReview');

      print('[ReviewProvider] Fetching from: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        throw Exception(
          AppErrorParser.fromBody(
            response.body,
            statusCode: response.statusCode,
          ),
        );
      }

      final data = jsonDecode(response.body);

      // Backend returns paginated result with "items" array
      final List<Review> allReviews = [];

      if (data['items'] != null && data['items'] is List) {
        allReviews.addAll(
          (data['items'] as List).map((json) => Review.fromJson(json)).toList(),
        );
      }

      print('[ReviewProvider] Loaded ${allReviews.length} total reviews');

      return allReviews;
    } catch (e) {
      print('[ReviewProvider] Error fetching all reviews: $e');
      throw Exception(AppErrorParser.fromException(e));
    }
  }
}
