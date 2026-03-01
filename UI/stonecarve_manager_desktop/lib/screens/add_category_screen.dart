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
    print('\n=== ADD_CATEGORY_SCREEN _fetchCategories() DEBUG ===');
    print('Fetching categories...');

    final result = await CategoryProvider().get();
    print('Categories fetched: ${result.items?.length ?? 0} items');

    setState(() {
      _allCategories = result.items ?? [];
      _isLoading = false;

      if (widget.category?.id != null) {
        // Editing existing category - populate all fields
        print('Initializing form for EDIT mode:');
        print('  - widget.category.id: ${widget.category!.id}');
        print('  - widget.category.name: ${widget.category!.name}');
        print(
          '  - widget.category.description: ${widget.category!.description}',
        );
        print(
          '  - widget.category.parentCategoryId: ${widget.category!.parentCategoryId}',
        );
        print('  - widget.category.isActive: ${widget.category!.isActive}');

        _nameController.text = widget.category!.name ?? '';
        _descriptionController.text = widget.category!.description ?? '';
        _parentCategoryId = widget.category!.parentCategoryId;
        _isActive = widget.category!.isActive ?? true;

        print('Form initialized with:');
        print('  - _nameController.text: ${_nameController.text}');
        print(
          '  - _descriptionController.text: ${_descriptionController.text}',
        );
        print('  - _parentCategoryId: $_parentCategoryId');
        print('  - _isActive: $_isActive');
      } else if (widget.category != null) {
        // Creating subcategory - only set parentCategoryId
        print('Initializing form for ADD SUBCATEGORY mode:');
        print(
          '  - widget.category.parentCategoryId: ${widget.category!.parentCategoryId}',
        );
        _parentCategoryId = widget.category!.parentCategoryId;
        print('  - _parentCategoryId set to: $_parentCategoryId');
      } else {
        print('No existing category data (creating new top-level category)');
      }
    });
  }

  Future<void> _save() async {
    print('\n=== ADD_CATEGORY_SCREEN _save() DEBUG ===');
    print('Form validation started');

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }
    print('Form validation passed');

    print('Creating Category object:');
    print('  - id: ${widget.category?.id}');
    print('  - name: ${_nameController.text.trim()}');
    print('  - description: ${_descriptionController.text.trim()}');
    print('  - parentCategoryId: $_parentCategoryId');
    print('  - isActive: $_isActive');
    print('  - widget.category: ${widget.category}');
    print(
      '  - widget.category?.parentCategoryId: ${widget.category?.parentCategoryId}',
    );
    print(
      '  - imageUrl: ${widget.category?.imageUrl} (preserved from existing)',
    );

    final data = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      parentCategoryId: _parentCategoryId,
      isActive: _isActive,
      imageUrl: widget.category?.imageUrl, // Preserve existing image URL
    );

    print('Category data object created successfully');
    print('Category toJson: ${data.toJson()}');

    try {
      final provider = CategoryProvider();

      if (widget.category?.id == null) {
        print('Creating new category (widget.category.id is null)');
        await provider.createCategory(data);
      } else {
        print('Updating existing category with id: ${widget.category!.id}');
        await provider.updateCategory(widget.category!.id!, data);
      }

      print('Category saved successfully in provider');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      print('\n!!! ERROR in _save() !!!');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('\n=== ADD_CATEGORY_SCREEN build() DEBUG ===');
    print('Current _parentCategoryId: $_parentCategoryId');
    print(
      'widget.category?.parentCategoryId: ${widget.category?.parentCategoryId}',
    );
    print('_allCategories count: ${_allCategories.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category?.id == null ? "Add Category" : "Edit Category",
        ),
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
                          Builder(
                            builder: (context) {
                              print('\n=== DROPDOWN BUILDER DEBUG ===');
                              print(
                                'Building dropdown with _parentCategoryId: $_parentCategoryId',
                              );
                              print('Available categories:');
                              for (var c in _allCategories) {
                                print('  - id: ${c.id}, name: ${c.name}');
                              }

                              return DropdownButtonFormField<int?>(
                                value: _parentCategoryId,
                                decoration: InputDecoration(
                                  labelText: "Parent Category (Optional)",
                                  border: OutlineInputBorder(),
                                  helperText: _parentCategoryId != null
                                      ? 'Subcategory of: ${_allCategories.firstWhere((c) => c.id == _parentCategoryId, orElse: () => Category()).name ?? "ID $_parentCategoryId"}'
                                      : 'No parent selected (top-level category)',
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text("None (Top Level)"),
                                  ),
                                  ..._allCategories
                                      .where(
                                        (c) =>
                                            c.id != null &&
                                            c.id! > 0 &&
                                            c.id != widget.category?.id,
                                      )
                                      .map(
                                        (c) => DropdownMenuItem<int?>(
                                          value: c.id,
                                          child: Text(c.name ?? ""),
                                        ),
                                      )
                                      .toList(),
                                ],
                                onChanged: (v) {
                                  print('\n=== DROPDOWN onChanged DEBUG ===');
                                  print('Previous value: $_parentCategoryId');
                                  print('New value: $v');
                                  setState(() => _parentCategoryId = v);
                                  print(
                                    'State updated with: $_parentCategoryId',
                                  );
                                },
                              );
                            },
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
