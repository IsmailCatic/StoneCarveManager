import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:stonecarve_manager_mobile/models/product.dart';
import 'package:stonecarve_manager_mobile/models/service_order_request.dart';
import 'package:stonecarve_manager_mobile/providers/order_provider.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/order_payment_screen.dart';
import 'package:stonecarve_manager_mobile/utils/location_data.dart';

class ServiceRequestScreen extends StatefulWidget {
  final Product service;

  const ServiceRequestScreen({super.key, required this.service});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _descriptionController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _locationZipController = TextEditingController();
  final _cityOtherController = TextEditingController();

  String _selectedCountry = 'Bosnia and Herzegovina';
  String? _selectedCity;

  DateTime? _preferredDate;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationAddressController.dispose();
    _locationZipController.dispose();
    _cityOtherController.dispose();
    _cleanupImages();
    super.dispose();
  }

  Future<void> _cleanupImages() async {
    for (final file in _selectedImages) {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed')));
      return;
    }
    try {
      final picked = await _picker.pickMultiImage();
      final appDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${appDir.path}/service_request_images');
      if (!await imgDir.exists()) await imgDir.create(recursive: true);

      final newFiles = <File>[];
      for (final p in picked.take(5 - _selectedImages.length)) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        final dest = '${imgDir.path}/${ts}_${path.basename(p.path)}';
        newFiles.add(await File(p.path).copy(dest));
      }
      setState(() => _selectedImages.addAll(newFiles));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not pick images: $e')));
      }
    }
  }

  Future<void> _removeImage(int index) async {
    final file = _selectedImages[index];
    setState(() => _selectedImages.removeAt(index));
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(
        Duration(days: widget.service.estimatedDays ?? 14),
      ),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final service = widget.service;
    final resolvedCity = _selectedCity == 'Other'
        ? _cityOtherController.text.trim()
        : (_selectedCity ?? '');
    final location = [
      _locationAddressController.text.trim(),
      resolvedCity,
      _selectedCountry,
      _locationZipController.text.trim(),
    ].where((s) => s.isNotEmpty).join(', ');

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Service Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service: ${service.name ?? '—'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Location: $location'),
            ],
            if (_preferredDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Date: ${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}',
              ),
            ],
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${_selectedImages.length} image(s) attached'),
            ],
            const SizedBox(height: 12),
            const Text('Submit this service request?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;

      setState(() => _isSubmitting = true);
      try {
        final request = ServiceOrderRequest(
          serviceProductId: service.id!,
          requirements: _descriptionController.text.trim(),
          deliveryAddress: _locationAddressController.text.trim().isEmpty
              ? null
              : _locationAddressController.text.trim(),
          deliveryCity: _selectedCity == 'Other'
              ? (_cityOtherController.text.trim().isEmpty
                    ? null
                    : _cityOtherController.text.trim())
              : _selectedCity,
          deliveryCountry: _selectedCountry,
          deliveryZipCode: _locationZipController.text.trim().isEmpty
              ? null
              : _locationZipController.text.trim(),
          preferredDate: _preferredDate,
        );

        final order = await OrderProvider.createServiceRequest(
          request,
          _selectedImages,
        );

        // Images uploaded — clear the local copies
        final imagesToClean = List<File>.from(_selectedImages);
        setState(() {
          _selectedImages = [];
          _isSubmitting = false;
        });
        for (final f in imagesToClean) {
          try {
            if (await f.exists()) await f.delete();
          } catch (_) {}
        }

        if (!mounted) return;
        // Navigate to payment screen — order is created, now collect payment
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderPaymentScreen(
              order: order,
              orderTypeLabel: 'Service Request',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  // ─── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildServiceBanner() {
    final service = widget.service;
    final primaryImage = service.images?.isNotEmpty == true
        ? service.images!.first.imageUrl
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: Colors.white.withOpacity(0.2),
                child: primaryImage != null
                    ? Image.network(
                        primaryImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.build,
                          color: Colors.white,
                          size: 32,
                        ),
                      )
                    : const Icon(Icons.build, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name ?? 'Service',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'From €${service.price?.toStringAsFixed(2) ?? '—'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (service.estimatedDays != null) ...[
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.schedule,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '~${service.estimatedDays} days',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (service.categoryName != null ||
                      service.materialName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        [
                          if (service.categoryName != null)
                            service.categoryName!,
                          if (service.materialName != null)
                            service.materialName!,
                        ].join(' · '),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.lock_outline, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Text(
              _preferredDate == null
                  ? 'Select a preferred date'
                  : '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}',
              style: TextStyle(
                color: _preferredDate == null
                    ? Colors.grey[500]
                    : Colors.black87,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (_preferredDate != null)
              GestureDetector(
                onTap: () => setState(() => _preferredDate = null),
                child: Icon(Icons.close, color: Colors.grey[500], size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    if (_selectedImages.isEmpty) {
      return OutlinedButton.icon(
        onPressed: _pickImages,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Add Photos'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length + 1,
        itemBuilder: (context, i) {
          if (i == _selectedImages.length) {
            if (_selectedImages.length >= 5) return const SizedBox();
            return GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 90,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey[500]),
                    Text(
                      'Add',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }
          final file = _selectedImages[i];
          return Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                margin: EdgeInsets.only(
                  right: i < _selectedImages.length - 1 ? 8 : 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(i),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
          'Request Service',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Service banner ──
                  _buildServiceBanner(),
                  const SizedBox(height: 24),

                  // ── What do you need? ──
                  _buildSectionLabel(
                    'What do you need? *',
                    subtitle:
                        'Describe the work — what needs doing, current condition, any specific requirements...',
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: _inputDecoration(
                      hint:
                          'e.g. "The lettering on a gravestone needs repainting and the stone has surface cracking that needs sealing..."',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please describe what you need';
                      }
                      if (v.trim().length < 20) {
                        return 'Please provide more detail (at least 20 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Location ──
                  _buildSectionLabel(
                    'Location *',
                    subtitle:
                        'Where the work will take place or where to deliver',
                  ),
                  const SizedBox(height: 8),

                  // Street address
                  TextFormField(
                    controller: _locationAddressController,
                    decoration: _inputDecoration(hint: 'Street and number'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Address is required'
                        : null,
                  ),
                  const SizedBox(height: 8),

                  // Country dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    decoration: _inputDecoration(hint: 'Country'),
                    items: LocationData.countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value!;
                        _selectedCity = null;
                        _cityOtherController.clear();
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Please select a country' : null,
                  ),
                  const SizedBox(height: 8),

                  // City dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: _inputDecoration(hint: 'City'),
                    hint: const Text('Select city'),
                    items: LocationData.citiesFor(_selectedCountry)
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        if (value != 'Other') _cityOtherController.clear();
                      });
                    },
                    validator: (v) => v == null ? 'Please select a city' : null,
                  ),
                  if (_selectedCity == 'Other') ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cityOtherController,
                      decoration: _inputDecoration(hint: 'Enter your city'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your city'
                          : null,
                    ),
                  ],
                  const SizedBox(height: 8),

                  // ZIP
                  SizedBox(
                    width: 160,
                    child: TextFormField(
                      controller: _locationZipController,
                      decoration: _inputDecoration(hint: 'ZIP / Postal code'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Preferred date ──
                  _buildSectionLabel(
                    'Preferred Date (Optional)',
                    subtitle: 'When would you like this done?',
                  ),
                  const SizedBox(height: 8),
                  _buildDatePicker(),
                  const SizedBox(height: 20),

                  // ── Photos ──
                  _buildSectionLabel(
                    'Photos (Optional)',
                    subtitle:
                        'Photos of the item, site, or existing damage help us assess the work accurately',
                  ),
                  const SizedBox(height: 8),
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Submit ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _isSubmitting ? 'Submitting…' : 'Review & Submit Request',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
