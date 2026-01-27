class ProductSearchObject {
  int? categoryId;
  int? materialId;
  bool? isActive;
  String? search;
  int? page;
  int? pageSize;

  ProductSearchObject({
    this.categoryId,
    this.materialId,
    this.isActive,
    this.search,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    
    if (categoryId != null) params['categoryId'] = categoryId;
    if (materialId != null) params['materialId'] = materialId;
    if (isActive != null) params['isActive'] = isActive;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    
    return params;
  }
}

class ProductInsertRequest {
  String? name;
  String? description;
  double? price;
  int? stockQuantity;
  bool? isActive;
  String? dimensions;
  double? weight;
  int? estimatedDays;
  bool? isInPortfolio;
  int? categoryId;
  int? materialId;
  String? productState;

  ProductInsertRequest({
    this.name,
    this.description,
    this.price,
    this.stockQuantity,
    this.isActive,
    this.dimensions,
    this.weight,
    this.estimatedDays,
    this.isInPortfolio,
    this.categoryId,
    this.materialId,
    this.productState,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stockQuantity': stockQuantity ?? 0,
      'isActive': isActive ?? true,
      'dimensions': dimensions,
      'weight': weight,
      'estimatedDays': estimatedDays ?? 7,
      'isInPortfolio': isInPortfolio ?? true,
      'categoryId': categoryId,
      'materialId': materialId,
      'productState': productState ?? 'draft',
    };
  }
}

class ProductUpdateRequest {
  String? name;
  String? description;
  double? price;
  int? stockQuantity;
  bool? isActive;
  String? dimensions;
  double? weight;
  int? estimatedDays;
  bool? isInPortfolio;
  int? categoryId;
  int? materialId;
  String? productState;

  ProductUpdateRequest({
    this.name,
    this.description,
    this.price,
    this.stockQuantity,
    this.isActive,
    this.dimensions,
    this.weight,
    this.estimatedDays,
    this.isInPortfolio,
    this.categoryId,
    this.materialId,
    this.productState,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (stockQuantity != null) data['stockQuantity'] = stockQuantity;
    if (isActive != null) data['isActive'] = isActive;
    if (dimensions != null) data['dimensions'] = dimensions;
    if (weight != null) data['weight'] = weight;
    if (estimatedDays != null) data['estimatedDays'] = estimatedDays;
    if (isInPortfolio != null) data['isInPortfolio'] = isInPortfolio;
    if (categoryId != null) data['categoryId'] = categoryId;
    if (materialId != null) data['materialId'] = materialId;
    if (productState != null) data['productState'] = productState;
    
    return data;
  }
}

class MaterialInsertRequest {
  String? name;
  String? description;
  String? imageUrl;
  double? pricePerUnit;
  String? unit;
  int? quantityInStock;
  bool? isAvailable;
  bool? isActive;

  MaterialInsertRequest({
    this.name,
    this.description,
    this.imageUrl,
    this.pricePerUnit,
    this.unit,
    this.quantityInStock,
    this.isAvailable,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description ?? '',
      'imageUrl': imageUrl,
      'pricePerUnit': pricePerUnit,
      'unit': unit ?? 'm²',
      'quantityInStock': quantityInStock ?? 0,
      'isAvailable': isAvailable ?? true,
      'isActive': isActive ?? true,
    };
  }
}

class MaterialUpdateRequest {
  String? name;
  String? description;
  String? imageUrl;
  double? pricePerUnit;
  String? unit;
  int? quantityInStock;
  bool? isAvailable;
  bool? isActive;

  MaterialUpdateRequest({
    this.name,
    this.description,
    this.imageUrl,
    this.pricePerUnit,
    this.unit,
    this.quantityInStock,
    this.isAvailable,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (pricePerUnit != null) data['pricePerUnit'] = pricePerUnit;
    if (unit != null) data['unit'] = unit;
    if (quantityInStock != null) data['quantityInStock'] = quantityInStock;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    if (isActive != null) data['isActive'] = isActive;
    
    return data;
  }
}