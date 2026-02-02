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

  Future<List<Product>> fetchPortfolioProducts() async {
    print(
      '[ProductProvider] fetchPortfolioProducts: $baseUrl?isInPortfolio=true',
    );
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.get(Uri.parse('$baseUrl?isInPortfolio=true'));
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

  // Future<List<Product>> fetchPortfolioProducts() async {
  //   print(
  //     '[ProductProvider] fetchPortfolioProducts: $baseUrl?isInPortfolio=true',
  //   );
  //   final response = await http.get(Uri.parse('$baseUrl?isInPortfolio=true'));
  //   print('[ProductProvider] Status: ${response.statusCode}');
  //   print('[ProductProvider] Body: ${response.body}');
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final items = data['items'] as List;
  //     return items.map((item) => Product.fromJson(item)).toList();
  //   } else {
  //     throw Exception(
  //       'Greška pri dohvaćanju portfolia: ${response.statusCode} ${response.body}',
  //     );
  //   }
  // }

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
