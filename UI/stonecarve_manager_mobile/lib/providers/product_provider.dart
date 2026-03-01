import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stonecarve_manager_mobile/utils/auth_client.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';

class ProductProvider {
  String get baseUrl => '${BaseProvider.baseUrl}/api/Product';

  // Fetch portfolio products using new endpoint
  Future<List<Product>> fetchPortfolioProducts() async {
    print('[ProductProvider] fetchPortfolioProducts: $baseUrl/portfolio');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.get(Uri.parse('$baseUrl/portfolio'));
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to fetch portfolio: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Fetch service products
  Future<List<Product>> fetchServiceProducts() async {
    print('[ProductProvider] fetchServiceProducts: $baseUrl/services');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.get(Uri.parse('$baseUrl/services'));
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to fetch services: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Get allowed actions for a product
  Future<List<String>> getAllowedActions(int productId) async {
    print(
      '[ProductProvider] getAllowedActions: $baseUrl/$productId/allowed-actions',
    );
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.get(
      Uri.parse('$baseUrl/$productId/allowed-actions'),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> actions = json.decode(response.body);
      return actions.cast<String>();
    } else {
      throw Exception(
        'Failed to fetch allowed actions: ${response.statusCode}',
      );
    }
  }

  // State transition: Activate product
  Future<void> activateProduct(int productId) async {
    print('[ProductProvider] activateProduct: $baseUrl/$productId/activate');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(
      Uri.parse('$baseUrl/$productId/activate'),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to activate product: ${response.body}');
    }
  }

  // State transition: Hide product
  Future<void> hideProduct(int productId) async {
    print('[ProductProvider] hideProduct: $baseUrl/$productId/hide');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(Uri.parse('$baseUrl/$productId/hide'));
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to hide product: ${response.body}');
    }
  }

  // State transition: Make service
  Future<void> makeService(int productId) async {
    print('[ProductProvider] makeService: $baseUrl/$productId/make-service');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(
      Uri.parse('$baseUrl/$productId/make-service'),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to convert product to service: ${response.body}');
    }
  }

  // State transition: Add to portfolio
  Future<void> addToPortfolio(int productId) async {
    print(
      '[ProductProvider] addToPortfolio: $baseUrl/$productId/add-to-portfolio',
    );
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(
      Uri.parse('$baseUrl/$productId/add-to-portfolio'),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to add product to portfolio: ${response.body}');
    }
  }

  Future<Product> addProduct(Product product) async {
    print('[ProductProvider] addProduct: ${product.toJson()}');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.post(
      Uri.parse(baseUrl),
      body: json.encode(product.toJson()),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to add product: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Product> updateProduct(int id, Product product) async {
    print('[ProductProvider] updateProduct: $id ${product.toJson()}');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.put(
      Uri.parse('$baseUrl/$id'),
      body: json.encode(product.toJson()),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to update product: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<bool> deleteProduct(int id) async {
    print('[ProductProvider] deleteProduct: $id');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.delete(Uri.parse('$baseUrl/$id'));
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        'Failed to delete product: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<ProductImage> uploadProductImage(
    int productId,
    String filePath,
  ) async {
    print('[ProductProvider] uploadProductImage: $productId $filePath');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$productId/images'),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    ); // <-- use 'file'
    final token = AuthProvider.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    // Do NOT set Content-Type for multipart
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProductImage.fromJson(data); // <-- expect a single object
    } else {
      throw Exception(
        'Failed to upload image: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<bool> deleteProductImage(int productId, int imageId) async {
    print('[ProductProvider] deleteProductImage: $productId $imageId');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.delete(
      Uri.parse('$baseUrl/$productId/images/$imageId'),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        'Failed to delete image: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Fetch cosine-similarity recommendations for a product.
  /// The endpoint is AllowAnonymous — no auth header required.
  Future<List<Product>> fetchRecommendations(
    int productId, {
    int count = 6,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/$productId/recommendations',
    ).replace(queryParameters: {'count': '$count'});
    print('[ProductProvider] fetchRecommendations: $uri');
    final response = await http.get(uri);
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List<dynamic> items = json.decode(response.body);
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to fetch recommendations: ${response.statusCode} ${response.body}',
      );
    }
  }
}
