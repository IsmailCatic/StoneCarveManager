class Order {
  int? id;
  String? orderNumber;
  DateTime? orderDate;
  DateTime? deliveryDate;
  String? status;
  String? clientName;
  String? clientContact;
  double? totalAmount;
  int? projectId;
  List<OrderItem>? items;

  Order({
    this.id,
    this.orderNumber,
    this.orderDate,
    this.deliveryDate,
    this.status,
    this.clientName,
    this.clientContact,
    this.totalAmount,
    this.projectId,
    this.items,
  });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['orderNumber'];
    orderDate = json['orderDate'] != null
        ? DateTime.parse(json['orderDate'])
        : null;
    deliveryDate = json['deliveryDate'] != null
        ? DateTime.parse(json['deliveryDate'])
        : null;
    status = json['status'];
    clientName = json['clientName'];
    clientContact = json['clientContact'];
    totalAmount = json['totalAmount']?.toDouble();
    projectId = json['projectId'];
    if (json['items'] != null) {
      items = <OrderItem>[];
      json['items'].forEach((v) {
        items!.add(OrderItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'orderDate': orderDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'status': status,
      'clientName': clientName,
      'clientContact': clientContact,
      'totalAmount': totalAmount,
      'projectId': projectId,
      'items': items?.map((v) => v.toJson()).toList(),
    };
  }
}

class OrderItem {
  int? id;
  int? orderId;
  int? stoneId;
  int? quantity;
  double? unitPrice;
  double? totalPrice;
  String? specifications;

  OrderItem({
    this.id,
    this.orderId,
    this.stoneId,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.specifications,
  });

  OrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['orderId'];
    stoneId = json['stoneId'];
    quantity = json['quantity'];
    unitPrice = json['unitPrice']?.toDouble();
    totalPrice = json['totalPrice']?.toDouble();
    specifications = json['specifications'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'stoneId': stoneId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'specifications': specifications,
    };
  }
}
