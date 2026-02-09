class Order {
  final int id;
  final DateTime orderDate;
  final String orderNumber;
  final int status;
  final double totalAmount;
  final String? customerNotes;
  final String? adminNotes;
  final String? attachmentUrl;
  final DateTime? estimatedCompletionDate;
  final DateTime? completedAt;
  final int userId;
  final int? assignedEmployeeId;
  final List<OrderItem> orderItems;
  final String? deliveryAddress;
  final String? deliveryCity;
  final String? deliveryZipCode;
  final DateTime? deliveryDate;
  final Review? review;
  final List<ProgressImage> progressImages;
  final List<OrderStatusHistory> statusHistory;
  final String? clientName;
  final String? clientEmail;

  static String statusToString(dynamic status) {
    // Adjust this logic based on your actual status type and values
    if (status == null) return 'Unknown';
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Processing';
      case 2:
        return 'Shipped';
      case 3:
        return 'Delivered';
      case 4:
        return 'Cancelled';
      case 5:
        return 'Returned';
      default:
        return status.toString();
    }
  }

  Order({
    required this.id,
    required this.orderDate,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    this.customerNotes,
    this.adminNotes,
    this.attachmentUrl,
    this.estimatedCompletionDate,
    this.completedAt,
    required this.userId,
    this.assignedEmployeeId,
    required this.orderItems,
    this.deliveryAddress,
    this.deliveryCity,
    this.deliveryZipCode,
    this.deliveryDate,
    this.review,
    required this.progressImages,
    this.statusHistory = const [],
    this.clientName,
    this.clientEmail,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    orderDate: DateTime.parse(json['orderDate']),
    orderNumber: json['orderNumber'],
    status: json['status'],
    totalAmount: (json['totalAmount'] as num).toDouble(),
    customerNotes: json['customerNotes'],
    adminNotes: json['adminNotes'],
    attachmentUrl: json['attachmentUrl'],
    estimatedCompletionDate: json['estimatedCompletionDate'] != null
        ? DateTime.parse(json['estimatedCompletionDate'])
        : null,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null,
    userId: json['userId'],
    assignedEmployeeId: json['assignedEmployeeId'],
    orderItems:
        (json['orderItems'] as List?)
            ?.map((e) => OrderItem.fromJson(e))
            .toList() ??
        [],
    deliveryAddress: json['deliveryAddress'],
    deliveryCity: json['deliveryCity'],
    deliveryZipCode: json['deliveryZipCode'],
    deliveryDate: json['deliveryDate'] != null
        ? DateTime.parse(json['deliveryDate'])
        : null,
    review: json['review'] != null ? Review.fromJson(json['review']) : null,
    progressImages:
        (json['progressImages'] as List?)
            ?.map((e) => ProgressImage.fromJson(e))
            .toList() ??
        [],
    statusHistory:
        (json['statusHistory'] as List?)
            ?.map((e) => OrderStatusHistory.fromJson(e))
            .toList() ??
        [],
    clientName: json['clientName'],
    clientEmail: json['clientEmail'],
  );

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'clientEmail': clientEmail,
    'id': id,
    'orderDate': orderDate.toIso8601String(),
    'orderNumber': orderNumber,
    'status': status,
    'totalAmount': totalAmount,
    'customerNotes': customerNotes,
    'adminNotes': adminNotes,
    'attachmentUrl': attachmentUrl,
    'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'userId': userId,
    'assignedEmployeeId': assignedEmployeeId,
    'orderItems': orderItems.map((e) => e.toJson()).toList(),
    'deliveryAddress': deliveryAddress,
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
    'deliveryCity': deliveryCity,
    'deliveryZipCode': deliveryZipCode,
    'deliveryDate': deliveryDate?.toIso8601String(),
    'review': review?.toJson(),
    'progressImages': progressImages.map((e) => e.toJson()).toList(),
  };
}

class OrderItem {
  final int id;
  final int? orderId;
  final int? stoneId;
  final int? productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specifications;

  OrderItem({
    required this.id,
    this.orderId,
    this.stoneId,
    this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specifications,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] ?? 0,
    orderId: json['orderId'],
    stoneId: json['stoneId'],
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'] ?? 0,
    unitPrice: json['unitPrice'] != null
        ? (json['unitPrice'] as num).toDouble()
        : 0.0,
    totalPrice: json['totalPrice'] != null
        ? (json['totalPrice'] as num).toDouble()
        : 0.0,
    specifications: json['specifications'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'stoneId': stoneId,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'specifications': specifications,
  };
}

class Review {
  final int id;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int userId;
  final String? userName;
  final int productId;
  final String? productName;
  final int orderId;
  final bool isApproved;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    required this.userId,
    this.userName,
    required this.productId,
    this.productName,
    required this.orderId,
    required this.isApproved,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    rating: json['rating'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    userId: json['userId'],
    userName: json['userName'],
    productId: json['productId'],
    productName: json['productName'],
    orderId: json['orderId'],
    isApproved: json['isApproved'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'userId': userId,
    'userName': userName,
    'productId': productId,
    'productName': productName,
    'orderId': orderId,
    'isApproved': isApproved,
  };
}

class ProgressImage {
  final int id;
  final String? imageUrl;
  final String? description;
  final DateTime uploadedAt;
  final int orderId;
  final int? uploadedByUserId;
  final String? uploadedByUserName;

  ProgressImage({
    required this.id,
    required this.imageUrl,
    this.description,
    required this.uploadedAt,
    required this.orderId,
    this.uploadedByUserId,
    this.uploadedByUserName,
  });

  factory ProgressImage.fromJson(Map<String, dynamic> json) => ProgressImage(
    id: json['id'],
    imageUrl: json['imageUrl']?.toString(),
    description: json['description']?.toString(),
    uploadedAt: DateTime.parse(json['uploadedAt']),
    orderId: json['orderId'],
    uploadedByUserId: json['uploadedByUserId'],
    uploadedByUserName: json['uploadedByUserName']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'description': description,
    'uploadedAt': uploadedAt.toIso8601String(),
    'orderId': orderId,
    'uploadedByUserId': uploadedByUserId,
    'uploadedByUserName': uploadedByUserName,
  };
}

class OrderStatusHistory {
  final int id;
  final int orderId;
  final int oldStatus;
  final int newStatus;
  final String? comment;
  final DateTime changedAt;
  final int? changedByUserId;
  final String? changedByUserName;

  OrderStatusHistory({
    required this.id,
    required this.orderId,
    required this.oldStatus,
    required this.newStatus,
    this.comment,
    required this.changedAt,
    this.changedByUserId,
    this.changedByUserName,
  });

  String get oldStatusDisplay => Order.statusToString(oldStatus);
  String get newStatusDisplay => Order.statusToString(newStatus);

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      OrderStatusHistory(
        id: json['id'],
        orderId: json['orderId'],
        oldStatus: json['oldStatus'],
        newStatus: json['newStatus'],
        comment: json['comment'],
        changedAt: DateTime.parse(json['changedAt']),
        changedByUserId: json['changedByUserId'],
        changedByUserName: json['changedByUserName'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'oldStatus': oldStatus,
    'newStatus': newStatus,
    'comment': comment,
    'changedAt': changedAt.toIso8601String(),
    'changedByUserId': changedByUserId,
    'changedByUserName': changedByUserName,
  };
}
