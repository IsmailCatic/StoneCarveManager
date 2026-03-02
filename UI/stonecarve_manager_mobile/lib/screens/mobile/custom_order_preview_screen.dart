import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/models/custom_order_request.dart';
import 'package:stonecarve_manager_mobile/providers/order_provider.dart';

class CustomOrderPreviewScreen extends StatefulWidget {
  final CustomOrderRequest request;
  final List<File> sketchFiles;
  final String? categoryName;
  final String? materialName;

  const CustomOrderPreviewScreen({
    super.key,
    required this.request,
    required this.sketchFiles,
    this.categoryName,
    this.materialName,
  });

  @override
  State<CustomOrderPreviewScreen> createState() =>
      _CustomOrderPreviewScreenState();
}

class _CustomOrderPreviewScreenState extends State<CustomOrderPreviewScreen> {
  bool _isSubmitting = false;

  Future<void> _cleanupTempImages() async {
    try {
      for (var file in widget.sketchFiles) {
        if (await file.exists()) {
          await file.delete();
          print('[CustomOrderPreview] Deleted temp image: ${file.path}');
        }
      }
    } catch (e) {
      print('[CustomOrderPreview] Error cleaning up temp images: $e');
    }
  }

  Future<void> _submitOrder() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      print('[CustomOrderPreview] Submitting custom order...');

      final order = await OrderProvider.createCustomOrder(
        widget.request,
        widget.sketchFiles,
      );

      print('[CustomOrderPreview] Order created successfully: ${order.id}');

      // Clean up temporary image files after successful upload
      await _cleanupTempImages();

      if (!mounted) return;

      // Custom orders have no fixed price — the admin reviews and quotes later.
      // Navigate to a confirmation screen rather than the payment screen.
      _showOrderConfirmation(order.orderNumber);
    } catch (e) {
      print('[CustomOrderPreview] Error: $e');

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit order: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showOrderConfirmation(String orderRef) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Order Submitted!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your custom order #$orderRef has been received.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Our team will review your request and provide a '
                      'price quote within 24–48 hours. You can pay from '
                      'the My Orders page once a quote is ready.',
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/orders',
                (route) => route.settings.name == '/home',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              'View My Orders',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Review Order',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard('Order Details', Icons.category, [
                  if (widget.categoryName != null)
                    _buildInfoRow('Category', widget.categoryName!),
                  if (widget.materialName != null)
                    _buildInfoRow('Material', widget.materialName!),
                  if (widget.request.dimensions != null)
                    _buildInfoRow('Dimensions', widget.request.dimensions!),
                  if (widget.categoryName == null &&
                      widget.materialName == null &&
                      widget.request.dimensions == null)
                    Text(
                      'No specific category, material or dimensions specified — our team will advise during review.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                ]),
                const SizedBox(height: 16),
                _buildInfoCard('Description', Icons.description, [
                  Text(
                    widget.request.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ]),
                if (widget.request.customerNotes != null &&
                    widget.request.customerNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoCard('Additional Notes', Icons.note, [
                    Text(
                      widget.request.customerNotes!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ]),
                ],
                if (widget.request.deliveryDate != null ||
                    widget.request.deliveryAddress != null ||
                    widget.request.deliveryCountry != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoCard('Delivery Information', Icons.local_shipping, [
                    if (widget.request.deliveryDate != null)
                      _buildInfoRow(
                        'Desired Date',
                        '${widget.request.deliveryDate!.month}/${widget.request.deliveryDate!.day}/${widget.request.deliveryDate!.year}',
                      ),
                    if (widget.request.deliveryAddress != null)
                      _buildInfoRow('Address', widget.request.deliveryAddress!),
                    if (widget.request.deliveryCity != null)
                      _buildInfoRow('City', widget.request.deliveryCity!),
                    if (widget.request.deliveryCountry != null)
                      _buildInfoRow('Country', widget.request.deliveryCountry!),
                    if (widget.request.deliveryZipCode != null)
                      _buildInfoRow(
                        'ZIP Code',
                        widget.request.deliveryZipCode!,
                      ),
                  ]),
                ],
                if (widget.sketchFiles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildImagesCard(),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'After submission, we will review your request and provide a quote within 24-48 hours.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.image, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Reference Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              '${widget.sketchFiles.length} image(s) attached',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.sketchFiles.map((file) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.send, color: Colors.blue),
            SizedBox(width: 10),
            Text('Submit Order'),
          ],
        ),
        content: const Text(
          'Are you sure you want to submit this custom order request? Once submitted, the request will be sent to our team for review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _submitOrder();
    }
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _confirmAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Custom Order Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}
