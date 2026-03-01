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
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (pricePerUnit != null) data['pricePerUnit'] = pricePerUnit;
    if (unit != null) data['unit'] = unit;
    if (quantityInStock != null) data['quantityInStock'] = quantityInStock;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    if (isActive != null) data['isActive'] = isActive;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (products != null)
      data['products'] = products!.map((v) => v.toJson()).toList();

    return data;
  }
}
