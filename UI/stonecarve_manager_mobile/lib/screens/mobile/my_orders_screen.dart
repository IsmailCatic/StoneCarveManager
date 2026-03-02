import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/models/order.dart';
import 'package:stonecarve_manager_mobile/providers/order_provider.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/order_details_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/order_payment_screen.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/app_drawer_mobile.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load orders once on initialization
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return; // Check before starting

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Use Future.wait for parallel execution (faster + single mounted check)
      final results = await Future.wait([
        OrderProvider.getMyActiveOrders(),
        OrderProvider.getMyOrderHistory(),
      ]);

      if (!mounted) return; // Check after async operations

      setState(() {
        _activeOrders = results[0];
        _completedOrders = results[1];
        _isLoading = false;
      });
    } catch (e) {
      print('[MyOrdersScreen] Error: $e');

      if (!mounted) return; // Check before setState in catch

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Tracking',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Monitor the progress of your stone carvings',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Active'),
                      if (_activeOrders.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_activeOrders.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Completed'),
                      if (_completedOrders.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_completedOrders.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(_activeOrders, isActive: true),
                      _buildOrderList(_completedOrders, isActive: false),
                    ],
                  ),
          ),
        ],
      ),
      drawer: const AppDrawerMobile(),
    );
  }

  Widget _buildOrderList(List<Order> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive
                  ? Icons.shopping_bag_outlined
                  : Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active orders' : 'No completed orders',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              isActive
                  ? 'Your active orders will appear here'
                  : 'Your order history will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  bool _isCustomOrder(Order order) {
    // Custom orders typically have:
    // 1. No productId in their order items (custom design)
    // 2. Or have an attachment URL (design files)
    // 3. Product name starts with "Custom" (auto-generated custom products)

    final hasNoProductId =
        order.orderItems.isEmpty ||
        order.orderItems.every((item) => item.productId == null);
    final hasAttachment =
        order.attachmentUrl != null && order.attachmentUrl!.isNotEmpty;
    final hasCustomProductName = order.orderItems.any(
      (item) =>
          item.productName != null &&
          item.productName!.toLowerCase().startsWith('custom'),
    );

    final isCustom = hasNoProductId || hasAttachment || hasCustomProductName;

    // Debug logging for ALL orders
    print(
      '[MyOrders] Order #${order.orderNumber}: '
      'hasNoProductId=$hasNoProductId, hasAttachment=$hasAttachment, '
      'hasCustomProductName=$hasCustomProductName, '
      'itemsCount=${order.orderItems.length}, '
      'firstItemProductId=${order.orderItems.isNotEmpty ? order.orderItems.first.productId : "N/A"}, '
      'firstItemProductName=${order.orderItems.isNotEmpty ? order.orderItems.first.productName : "N/A"}, '
      'isCustom=$isCustom',
    );

    return isCustom;
  }

  Widget _buildOrderCard(Order order) {
    final statusInfo = _getStatusInfo(order.status);
    final isCustomOrder = _isCustomOrder(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(orderId: order.id),
            ),
          );
          // Reload orders when returning from details
          _loadOrders();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderItems.isNotEmpty
                              ? order.orderItems.first.productName ??
                                    'Custom Order'
                              : 'Custom Order',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Order #${order.orderNumber}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCustomOrder) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  border: Border.all(
                                    color: Colors.amber.shade700,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 11,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Custom Order',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo['color'],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusInfo['icon'], size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo['label'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress bar (for active orders)
              if (order.status != 3 && order.status != 4) ...[
                Row(
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      '${_getProgressPercentage(order.status)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getProgressPercentage(order.status) / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Image preview (if available)
              if (order.progressImages.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.progressImages.first.imageUrl ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(order.orderDate),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Est. Completion',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.estimatedCompletionDate != null
                              ? _formatDate(order.estimatedCompletionDate!)
                              : 'TBD',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Pay Now banner (Pending status only for service/custom orders)
              // Shows for status 0 (Pending) with a quote set
              if (order.status == 0 &&
                  (order.orderType == 'service_request' ||
                      order.orderType == 'custom_order')) ...[
                const SizedBox(height: 4),
                // Custom orders with no price yet are awaiting an admin quote
                if (order.orderType == 'custom_order' &&
                    order.totalAmount <= 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_top,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Awaiting quote — our team will review your request and provide a price within 24–48 hours.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      border: Border.all(color: Colors.amber.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Payment required to start your order.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final orderTypeLabel =
                            order.orderType == 'service_request'
                            ? 'Service Request'
                            : 'Custom Order';
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPaymentScreen(
                              order: order,
                              orderTypeLabel: orderTypeLabel,
                            ),
                          ),
                        );
                        _loadOrders();
                      },
                      icon: const Icon(Icons.payment, size: 18),
                      label: const Text('Pay Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
              ],

              // View Updates button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(orderId: order.id),
                      ),
                    );
                    _loadOrders();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'View Updates',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(int status) {
    switch (status) {
      case 0: // Pending — awaiting payment
        return {
          'label': 'Awaiting Payment',
          'color': Colors.orange,
          'icon': Icons.payment,
        };
      case 1: // Processing
        return {
          'label': 'In Progress',
          'color': Colors.blue,
          'icon': Icons.construction,
        };
      case 2: // Shipped
        return {
          'label': 'Quality Check',
          'color': Colors.purple,
          'icon': Icons.verified,
        };
      case 3: // Delivered
        return {
          'label': 'Completed',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 4: // Cancelled
        return {
          'label': 'Cancelled',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case 5: // Returned
        return {'label': 'Returned', 'color': Colors.grey, 'icon': Icons.undo};
      default:
        return {'label': 'Unknown', 'color': Colors.grey, 'icon': Icons.help};
    }
  }

  int _getProgressPercentage(int status) {
    switch (status) {
      case 0: // Pending
        return 25;
      case 1: // Processing
        return 50;
      case 2: // Shipped
        return 85;
      case 3: // Delivered
        return 100;
      default:
        return 0;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day}/${date.month}/${date.year}';
  }
}
