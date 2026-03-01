import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/product_card.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/app_drawer_mobile.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/providers/favorites_provider.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/cart_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductsMobileScreen extends StatefulWidget {
  const ProductsMobileScreen({super.key});

  @override
  State<ProductsMobileScreen> createState() => _ProductsMobileScreenState();
}

class _ProductsMobileScreenState extends State<ProductsMobileScreen>
    with AutomaticKeepAliveClientMixin {
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'default';
  Timer? _searchDebounce;

  // Filter options
  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Default', 'value': 'default'},
    {'label': 'A-Z', 'value': 'name_asc'},
    {'label': '\$ → \$\$', 'value': 'price_asc'},
    {'label': '\$\$ → \$', 'value': 'price_desc'},
  ];

  @override
  bool get wantKeepAlive => true; // Preserve state when switching tabs

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Fetch products once on initialization
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts({String? search}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Build query params — same pattern as desktop app
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '${BaseProvider.baseUrl}/api/Product',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('[ProductsMobile] Fetching from: $uri');

      final response = await http.get(
        uri,
        headers: AuthProvider.getAuthHeaders(),
      );

      print('[ProductsMobile] Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        // Token expired or invalid — clear session and redirect to login
        if (!mounted) return;
        await AuthProvider.handleSessionExpired(context);
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['items'] ?? [];
        print('[ProductsMobile] Loaded ${items.length} products');
        if (!mounted) return;
        setState(() {
          // Show only products with productState == 'active'
          _products = items
              .map((json) => Product.fromJson(json))
              .where(
                (product) => product.productState?.toLowerCase() == 'active',
              )
              .toList();
          _applySorting();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load products (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[ProductsMobile] Error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Debounced handler — matching desktop users_screen.dart pattern
  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      _fetchProducts(search: query.isEmpty ? null : query);
    });
  }

  void _applySorting() {
    switch (_selectedSort) {
      case 'name_asc':
        _products.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case 'price_asc':
        _products.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'price_desc':
        _products.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      default:
        // Keep order returned by backend
        break;
    }
  }

  Future<void> _toggleFavorite(int productId) async {
    final favoritesProvider = context.read<FavoritesProvider>();
    final isNowFavorite = await favoritesProvider.toggleFavorite(productId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFavorite ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart(Product product) {
    if (product.id == null) return;

    context.read<CartProvider>().addItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'StoneCarve Manager',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'All Aisles/products',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sortOptions.map((option) {
                  final isSelected = _selectedSort == option['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(option['label']),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSort = option['value'];
                          _applySorting();
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1),

          // Products List
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
                          onPressed: () => _fetchProducts(
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _fetchProducts(
                      search: _searchController.text.trim().isEmpty
                          ? null
                          : _searchController.text.trim(),
                    ),
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, child) {
                        return ListView.builder(
                          itemCount: _products.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final isFavorite = favoritesProvider.isFavorite(
                              product.id,
                            );

                            return ProductCard(
                              product: product,
                              isFavorite: isFavorite,
                              onTap: () {
                                // Navigate to product details
                              },
                              onToggleFavorite: () =>
                                  _toggleFavorite(product.id!),
                              onAddToCart: () => _addToCart(product),
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
