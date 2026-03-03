import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/payment.dart';
import 'package:stonecarve_manager_flutter/providers/payment_provider.dart';
import 'package:stonecarve_manager_flutter/providers/order_provider.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/screens/order_details_screen.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentProvider _paymentProvider = PaymentProvider();
  final OrderProvider _orderProvider = OrderProvider();

  List<Payment> _payments = [];
  bool _isLoading = true;

  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  // Statistics
  double _totalRevenue = 0;
  int _successfulPayments = 0;
  int _failedPayments = 0;
  int _pendingPayments = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    try {
      setState(() => _isLoading = true);

      final search = PaymentSearchObject(
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate != null
            ? DateTime(
                _endDate!.year,
                _endDate!.month,
                _endDate!.day,
                23,
                59,
                59,
              )
            : null,
      );

      print(
        '[PaymentsScreen] Loading payments with filters: status=$_selectedStatus, dates=$_startDate to $_endDate',
      );

      final result = await _paymentProvider.getPayments(search);
      final items = result.items ?? [];

      setState(() {
        _payments = items;
        _isLoading = false;
        // Compute stats locally — no extra API call needed
        _totalRevenue = items
            .where((p) => p.status == 'succeeded')
            .fold(0.0, (sum, p) => sum + p.amount);
        _successfulPayments = items
            .where((p) => p.status == 'succeeded')
            .length;
        _failedPayments = items.where((p) => p.status == 'failed').length;
        _pendingPayments = items.where((p) => p.status == 'pending').length;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading payments: $e')));
      }
    }
  }

  Future<void> _issueRefund(Payment payment) async {
    final amountController = TextEditingController(
      text: payment.amount.toStringAsFixed(2),
    );
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue Refund'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${payment.orderNumber}'),
              Text('Original Amount: \$${payment.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Refund Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Issue Refund'),
          ),
        ],
      ),
    );

    if (confirm == true && payment.stripePaymentIntentId != null) {
      try {
        final refundAmount = double.tryParse(amountController.text);

        final request = RefundRequest(
          paymentIntentId: payment.stripePaymentIntentId!,
          orderId: payment.orderId,
          amount: refundAmount,
          reason: reasonController.text.isEmpty ? null : reasonController.text,
        );

        await _paymentProvider.issueRefund(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refund issued successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPayments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error issuing refund: $e')));
        }
      }
    }

    amountController.dispose();
    reasonController.dispose();
  }

  Future<void> _deletePayment(Payment payment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text(
          'Are you sure you want to permanently delete the payment for Order #${payment.orderNumber}?\n\nAmount: \$${payment.amount.toStringAsFixed(2)}\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _paymentProvider.deletePayment(payment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment for Order #${payment.orderNumber} deleted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadPayments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentDetails(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Details — Order #${payment.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Payment Status',
                _getStatusBadge(payment.status),
              ),
              if (payment.orderStatus != null)
                _buildDetailRow(
                  'Order Status',
                  _getOrderStatusBadge(payment.orderStatus!),
                ),
              const Divider(),
              _buildDetailRow(
                'Amount',
                '\$${payment.amount.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Method', _getMethodLabel(payment.method)),
              _buildDetailRow('Order', '#${payment.orderNumber}'),
              if (payment.customerName != null)
                _buildDetailRow('Customer', payment.customerName!),
              if (payment.customerEmail != null)
                _buildDetailRow('Email', payment.customerEmail!),
              const Divider(),
              _buildDetailRow('Created', _formatDateTime(payment.createdAt)),
              if (payment.completedAt != null)
                _buildDetailRow(
                  'Completed',
                  _formatDateTime(payment.completedAt!),
                ),
              if (payment.failureReason != null) ...[
                const Divider(),
                _buildDetailRow('Failure Reason', payment.failureReason!),
              ],
            ],
          ),
        ),
        actions: [
          if (payment.status == 'succeeded' &&
              payment.stripePaymentIntentId != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _issueRefund(payment);
              },
              child: const Text('Issue Refund'),
            ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                // Fetch the order
                final order = await _orderProvider.getOrderById(
                  payment.orderId,
                );

                // Close loading indicator
                if (mounted) Navigator.pop(context);

                // Navigate to order details
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(order: order),
                    ),
                  );
                }
              } catch (e) {
                // Close loading indicator
                if (mounted) Navigator.pop(context);

                // Show error
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading order: $e')),
                  );
                }
              }
            },
            child: const Text('View Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: const TextStyle(color: Colors.black87),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Payments',
      currentRoute: '/payments',
      child: Column(
        children: [
          // ⚠️ Seed data warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF3CD),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF856404),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Color(0xFF856404), fontSize: 13),
                      children: [
                        TextSpan(
                          text: 'Testing Notice: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'These payments use seeded data with fake Stripe Payment Intent IDs. '
                              'Refund operations will fail because the intent IDs do not exist in Stripe.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Header with statistics
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Management',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track and manage all payment transactions',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    // Stats cards
                    _buildStatCard(
                      'Revenue',
                      '\$${_totalRevenue.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Successful',
                      _successfulPayments.toString(),
                      Icons.check_circle,
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Failed',
                      _failedPayments.toString(),
                      Icons.error,
                      Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Pending',
                      _pendingPayments.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    // Status filter
                    SizedBox(
                      width: 160,
                      child: DropdownButtonFormField<String?>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All'),
                          ),
                          ...[
                            'succeeded',
                            'pending',
                            'failed',
                            'cancelled',
                            'refunded',
                          ].map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status[0].toUpperCase() + status.substring(1),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                          _loadPayments();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Date range
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked.start;
                            _endDate = picked.end;
                          });
                          _loadPayments();
                        }
                      },
                      icon: const Icon(Icons.date_range, size: 18),
                      label: Text(
                        _startDate != null && _endDate != null
                            ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                            : 'Date Range',
                      ),
                    ),
                    if (_startDate != null || _endDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                          _loadPayments();
                        },
                        tooltip: 'Clear date filter',
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _loadPayments();
                      },
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Payments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payments found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPayments,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _payments.length,
                      itemBuilder: (context, index) {
                        final payment = _payments[index];
                        return _buildPaymentCard(payment);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color.shade700,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: color.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Payment icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(payment.status).shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentIcon(payment.method),
                  color: _getStatusColor(payment.status).shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Payment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order #${payment.orderNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _getStatusBadge(payment.status),
                      ],
                    ),
                    if (payment.orderStatus != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Order: ${_getOrderStatusLabel(payment.orderStatus!)}',
                            style: TextStyle(
                              color: _getOrderStatusColor(
                                payment.orderStatus!,
                              ).shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Order #${payment.orderNumber} • ${payment.customerName ?? "Unknown"}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(payment.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Show net amount if refunded
                  if (payment.isRefunded) ...[
                    Text(
                      '\$${payment.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '\$${payment.netAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      '-\$${payment.refundAmount!.toStringAsFixed(2)} refunded',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '\$${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _getMethodLabel(payment.method),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (payment.status == 'succeeded' &&
                      payment.stripePaymentIntentId != null &&
                      !payment.isFullyRefunded) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _issueRefund(payment),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        payment.isPartiallyRefunded ? 'Refund More' : 'Refund',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  if (AuthProvider.isAdmin) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => _deletePayment(payment),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    final color = _getStatusColor(status);
    String label;
    switch (status.toLowerCase()) {
      case 'partially_refunded':
        label = 'Partial Refund';
        break;
      case 'succeeded':
        label = 'Paid';
        break;
      default:
        label = status[0].toUpperCase() + status.substring(1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  MaterialColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'partially_refunded':
        return Colors.orange;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  String _getMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'stripe':
        return 'Card';
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  Widget _getOrderStatusBadge(String status) {
    final color = _getOrderStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        _getOrderStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  MaterialColor _getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'returned':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusLabel(String status) {
    // Return the status with proper capitalization
    return status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).toLowerCase()
        : 'Unknown';
  }
}
