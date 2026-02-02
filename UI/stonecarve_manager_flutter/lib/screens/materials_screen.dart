import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';

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
                  onPressed: () {
                    // TODO: Implement add material functionality
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
                                  child: const Icon(
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
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () async {
                                              // Implement edit functionality
                                              final updatedMaterial = await showDialog<stone_material.StoneMaterial>(
                                                context: context,
                                                builder: (context) {
                                                  final nameController =
                                                      TextEditingController(
                                                        text: material.name,
                                                      );
                                                  final priceController =
                                                      TextEditingController(
                                                        text:
                                                            material
                                                                .pricePerUnit
                                                                ?.toString() ??
                                                            '',
                                                      );
                                                  final quantityController =
                                                      TextEditingController(
                                                        text:
                                                            material
                                                                .quantityInStock
                                                                ?.toString() ??
                                                            '',
                                                      );
                                                  return AlertDialog(
                                                    title: const Text(
                                                      'Edit Material',
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              nameController,
                                                          decoration:
                                                              const InputDecoration(
                                                                labelText:
                                                                    'Name',
                                                              ),
                                                        ),
                                                        TextField(
                                                          controller:
                                                              priceController,
                                                          decoration:
                                                              const InputDecoration(
                                                                labelText:
                                                                    'Price per Unit',
                                                              ),
                                                          keyboardType:
                                                              TextInputType.numberWithOptions(
                                                                decimal: true,
                                                              ),
                                                        ),
                                                        TextField(
                                                          controller:
                                                              quantityController,
                                                          decoration:
                                                              const InputDecoration(
                                                                labelText:
                                                                    'Quantity in Stock',
                                                              ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                        ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          final updated = stone_material.StoneMaterial(
                                                            id: material.id,
                                                            name: nameController
                                                                .text,
                                                            pricePerUnit:
                                                                double.tryParse(
                                                                  priceController
                                                                      .text,
                                                                ) ??
                                                                0,
                                                            quantityInStock:
                                                                int.tryParse(
                                                                  quantityController
                                                                      .text,
                                                                ) ??
                                                                0,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                            updated,
                                                          );
                                                        },
                                                        child: const Text(
                                                          'Save',
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              if (updatedMaterial != null) {
                                                await _materialProvider.update(
                                                  material.id!,
                                                  updatedMaterial,
                                                );
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
                                              // Implement delete functionality
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text(
                                                    'Delete Material',
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this material?',
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
                                                      child: const Text(
                                                        'Delete',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                await _materialProvider.delete(
                                                  material.id!,
                                                );
                                                _loadMaterials();
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
