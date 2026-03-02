import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/models/material.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/providers/product_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import '../models/product.dart';
import '../utils/validators.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final bool isEdit;

  const ProductFormScreen({Key? key, this.product, this.isEdit = false})
    : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dimensionsController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _estimatedDaysController;
  late TextEditingController _weightController;

  // Portfolio fields
  late TextEditingController _portfolioDescriptionController;
  late TextEditingController _clientChallengeController;
  late TextEditingController _ourSolutionController;
  late TextEditingController _projectOutcomeController;
  late TextEditingController _locationController;
  late TextEditingController _completionYearController;
  late TextEditingController _projectDurationController;
  late TextEditingController _techniquesUsedController;

  List<Category> _categories = [];
  List<StoneMaterial> _materials = [];
  int? _selectedCategoryId;
  int? _selectedMaterialId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _dimensionsController = TextEditingController(
      text: widget.product?.dimensions ?? '',
    );
    // If price is 0 (e.g., former custom order), clear it so the validator
    // prompts the user to enter a real price rather than silently submitting 0.
    final rawPrice = widget.product?.price;
    final priceText = (rawPrice == null || rawPrice <= 0)
        ? ''
        : rawPrice.toString();
    _priceController = TextEditingController(text: priceText);
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity?.toString() ?? '',
    );
    _estimatedDaysController = TextEditingController(
      text: widget.product?.estimatedDays?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.product?.weight?.toString() ?? '',
    );

    // Portfolio fields
    _portfolioDescriptionController = TextEditingController(
      text: widget.product?.portfolioDescription ?? '',
    );
    _clientChallengeController = TextEditingController(
      text: widget.product?.clientChallenge ?? '',
    );
    _ourSolutionController = TextEditingController(
      text: widget.product?.ourSolution ?? '',
    );
    _projectOutcomeController = TextEditingController(
      text: widget.product?.projectOutcome ?? '',
    );
    _locationController = TextEditingController(
      text: widget.product?.location ?? '',
    );
    _completionYearController = TextEditingController(
      text: widget.product?.completionYear?.toString() ?? '',
    );
    _projectDurationController = TextEditingController(
      text: widget.product?.projectDuration?.toString() ?? '',
    );
    _techniquesUsedController = TextEditingController(
      text: widget.product?.techniquesUsed ?? '',
    );

    _selectedCategoryId = widget.product?.categoryId;
    _selectedMaterialId = widget.product?.materialId;
    _images = List<ProductImage>.from(widget.product?.images ?? []);
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final categories = await CategoryProvider().getActiveCategories();
    final materials = await MaterialProvider().getAvailableMaterials();
    setState(() {
      _categories = categories;
      _materials = materials;
    });
  }

  Future<void> _deleteImage(int? productId, int imageId) async {
    if (productId != null) {
      try {
        await ProductProvider().deleteProductImage(productId, imageId);
        setState(() {
          _images.removeWhere((img) => img.id == imageId);
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
      }
    }
  }

  List<ProductImage> _images = [];

  Future<void> _pickAndUploadImage(int? productId) async {
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save your work before adding an image.')),
      );
      return;
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final uploadedImage = await ProductProvider().uploadProductImage(
          productId,
          pickedFile.path,
        );
        setState(() {
          _images.add(uploadedImage);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product image uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload product image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dimensionsController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _estimatedDaysController.dispose();
    _weightController.dispose();
    _portfolioDescriptionController.dispose();
    _clientChallengeController.dispose();
    _ourSolutionController.dispose();
    _projectOutcomeController.dispose();
    _locationController.dispose();
    _completionYearController.dispose();
    _projectDurationController.dispose();
    _techniquesUsedController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        dimensions: _dimensionsController.text,
        price: double.tryParse(_priceController.text),
        stockQuantity: int.tryParse(_stockController.text),
        estimatedDays: int.tryParse(_estimatedDaysController.text),
        weight: double.tryParse(_weightController.text),
        categoryId: _selectedCategoryId,
        materialId: _selectedMaterialId,
        isInPortfolio: true,
        productState: widget.product?.productState ?? 'draft',
        portfolioDescription: _portfolioDescriptionController.text.isNotEmpty
            ? _portfolioDescriptionController.text
            : null,
        clientChallenge: _clientChallengeController.text.isNotEmpty
            ? _clientChallengeController.text
            : null,
        ourSolution: _ourSolutionController.text.isNotEmpty
            ? _ourSolutionController.text
            : null,
        projectOutcome: _projectOutcomeController.text.isNotEmpty
            ? _projectOutcomeController.text
            : null,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        completionYear: int.tryParse(_completionYearController.text),
        projectDuration: int.tryParse(_projectDurationController.text),
        techniquesUsed: _techniquesUsedController.text.isNotEmpty
            ? _techniquesUsedController.text
            : null,
      );
      try {
        if (widget.isEdit && product.id != null) {
          await ProductProvider().updateProduct(product.id!, product);
        } else {
          final newProduct = await ProductProvider().addProduct(product);
          // After adding, allow image upload
          setState(() {
            _images = newProduct.images ?? [];
          });
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save product: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Product' : 'Add New Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g., Stone Vase',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  if (RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                    return 'Name cannot contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 5) {
                    return 'Description must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dimensionsController,
                decoration: const InputDecoration(
                  labelText: 'Dimensions *',
                  hintText: 'e.g., 100x50x20 cm',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (BAM) *',
                  hintText: 'e.g., 250.00',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  final price = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );
                  if (price == null) {
                    return 'Enter a valid decimal number (e.g., 250.00)';
                  }
                  if (price <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  hintText: 'e.g., 5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  final stock = int.tryParse(value.trim());
                  if (stock == null) {
                    return 'Enter a valid whole number (no decimals)';
                  }
                  if (stock < 0) {
                    return 'Stock cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _estimatedDaysController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Production Days *',
                  hintText: 'e.g., 14',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  final days = int.tryParse(value.trim());
                  if (days == null) {
                    return 'Enter a valid whole number (no decimals)';
                  }
                  if (days <= 0) {
                    return 'Days must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (g) *',
                  hintText: 'e.g., 2500.50',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  final weight = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );
                  if (weight == null) {
                    return 'Enter a valid decimal number (e.g., 2500.50)';
                  }
                  if (weight <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .where((cat) => cat.id != null && cat.id! > 0)
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedMaterialId,
                decoration: InputDecoration(
                  labelText: 'Material *',
                  border: OutlineInputBorder(),
                ),
                items: _materials
                    .where((mat) => mat.id != null && mat.id! > 0)
                    .map(
                      (mat) => DropdownMenuItem(
                        value: mat.id,
                        child: Text(mat.name ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMaterialId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 2),
              const SizedBox(height: 8),
              Text(
                'Portfolio Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portfolioDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio Description',
                  hintText: 'Detailed description for portfolio showcase',
                ),
                maxLines: 3,
                validator: (value) => value != null && value.isNotEmpty
                    ? Validators.validateMinLength(
                        value,
                        20,
                        fieldName: 'Portfolio Description',
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientChallengeController,
                decoration: const InputDecoration(
                  labelText: 'Client Challenge',
                  hintText: 'What was the client\'s challenge or need?',
                ),
                maxLines: 4,
                validator: (value) => value != null && value.isNotEmpty
                    ? Validators.validateMinLength(
                        value,
                        15,
                        fieldName: 'Client Challenge',
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ourSolutionController,
                decoration: const InputDecoration(
                  labelText: 'Our Solution',
                  hintText: 'How did you solve the challenge?',
                ),
                maxLines: 4,
                validator: (value) => value != null && value.isNotEmpty
                    ? Validators.validateMinLength(
                        value,
                        15,
                        fieldName: 'Our Solution',
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _projectOutcomeController,
                decoration: const InputDecoration(
                  labelText: 'Project Outcome',
                  hintText: 'What was the final result?',
                ),
                maxLines: 4,
                validator: (value) => value != null && value.isNotEmpty
                    ? Validators.validateMinLength(
                        value,
                        15,
                        fieldName: 'Project Outcome',
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'City, Country',
                      ),
                      validator: (value) => value != null && value.isNotEmpty
                          ? Validators.validateMinLength(
                              value,
                              3,
                              fieldName: 'Location',
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _completionYearController,
                      decoration: const InputDecoration(
                        labelText: 'Completion Year',
                        hintText: '2024',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value != null && value.isNotEmpty
                          ? Validators.validateYear(value, required: false)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _projectDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Project Duration (days)',
                        hintText: '30',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validatePositiveInteger(
                        value,
                        fieldName: 'Project Duration',
                        required: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _techniquesUsedController,
                      decoration: const InputDecoration(
                        labelText: 'Techniques Used',
                        hintText: 'Hand carving, polishing',
                      ),
                      validator: (value) => value != null && value.isNotEmpty
                          ? Validators.validateMinLength(
                              value,
                              5,
                              fieldName: 'Techniques Used',
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 2),
              const SizedBox(height: 16),
              Text('Images:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _images.length) {
                      final img = _images[index];
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
                                      title: const Text('Delete Image'),
                                      content: const Text(
                                        'Are you sure you want to delete this image?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final success = await ProductProvider()
                                        .deleteProductImage(
                                          widget.product?.id ?? 0,
                                          img.id!,
                                        );
                                    if (success) {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Product image removed successfully',
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
                                              'Error deleting image!',
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
                        onTap: () async {
                          await _pickAndUploadImage(widget.product?.id);
                        },
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  widget.isEdit ? 'Save Changes' : 'Add Product',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
