import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';

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
}
