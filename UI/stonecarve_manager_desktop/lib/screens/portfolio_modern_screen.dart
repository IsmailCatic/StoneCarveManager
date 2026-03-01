import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/product.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/models/material.dart'
    as stone_material;
import 'package:stonecarve_manager_flutter/providers/product_provider.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/screens/product_form_screen.dart';

class PortfolioModernScreen extends StatefulWidget {
  const PortfolioModernScreen({super.key});

  @override
  State<PortfolioModernScreen> createState() => _PortfolioModernScreenState();
}

class _PortfolioModernScreenState extends State<PortfolioModernScreen> {
  final ProductProvider _productProvider = ProductProvider();
  final CategoryProvider _categoryProvider = CategoryProvider();
  final MaterialProvider _materialProvider = MaterialProvider();

  List<Product> _portfolioItems = [];
  List<Product> _allPortfolioItems = [];
  List<Category> _categories = [];
  List<stone_material.StoneMaterial> _materials = [];

  bool _isLoading = true;
  String? _selectedType;
  int? _selectedMaterialId;
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load all data in parallel for better performance
    // Load all portfolio items (unfiltered) for dropdowns
    try {
      final allItems = await _productProvider.fetchPortfolioProducts();
      setState(() => _allPortfolioItems = allItems);
    } catch (e) {
      print('Error loading all portfolio items: $e');
    }
    await Future.wait([
      _loadPortfolioItems(),
      _loadCategories(),
      _loadMaterials(),
    ]);
    // Map category and material names AFTER all data is loaded
    _mapCategoryAndMaterialNames();
    setState(() => _isLoading = false);
  }

  Future<void> _loadPortfolioItems() async {
    try {
      final items = await _productProvider.fetchPortfolioProducts(
        categoryName: _selectedType,
        materialId: _selectedMaterialId,
        completionYear: _selectedYear,
      );
      setState(() => _portfolioItems = items);
    } catch (e) {
      print('Error loading portfolio: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryProvider.get();
      setState(() => _categories = result.items ?? []);
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadMaterials() async {
    try {
      final result = await _materialProvider.get();
      setState(() => _materials = result.items ?? []);
    } catch (e) {
      print('Error loading materials: $e');
    }
  }

  /// Map category and material names to portfolio items
  /// This is called AFTER all data is loaded
  void _mapCategoryAndMaterialNames() {
    for (var item in _portfolioItems) {
      if (item.categoryId != null) {
        final category = _categories.firstWhere(
          (cat) => cat.id == item.categoryId,
          orElse: () => Category(id: null, name: null),
        );
        item.categoryName = category.name;
      }
      if (item.materialId != null) {
        final material = _materials.firstWhere(
          (mat) => mat.id == item.materialId,
          orElse: () => stone_material.StoneMaterial(id: null, name: null),
        );
        item.materialName = material.name;
      }
    }
  }

  // Removed frontend filtering - now done on backend

  List<int> get _availableYears {
    final years = _allPortfolioItems
        .where((item) => item.completionYear != null)
        .map((item) => item.completionYear!)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Portfolio',
      currentRoute: '/portfolio',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFilters(),
                  _buildPortfolioGrid(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Our Craftsmanship',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore our finest works in stone carving, restoration, and memorial craftsmanship',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard(
                '${_portfolioItems.length}+',
                'Projects',
                Icons.check_circle_outline,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                '${_materials.length}+',
                'Materials',
                Icons.terrain,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                '${_availableYears.isNotEmpty ? _availableYears.first - _availableYears.last : 0}+',
                'Years',
                Icons.stars,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          // Type filter
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Type',
                prefixIcon: const Icon(Icons.category, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Types'),
                ),
                ..._categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat.name,
                    child: Text(cat.name ?? ''),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
                _loadPortfolioItems();
              },
            ),
          ),

          // Material filter
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
            child: DropdownButtonFormField<int?>(
              value: _selectedMaterialId,
              decoration: InputDecoration(
                labelText: 'Material',
                prefixIcon: const Icon(Icons.terrain, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Materials'),
                ),
                ..._materials
                    .where(
                      (material) => material.id != null && material.id! > 0,
                    )
                    .map((material) {
                      return DropdownMenuItem<int?>(
                        value: material.id,
                        child: Text(material.name ?? ''),
                      );
                    }),
              ],
              onChanged: (value) {
                setState(() => _selectedMaterialId = value);
                _loadPortfolioItems();
              },
            ),
          ),

          // Year filter
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 150),
            child: Builder(
              builder: (context) {
                // Ensure selected year is always present in dropdown items
                final availableYears = _availableYears;
                final dropdownYears = <int?>[null, ...availableYears];
                int? selectedYear = _selectedYear;
                if (selectedYear != null &&
                    !availableYears.contains(selectedYear)) {
                  // Reset selection if not present
                  selectedYear = null;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedYear = null);
                  });
                }
                return DropdownButtonFormField<int?>(
                  value: selectedYear,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    prefixIcon: const Icon(Icons.calendar_today, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Years'),
                    ),
                    ...availableYears.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedYear = value);
                    _loadPortfolioItems();
                  },
                );
              },
            ),
          ),

          // Clear filters
          if (_selectedType != null ||
              _selectedMaterialId != null ||
              _selectedYear != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedMaterialId = null;
                  _selectedYear = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioGrid() {
    if (_portfolioItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolio items found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedMaterialId = null;
                  _selectedYear = null;
                });
                _loadPortfolioItems();
              },
              child: const Text('Clear filters to see all projects'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - (24 * (crossAxisCount + 1))) /
            crossAxisCount;
        final itemHeight = itemWidth / 0.75;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: _portfolioItems.map((item) {
              return SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _buildPortfolioCard(item),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPortfolioCard(Product item) {
    ProductImage? primaryImage;
    if (item.images != null && item.images!.isNotEmpty) {
      try {
        primaryImage = item.images!.firstWhere(
          (img) => img.isPrimary == true,
          orElse: () => item.images!.first,
        );
      } catch (e) {
        primaryImage = item.images!.first;
      }
    }

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showCaseStudy(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.images != null && item.images!.isNotEmpty)
                    Image.network(
                      primaryImage?.imageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.photo_library, size: 64),
                    ),
                  // Edit/Delete menu button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductFormScreen(
                                product: item,
                                isEdit: true,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadData();
                          }
                        } else if (value == 'delete') {
                          _deleteProduct(item);
                        }
                      },
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
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlay gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.location != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.location!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Minimal text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? 'Untitled Project',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (item.description != null)
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (item.categoryName != null)
                        Chip(
                          label: Text(
                            item.categoryName!,
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.blue.shade50,
                        ),
                      const Spacer(),
                      if (item.completionYear != null)
                        Text(
                          item.completionYear.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaseStudy(Product item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 900,
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name ?? 'Project Details',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (item.location != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.location!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery
                      if (item.images != null && item.images!.isNotEmpty) ...[
                        SizedBox(
                          height: 400,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: item.images!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.images![index].imageUrl ?? '',
                                    height: 400,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Project Info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Material',
                              item.materialName ?? 'Not specified',
                              Icons.terrain,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              'Type',
                              item.categoryName ?? 'Not specified',
                              Icons.category,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              'Completed',
                              item.completionYear?.toString() ?? 'N/A',
                              Icons.calendar_today,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // The Challenge
                      if (item.clientChallenge != null) ...[
                        _buildSection(
                          'The Challenge',
                          item.clientChallenge!,
                          Icons.lightbulb_outline,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Our Solution
                      if (item.ourSolution != null) ...[
                        _buildSection(
                          'Our Solution',
                          item.ourSolution!,
                          Icons.build_circle_outlined,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // The Outcome
                      if (item.projectOutcome != null) ...[
                        _buildSection(
                          'The Outcome',
                          item.projectOutcome!,
                          Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Additional Details
                      const Text(
                        'Project Specifications',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          if (item.dimensions != null)
                            _buildSpec('Dimensions', item.dimensions!),
                          if (item.projectDuration != null)
                            _buildSpec(
                              'Duration',
                              '${item.projectDuration} days',
                            ),
                          if (item.techniquesUsed != null)
                            _buildSpec('Techniques', item.techniquesUsed!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSpec(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Portfolio Item'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && item.id != null) {
      try {
        await _productProvider.deleteProduct(item.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Portfolio item deleted successfully')),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting item: $e')));
      }
    }
  }
}
