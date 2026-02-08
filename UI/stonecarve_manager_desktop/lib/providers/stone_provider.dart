import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;

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
}
