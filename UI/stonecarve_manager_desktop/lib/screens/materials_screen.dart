import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/screens/add_material_screen.dart';
import 'package:stonecarve_manager_flutter/widgets/optimized_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  final MaterialProvider _materialProvider = MaterialProvider();
  List<stone_material.StoneMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final result = await _materialProvider.get();
      setState(() {
        _materials = result.items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading materials: $e')));
      }
    }
  }

  Future<void> _pickAndUploadImage(
    stone_material.StoneMaterial material,
  ) async {
    if (material.id == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        await _materialProvider.uploadMaterialImage(
          material.id!,
          File(pickedFile.path),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMaterials();
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

  Future<void> _deleteImage(stone_material.StoneMaterial material) async {
    if (material.id == null ||
        material.imageUrl == null ||
        material.imageUrl!.isEmpty)
      return;

    try {
      await _materialProvider.deleteMaterialImage(material.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMaterials();
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
      title: 'Materials',
      currentRoute: '/materials',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Material Inventory',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMaterialScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadMaterials();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Material'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _materials.isEmpty
                  ? const Center(child: Text('No materials found'))
                  : GridView.builder(
                      // Performance optimizations
                      cacheExtent: 200,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: _materials.length,
                      itemBuilder: (context, index) {
                        final material = _materials[index];
                        return Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                  child: material.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(4),
                                              ),
                                          child: OptimizedImage(
                                            imageUrl: material.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorWidget: const Icon(
                                              Icons.terrain,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.terrain,
                                          size: 64,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        material.name ?? 'Unknown Material',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${material.pricePerUnit?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Stock: ${material.quantityInStock ?? 0}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Image upload/delete button
                                          IconButton(
                                            icon: Icon(
                                              (material.imageUrl != null &&
                                                      material
                                                          .imageUrl!
                                                          .isNotEmpty)
                                                  ? Icons.hide_image
                                                  : Icons.add_photo_alternate,
                                              size: 18,
                                              color:
                                                  (material.imageUrl != null &&
                                                      material
                                                          .imageUrl!
                                                          .isNotEmpty)
                                                  ? Colors.orange
                                                  : Colors.blue,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            tooltip:
                                                (material.imageUrl != null &&
                                                    material
                                                        .imageUrl!
                                                        .isNotEmpty)
                                                ? 'Delete Image'
                                                : 'Add Image',
                                            onPressed: () async {
                                              if (material.imageUrl != null &&
                                                  material
                                                      .imageUrl!
                                                      .isNotEmpty) {
                                                // Delete image
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text(
                                                      'Delete Image',
                                                    ),
                                                    content: const Text(
                                                      'Are you sure you want to delete this image?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                              true,
                                                            ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                        child: const Text(
                                                          'Delete',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await _deleteImage(material);
                                                }
                                              } else {
                                                // Upload image
                                                await _pickAndUploadImage(
                                                  material,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddMaterialScreen(
                                                            material: material,
                                                          ),
                                                    ),
                                                  );
                                              if (result == true) {
                                                _loadMaterials();
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Delete Material',
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to delete "${material.name}"?\nThis action cannot be undone.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancel',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                try {
                                                  await _materialProvider
                                                      .delete(material.id!);
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Material deleted successfully',
                                                        ),
                                                      ),
                                                    );
                                                    _loadMaterials();
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Error deleting material: $e',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
