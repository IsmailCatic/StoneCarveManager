import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/review.dart';
import 'package:stonecarve_manager_flutter/models/search_result.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class ReviewProvider {
  static const String baseUrl = 'http://localhost:5021/api';

  Map<String, String> _createHeaders() {
    final token = AuthProvider.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all reviews with optional filters
  Future<SearchResult<ProductReview>> getReviews([
    ReviewSearchObject? search,
  ]) async {
    search ??= ReviewSearchObject(retrieveAll: true);

    final queryParams = search.toQueryParameters();
    final uri = Uri.parse(
      '$baseUrl/ProductReview',
    ).replace(queryParameters: queryParams);

    print('[ReviewProvider] GET $uri');
    print('[ReviewProvider] Query params: $queryParams');

    final response = await http.get(uri, headers: _createHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SearchResult<ProductReview>(
        items:
            (data['items'] as List?)
                ?.map((item) => ProductReview.fromJson(item))
                .toList() ??
            [],
        totalCount: data['totalCount'],
      );
    }

    throw Exception('Failed to load reviews: ${response.body}');
  }

  /// Get pending reviews (awaiting approval)
  Future<SearchResult<ProductReview>> getPendingReviews({
    String? searchQuery,
    int? rating,
  }) async {
    final search = ReviewSearchObject(
      isApproved: false,
      searchQuery: searchQuery,
      rating: rating,
    );
    return getReviews(search);
  }

  /// Get approved reviews
  Future<SearchResult<ProductReview>> getApprovedReviews({
    String? searchQuery,
    int? rating,
  }) async {
    final search = ReviewSearchObject(
      isApproved: true,
      searchQuery: searchQuery,
      rating: rating,
    );
    return getReviews(search);
  }

  /// Approve a review
  Future<void> approveReview(int reviewId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ProductReview/$reviewId/approve'),
      headers: _createHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve review: ${response.body}');
    }
  }

  /// Reject a review (unapprove)
  Future<void> rejectReview(int reviewId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/ProductReview/$reviewId/reject'),
      headers: _createHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject review: ${response.body}');
    }
  }

  /// Delete a review permanently
  Future<void> deleteReview(int reviewId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ProductReview/$reviewId'),
      headers: _createHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete review: ${response.body}');
    }
  }

  /// Get review for a specific order
  Future<ProductReview?> getOrderReview(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Order/$orderId/review'),
        headers: _createHeaders(),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return ProductReview.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      // 404 or empty response means no review exists
      return null;
    }
  }
}
