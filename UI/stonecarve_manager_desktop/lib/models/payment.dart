class Payment {
  final int id;
  final double amount;
  final String method; // stripe, cash, bank_transfer
  final String
  status; // pending, succeeded, failed, cancelled, refunded, partially_refunded
  final String? transactionId;
  final String? stripePaymentIntentId;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int orderId;
  final String? orderNumber;
  final String?
  orderStatus; // Order status: Pending, Processing, Shipped, Delivered, Cancelled, Returned
  final String? customerName;
  final String? customerEmail;

  // Refund tracking fields
  final double? refundAmount;
  final String? refundReason;
  final DateTime? refundedAt;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.stripePaymentIntentId,
    this.failureReason,
    required this.createdAt,
    this.completedAt,
    required this.orderId,
    this.orderNumber,
    this.orderStatus,
    this.customerName,
    this.customerEmail,
    this.refundAmount,
    this.refundReason,
    this.refundedAt,
  });

  // Calculated property for net amount after refunds
  double get netAmount => amount - (refundAmount ?? 0.0);

  // Check if payment has any refund
  bool get isRefunded => refundAmount != null && refundAmount! > 0;

  // Check if fully refunded
  bool get isFullyRefunded => refundAmount != null && refundAmount! >= amount;

  // Check if partially refunded
  bool get isPartiallyRefunded =>
      refundAmount != null && refundAmount! > 0 && refundAmount! < amount;

  factory Payment.fromJson(Map<String, dynamic> json) {
    print(
      '[Payment.fromJson] Parsing payment: id=${json['id']}, status=${json['status']}, rawJson=$json',
    );
    return Payment(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? 'stripe',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
      stripePaymentIntentId: json['stripePaymentIntentId'],
      failureReason: json['failureReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      orderId: json['orderId'] ?? 0,
      orderNumber: json['orderNumber'],
      orderStatus: json['orderStatus'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] as num).toDouble()
          : null,
      refundReason: json['refundReason'],
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'stripePaymentIntentId': stripePaymentIntentId,
      'failureReason': failureReason,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'orderId': orderId,
      'orderNumber': orderNumber,
      'orderStatus': orderStatus,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'refundAmount': refundAmount,
      'refundReason': refundReason,
      'refundedAt': refundedAt?.toIso8601String(),
    };
  }
}

class PaymentSearchObject {
  int? page;
  int? pageSize;
  String? status;
  String? method;
  DateTime? startDate;
  DateTime? endDate;
  int? orderId;
  bool retrieveAll;

  PaymentSearchObject({
    this.page,
    this.pageSize,
    this.status,
    this.method,
    this.startDate,
    this.endDate,
    this.orderId,
    this.retrieveAll = false,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page.toString();
    if (pageSize != null) params['pageSize'] = pageSize.toString();
    if (status != null) params['status'] = status;
    if (method != null) params['method'] = method;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (orderId != null) params['orderId'] = orderId.toString();
    if (retrieveAll) params['retrieveAll'] = 'true';

    return params;
  }
}

class RefundRequest {
  final String paymentIntentId;
  final int orderId;
  final double? amount; // null = full refund
  final String? reason;

  RefundRequest({
    required this.paymentIntentId,
    required this.orderId,
    this.amount,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentIntentId': paymentIntentId,
      'orderId': orderId,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
    };
  }
}

class PaymentStatistics {
  final double totalRevenue;
  final int successfulCount;
  final int failedCount;
  final int pendingCount;
  final double refundedAmount;
  final Map<String, double> revenueByMethod;

  PaymentStatistics({
    required this.totalRevenue,
    required this.successfulCount,
    required this.failedCount,
    required this.pendingCount,
    required this.refundedAmount,
    required this.revenueByMethod,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, double> methodRevenue = {};
    if (json['revenueByMethod'] != null) {
      (json['revenueByMethod'] as Map<String, dynamic>).forEach((key, value) {
        methodRevenue[key] = (value ?? 0).toDouble();
      });
    }

    return PaymentStatistics(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      successfulCount: json['successfulCount'] ?? 0,
      failedCount: json['failedCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      refundedAmount: (json['refundedAmount'] ?? 0).toDouble(),
      revenueByMethod: methodRevenue,
    );
  }
}
