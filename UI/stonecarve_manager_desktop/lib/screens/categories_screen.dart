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

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCategories();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCategories();
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
                  : ListView.builder(
                      // Performance optimizations
                      cacheExtent: 100,
                      itemExtent: 80,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: OptimizedCircleAvatar(
                              imageUrl: category.imageUrl,
                              radius: 20,
                              fallbackChild: Icon(
                                category.parentCategoryId == null
                                    ? Icons.category
                                    : Icons.subdirectory_arrow_right,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              category.name ?? 'Unnamed Category',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              category.description ?? 'No description',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (category.isActive == true)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                PopupMenuButton(
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
                                                    category
                                                        .imageUrl!
                                                        .isNotEmpty)
                                                ? Icons.hide_image
                                                : Icons.add_photo_alternate,
                                            size: 18,
                                            color:
                                                (category.imageUrl != null &&
                                                    category
                                                        .imageUrl!
                                                        .isNotEmpty)
                                                ? Colors.orange
                                                : Colors.blue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            (category.imageUrl != null &&
                                                    category
                                                        .imageUrl!
                                                        .isNotEmpty)
                                                ? 'Delete Image'
                                                : 'Upload Image',
                                            style: TextStyle(
                                              color:
                                                  (category.imageUrl != null &&
                                                      category
                                                          .imageUrl!
                                                          .isNotEmpty)
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
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddCategoryScreen(
                                                category: category,
                                              ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadCategories();
                                      }
                                    } else if (value == 'subcategory') {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddCategoryScreen(
                                                category: Category(
                                                  parentCategoryId: category.id,
                                                ),
                                              ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadCategories();
                                      }
                                    } else if (value == 'upload-image') {
                                      await _pickAndUploadImage(category);
                                    } else if (value == 'delete-image') {
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
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                              ),
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
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        try {
                                          await _categoryProvider.delete(
                                            category.id!,
                                          );
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Category deleted successfully',
                                                ),
                                              ),
                                            );
                                            _loadCategories();
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error deleting category: $e',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
