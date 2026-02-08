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
    this.parentCategory,
    this.childCategories,
    this.products,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    parentCategoryId = json['parentCategoryId'];
    imageUrl = json['imageUrl'];
    isActive = json['isActive'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null;

    if (json['parentCategory'] != null) {
      parentCategory = Category.fromJson(json['parentCategory']);
    }
    if (json['childCategories'] != null) {
      childCategories = <Category>[];
      json['childCategories'].forEach((v) {
        childCategories!.add(Category.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Product>[];
      json['products'].forEach((v) {
        products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'parentCategoryId': parentCategoryId,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'parentCategory': parentCategory?.toJson(),
      'childCategories': childCategories?.map((v) => v.toJson()).toList(),
      'products': products?.map((v) => v.toJson()).toList(),
    };
  }
}
