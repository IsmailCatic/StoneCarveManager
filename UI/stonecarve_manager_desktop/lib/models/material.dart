import 'product.dart';

class StoneMaterial {
  int? id;
  String? name;
  String? description;
  String? imageUrl;
  double? pricePerUnit;
  String? unit;
  int? quantityInStock;
  bool? isAvailable;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Related objects
  List<Product>? products;

  StoneMaterial({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.pricePerUnit,
    this.unit,
    this.quantityInStock,
    this.isAvailable,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.products,
  });

  StoneMaterial.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    pricePerUnit = json['pricePerUnit']?.toDouble();
    unit = json['unit'];
    quantityInStock = json['quantityInStock'];
    isAvailable = json['isAvailable'];
    isActive = json['isActive'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null;

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
      'imageUrl': imageUrl,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'quantityInStock': quantityInStock,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'products': products?.map((v) => v.toJson()).toList(),
    };
  }
}
