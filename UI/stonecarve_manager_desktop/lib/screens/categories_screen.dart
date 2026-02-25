import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/screens/add_category_screen.dart';
import 'package:stonecarve_manager_flutter/widgets/optimized_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryProvider _categoryProvider = CategoryProvider();
  List<Category> _categories = [];
  bool _isLoading = true;
  final Set<int> _expandedCategories = {}; // Track expanded parent categories

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Helper method to get root categories (categories without parent)
  List<Category> _getRootCategories() {
    return _categories.where((cat) => cat.parentCategoryId == null).toList()
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
  }

  // Helper method to get child categories for a given parent ID
  List<Category> _getChildCategories(int parentId) {
    return _categories.where((cat) => cat.parentCategoryId == parentId).toList()
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _categoryProvider.get();
      setState(() {
        _categories = result.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    }
  }

  Future<void> _pickAndUploadImage(Category category) async {
    if (category.id == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        await _categoryProvider.uploadCategoryImage(
          category.id!,
          File(pickedFile.path),
        );
        // Reload data immediately to show the new image
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
        }
      }
    }
  }

  Future<void> _deleteImage(Category category) async {
    if (category.id == null ||
        category.imageUrl == null ||
        category.imageUrl!.isEmpty)
      return;

    try {
      await _categoryProvider.deleteCategoryImage(category.id!);
      // Reload data immediately to reflect the deletion
      await _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Categories',
      currentRoute: '/categories',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCategoryScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadCategories();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Category'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                  ? const Center(child: Text('No categories found'))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      children: _buildCategoryTree(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the hierarchical category tree
  List<Widget> _buildCategoryTree() {
    final widgets = <Widget>[];
    final rootCategories = _getRootCategories();

    for (final category in rootCategories) {
      widgets.add(_buildCategoryItem(category, level: 0));

      // Add subcategories if parent is expanded
      if (_expandedCategories.contains(category.id)) {
        final children = _getChildCategories(category.id!);
        for (final child in children) {
          widgets.add(_buildCategoryItem(child, level: 1));
        }
      }
    }

    return widgets;
  }

  // Build individual category item with proper indentation
  Widget _buildCategoryItem(Category category, {required int level}) {
    final isParent = (category.childCategoryCount ?? 0) > 0;
    final isExpanded = _expandedCategories.contains(category.id);
    final indentWidth = level * 40.0;

    return Card(
      margin: EdgeInsets.only(
        left: indentWidth + 4,
        right: 4,
        top: 4,
        bottom: 4,
      ),
      elevation: level == 0 ? 2 : 1,
      color: level == 0 ? null : Colors.grey.shade50,
      child: InkWell(
        onTap: isParent
            ? () {
                setState(() {
                  if (isExpanded) {
                    _expandedCategories.remove(category.id);
                  } else {
                    _expandedCategories.add(category.id!);
                  }
                });
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Expand/collapse icon for parent categories
              if (isParent)
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 24,
                  color: Colors.grey.shade700,
                )
              else if (level > 0)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.subdirectory_arrow_right,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                )
              else
                const SizedBox(width: 24),
              const SizedBox(width: 8),

              // Category image
              OptimizedCircleAvatar(
                imageUrl: category.imageUrl,
                radius: 24,
                fallbackChild: Icon(
                  level == 0 ? Icons.category : Icons.label,
                  size: 24,
                  color: level == 0 ? Colors.blue : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),

              // Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with name and status
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category.name ?? 'Unnamed Category',
                            style: TextStyle(
                              fontWeight: level == 0
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: level == 0 ? 16 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (category.isActive == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Description
                    if (category.description != null &&
                        category.description!.isNotEmpty)
                      Text(
                        category.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 6),

                    // Badges row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Product count
                        if (category.productCount != null &&
                            category.productCount! > 0)
                          _buildBadge(
                            icon: Icons.inventory_2_outlined,
                            label: '${category.productCount} products',
                            color: Colors.green,
                          ),

                        // Subcategory count
                        if (category.childCategoryCount != null &&
                            category.childCategoryCount! > 0)
                          _buildBadge(
                            icon: Icons.folder,
                            label:
                                '${category.childCategoryCount} subcategories',
                            color: Colors.purple,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick add subcategory button for parent categories
                  if (level == 0)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 20,
                      color: Colors.blue,
                      tooltip: 'Add Subcategory',
                      onPressed: () => _addSubcategory(category),
                    ),

                  // More options menu
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'subcategory',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Add Subcategory'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value:
                            (category.imageUrl != null &&
                                category.imageUrl!.isNotEmpty)
                            ? 'delete-image'
                            : 'upload-image',
                        child: Row(
                          children: [
                            Icon(
                              (category.imageUrl != null &&
                                      category.imageUrl!.isNotEmpty)
                                  ? Icons.hide_image
                                  : Icons.add_photo_alternate,
                              size: 18,
                              color:
                                  (category.imageUrl != null &&
                                      category.imageUrl!.isNotEmpty)
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (category.imageUrl != null &&
                                      category.imageUrl!.isNotEmpty)
                                  ? 'Delete Image'
                                  : 'Upload Image',
                              style: TextStyle(
                                color:
                                    (category.imageUrl != null &&
                                        category.imageUrl!.isNotEmpty)
                                    ? Colors.orange
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value, category),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build badge widgets
  // Helper to build badge widgets
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Handle adding subcategory
  Future<void> _addSubcategory(Category parentCategory) async {
    print('=== SUBCATEGORY CREATION DEBUG ===');
    print('Parent category: ${parentCategory.name}');
    print('Parent category ID: ${parentCategory.id}');

    final newCategory = Category(parentCategoryId: parentCategory.id);
    print(
      'New subcategory object created with parentCategoryId: ${newCategory.parentCategoryId}',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(category: newCategory),
      ),
    );

    if (result == true) {
      print('Subcategory saved successfully, reloading categories');
      _loadCategories();
      // Auto-expand the parent category to show the new subcategory
      setState(() {
        _expandedCategories.add(parentCategory.id!);
      });
    }
  }

  // Handle menu actions
  Future<void> _handleMenuAction(dynamic value, Category category) async {
    if (value == 'edit') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCategoryScreen(category: category),
        ),
      );
      if (result == true) {
        _loadCategories();
      }
    } else if (value == 'subcategory') {
      await _addSubcategory(category);
    } else if (value == 'upload-image') {
      await _pickAndUploadImage(category);
    } else if (value == 'delete-image') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _deleteImage(category);
      }
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"?\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        try {
          await _categoryProvider.delete(category.id!);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category deleted successfully')),
            );
            _loadCategories();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting category: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}
