import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/order.dart';
import '../models/order_update_request.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

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

  @override
  void initState() {
    super.initState();
    order = widget.order;
    selectedStatus = order.status;
    customerNotesController = TextEditingController(text: order.customerNotes);
    adminNotesController = TextEditingController(text: order.adminNotes);
    progressImages = List<ProgressImage>.from(order.progressImages);
  }

  @override
  void dispose() {
    customerNotesController.dispose();
    adminNotesController.dispose();
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
      final userId = AuthProvider.userId;
      final newImage = await _orderProvider.uploadProgressImage(
        order.id,
        imageFile.path,
        uploadedByUserId: userId,
      );
      setState(() {
        progressImages.add(newImage as ProgressImage);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slika uspješno uploadana!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška pri uploadu slike: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Promjene spremljene!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška: $e')));
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
        title: const Text('Potvrdi Promjenu Statusa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Novi status: $statusLabel'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Komentar (opciono)',
                hintText: 'Razlog promjene statusa...',
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
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(newStatus, comment);
            },
            child: const Text('Potvrdi'),
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
          const SnackBar(
            content: Text('Status uspješno promijenjen'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => isUpdatingStatus = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
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
              'Trenutni status: ${Order.statusToString(order.status)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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
              'Promijeni Status',
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

  Widget _buildStatusHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Istorija Promjena Statusa',
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
              'Promijenio: ${history.changedByUserName}',
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
      appBar: AppBar(title: const Text('Detalji narudžbe'), elevation: 2),
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
                                'Narudžba #${order.orderNumber ?? order.id}',
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
                      'Ukupan iznos',
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                    if (order.clientName != null)
                      _buildInfoRow(
                        'Klijent',
                        order.clientName!,
                        Icons.person,
                        Colors.blue,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Current Status Card
            _buildCurrentStatusCard(),
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
                        Text(
                          'Bilješke',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: customerNotesController,
                      decoration: InputDecoration(
                        labelText: 'Bilješke klijenta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: adminNotesController,
                      decoration: InputDecoration(
                        labelText: 'Bilješke administratora',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
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
                          'Slike napretka',
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
                                            title: const Text('Obriši sliku'),
                                            content: const Text(
                                              'Jeste li sigurni da želite obrisati ovu sliku?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(false),
                                                child: const Text('Ne'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pop(true),
                                                child: const Text('Da'),
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
                                                    'Slika obrisana!',
                                                  ),
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
                                                    'Greška pri brisanju slike!',
                                                  ),
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
                                      'Dodaj',
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
                    label: const Text('Spasi promjene'),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
