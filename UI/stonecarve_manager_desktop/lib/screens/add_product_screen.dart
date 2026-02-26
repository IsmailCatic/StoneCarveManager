import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/models/material.dart';
import 'package:stonecarve_manager_flutter/models/product.dart';
import 'package:stonecarve_manager_flutter/models/requests.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _estimatedDaysController = TextEditingController();
  final _weightController = TextEditingController();

  int? _categoryId;
  int? _materialId;

  List<Category> _categories = [];
  List<StoneMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final categories = await CategoryProvider().getActiveCategories();
    final materials = await MaterialProvider().getAvailableMaterials();
    setState(() {
      _categories = categories;
      _materials = materials;
      _isLoading = false;

      if (widget.product != null) {
        _nameController.text = widget.product!.name ?? '';
        _descriptionController.text = widget.product!.description ?? '';
        _dimensionsController.text = widget.product!.dimensions ?? '';
        _priceController.text = widget.product!.price?.toString() ?? '';
        _stockController.text = widget.product!.stockQuantity?.toString() ?? '';
        _estimatedDaysController.text =
            widget.product!.estimatedDays?.toString() ?? '';
        _weightController.text = widget.product!.weight?.toString() ?? '';
        // Normalize 0 to null and validate IDs exist in dropdown lists
        _categoryId =
            (widget.product!.categoryId == null ||
                widget.product!.categoryId == 0)
            ? null
            : widget.product!.categoryId;
        // Check if category exists in the list, if not set to null
        if (_categoryId != null &&
            !_categories.any((cat) => cat.id == _categoryId)) {
          _categoryId = null;
        }

        _materialId =
            (widget.product!.materialId == null ||
                widget.product!.materialId == 0)
            ? null
            : widget.product!.materialId;
        // Check if material exists in the list, if not set to null
        if (_materialId != null &&
            !_materials.any((mat) => mat.id == _materialId)) {
          _materialId = null;
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final provider = ProductProvider();
      if (widget.product == null) {
        // Create new product using ProductInsertRequest
        final request = ProductInsertRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          dimensions: _dimensionsController.text.trim(),
          price: double.tryParse(_priceController.text.trim()),
          stockQuantity: int.tryParse(_stockController.text.trim()),
          estimatedDays: int.tryParse(_estimatedDaysController.text.trim()),
          weight: double.tryParse(_weightController.text.trim()),
          categoryId: _categoryId,
          materialId: _materialId,
          isActive: true,
          isInPortfolio: true,
        );
        await provider.addProduct(request.toJson());
      } else {
        // Update existing product using ProductUpdateRequest
        final request = ProductUpdateRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          dimensions: _dimensionsController.text.trim(),
          price: double.tryParse(_priceController.text.trim()),
          stockQuantity: int.tryParse(_stockController.text.trim()),
          estimatedDays: int.tryParse(_estimatedDaysController.text.trim()),
          weight: double.tryParse(_weightController.text.trim()),
          categoryId: _categoryId,
          materialId: _materialId,
          isActive: true,
          isInPortfolio: true,
        );
        await provider.updateProduct(widget.product!.id!, request.toJson());
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Product saved successfully!")));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Add Product" : "Edit Product"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 40,
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Product Name *",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return "This field is required";
                              if (v.trim().length < 2)
                                return "Name must be at least 2 characters";
                              if (RegExp(r'^[0-9]+$').hasMatch(v.trim()))
                                return "Name cannot contain only numbers";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: "Description *",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return "This field is required";
                              if (v.trim().length < 5)
                                return "Description must be at least 5 characters";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _dimensionsController,
                            decoration: InputDecoration(
                              labelText: "Dimensions *",
                              hintText: "e.g., 100x50x20 cm",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? "This field is required"
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              labelText: "Price (BAM) *",
                              hintText: "e.g., 250.00",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "This field is required";
                              final price = double.tryParse(
                                v.replaceAll(',', '.'),
                              );
                              if (price == null)
                                return "Enter a valid decimal number (e.g., 250.00)";
                              if (price < 0) return "Price cannot be negative";
                              if (price == 0)
                                return "Price must be greater than 0";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: "Stock Quantity *",
                              hintText: "e.g., 5",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "This field is required";
                              final stock = int.tryParse(v);
                              if (stock == null)
                                return "Enter a valid whole number (no decimals)";
                              if (stock < 0) return "Stock cannot be negative";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _estimatedDaysController,
                            decoration: InputDecoration(
                              labelText: "Estimated Production Days *",
                              hintText: "e.g., 14",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "This field is required";
                              final days = int.tryParse(v);
                              if (days == null)
                                return "Enter a valid whole number (no decimals)";
                              if (days <= 0)
                                return "Days must be greater than 0";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(
                              labelText: "Weight (g) *",
                              hintText: "e.g., 2500.50",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "This field is required";
                              final weight = double.tryParse(
                                v.replaceAll(',', '.'),
                              );
                              if (weight == null)
                                return "Enter a valid decimal number (e.g., 2500.50)";
                              if (weight <= 0)
                                return "Weight must be greater than 0";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            value: _categoryId,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Not assigned'),
                              ),
                              ...{
                                for (var c in _categories)
                                  if (c.id != null && c.id! > 0) c.id: c,
                              }.values.map(
                                (c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.name ?? ""),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _categoryId = v),
                            decoration: const InputDecoration(
                              labelText: "Category (Optional)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int?>(
                            value: _materialId,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Not assigned'),
                              ),
                              ...{
                                for (var m in _materials)
                                  if (m.id != null && m.id! > 0) m.id: m,
                              }.values.map(
                                (m) => DropdownMenuItem<int?>(
                                  value: m.id,
                                  child: Text(m.name ?? ""),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _materialId = v),
                            decoration: const InputDecoration(
                              labelText: "Material (Optional)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("Cancel"),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _save,
                                child: Text("Save"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
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
    super.dispose();
  }
}
