import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';
import 'package:stonecarve_manager_mobile/models/category.dart';
import 'package:stonecarve_manager_mobile/models/material.dart'
    as stone_material;
import 'package:stonecarve_manager_mobile/widgets/mobile/portfolio_card.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/app_drawer_mobile.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/category_provider.dart';
import 'package:stonecarve_manager_mobile/providers/stone_provider.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/portfolio_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PortfolioMobileScreen extends StatefulWidget {
  const PortfolioMobileScreen({super.key});

  @override
  State<PortfolioMobileScreen> createState() => _PortfolioMobileScreenState();
}

class _PortfolioMobileScreenState extends State<PortfolioMobileScreen>
    with AutomaticKeepAliveClientMixin {
  final CategoryProvider _categoryProvider = CategoryProvider();
  final MaterialProvider _materialProvider = MaterialProvider();

  List<Product> _projects = [];
  List<Product> _filteredProjects = [];
  List<Category> _categories = [];
  List<stone_material.StoneMaterial> _materials = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedMaterial;
  String? _selectedStyle;
  String _selectedSort = 'date_desc';

  // Filter options based on mockup
  final List<String> _categoryOptions = [
    'All',
    'Crest',
    'Sign/Lettering',
    'Geometric',
  ];
  final List<String> _materialOptions = [
    'All',
    'Limestone',
    'Granite',
    'Marble',
  ];
  final List<String> _styleOptions = [
    'All',
    'Traditional',
    'Contemporary',
    'Modern',
  ];

  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
    _selectedMaterial = 'All';
    _selectedStyle = 'All';
    _searchController.addListener(_filterProjects);
    // Fetch portfolio once on initialization
    _fetchPortfolio();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPortfolio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load categories and materials first
      await Future.wait([_loadCategories(), _loadMaterials()]);

      final url = '${BaseProvider.baseUrl}/api/Product/portfolio';
      print('[PortfolioMobile] Fetching from: $url');
      print(
        '[PortfolioMobile] Auth token: ${AuthProvider.token?.substring(0, 20)}...',
      );

      final response = await http.get(
        Uri.parse(url),
        headers: AuthProvider.getAuthHeaders(),
      );

      print('[PortfolioMobile] Response status: ${response.statusCode}');
      print(
        '[PortfolioMobile] Response body: ${response.body.substring(0, 200)}...',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['items'] ?? [];
        print('[PortfolioMobile] Loaded ${items.length} portfolio items');

        var projects = items.map((json) => Product.fromJson(json)).toList();

        // Map category and material names from loaded lists
        for (var item in projects) {
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

        setState(() {
          _projects = projects;
          _filteredProjects = List.from(_projects);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load portfolio (${response.statusCode}): ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
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

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = _projects.where((project) {
        // Search filter
        final nameMatch = project.name?.toLowerCase().contains(query) ?? false;
        final descMatch =
            project.description?.toLowerCase().contains(query) ?? false;
        if (query.isNotEmpty && !nameMatch && !descMatch) return false;

        // Category filter
        if (_selectedCategory != 'All') {
          final categoryMatch =
              project.categoryName?.toLowerCase() ==
              _selectedCategory?.toLowerCase();
          if (!categoryMatch) return false;
        }

        // Material filter
        if (_selectedMaterial != 'All') {
          final materialMatch =
              project.materialName?.toLowerCase() ==
              _selectedMaterial?.toLowerCase();
          if (!materialMatch) return false;
        }

        // Style filter (you may need to add a style field to Product model)
        // For now, we'll skip this or use a workaround

        return true;
      }).toList();

      _applySorting();
    });
  }

  void _applySorting() {
    switch (_selectedSort) {
      case 'date_desc':
        _filteredProjects.sort(
          (a, b) => (b.completionYear ?? 0).compareTo(a.completionYear ?? 0),
        );
        break;
      case 'date_asc':
        _filteredProjects.sort(
          (a, b) => (a.completionYear ?? 0).compareTo(b.completionYear ?? 0),
        );
        break;
      case 'price_asc':
        _filteredProjects.sort(
          (a, b) => (a.price ?? 0).compareTo(b.price ?? 0),
        );
        break;
      case 'price_desc':
        _filteredProjects.sort(
          (a, b) => (b.price ?? 0).compareTo(a.price ?? 0),
        );
        break;
    }
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey[300]!),
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Portfolio',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categoryOptions.map((category) {
                      return _buildFilterChip(
                        category,
                        _selectedCategory == category,
                        () {
                          setState(() {
                            _selectedCategory = category;
                            _filterProjects();
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Material Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _materialOptions.map((material) {
                  return _buildFilterChip(
                    material,
                    _selectedMaterial == material,
                    () {
                      setState(() {
                        _selectedMaterial = material;
                        _filterProjects();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          // Style Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _styleOptions.map((style) {
                  return _buildFilterChip(style, _selectedStyle == style, () {
                    setState(() {
                      _selectedStyle = style;
                      _filterProjects();
                    });
                  });
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1),

          // Projects Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchPortfolio,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _filteredProjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No portfolio items found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchPortfolio,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: _filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = _filteredProjects[index];
                        return PortfolioCard(
                          project: project,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PortfolioDetailScreen(product: project),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      drawer: const AppDrawerMobile(),
    );
  }
}
