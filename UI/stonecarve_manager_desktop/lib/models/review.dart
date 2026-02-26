class ProductReview {
  final int id;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final int userId;
  final String? userName;
  final int? productId;
  final String? productName;
  final int? orderId;
  final String? orderNumber;
  final bool isApproved;
  final DateTime? updatedAt;

  ProductReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.userId,
    this.userName,
    this.productId,
    this.productName,
    this.orderId,
    this.orderNumber,
    required this.isApproved,
    this.updatedAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      userId: json['userId'] ?? 0,
      userName: json['userName'],
      productId: json['productId'],
      productName: json['productName'],
      orderId: json['orderId'],
      orderNumber: json['orderNumber'],
      isApproved: json['isApproved'] ?? false,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'productId': productId,
      'productName': productName,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'isApproved': isApproved,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ReviewSearchObject {
  int? page;
  int? pageSize;
  bool? isApproved;
  int? productId;
  int? orderId;
  int? userId;
  int? minRating;
  int? maxRating;
  int? rating;
  String? searchQuery;
  bool retrieveAll;

  ReviewSearchObject({
    this.page,
    this.pageSize,
    this.isApproved,
    this.productId,
    this.orderId,
    this.userId,
    this.minRating,
    this.maxRating,
    this.rating,
    this.searchQuery,
    this.retrieveAll = false,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['pageSize'] = pageSize.toString();
    if (isApproved != null) params['isApproved'] = isApproved.toString();
    if (productId != null) params['productId'] = productId.toString();
    if (orderId != null) params['orderId'] = orderId.toString();
    if (userId != null) params['userId'] = userId.toString();
    if (minRating != null) params['minRating'] = minRating.toString();
    if (maxRating != null) params['maxRating'] = maxRating.toString();
    if (rating != null) params['rating'] = rating.toString();
    if (searchQuery != null && searchQuery!.isNotEmpty)
      params['searchQuery'] = searchQuery!;
    if (retrieveAll) params['retrieveAll'] = 'true';

    return params;
  }
}
