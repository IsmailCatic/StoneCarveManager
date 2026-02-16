import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class MaterialProvider extends BaseProvider<stone_material.StoneMaterial> {
  MaterialProvider() : super("Material");

  @override
  stone_material.StoneMaterial fromJson(data) {
    return stone_material.StoneMaterial.fromJson(data);
  }

  Future<stone_material.StoneMaterial> createMaterial(
    stone_material.StoneMaterial material,
  ) async {
    return await insert(material.toJson());
  }

  Future<stone_material.StoneMaterial> updateMaterial(
    int id,
    stone_material.StoneMaterial material,
  ) async {
    return await update(id, material.toJson());
  }

  Future<List<stone_material.StoneMaterial>> getAvailableMaterials() async {
    var filter = {"isAvailable": true, "isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<stone_material.StoneMaterial>> getMaterialsInStock() async {
    var filter = {"quantityInStock__gt": 0, "isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<stone_material.StoneMaterial>> searchMaterials(
    String searchTerm,
  ) async {
    var filter = {"search": searchTerm};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<stone_material.StoneMaterial>> getMaterialsByUnit(
    String unit,
  ) async {
    var filter = {"unit": unit};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<stone_material.StoneMaterial?> getMaterialById(int id) async {
    final url = "http://localhost:5021/api/Material/$id";
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
      return stone_material.StoneMaterial.fromJson(data);
    } else {
      return null;
    }
  }

  Future<String> uploadMaterialImage(int materialId, File imageFile) async {
    final url = "http://localhost:5021/api/Material/$materialId/image";
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

  Future<bool> deleteMaterialImage(int materialId) async {
    final url = "http://localhost:5021/api/Material/$materialId/image";
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
