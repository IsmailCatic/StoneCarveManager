import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _parentCategoryId;
  bool _isActive = true;
  List<Category> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final result = await CategoryProvider().get();
    setState(() {
      _allCategories = result.items ?? [];
      _isLoading = false;

      if (widget.category != null) {
        _nameController.text = widget.category!.name ?? '';
        _descriptionController.text = widget.category!.description ?? '';
        _parentCategoryId = widget.category!.parentCategoryId;
        _isActive = widget.category!.isActive ?? true;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      parentCategoryId: _parentCategoryId,
      isActive: _isActive,
    );

    try {
      final provider = CategoryProvider();

      if (widget.category == null) {
        await provider.createCategory(data);
      } else {
        await provider.updateCategory(widget.category!.id!, data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category saved successfully!'),
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
        title: Text(widget.category == null ? "Add Category" : "Edit Category"),
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
                              labelText: "Category Name *",
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
                          DropdownButtonFormField<int>(
                            value: _parentCategoryId,
                            decoration: InputDecoration(
                              labelText: "Parent Category (Optional)",
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text("None (Top Level)"),
                              ),
                              ..._allCategories
                                  .where((c) => c.id != widget.category?.id)
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name ?? ""),
                                    ),
                                  )
                                  .toList(),
                            ],
                            onChanged: (v) =>
                                setState(() => _parentCategoryId = v),
                          ),
                          const SizedBox(height: 24),
                          SwitchListTile(
                            title: Text("Active"),
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
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
    super.dispose();
  }
}
