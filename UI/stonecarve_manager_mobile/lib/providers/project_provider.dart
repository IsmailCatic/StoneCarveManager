import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(data) {
    return Product.fromJson(data);
  }

  Future<Product> createProduct(Product product) async {
    return await insert(product.toJson());
  }

  Future<Product> updateProduct(int id, Product product) async {
    return await update(id, product.toJson());
  }

  Future<bool> deleteProduct(int id) async {
    return await delete(id);
  }

  Future<List<Product>> getActiveProducts() async {
    var filter = {"isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    var filter = {"categoryId": categoryId};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Product>> getProductsByMaterial(int materialId) async {
    var filter = {"materialId": materialId};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Product>> getInStockProducts() async {
    var filter = {"stockQuantity__gt": 0};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Product>> getPortfolioProducts() async {
    var filter = {"isInPortfolio": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Product>> searchProducts(String searchTerm) async {
    var filter = {"search": searchTerm};
    var result = await get(filter: filter);
    return result.items ?? [];
  }
}
