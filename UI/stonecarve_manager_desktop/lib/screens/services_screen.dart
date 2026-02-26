import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/product.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;
import 'package:stonecarve_manager_flutter/providers/product_provider.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/product_state_chip.dart';
import '../utils/validators.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final ProductProvider _productProvider = ProductProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final MaterialProvider _materialProvider = MaterialProvider();
  List<Product> _services = [];
  List<Category> _categories = [];
  List<stone_material.StoneMaterial> _materials = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load categories and materials first (in parallel)
    await Future.wait([_loadCategories(), _loadMaterials()]);

    // Then load services and map the names
    await _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      print(
        '🔵 [ServicesScreen] Loading services with search: "$_searchQuery"',
      );
      final services = await _productProvider.fetchServiceProducts(
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
      print('✅ [ServicesScreen] Loaded ${services.length} services');
      print(
        '📋 [ServicesScreen] Available categories: ${_categories.length}, materials: ${_materials.length}',
      );

      // Map category and material names from loaded lists
      for (var service in services) {
        if (service.categoryId != null) {
          final category = _categories.firstWhere(
            (cat) => cat.id == service.categoryId,
            orElse: () => Category(id: null, name: null),
          );
          service.categoryName = category.name;
          print(
            '  ✅ Service "${service.name}" -> Category: ${category.name ?? "null"} (ID: ${service.categoryId})',
          );
        }
        if (service.materialId != null) {
          final material = _materials.firstWhere(
            (mat) => mat.id == service.materialId,
            orElse: () => stone_material.StoneMaterial(id: null, name: null),
          );
          service.materialName = material.name;
        }
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [ServicesScreen] Error loading services: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading services: $e')));
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryProvider.get();
      setState(() {
        _categories = result.items ?? [];
      });
    } catch (e) {
      print('❌ [ServicesScreen] Error loading categories: $e');
    }
  }

  Future<void> _loadMaterials() async {
    try {
      final result = await _materialProvider.get();
      setState(() {
        _materials = result.items ?? [];
      });
    } catch (e) {
      print('❌ [ServicesScreen] Error loading materials: $e');
    }
  }

  // Filtering now done on backend

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Service Pricing',
      currentRoute: '/services',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with search
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Management',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stone carving, family crests, decorative plates and other services',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      // Debounce search
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 500),
                        () => _loadServices(),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Services count and info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.build_circle,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Services: ${_services.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Active services in pricing list',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadServices,
                      tooltip: 'Refresh',
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Services list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No services in pricing list'
                                : 'No search results',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Move products to Service state to show them here',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        final service = _services[index];
                        return _buildServiceCard(service);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Product service) {
    final hasImage = service.images != null && service.images!.isNotEmpty;
    final imageUrl = hasImage ? service.images!.first.imageUrl : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showServiceDetails(service),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade200,
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.build, size: 48),
                        ),
                      )
                    : const Icon(Icons.build, size: 48, color: Colors.grey),
              ),
              const SizedBox(width: 16),

              // Service details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.name ?? 'Bez naziva',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ProductStateChip(state: service.productState),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (service.description != null &&
                        service.description!.isNotEmpty)
                      Text(
                        service.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.euro,
                                size: 16,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.price?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Duration
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.estimatedDays ?? 7} days',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        // Edit button
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit service',
                          onPressed: () => _showEditServiceDialog(service),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showServiceDetails(Product service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.build_circle, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                service.name ?? 'Service Details',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (service.images != null && service.images!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      service.images!.first.imageUrl ?? '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Description',
                  service.description ?? 'No description',
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Price',
                        '€${service.price?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Duration',
                        '${service.estimatedDays ?? 7} days',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Dimensions',
                        service.dimensions ?? 'N/A',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Weight',
                        service.weight != null ? '${service.weight} kg' : 'N/A',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Category',
                        service.categoryName ?? 'Not assigned',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'Material',
                        service.materialName ?? 'Not assigned',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        'Status',
                        service.isActive == true ? 'Active' : 'Inactive',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        'State',
                        service.productState ?? 'N/A',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditServiceDialog(service);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Product service) {
    final nameController = TextEditingController(text: service.name);
    final descriptionController = TextEditingController(
      text: service.description,
    );
    final priceController = TextEditingController(
      text: service.price?.toString(),
    );
    final estimatedDaysController = TextEditingController(
      text: service.estimatedDays?.toString(),
    );
    final dimensionsController = TextEditingController(
      text: service.dimensions,
    );
    final weightController = TextEditingController(
      text: service.weight?.toString(),
    );

    // Normalize 0 to null and validate IDs exist in dropdown lists
    int? selectedCategoryId =
        (service.categoryId == null || service.categoryId == 0)
        ? null
        : service.categoryId;
    // Check if category exists in the list, if not set to null
    if (selectedCategoryId != null &&
        !_categories.any((cat) => cat.id == selectedCategoryId)) {
      selectedCategoryId = null;
    }

    int? selectedMaterialId =
        (service.materialId == null || service.materialId == 0)
        ? null
        : service.materialId;
    // Check if material exists in the list, if not set to null
    if (selectedMaterialId != null &&
        !_materials.any((mat) => mat.id == selectedMaterialId)) {
      selectedMaterialId = null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Service'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service name *',
                      prefixIcon: Icon(Icons.build),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price (€) *',
                            prefixIcon: Icon(Icons.euro),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: estimatedDaysController,
                          decoration: const InputDecoration(
                            labelText: 'Duration (days)',
                            prefixIcon: Icon(Icons.schedule),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dimensionsController,
                          decoration: const InputDecoration(
                            labelText: 'Dimensions',
                            hintText:
                                'Optional (e.g., 100x50x20 or leave empty)',
                            prefixIcon: Icon(Icons.straighten),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            hintText: 'Optional (e.g., 50 or leave empty)',
                            prefixIcon: Icon(Icons.monitor_weight),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Category Dropdown
                  DropdownButtonFormField<int?>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Not assigned'),
                      ),
                      ...{
                        for (var category in _categories)
                          if (category.id != null && category.id! > 0)
                            category.id: category,
                      }.values.map((category) {
                        return DropdownMenuItem<int?>(
                          value: category.id,
                          child: Text(category.name ?? 'N/A'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Material Dropdown
                  DropdownButtonFormField<int?>(
                    value: selectedMaterialId,
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      prefixIcon: Icon(Icons.terrain),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Not assigned'),
                      ),
                      ...{
                        for (var material in _materials)
                          if (material.id != null && material.id! > 0)
                            material.id: material,
                      }.values.map((material) {
                        return DropdownMenuItem<int?>(
                          value: material.id,
                          child: Text(material.name ?? 'N/A'),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMaterialId = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate name
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service name is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate description
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Description is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate price
                final priceText = priceController.text.trim();
                if (priceText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final price = double.tryParse(priceText);
                if (price == null || price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate weight if provided
                final weightText = weightController.text.trim();
                double? weight;
                if (weightText.isNotEmpty) {
                  weight = double.tryParse(weightText);
                  if (weight == null || weight < 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Weight must be a valid positive number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                // Use original service object and only update fields that are changing
                final updatedService = Product(
                  // Retain ALL existing fields from original object
                  id: service.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  price: price,
                  estimatedDays: int.tryParse(estimatedDaysController.text),
                  dimensions: dimensionsController.text.trim().isEmpty
                      ? null
                      : dimensionsController.text.trim(),
                  weight: weight,
                  // Updated categoryId and materialId from dropdowns
                  categoryId: selectedCategoryId,
                  materialId: selectedMaterialId,
                  // CRITICAL: Retain all other fields from original object
                  stockQuantity: service.stockQuantity,
                  isActive: service.isActive,
                  createdAt: service.createdAt,
                  updatedAt: service.updatedAt,
                  isInPortfolio: service.isInPortfolio,
                  viewCount: service.viewCount,
                  categoryName: service.categoryName,
                  materialName: service.materialName,
                  productState: service.productState,
                  reviewCount: service.reviewCount,
                  averageRating: service.averageRating,
                  category: service.category,
                  material: service.material,
                  images: service.images,
                  reviews: service.reviews,
                );

                try {
                  if (service.id == null) {
                    throw Exception('Service ID is null');
                  }
                  await _productProvider.updateProduct(
                    service.id!,
                    updatedService,
                  );
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Service successfully updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadServices();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating service: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
