import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/utils/api_config.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(data) {
    return Category.fromJson(data);
  }

  Future<Category> createCategory(Category category) async {
    print('\n=== CATEGORY_PROVIDER createCategory() DEBUG ===');
    print('Creating category with data:');
    print('  - category.id: ${category.id}');
    print('  - category.name: ${category.name}');
    print('  - category.description: ${category.description}');
    print('  - category.parentCategoryId: ${category.parentCategoryId}');
    print('  - category.isActive: ${category.isActive}');

    try {
      final jsonData = category.toJson();
      print('Category toJson() result: $jsonData');

      final result = await insert(jsonData);
      print('Category created successfully: ${result.toJson()}');
      return result;
    } catch (e, stackTrace) {
      print('\n!!! ERROR in createCategory() !!!');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<Category> updateCategory(int id, Category category) async {
    print('\n=== CATEGORY_PROVIDER updateCategory() DEBUG ===');
    print('Updating category $id with data:');
    print('  - category.name: ${category.name}');
    print('  - category.description: ${category.description}');
    print('  - category.parentCategoryId: ${category.parentCategoryId}');
    print('  - category.isActive: ${category.isActive}');

    try {
      final jsonData = category.toJson();
      print('Category toJson() result: $jsonData');

      final result = await update(id, jsonData);
      print('Category updated successfully: ${result.toJson()}');
      return result;
    } catch (e, stackTrace) {
      print('\n!!! ERROR in updateCategory() !!!');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Category>> getActiveCategories() async {
    var filter = {"isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Category>> getRootCategories() async {
    var filter = {"parentCategoryId": null, "isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Category>> getSubCategories(int parentCategoryId) async {
    var filter = {"parentCategoryId": parentCategoryId, "isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Category>> searchCategories(String searchTerm) async {
    var filter = {"search": searchTerm};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<Category?> getCategoryById(int id) async {
    final url = "${ApiConfig.apiUrl}/Category/$id";
    final token = AuthProvider.token;

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Category.fromJson(data);
    } else {
      return null;
    }
  }

  Future<String> uploadCategoryImage(int categoryId, File imageFile) async {
    final url = "${ApiConfig.apiUrl}/Category/$categoryId/image";
    final request = http.MultipartRequest('POST', Uri.parse(url));

    final token = AuthProvider.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Detect correct MIME type based on file extension
    String? contentType;
    final extension = imageFile.path.toLowerCase().split('.').last;
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
        imageFile.path,
        contentType: contentType != null
            ? http.MediaType.parse(contentType)
            : null,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    } else {
      throw HttpErrorHandler.createException(response, 'upload category image');
    }
  }

  Future<bool> deleteCategoryImage(int categoryId) async {
    final url = "${ApiConfig.apiUrl}/Category/$categoryId/image";
    final token = AuthProvider.token;

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw HttpErrorHandler.createException(response, 'delete category image');
    }
  }
}
