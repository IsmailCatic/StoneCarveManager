class OrderUpdateRequest {
  int? assignedEmployeeId;
  int? status;
  String? customerNotes;
  String? adminNotes;
  String? attachmentUrl;
  DateTime? estimatedCompletionDate;
  DateTime? completedAt;
  String? deliveryAddress;
  String? deliveryCity;
  String? deliveryZipCode;
  DateTime? deliveryDate;
  List<OrderItemUpdateRequest>? items;

  OrderUpdateRequest({
    this.assignedEmployeeId,
    this.status,
    this.customerNotes,
    this.adminNotes,
    this.attachmentUrl,
    this.estimatedCompletionDate,
    this.completedAt,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryZipCode,
    this.deliveryDate,
    this.items,
  });

  Map<String, dynamic> toJson() => {
    if (assignedEmployeeId != null) 'assignedEmployeeId': assignedEmployeeId,
    if (status != null) 'status': status,
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (adminNotes != null) 'adminNotes': adminNotes,
    if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    if (estimatedCompletionDate != null)
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt?.toIso8601String(),
    if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
    if (deliveryCity != null) 'deliveryCity': deliveryCity,
    if (deliveryZipCode != null) 'deliveryZipCode': deliveryZipCode,
    if (deliveryDate != null) 'deliveryDate': deliveryDate?.toIso8601String(),
    if (items != null) 'items': items?.map((e) => e.toJson()).toList(),
  };
}

class OrderItemUpdateRequest {
  // Define fields as per your backend model
  // Example:
  int? id;
  int? stoneId;
  int? quantity;
  double? unitPrice;
  double? totalPrice;
  String? specifications;

  OrderItemUpdateRequest({
    this.id,
    this.stoneId,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.specifications,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (stoneId != null) 'stoneId': stoneId,
    if (quantity != null) 'quantity': quantity,
    if (unitPrice != null) 'unitPrice': unitPrice,
    if (totalPrice != null) 'totalPrice': totalPrice,
    if (specifications != null) 'specifications': specifications,
  };
}
