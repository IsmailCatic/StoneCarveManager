class CreatePaymentIntentRequest {
  final int orderId;
  final String paymentMethod;
  final String? customerEmail;
  final String? customerName;

  CreatePaymentIntentRequest({
    required this.orderId,
    this.paymentMethod = 'stripe',
    this.customerEmail,
    this.customerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'paymentMethod': paymentMethod,
      'customerEmail': customerEmail,
      'customerName': customerName,
    };
  }
}

class ConfirmPaymentRequest {
  final String paymentIntentId;
  final int orderId;

  ConfirmPaymentRequest({required this.paymentIntentId, required this.orderId});

  Map<String, dynamic> toJson() {
    return {'paymentIntentId': paymentIntentId, 'orderId': orderId};
  }
}

class PaymentIntent {
  final String? id;
  final String? clientSecret;
  final double? amount;
  final String? currency;
  final String? status;

  PaymentIntent({
    this.id,
    this.clientSecret,
    this.amount,
    this.currency,
    this.status,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['paymentIntentId'],
      clientSecret: json['clientSecret'],
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
      status: json['status'],
    );
  }
}

class Payment {
  final int? id;
  final int? orderId;
  final double? amount;
  final String? currency;
  final String? paymentIntentId;
  final String? status;
  final String? paymentMethod;
  final String? failureReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    this.id,
    this.orderId,
    this.amount,
    this.currency,
    this.paymentIntentId,
    this.status,
    this.paymentMethod,
    this.failureReason,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['orderId'],
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
      paymentIntentId: json['paymentIntentId'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      failureReason: json['failureReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'paymentIntentId': paymentIntentId,
      'status': status,
      'paymentMethod': paymentMethod,
      'failureReason': failureReason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
