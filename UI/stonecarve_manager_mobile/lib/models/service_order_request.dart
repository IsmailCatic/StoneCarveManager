class ServiceOrderRequest {
  final int serviceProductId;
  final String requirements;
  final String? dimensions;
  final String? customerNotes;
  final List<String>? referenceImageUrls;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryCountry;
  final String? deliveryZipCode;
  final DateTime? preferredDate;

  const ServiceOrderRequest({
    required this.serviceProductId,
    required this.requirements,
    this.dimensions,
    this.customerNotes,
    this.referenceImageUrls,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryCountry,
    this.deliveryZipCode,
    this.preferredDate,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'serviceProductId': serviceProductId,
      'requirements': requirements,
    };
    if (dimensions != null) map['dimensions'] = dimensions;
    if (customerNotes != null) map['customerNotes'] = customerNotes;
    if (referenceImageUrls != null && referenceImageUrls!.isNotEmpty) {
      map['referenceImageUrls'] = referenceImageUrls;
    }
    if (deliveryAddress != null) map['deliveryAddress'] = deliveryAddress;
    if (deliveryCity != null) map['deliveryCity'] = deliveryCity;
    if (deliveryCountry != null) map['deliveryCountry'] = deliveryCountry;
    if (deliveryZipCode != null) map['deliveryZipCode'] = deliveryZipCode;
    if (preferredDate != null) {
      map['deliveryDate'] = preferredDate!.toIso8601String();
    }
    return map;
  }
}
