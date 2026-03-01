import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:stonecarve_manager_mobile/models/category.dart';
import 'package:stonecarve_manager_mobile/models/material.dart';
import 'package:stonecarve_manager_mobile/models/custom_order_request.dart';
import 'package:stonecarve_manager_mobile/providers/category_provider.dart';
import 'package:stonecarve_manager_mobile/providers/stone_provider.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/custom_order_preview_screen.dart';
import 'package:stonecarve_manager_mobile/utils/location_data.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/app_drawer_mobile.dart';

class CustomOrderFormScreen extends StatefulWidget {
  const CustomOrderFormScreen({super.key});

  @override
  State<CustomOrderFormScreen> createState() => _CustomOrderFormScreenState();
}

class _CustomOrderFormScreenState extends State<CustomOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Form controllers
  final _dimensionsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customerNotesController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _deliveryZipCodeController = TextEditingController();
  final _cityOtherController = TextEditingController();

  // Form state
  int? _selectedCategoryId;
  int? _selectedMaterialId;
  DateTime? _selectedDeliveryDate;
  List<File> _selectedImages = [];
  String _selectedCountry = 'Bosnia and Herzegovina';
  String? _selectedCity;

  // Data from backend
  List<Category> _categories = [];
  List<StoneMaterial> _materials = [];
  bool _isLoadingData = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _dimensionsController.dispose();
    _descriptionController.dispose();
    _customerNotesController.dispose();
    _deliveryAddressController.dispose();
    _deliveryZipCodeController.dispose();
    _cityOtherController.dispose();

    // Clean up temporary image files
    _cleanupTempImages();

    super.dispose();
  }

  Future<void> _cleanupTempImages() async {
    try {
      for (var file in _selectedImages) {
        if (await file.exists()) {
          await file.delete();
          print('[CustomOrderForm] Deleted temp image: ${file.path}');
        }
      }
    } catch (e) {
      print('[CustomOrderForm] Error cleaning up temp images: $e');
    }
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = '';
    });

    try {
      final categoryProvider = CategoryProvider();
      final materialProvider = MaterialProvider();

      final categoriesResult = await categoryProvider.get();
      final materialsResult = await materialProvider.get();

      setState(() {
        _categories = categoriesResult.items ?? [];
        _materials = materialsResult.items ?? [];
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load form data: $e';
        _isLoadingData = false;
      });
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
      final pickedFiles = await _picker.pickMultiImage();

      // Get app directory for permanent storage
      final appDir = await getApplicationDocumentsDirectory();
      final customOrderDir = Directory('${appDir.path}/custom_order_images');

      // Create directory if it doesn't exist
      if (!await customOrderDir.exists()) {
        await customOrderDir.create(recursive: true);
      }

      // Copy files to permanent location
      final newImages = <File>[];
      for (var pickedFile in pickedFiles.take(5 - _selectedImages.length)) {
        final fileName = path.basename(pickedFile.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final permanentPath = '${customOrderDir.path}/${timestamp}_$fileName';

        // Copy the file to permanent location
        final originalFile = File(pickedFile.path);
        final copiedFile = await originalFile.copy(permanentPath);
        newImages.add(copiedFile);

        print('[CustomOrderForm] Copied image to: $permanentPath');
      }

      setState(() {
        _selectedImages.addAll(newImages);
      });
    } catch (e) {
      print('[CustomOrderForm] Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  Future<void> _removeImage(int index) async {
    final file = _selectedImages[index];

    setState(() {
      _selectedImages.removeAt(index);
    });

    // Delete the file from disk
    try {
      if (await file.exists()) {
        await file.delete();
        print('[CustomOrderForm] Deleted removed image: ${file.path}');
      }
    } catch (e) {
      print('[CustomOrderForm] Error deleting image: $e');
    }
  }

  Future<void> _selectDeliveryDate() async {
    final today = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDeliveryDate != null && _selectedDeliveryDate!.isAfter(today)
          ? _selectedDeliveryDate!
          : today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDeliveryDate = selectedDate;
      });
    }
  }

  void _previewOrder() {
    if (!_formKey.currentState!.validate()) return;

    final resolvedCity = _selectedCity == 'Other'
        ? _cityOtherController.text.trim()
        : (_selectedCity ?? '');

    final request = CustomOrderRequest(
      categoryId: _selectedCategoryId,
      materialId: _selectedMaterialId,
      dimensions: _dimensionsController.text.trim().isEmpty
          ? null
          : _dimensionsController.text.trim(),
      description: _descriptionController.text.trim(),
      customerNotes: _customerNotesController.text.trim().isEmpty
          ? null
          : _customerNotesController.text.trim(),
      deliveryAddress: _deliveryAddressController.text.trim(),
      deliveryCity: resolvedCity,
      deliveryCountry: _selectedCountry,
      deliveryZipCode: _deliveryZipCodeController.text.trim(),
      deliveryDate: _selectedDeliveryDate,
    );

    final categoryName = _selectedCategoryId != null
        ? _categories
              .firstWhere(
                (c) => c.id == _selectedCategoryId,
                orElse: () => Category(),
              )
              .name
        : null;
    final materialName = _selectedMaterialId != null
        ? _materials
              .firstWhere(
                (m) => m.id == _selectedMaterialId,
                orElse: () => StoneMaterial(),
              )
              .name
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomOrderPreviewScreen(
          request: request,
          sketchFiles: _selectedImages,
          categoryName: categoryName,
          materialName: materialName,
        ),
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
          'Custom Order',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const AppDrawerMobile(),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFormData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildCategoryDropdown(),
                        const SizedBox(height: 16),
                        _buildMaterialDropdown(),
                        const SizedBox(height: 16),
                        _buildDimensionsField(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        _buildCustomerNotesField(),
                        const SizedBox(height: 16),
                        _buildDeliveryDateField(),
                        const SizedBox(height: 16),
                        _buildDeliveryFields(),
                        const SizedBox(height: 16),
                        _buildImageUploadSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Category (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Leave blank if your idea doesn\'t fit a standard category',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedCategoryId,
          decoration: InputDecoration(
            hintText: 'Select a category (optional)',
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
          ),
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('— None —')),
            ..._categories.map(
              (category) => DropdownMenuItem<int>(
                value: category.id,
                child: Text(category.name ?? 'Unknown'),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _selectedCategoryId = value),
        ),
      ],
    );
  }

  Widget _buildMaterialDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Material (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Leave blank if you\'re unsure — we can advise during review',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedMaterialId,
          decoration: InputDecoration(
            hintText: 'Select material (optional)',
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
          ),
          items: [
            const DropdownMenuItem<int>(value: null, child: Text('— None —')),
            ..._materials.map(
              (material) => DropdownMenuItem<int>(
                value: material.id,
                child: Text(material.name ?? 'Unknown'),
              ),
            ),
          ],
          onChanged: (value) => setState(() => _selectedMaterialId = value),
        ),
      ],
    );
  }

  Widget _buildDimensionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Approximate Dimensions (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dimensionsController,
          decoration: InputDecoration(
            hintText: 'e.g., 60cm x 45cm',
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
          ),
          maxLength: 200,
          buildCounter:
              (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
          validator: (value) {
            if (value != null && value.trim().length > 200) {
              return 'Dimensions must be less than 200 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Description *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText:
                'Describe your vision in detail. Include any specific design elements, symbols, or references...',
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
          ),
          maxLines: 6,
          maxLength: 4000,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            if (value.trim().length < 20) {
              return 'Description must be at least 20 characters';
            }
            if (value.trim().length > 4000) {
              return 'Description must be less than 4000 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomerNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _customerNotesController,
          decoration: InputDecoration(
            hintText: 'Any special requests or considerations...',
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
          ),
          maxLines: 4,
          maxLength: 2000,
          validator: (value) {
            if (value != null && value.trim().length > 2000) {
              return 'Notes must be less than 2000 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDeliveryDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Desired Completion Date (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDeliveryDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                  _selectedDeliveryDate == null
                      ? 'mm/dd/yyyy'
                      : '${_selectedDeliveryDate!.month}/${_selectedDeliveryDate!.day}/${_selectedDeliveryDate!.year}',
                  style: TextStyle(
                    color: _selectedDeliveryDate == null
                        ? Colors.grey[600]
                        : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
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

  Widget _buildDeliveryFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Information *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Address (required)
        TextFormField(
          controller: _deliveryAddressController,
          decoration: _inputDecoration(hint: 'e.g. 123 Main Street'),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Delivery address is required'
              : null,
        ),
        const SizedBox(height: 8),

        // Country
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: _inputDecoration(),
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
        ),
        const SizedBox(height: 8),

        // City (dropdown)
        DropdownButtonFormField<String>(
          value: _selectedCity,
          decoration: _inputDecoration(),
          hint: const Text('Select city'),
          items: LocationData.citiesFor(
            _selectedCountry,
          ).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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

        // ZIP (required)
        TextFormField(
          controller: _deliveryZipCodeController,
          decoration: _inputDecoration(hint: 'ZIP / Postal code'),
          keyboardType: TextInputType.number,
          maxLength: 10,
          buildCounter:
              (_, {required currentLength, required isFocused, maxLength}) =>
                  null,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Postal code is required'
              : null,
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reference Images or Sketches (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload up to 5 images',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickImages,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Click to upload images',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PNG, JPG up to 10MB',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
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
            onPressed: _previewOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Preview Order',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
