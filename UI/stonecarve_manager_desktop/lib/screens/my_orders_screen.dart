import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/order.dart';
import 'package:stonecarve_manager_flutter/providers/order_provider.dart';
import 'package:stonecarve_manager_flutter/screens/order_details_screen.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderProvider _orderProvider = OrderProvider();
  List<Order> _myOrders = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // all, 0 (pending), 1 (processing), etc.

  @override
  void initState() {
    super.initState();
    _loadMyOrders();
  }

  Future<void> _loadMyOrders() async {
    try {
      setState(() => _isLoading = true);

      final statusFilter = _filterStatus == 'all'
          ? null
          : int.tryParse(_filterStatus);

      final result = await _orderProvider.getMyOrders(status: statusFilter);

      setState(() {
        _myOrders = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading my orders: $e')));
      }
    }
  }

  Map<String, List<Order>> _groupOrdersByStatus() {
    final Map<String, List<Order>> grouped = {
      'Pending': [],
      'Processing': [],
      'Shipped': [],
      'Delivered': [],
      'Cancelled': [],
      'Returned': [],
    };

    for (var order in _myOrders) {
      final statusStr = Order.statusToString(order.status);
      if (grouped.containsKey(statusStr)) {
        grouped[statusStr]!.add(order);
      }
    }

    return grouped;
  }

  Future<void> _viewOrderDetails(Order order) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
    );

    if (result == true || mounted) {
      _loadMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedOrders = _filterStatus == 'all'
        ? _groupOrdersByStatus()
        : {Order.statusToString(int.parse(_filterStatus)): _myOrders};

    return MasterScreen(
      title: 'My Orders',
      currentRoute: '/my-orders',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment, size: 32, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            'My Assigned Orders',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orders assigned to you',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Stats card
                Card(
                  color: Colors.blue.shade50,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_myOrders.length}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              'Total Assigned',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filters
            Row(
              children: [
                const Text(
                  'Filter by status: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                ...[
                  ('all', 'All'),
                  ('0', 'Pending'),
                  ('1', 'Processing'),
                  ('2', 'Shipped'),
                  ('3', 'Delivered'),
                  ('4', 'Cancelled'),
                  ('5', 'Returned'),
                ].map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter.$2),
                      selected: _filterStatus == filter.$1,
                      onSelected: (selected) {
                        setState(() => _filterStatus = filter.$1);
                        _loadMyOrders();
                      },
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: _loadMyOrders,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Orders list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders assigned to you',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Orders will appear here when assigned by admin',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: groupedOrders.entries
                          .where((entry) => entry.value.isNotEmpty)
                          .map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status group header
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(entry.key),
                                        color: _getStatusColor(entry.key),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${entry.key} (${entry.value.length})',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(entry.key),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Orders in this status
                                ...entry.value.map(
                                  (order) => _buildOrderCard(order),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          })
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDateTime(order.orderDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Order info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      Icons.attach_money,
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ),
                  if (order.clientName != null)
                    Expanded(
                      child: _buildInfoChip(
                        Icons.person,
                        order.clientName!,
                        Colors.blue,
                      ),
                    ),
                ],
              ),
              if (order.orderItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoChip(
                  Icons.shopping_bag,
                  '${order.orderItems.length} ${order.orderItems.length == 1 ? 'item' : 'items'}',
                  Colors.orange,
                ),
              ],
              if (order.progressImages.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoChip(
                  Icons.photo_library,
                  '${order.progressImages.length} ${order.progressImages.length == 1 ? 'image' : 'images'}',
                  Colors.purple,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int status) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    String label;

    switch (status) {
      case 0:
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade300;
        textColor = Colors.orange.shade700;
        label = 'Pending';
        break;
      case 1:
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade300;
        textColor = Colors.blue.shade700;
        label = 'Processing';
        break;
      case 2:
        backgroundColor = Colors.purple.shade50;
        borderColor = Colors.purple.shade300;
        textColor = Colors.purple.shade700;
        label = 'Shipped';
        break;
      case 3:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade300;
        textColor = Colors.green.shade700;
        label = 'Delivered';
        break;
      case 4:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade700;
        label = 'Cancelled';
        break;
      case 5:
        backgroundColor = Colors.brown.shade50;
        borderColor = Colors.brown.shade300;
        textColor = Colors.brown.shade700;
        label = 'Returned';
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade700;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Processing':
        return Icons.autorenew;
      case 'Shipped':
        return Icons.local_shipping;
      case 'Delivered':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      case 'Returned':
        return Icons.keyboard_return;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Returned':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }
}
