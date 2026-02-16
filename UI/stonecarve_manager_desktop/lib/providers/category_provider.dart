import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super("Category");

  @override
  Category fromJson(data) {
    return Category.fromJson(data);
  }

  Future<Category> createCategory(Category category) async {
    return await insert(category.toJson());
  }

  Future<Category> updateCategory(int id, Category category) async {
    return await update(id, category.toJson());
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
    final url = "http://localhost:5021/api/Category/$id";
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
    final url = "http://localhost:5021/api/Category/$categoryId/image";
    final request = http.MultipartRequest('POST', Uri.parse(url));

    final token = AuthProvider.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    } else {
      throw Exception("Failed to upload image: ${response.body}");
    }
  }

  Future<bool> deleteCategoryImage(int categoryId) async {
    final url = "http://localhost:5021/api/Category/$categoryId/image";
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
      throw Exception("Failed to delete image: ${response.body}");
    }
  }
}
