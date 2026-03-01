import 'category.dart';
import 'material.dart' as stone_material;

class Product {
  int? id;
  String? name;
  String? description;
  double? price;
  int? stockQuantity;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? dimensions;
  double? weight;
  int? estimatedDays;
  bool? isInPortfolio;
  int? viewCount;
  int? categoryId;
  String? categoryName;
  int? materialId;
  String? materialName;
  String? productState;
  int? reviewCount;
  double? averageRating;

  // Portfolio-specific fields
  String? portfolioDescription;
  String? clientChallenge;
  String? ourSolution;
  String? projectOutcome;
  String? location;
  int? completionYear;
  int? projectDuration;
  String? techniquesUsed;

  // Related objects
  Category? category;
  stone_material.StoneMaterial? material;
  List<ProductImage>? images;
  List<ProductReview>? reviews;

  Product({
    this.id,
    this.name,
    this.description,
    this.price,
    this.stockQuantity,
    this.createdAt,
    this.updatedAt,
    this.dimensions,
    this.weight,
    this.estimatedDays,
    this.isInPortfolio,
    this.viewCount,
    this.categoryId,
    this.categoryName,
    this.materialId,
    this.materialName,
    this.productState,
    this.reviewCount,
    this.averageRating,
    this.portfolioDescription,
    this.clientChallenge,
    this.ourSolution,
    this.projectOutcome,
    this.location,
    this.completionYear,
    this.projectDuration,
    this.techniquesUsed,
    this.category,
    this.material,
    this.images,
    this.reviews,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price']?.toDouble();
    stockQuantity = json['stockQuantity'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null;
    dimensions = json['dimensions'];
    weight = json['weight']?.toDouble();
    estimatedDays = json['estimatedDays'];
    isInPortfolio = json['isInPortfolio'];
    viewCount = json['viewCount'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    materialId = json['materialId'];
    materialName = json['materialName'];
    productState = json['productState'];
    reviewCount = json['reviewCount'];
    averageRating = json['averageRating']?.toDouble();

    portfolioDescription = json['portfolioDescription'];
    clientChallenge = json['clientChallenge'];
    ourSolution = json['ourSolution'];
    projectOutcome = json['projectOutcome'];
    location = json['location'];
    completionYear = json['completionYear'];
    projectDuration = json['projectDuration'];
    techniquesUsed = json['techniquesUsed'];

    if (json['category'] != null) {
      category = Category.fromJson(json['category']);
    }
    if (json['material'] != null) {
      material = stone_material.StoneMaterial.fromJson(json['material']);
    }
    if (json['images'] != null) {
      images = <ProductImage>[];
      json['images'].forEach((v) {
        images!.add(ProductImage.fromJson(v));
      });
    }
    if (json['reviews'] != null) {
      reviews = <ProductReview>[];
      json['reviews'].forEach((v) {
        reviews!.add(ProductReview.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dimensions': dimensions,
      'weight': weight,
      'estimatedDays': estimatedDays,
      'isInPortfolio': isInPortfolio,
      'viewCount': viewCount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'materialId': materialId,
      'materialName': materialName,
      'productState': productState,
      'reviewCount': reviewCount,
      'averageRating': averageRating,
      'portfolioDescription': portfolioDescription,
      'clientChallenge': clientChallenge,
      'ourSolution': ourSolution,
      'projectOutcome': projectOutcome,
      'location': location,
      'completionYear': completionYear,
      'projectDuration': projectDuration,
      'techniquesUsed': techniquesUsed,
      'category': category?.toJson(),
      'material': material?.toJson(),
      'images': images?.map((v) => v.toJson()).toList(),
      'reviews': reviews?.map((v) => v.toJson()).toList(),
    };
  }
}

class ProductImage {
  int? id;
  int? productId;
  String? imageUrl;
  String? altText;
  bool? isPrimary;
  DateTime? createdAt;

  ProductImage({
    this.id,
    this.productId,
    this.imageUrl,
    this.altText,
    this.isPrimary,
    this.createdAt,
  });

  ProductImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    imageUrl = json['imageUrl'];
    altText = json['altText'];
    isPrimary = json['isPrimary'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
      'altText': altText,
      'isPrimary': isPrimary,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class ProductReview {
  int? id;
  int? productId;
  int? userId;
  String? userName;
  int? rating;
  String? comment;
  DateTime? createdAt;

  ProductReview({
    this.id,
    this.productId,
    this.userId,
    this.userName,
    this.rating,
    this.comment,
    this.createdAt,
  });

  ProductReview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    userId = json['userId'];
    userName = json['userName'];
    rating = json['rating'];
    comment = json['comment'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
