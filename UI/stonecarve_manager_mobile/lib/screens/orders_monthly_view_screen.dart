import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stonecarve_manager_mobile/layouts/master_screen.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';
import 'package:stonecarve_manager_mobile/providers/order_provider.dart';
import 'order_details_screen.dart';

class OrdersMonthlyViewScreen extends StatefulWidget {
  const OrdersMonthlyViewScreen({super.key});

  @override
  State<OrdersMonthlyViewScreen> createState() =>
      _OrdersMonthlyViewScreenState();
}

class _OrdersMonthlyViewScreenState extends State<OrdersMonthlyViewScreen> {
  final OrderProvider _orderProvider = OrderProvider();
  List<Order> _orders = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;
  Map<int, List<Order>> _ordersByMonth = {};
  Map<int, double> _monthlyRevenue = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _orderProvider.get();
      setState(() {
        _orders = (result.items as List<Order>?) ?? [];
        _organizeOrdersByMonth();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
      }
    }
  }

  void _organizeOrdersByMonth() {
    _ordersByMonth.clear();
    _monthlyRevenue.clear();

    // Initialize all 12 months
    for (int i = 1; i <= 12; i++) {
      _ordersByMonth[i] = [];
      _monthlyRevenue[i] = 0.0;
    }

    // Filter and organize orders by selected year
    for (var order in _orders) {
      if (order.orderDate.year == _selectedYear) {
        int month = order.orderDate.month;
        _ordersByMonth[month]!.add(order);
        _monthlyRevenue[month] =
            (_monthlyRevenue[month] ?? 0) + order.totalAmount;
      }
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      case 5:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  List<int> _getAvailableYears() {
    if (_orders.isEmpty) return [DateTime.now().year];

    final years = _orders.map((order) => order.orderDate.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Sort descending
    return years;
  }

  @override
  Widget build(BuildContext context) {
    final availableYears = _getAvailableYears();

    return MasterScreen(
      title: 'Monthly Orders View',
      currentRoute: '/orders/monthly',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with year selector and stats
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Orders by Month',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Text('Year: '),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: _selectedYear,
                                items: availableYears.map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedYear = value;
                                      _organizeOrdersByMonth();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Summary stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Total Orders',
                            _ordersByMonth.values
                                .fold(0, (sum, list) => sum + list.length)
                                .toString(),
                            Icons.receipt_long,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Total Revenue',
                            '\$${_monthlyRevenue.values.fold(0.0, (sum, value) => sum + value).toStringAsFixed(2)}',
                            Icons.attach_money,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Avg per Month',
                            '\$${(_monthlyRevenue.values.fold(0.0, (sum, value) => sum + value) / 12).toStringAsFixed(2)}',
                            Icons.trending_up,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Monthly columns
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(12, (index) {
                        final month = index + 1;
                        return _buildMonthColumn(month);
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthColumn(int month) {
    final monthOrders = _ordersByMonth[month] ?? [];
    final monthRevenue = _monthlyRevenue[month] ?? 0.0;
    final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, month));

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 16),
      constraints: const BoxConstraints(maxHeight: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${monthOrders.length} orders',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${monthRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Orders list
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: monthOrders.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(32.0),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No orders',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: monthOrders.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = monthOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d').format(order.orderDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Client name
              if (order.clientName != null && order.clientName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          order.clientName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(order.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  Order.statusToString(order.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.orderItems.length} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
