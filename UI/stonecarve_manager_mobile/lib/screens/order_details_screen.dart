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
          clientName: order.clientName,
          statusHistory: [],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalji narudžbe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Narudžba #${order.orderNumber ?? order.id}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Pending')),
                DropdownMenuItem(value: 1, child: Text('Processing')),
                DropdownMenuItem(value: 2, child: Text('Shipped')),
                DropdownMenuItem(value: 3, child: Text('Delivered')),
                DropdownMenuItem(value: 4, child: Text('Cancelled')),
                DropdownMenuItem(value: 5, child: Text('Returned')),
              ],
              onChanged: (value) => setState(() => selectedStatus = value),
              decoration: const InputDecoration(labelText: 'Status narudžbe'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: customerNotesController,
              decoration: const InputDecoration(labelText: 'Bilješke klijenta'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: adminNotesController,
              decoration: const InputDecoration(
                labelText: 'Bilješke administratora',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text(
              'Slike napretka',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: progressImages.length + 1,
                itemBuilder: (context, index) {
                  if (index < progressImages.length) {
                    final img = progressImages[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          img.imageUrl != null && img.imageUrl!.isNotEmpty
                              ? Image.network(
                                  img.imageUrl!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey,
                                ),
                          Positioned(
                            top: 0,
                            right: 0,
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
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Ne'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
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
                                          content: Text('Slika obrisana!'),
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
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
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
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: isSaving ? null : _saveChanges,
                  child: isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Spasi promjene'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Otkazivanje narudžbe
                  },
                  child: const Text('Otkaži narudžbu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
