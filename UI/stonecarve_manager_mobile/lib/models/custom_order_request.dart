class CustomOrderRequest {
  final int? categoryId;
  final int? materialId;
  final String? dimensions;
  final String description;
  final String? customerNotes;
  final List<String> referenceImageUrls;
  final double? estimatedPrice;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryCountry;
  final String? deliveryZipCode;
  final DateTime? deliveryDate;

  CustomOrderRequest({
    this.categoryId,
    this.materialId,
    this.dimensions,
    required this.description,
    this.customerNotes,
    this.referenceImageUrls = const [],
    this.estimatedPrice,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryCountry,
    this.deliveryZipCode,
    this.deliveryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (categoryId != null) 'categoryId': categoryId,
      if (materialId != null) 'materialId': materialId,
      if (dimensions != null && dimensions!.isNotEmpty)
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
      if (deliveryCountry != null && deliveryCountry!.isNotEmpty)
        'deliveryCountry': deliveryCountry,
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
      deliveryCountry: json['deliveryCountry'],
      deliveryZipCode: json['deliveryZipCode'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }

  bool isValid() {
    return description.trim().isNotEmpty && description.length <= 4000;
  }
}
