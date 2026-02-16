import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';

class AddMaterialScreen extends StatefulWidget {
  final stone_material.StoneMaterial? material;
  const AddMaterialScreen({super.key, this.material});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.material != null) {
      _nameController.text = widget.material!.name ?? '';
      _descriptionController.text = widget.material!.description ?? '';
      _priceController.text = widget.material!.pricePerUnit?.toString() ?? '';
      _quantityController.text =
          widget.material!.quantityInStock?.toString() ?? '';
      _unitController.text = widget.material!.unit ?? '';
      _isAvailable = widget.material!.isAvailable ?? true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = stone_material.StoneMaterial(
      id: widget.material?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      pricePerUnit: double.tryParse(_priceController.text.trim()),
      quantityInStock: int.tryParse(_quantityController.text.trim()),
      unit: _unitController.text.trim(),
      isAvailable: _isAvailable,
    );

    try {
      final provider = MaterialProvider();

      if (widget.material == null) {
        await provider.createMaterial(data);
      } else {
        await provider.updateMaterial(widget.material!.id!, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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
        title: Text(widget.material == null ? "Add Material" : "Edit Material"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Material Name *",
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
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Price Per Unit (BAM) *",
                        hintText: "e.g., 25.50",
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
                        final price = double.tryParse(v.replaceAll(',', '.'));
                        if (price == null)
                          return "Enter a valid decimal number (e.g., 25.50)";
                        if (price < 0) return "Price cannot be negative";
                        if (price == 0) return "Price must be greater than 0";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: "Quantity In Stock *",
                        hintText: "e.g., 100",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return "This field is required";
                        final quantity = int.tryParse(v);
                        if (quantity == null)
                          return "Enter a valid whole number (no decimals)";
                        if (quantity < 0) return "Quantity cannot be negative";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _unitController,
                      decoration: InputDecoration(
                        labelText: "Unit (e.g., kg, m², pcs) *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return "This field is required";
                        if (v.trim().length < 1)
                          return "Unit must be at least 1 character";
                        if (RegExp(r'^[0-9]+$').hasMatch(v.trim()))
                          return "Unit cannot be only numbers";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: Text("Available"),
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
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
                        ElevatedButton(onPressed: _save, child: Text("Save")),
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
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
