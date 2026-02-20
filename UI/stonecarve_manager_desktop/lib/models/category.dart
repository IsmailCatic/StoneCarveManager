import 'product.dart';

class Category {
  int? id;
  String? name;
  String? description;
  int? parentCategoryId;
  String? imageUrl;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Hierarchical properties from backend
  String? parentCategoryName;
  int? productCount;
  int? childCategoryCount;

  // Related objects
  Category? parentCategory;
  List<Category>? childCategories;
  List<Product>? products;

  Category({
    this.id,
    this.name,
    this.description,
    this.parentCategoryId,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.parentCategoryName,
    this.productCount,
    this.childCategoryCount,
    this.parentCategory,
    this.childCategories,
    this.products,
  });

  Category.fromJson(Map<String, dynamic> json) {
    // Support both PascalCase (C# standard) and camelCase (JSON standard)
    id = json['Id'] ?? json['id'];
    name = json['Name'] ?? json['name'];
    description = json['Description'] ?? json['description'];
    parentCategoryId = json['ParentCategoryId'] ?? json['parentCategoryId'];
    imageUrl = json['ImageUrl'] ?? json['imageUrl'];
    isActive = json['IsActive'] ?? json['isActive'];

    // Hierarchical properties
    parentCategoryName =
        json['ParentCategoryName'] ?? json['parentCategoryName'];
    productCount = json['ProductCount'] ?? json['productCount'];
    childCategoryCount =
        json['ChildCategoryCount'] ?? json['childCategoryCount'];

    createdAt = (json['CreatedAt'] ?? json['createdAt']) != null
        ? DateTime.parse(json['CreatedAt'] ?? json['createdAt'])
        : null;
    updatedAt = (json['UpdatedAt'] ?? json['updatedAt']) != null
        ? DateTime.parse(json['UpdatedAt'] ?? json['updatedAt'])
        : null;

    if ((json['ParentCategory'] ?? json['parentCategory']) != null) {
      parentCategory = Category.fromJson(
        json['ParentCategory'] ?? json['parentCategory'],
      );
    }
    if ((json['ChildCategories'] ?? json['childCategories']) != null) {
      childCategories = <Category>[];
      (json['ChildCategories'] ?? json['childCategories']).forEach((v) {
        childCategories!.add(Category.fromJson(v));
      });
    }
    if ((json['Products'] ?? json['products']) != null) {
      products = <Product>[];
      (json['Products'] ?? json['products']).forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    print('\n=== CATEGORY toJson() DEBUG ===');
    print('Converting category to JSON:');
    print('  - id: $id');
    print('  - name: $name');
    print('  - description: $description');
    print('  - parentCategoryId: $parentCategoryId');
    print('  - imageUrl: $imageUrl');
    print('  - isActive: $isActive');
    print('  - createdAt: $createdAt');
    print('  - updatedAt: $updatedAt');
    print('  - parentCategoryName: $parentCategoryName');
    print('  - productCount: $productCount');
    print('  - childCategoryCount: $childCategoryCount');
    print('  - parentCategory: ${parentCategory != null ? "exists" : "null"}');
    print('  - childCategories: ${childCategories?.length ?? "null"}');
    print('  - products: ${products?.length ?? "null"}');

    try {
      final result = {
        'Id': id,
        'Name': name,
        'Description': description,
        'ParentCategoryId': parentCategoryId,
        'ImageUrl': imageUrl,
        'IsActive': isActive,
        'CreatedAt': createdAt?.toIso8601String(),
        'UpdatedAt': updatedAt?.toIso8601String(),
        // Don't send navigation properties or computed properties to the backend
        // These are read-only from the backend response:
        // - ParentCategoryName
        // - ProductCount
        // - ChildCategoryCount
        // - ParentCategory
        // - ChildCategories
        // - Products
      };
      print('toJson() completed successfully: $result');
      return result;
    } catch (e, stackTrace) {
      print('\n!!! ERROR in toJson() !!!');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }
}
