import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stonecarve_manager_flutter/utils/auth_client.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';

class ProductProvider {
  final String baseUrl = 'http://localhost:5021/api/Product';

  // Fetch portfolio products using new endpoint with optional filters
  Future<List<Product>> fetchPortfolioProducts({
    String? categoryName,
    int? materialId,
    int? completionYear,
  }) async {
    var url = '$baseUrl/portfolio';
    final queryParams = <String, String>{};

    if (categoryName != null) queryParams['categoryName'] = categoryName;
    if (materialId != null) queryParams['materialId'] = materialId.toString();
    if (completionYear != null)
      queryParams['completionYear'] = completionYear.toString();

    if (queryParams.isNotEmpty) {
      url +=
          '?${queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    }

    print('[ProductProvider] fetchPortfolioProducts: $url');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.get(Uri.parse(url));
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(
        'Error fetching portfolio: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Fetch service products with optional search
  Future<List<Product>> fetchServiceProducts({String? searchQuery}) async {
    var url = '$baseUrl/services';
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '?searchQuery=${Uri.encodeComponent(searchQuery)}';
    }

    print('[ProductProvider] fetchServiceProducts: $url');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.get(Uri.parse(url));
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List;
      return items.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception(
        'Error fetching services: ${response.statusCode} ${response.body}',
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
      throw Exception('Error fetching allowed actions: ${response.statusCode}');
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
      throw HttpErrorHandler.createException(response, 'activate product');
    }
  }

  // State transition: Hide product
  Future<void> hideProduct(int productId) async {
    print('[ProductProvider] hideProduct: $baseUrl/$productId/hide');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(Uri.parse('$baseUrl/$productId/hide'));
    print('[ProductProvider] Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw HttpErrorHandler.createException(response, 'hide product');
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
      throw HttpErrorHandler.createException(response, 'convert to service');
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
      throw HttpErrorHandler.createException(
        response,
        'add product to portfolio',
      );
    }
  }

  Future<Product> addProduct(dynamic productData) async {
    final requestBody = productData is Product
        ? productData.toJson()
        : productData;
    print('[ProductProvider] addProduct: $requestBody');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.post(
      Uri.parse(baseUrl),
      body: json.encode(requestBody),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Error adding product: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<Product> updateProduct(int id, dynamic productData) async {
    final requestBody = productData is Product
        ? productData.toJson()
        : productData;
    print('[ProductProvider] updateProduct: $id $requestBody');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.put(
      Uri.parse('$baseUrl/$id'),
      body: json.encode(requestBody),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Error updating product: ${response.statusCode} ${response.body}',
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
        'Error deleting product: ${response.statusCode} ${response.body}',
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
        'Error uploading image: ${response.statusCode} ${response.body}',
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
        'Error deleting image: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<bool> setPrimaryImage(int productId, int imageId) async {
    print('[ProductProvider] setPrimaryImage: $productId $imageId');
    final client = AuthClient(getToken: () async => AuthProvider.token);
    final response = await client.patch(
      Uri.parse('http://localhost:5021/api/ProductImage/$imageId/set-primary'),
    );
    print('[ProductProvider] Status: ${response.statusCode}');
    print('[ProductProvider] Body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        'Error setting primary image: ${response.statusCode} ${response.body}',
      );
    }
  }
}
