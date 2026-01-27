import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/order.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("orders");

  @override
  Order fromJson(data) {
    return Order.fromJson(data);
  }

  Future<Order> createOrder(Order order) async {
    return await insert(order.toJson());
  }

  Future<Order> updateOrder(int id, Order order) async {
    return await update(id, order.toJson());
  }

  Future<List<Order>> getPendingOrders() async {
    var filter = {"status": "pending"};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    var filter = {
      "orderDate__gte": startDate.toIso8601String(),
      "orderDate__lte": endDate.toIso8601String(),
    };
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<Order>> getOrdersByClient(String clientName) async {
    var filter = {"clientName": clientName};
    var result = await get(filter: filter);
    return result.items ?? [];
  }
}
