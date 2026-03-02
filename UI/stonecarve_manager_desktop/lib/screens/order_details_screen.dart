import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/order.dart';
import '../models/user.dart';
import '../models/payment.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/payment_provider.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Order order;
  late int? selectedStatus;
  late TextEditingController customerNotesController;
  late TextEditingController adminNotesController;
  late List<ProgressImage> progressImages;
  bool isSaving = false;
  bool isUpdatingStatus = false;
  File? _imageFile;
  final OrderProvider _orderProvider = OrderProvider();
  final UserProvider _userProvider = UserProvider();
  final PaymentProvider _paymentProvider = PaymentProvider();

  // Employee assignment
  List<User> employees = [];
  bool isLoadingEmployees = false;
  int? selectedEmployeeId;

  // Payment information
  Payment? orderPayment;
  bool isLoadingPayment = false;

  // Quote (admin price for custom/service orders)
  late TextEditingController _quoteController;
  bool _isSavingQuote = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
    selectedStatus = order.status;
    selectedEmployeeId = order.assignedEmployeeId;
    customerNotesController = TextEditingController(text: order.customerNotes);
    adminNotesController = TextEditingController(text: order.adminNotes);
    progressImages = List<ProgressImage>.from(order.progressImages);
    _quoteController = TextEditingController(
      text: order.totalAmount > 0 ? order.totalAmount.toStringAsFixed(2) : '',
    );

    // Load employees list if user is admin
    if (AuthProvider.isAdmin) {
      // Run employees, payment, and fresh order data all in parallel
      Future.wait([_loadEmployees(), _loadPayment(), _loadFreshOrderData()]);
    } else {
      // Non-admin still needs fresh order data for reference images
      _loadFreshOrderData();
    }
  }

  Future<void> _loadFreshOrderData() async {
    try {
      final freshOrder = await _orderProvider.getOrderById(order.id);
      if (mounted) {
        setState(() {
          order = freshOrder;
          selectedStatus = freshOrder.status;
          selectedEmployeeId = freshOrder.assignedEmployeeId;
          customerNotesController.text = freshOrder.customerNotes ?? '';
          adminNotesController.text = freshOrder.adminNotes ?? '';
          progressImages = List<ProgressImage>.from(freshOrder.progressImages);
          _quoteController.text = freshOrder.totalAmount > 0
              ? freshOrder.totalAmount.toStringAsFixed(2)
              : '';
        });
      }
    } catch (e) {
      // Silently fail — we already have the order from the listing, just won't have reference images
      debugPrint('[OrderDetails] Failed to reload fresh order data: \$e');
    }
  }

  Future<void> _loadPayment() async {
    setState(() {
      isLoadingPayment = true;
    });

    try {
      final payment = await _paymentProvider.getPaymentByOrderId(order.id);
      setState(() {
        orderPayment = payment;
        isLoadingPayment = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPayment = false;
      });
      print('Error loading payment: $e');
    }
  }

  Future<void> _loadEmployees() async {
    setState(() {
      isLoadingEmployees = true;
    });

    try {
      final loadedEmployees = await _userProvider.getEmployees();
      setState(() {
        employees = loadedEmployees;
        isLoadingEmployees = false;
      });
    } catch (e) {
      setState(() {
        isLoadingEmployees = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load employees: $e')));
      }
    }
  }

  Future<void> _assignEmployee(int? employeeId) async {
    try {
      final updatedOrder = await _orderProvider.assignEmployee(
        order.id,
        employeeId,
      );
      setState(() {
        order = updatedOrder;
        selectedEmployeeId = employeeId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              employeeId == null
                  ? 'Employee unassigned successfully'
                  : 'Employee assigned successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign employee: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    customerNotesController.dispose();
    adminNotesController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage(_imageFile!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      print('=== ORDER DETAILS SCREEN - UPLOAD IMAGE ===');
      print('Order ID: ${order.id}');
      print('Image file path: ${imageFile.path}');

      final userId = AuthProvider.userId;
      print('User ID: $userId');

      final newImage = await _orderProvider.uploadProgressImage(
        order.id,
        imageFile.path,
        uploadedByUserId: userId,
      );

      print('Received new image: ${newImage.id}, ${newImage.imageUrl}');

      setState(() {
        progressImages.add(newImage);
        print('Added image to list. Total images: ${progressImages.length}');
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order progress image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('ERROR uploading image: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload progress image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      isSaving = true;
    });
    try {
      final updatedOrder = await _orderProvider.updateOrder(
        order.id,
        Order(
          id: order.id,
          orderDate: order.orderDate,
          orderNumber: order.orderNumber,
          status: selectedStatus ?? order.status,
          totalAmount: order.totalAmount,
          customerNotes: customerNotesController.text,
          adminNotes: adminNotesController.text,
          attachmentUrl: order.attachmentUrl,
          estimatedCompletionDate: order.estimatedCompletionDate,
          completedAt: order.completedAt,
          userId: order.userId,
          assignedEmployeeId: order.assignedEmployeeId,
          orderItems: order.orderItems,
          deliveryAddress: order.deliveryAddress,
          deliveryCity: order.deliveryCity,
          deliveryZipCode: order.deliveryZipCode,
          deliveryDate: order.deliveryDate,
          review: order.review,
          progressImages: progressImages,
          statusHistory: order.statusHistory,
          clientName: order.clientName,
        ),
      );
      setState(() {
        order = updatedOrder;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order details updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  void _showChangeStatusDialog(int newStatus, String statusLabel) {
    String? comment;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New status: $statusLabel'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Reason for status change...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                comment = value.isNotEmpty ? value : null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(newStatus, comment);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(int newStatus, String? comment) async {
    setState(() => isUpdatingStatus = true);

    try {
      final updatedOrder = await _orderProvider.updateOrderStatus(
        order.id,
        newStatus,
        comment: comment,
      );

      setState(() {
        order = updatedOrder;
        selectedStatus = updatedOrder.status;
        isUpdatingStatus = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order status updated to: ${Order.statusToString(newStatus)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => isUpdatingStatus = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange; // Pending
      case 1:
        return Colors.blue; // Processing
      case 2:
        return Colors.purple; // Shipped
      case 3:
        return Colors.green; // Delivered
      case 4:
        return Colors.red; // Cancelled
      case 5:
        return Colors.grey; // Returned
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    if (orderPayment == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  orderPayment!.isRefunded
                      ? Icons.payment_outlined
                      : Icons.payment,
                  color: orderPayment!.isRefunded
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Status Badge
            Row(
              children: [
                // Payment Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(
                      orderPayment!.status,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPaymentStatusColor(orderPayment!.status),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPaymentStatusIcon(orderPayment!.status),
                        size: 16,
                        color: _getPaymentStatusColor(orderPayment!.status),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Payment: ${_getPaymentStatusLabel(orderPayment!.status)}',
                        style: TextStyle(
                          color: _getPaymentStatusColor(orderPayment!.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Status (if available)
                if (orderPayment!.orderStatus != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getOrderStatusColor(
                        orderPayment!.orderStatus!,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getOrderStatusColor(orderPayment!.orderStatus!),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          size: 16,
                          color: _getOrderStatusColor(
                            orderPayment!.orderStatus!,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Order: ${_getOrderStatusLabel(orderPayment!.orderStatus!)}',
                          style: TextStyle(
                            color: _getOrderStatusColor(
                              orderPayment!.orderStatus!,
                            ),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),
                Text(
                  orderPayment!.method.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 12),

            // Payment Breakdown
            _buildPaymentRow(
              'Original Amount',
              '\$${orderPayment!.amount.toStringAsFixed(2)}',
              isTotal: false,
            ),

            if (orderPayment!.isRefunded) ...[
              const SizedBox(height: 8),
              _buildPaymentRow(
                'Refunded',
                '-\$${orderPayment!.refundAmount!.toStringAsFixed(2)}',
                isRefund: true,
              ),
              const SizedBox(height: 12),
              Divider(),
              const SizedBox(height: 12),
              _buildPaymentRow(
                'Net Amount',
                '\$${orderPayment!.netAmount.toStringAsFixed(2)}',
                isTotal: true,
              ),

              // Refund details
              if (orderPayment!.refundReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refund Reason',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRefundReason(orderPayment!.refundReason!),
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 13,
                              ),
                            ),
                            if (orderPayment!.refundedAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Refunded on ${DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(orderPayment!.refundedAt!)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            // Payment date
            if (orderPayment!.completedAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Completed on ${DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(orderPayment!.completedAt!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool isRefund = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isRefund
                ? Colors.red[700]
                : (isTotal ? Colors.black : Colors.grey[700]),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isRefund
                ? Colors.red[700]
                : (isTotal ? Colors.green[700] : Colors.black87),
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Colors.green;
      case 'partially_refunded':
        return Colors.orange;
      case 'refunded':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Icons.check_circle;
      case 'partially_refunded':
        return Icons.remove_circle_outline;
      case 'refunded':
        return Icons.replay;
      case 'pending':
        return Icons.pending;
      case 'failed':
      case 'cancelled':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getPaymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return 'Paid';
      case 'partially_refunded':
        return 'Partially Refunded';
      case 'refunded':
        return 'Fully Refunded';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatRefundReason(String reason) {
    // Convert snake_case to Title Case
    return reason
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getOrderStatusColor(String status) {
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

  Widget _buildCurrentStatusCard() {
    return Card(
      color: _getStatusColor(order.status).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.circle, color: _getStatusColor(order.status), size: 16),
            const SizedBox(width: 12),
            Text(
              'Current status: ${Order.statusToString(order.status)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeAssignmentSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_pin, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Employee Assignment',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (AuthProvider.isAdmin) ...[
              // Admin can assign employees
              if (isLoadingEmployees)
                const Center(child: CircularProgressIndicator())
              else if (employees.isEmpty)
                Text(
                  'No employees available',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign to Employee:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: selectedEmployeeId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('Select Employee (or leave unassigned)'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        ...employees.map((employee) {
                          final roleLabel = employee.isAdmin
                              ? ' (Admin)'
                              : ' (Employee)';
                          return DropdownMenuItem<int?>(
                            value: employee.id,
                            child: Text(
                              '${employee.displayName}$roleLabel',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        if (value != selectedEmployeeId) {
                          _assignEmployee(value);
                        }
                      },
                    ),
                  ],
                ),
            ] else ...[
              // Employee/User just sees who it's assigned to
              Row(
                children: [
                  Icon(
                    order.assignedEmployeeId != null
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: order.assignedEmployeeId != null
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.assignedEmployeeId != null
                        ? 'Assigned to: ${order.assignedEmployeeName ?? "Unknown Employee"}'
                        : 'Not assigned to any employee',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (order.orderItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No items in this order',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...order.orderItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${index + 1}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName ?? 'Custom Product',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.productState != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.productState == 'custom_order'
                                          ? Colors.orange[100]
                                          : Colors.green[100],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.productState == 'custom_order'
                                          ? 'CUSTOM ORDER'
                                          : 'STANDARD',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            item.productState == 'custom_order'
                                            ? Colors.orange[900]
                                            : Colors.green[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildItemDetail(
                            'Quantity',
                            '${item.quantity}',
                            Icons.numbers,
                          ),
                          _buildItemDetail(
                            'Unit Price',
                            '\$${item.unitPrice.toStringAsFixed(2)}',
                            Icons.attach_money,
                          ),
                        ],
                      ),
                      if (item.specifications != null &&
                          item.specifications!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description,
                                    size: 16,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Specifications:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.specifications!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (item.customSpecifications != null &&
                          item.customSpecifications!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 16,
                                    color: Colors.orange[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Custom Specifications:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.customSpecifications!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (item.customSketchUrl != null &&
                          item.customSketchUrl!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppBar(
                                      title: const Text('Custom Sketch'),
                                      automaticallyImplyLeading: false,
                                      actions: [
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.network(
                                        item.customSketchUrl!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.purple[200]!),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    item.customSketchUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Custom Sketch',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple[900],
                                        ),
                                      ),
                                      Text(
                                        'Tap to view full size',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.zoom_in, color: Colors.purple[700]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusButton(0, 'Pending', Colors.orange),
                _buildStatusButton(1, 'Processing', Colors.blue),
                _buildStatusButton(2, 'Shipped', Colors.purple),
                _buildStatusButton(3, 'Delivered', Colors.green),
                _buildStatusButton(4, 'Cancelled', Colors.red),
                _buildStatusButton(5, 'Returned', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(int status, String label, Color color) {
    bool isCurrentStatus = order.status == status;

    return ElevatedButton(
      onPressed: isCurrentStatus || isUpdatingStatus
          ? null
          : () => _showChangeStatusDialog(status, label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentStatus ? color : Colors.grey[300],
        foregroundColor: isCurrentStatus ? Colors.white : Colors.black,
        disabledBackgroundColor: isCurrentStatus
            ? color.withOpacity(0.5)
            : null,
        disabledForegroundColor: isCurrentStatus ? Colors.white70 : null,
      ),
      child: Text(label),
    );
  }

  Future<void> _deleteOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Are you sure you want to permanently delete Order #${order.orderNumber}?\n\nThis will remove all associated data and cannot be undone.',
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
      await _orderProvider.deleteOrder(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete order: \$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setQuote() async {
    final input = _quoteController.text.trim();
    final price = double.tryParse(input);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSavingQuote = true);
    try {
      final updatedOrder = await _orderProvider.setQuote(order.id, price);
      setState(() {
        order = updatedOrder;
        _quoteController.text = updatedOrder.totalAmount.toStringAsFixed(2);
        _isSavingQuote = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quote set to \$${updatedOrder.totalAmount.toStringAsFixed(2)}. '
              'The customer can now pay from the mobile app.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSavingQuote = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set quote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildQuoteSection() {
    final isQuoteSet = order.totalAmount > 0;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.request_quote, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  isQuoteSet ? 'Price Quote' : 'Set Price Quote',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (isQuoteSet) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Quoted',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isQuoteSet
                  ? 'Current quote: \$${order.totalAmount.toStringAsFixed(2)}. Update it below if needed.'
                  : 'This order has no price yet. Enter a quote and the customer will be able to pay from the mobile app.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _quoteController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Price (USD)',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'e.g. 250.00',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isSavingQuote ? null : _setQuote,
                    icon: _isSavingQuote
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(isQuoteSet ? 'Update Quote' : 'Set Quote'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceImagesSection() {
    final allUrls = order.orderItems
        .expand((item) => item.referenceImageUrls)
        .toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.draw, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Customer Reference Images',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${allUrls.length} image${allUrls.length == 1 ? "" : "s"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.deepPurple[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Sketches and reference photos submitted by the customer',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allUrls.length,
                itemBuilder: (context, index) {
                  final url = allUrls[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppBar(
                                title: const Text('Reference Image'),
                                automaticallyImplyLeading: false,
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 120,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 140,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Change History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...order.statusHistory
                .map((history) => _buildHistoryItem(history))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(OrderStatusHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${history.oldStatusDisplay} → ${history.newStatusDisplay}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(history.changedAt),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (history.comment != null) ...[
            const SizedBox(height: 4),
            Text(history.comment!),
          ],
          if (history.changedByUserName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Changed by: ${history.changedByUserName}',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details'), elevation: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, size: 32, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.orderNumber ?? order.id}',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(order.orderDate),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Total Amount',
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    if (order.clientName != null)
                      _buildInfoRow(
                        'Client',
                        order.clientName!,
                        Icons.person,
                        Colors.blue,
                      ),
                    if (order.clientEmail != null)
                      _buildInfoRow(
                        'Email',
                        order.clientEmail!,
                        Icons.email_outlined,
                        Colors.indigo,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Service & Delivery Details Card
            if (order.customerNotes != null &&
                    order.customerNotes!.isNotEmpty ||
                order.deliveryAddress != null ||
                order.deliveryDate != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.handyman, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Service & Delivery Details',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Customer requirements
                      if (order.customerNotes != null &&
                          order.customerNotes!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    size: 16,
                                    color: Colors.teal[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Customer Requirements',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[900],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.customerNotes!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal[900],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Delivery fields
                      if (order.deliveryAddress != null ||
                          order.deliveryCity != null ||
                          order.deliveryZipCode != null) ...[
                        _buildInfoRow(
                          'Delivery Address',
                          [
                            order.deliveryAddress,
                            order.deliveryCity,
                            order.deliveryZipCode,
                          ].where((s) => s != null && s.isNotEmpty).join(', '),
                          Icons.location_on,
                          Colors.red,
                        ),
                      ],
                      if (order.deliveryDate != null)
                        _buildInfoRow(
                          'Preferred Date',
                          _formatDate(order.deliveryDate!),
                          Icons.calendar_today,
                          Colors.orange,
                        ),
                    ],
                  ),
                ),
              ),
            if (order.customerNotes != null &&
                    order.customerNotes!.isNotEmpty ||
                order.deliveryAddress != null ||
                order.deliveryDate != null)
              const SizedBox(height: 16),

            // Payment Information Section (Admin only)
            if (AuthProvider.isAdmin && orderPayment != null)
              _buildPaymentSection(),
            if (AuthProvider.isAdmin && orderPayment != null)
              const SizedBox(height: 16),

            // Order Items Section
            _buildOrderItemsSection(),
            const SizedBox(height: 16),

            // Price Quote Section (admin or employee — for custom/service orders that need a quote)
            if ((AuthProvider.isAdmin || AuthProvider.isEmployee) &&
                (order.orderType == 'custom_order' ||
                    order.orderType == 'service_request')) ...[
              _buildQuoteSection(),
              const SizedBox(height: 16),
            ],

            // Customer Reference Images Section (custom orders & service requests)
            if ((order.orderType == 'custom_order' ||
                    order.orderType == 'service_request') &&
                order.orderItems.any(
                  (item) => item.referenceImageUrls.isNotEmpty,
                )) ...[
              _buildReferenceImagesSection(),
              const SizedBox(height: 16),
            ],

            // Current Status Card
            _buildCurrentStatusCard(),
            const SizedBox(height: 16),

            // Employee Assignment Section
            _buildEmployeeAssignmentSection(),
            const SizedBox(height: 16),

            // Status Change Section
            _buildStatusChangeSection(),
            const SizedBox(height: 16),

            // Notes Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Notes',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Notes specific to this order (Order #${order.orderNumber ?? order.id})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: customerNotesController,
                      decoration: InputDecoration(
                        labelText: 'Customer Requirements / Notes',
                        helperText:
                            'Text submitted by the customer (e.g. service requirements, special requests)',
                        helperMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.teal[50],
                        prefixIcon: Icon(
                          Icons.format_quote,
                          color: Colors.teal,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: adminNotesController,
                      decoration: InputDecoration(
                        labelText: 'Message to Customer',
                        helperText:
                            'This message will be visible to the customer in the mobile app',
                        helperMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.orange[50],
                        prefixIcon: Icon(
                          Icons.message_outlined,
                          color: Colors.orange,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            color: Colors.orange[800],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'The message above is visible to the customer on the mobile app. Use it to communicate updates, ask for clarifications, or provide instructions.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Click "Save Changes" below to save your notes',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress Images Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_library, color: Colors.purple),
                        const SizedBox(width: 8),
                        Text(
                          'Progress Images',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: progressImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index < progressImages.length) {
                            final img = progressImages[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        img.imageUrl != null &&
                                            img.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            img.imageUrl!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[300],
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Image'),
                                            content: const Text(
                                              'Are you sure you want to delete this image?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                                child: const Text('No'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final success = await _orderProvider
                                              .deleteProgressImage(img.id);
                                          if (success) {
                                            setState(() {
                                              progressImages.removeAt(index);
                                            });
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Order progress image deleted successfully',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Failed to delete progress image',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Add image button
                            return GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue[200]!,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      color: Colors.blue[400],
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add',
                                      style: TextStyle(
                                        color: Colors.blue[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status History Timeline
            if (order.statusHistory.isNotEmpty) ...[
              _buildStatusHistory(),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _saveChanges,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (AuthProvider.isAdmin) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _deleteOrder,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Order'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
