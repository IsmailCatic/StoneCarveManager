class CustomOrderRequest {
  final int categoryId;
  final int materialId;
  final String dimensions;
  final String description;
  final String? customerNotes;
  final List<String> referenceImageUrls;
  final double? estimatedPrice;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryZipCode;
  final DateTime? deliveryDate;

  CustomOrderRequest({
    required this.categoryId,
    required this.materialId,
    required this.dimensions,
    required this.description,
    this.customerNotes,
    this.referenceImageUrls = const [],
    this.estimatedPrice,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryZipCode,
    this.deliveryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'materialId': materialId,
      'dimensions': dimensions,
      'description': description,
      if (customerNotes != null && customerNotes!.isNotEmpty)
        'customerNotes': customerNotes,
      'referenceImageUrls': referenceImageUrls,
      if (estimatedPrice != null) 'estimatedPrice': estimatedPrice,
      if (deliveryAddress != null && deliveryAddress!.isNotEmpty)
        'deliveryAddress': deliveryAddress,
      if (deliveryCity != null && deliveryCity!.isNotEmpty)
        'deliveryCity': deliveryCity,
      if (deliveryZipCode != null && deliveryZipCode!.isNotEmpty)
        'deliveryZipCode': deliveryZipCode,
      if (deliveryDate != null) 'deliveryDate': deliveryDate!.toIso8601String(),
    };
  }

  factory CustomOrderRequest.fromJson(Map<String, dynamic> json) {
    return CustomOrderRequest(
      categoryId: json['categoryId'],
      materialId: json['materialId'],
      dimensions: json['dimensions'],
      description: json['description'],
      customerNotes: json['customerNotes'],
      referenceImageUrls: json['referenceImageUrls'] != null
          ? List<String>.from(json['referenceImageUrls'])
          : [],
      estimatedPrice: json['estimatedPrice']?.toDouble(),
      deliveryAddress: json['deliveryAddress'],
      deliveryCity: json['deliveryCity'],
      deliveryZipCode: json['deliveryZipCode'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }

  // Helper for validation
  bool isValid() {
    return categoryId > 0 &&
        materialId > 0 &&
        dimensions.trim().isNotEmpty &&
        dimensions.length <= 200 &&
        description.trim().isNotEmpty &&
        description.length <= 4000 &&
        (customerNotes == null || customerNotes!.length <= 2000);
  }
}
