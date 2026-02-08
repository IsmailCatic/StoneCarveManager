import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stonecarve_manager_flutter/utils/auth_client.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class ProductProvider {
  final String baseUrl = 'http://localhost:5021/api/Product';

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
        'Greška pri dohvaćanju portfolia: ${response.statusCode} ${response.body}',
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
        'Greška pri dohvaćanju usluga: ${response.statusCode} ${response.body}',
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
        'Greška pri dohvaćanju dozvoljenih akcija: ${response.statusCode}',
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
      throw Exception('Greška pri aktivaciji proizvoda: ${response.body}');
    }
  }

  // State transition: Hide product
  Future<void> hideProduct(int productId) async {
    print('[ProductProvider] hideProduct: $baseUrl/$productId/hide');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(Uri.parse('$baseUrl/$productId/hide'));
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Greška pri sakrivanju proizvoda: ${response.body}');
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
      throw Exception('Greška pri konverziji u uslugu: ${response.body}');
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
      throw Exception('Greška pri dodavanju u portfolio: ${response.body}');
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
        'Greška pri dodavanju proizvoda: ${response.statusCode} ${response.body}',
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
        'Greška pri ažuriranju proizvoda: ${response.statusCode} ${response.body}',
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
        'Greška pri brisanju proizvoda: ${response.statusCode} ${response.body}',
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
        'Greška pri uploadu slike: ${response.statusCode} ${response.body}',
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
        'Greška pri brisanju slike: ${response.statusCode} ${response.body}',
      );
    }
  }
}
