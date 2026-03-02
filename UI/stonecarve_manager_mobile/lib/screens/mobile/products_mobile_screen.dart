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
import 'package:stonecarve_manager_mobile/screens/mobile/product_detail_screen.dart';
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
  List<Product> _productsOriginalOrder = []; // backend order — used by Default sort
  List<Product> _allActiveProducts = []; // master cache of ALL active products (built by infinite scroll, used for client-side search filtering)
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 10;
  String _errorMessage = '';

  // Scroll controller for infinite scroll
  final ScrollController _scrollController = ScrollController();

  // Search and filter state
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'default';
  String _activeSearchQuery = ''; // always mirrors the last submitted search
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
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    // Never paginate while a search is active — search mode uses a single fetch
    if (_activeSearchQuery.isNotEmpty) return;
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    await _fetchProducts(page: _currentPage + 1, append: true);
  }

  Future<void> _fetchProducts({
    String? search,
    int page = 0,
    bool append = false,
  }) async {
    if (!mounted) return;
    final isSearchMode = search != null && search.isNotEmpty;

    if (append) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      if (!append) {
        _activeSearchQuery = search ?? '';
      }

      final queryParams = <String, String>{'productState': 'active'};

      if (isSearchMode) {
        // Search mode: fetch ALL matching products in one request, no pagination.
        // retrieveAll=true tells the backend to skip Skip/Take.
        queryParams['search'] = search!;
        queryParams['retrieveAll'] = 'true';
      } else {
        // Normal mode: paginated infinite scroll
        queryParams['page'] = page.toString();
        queryParams['pageSize'] = _pageSize.toString();
      }

      final uri = Uri.parse(
        '${BaseProvider.baseUrl}/api/Product',
      ).replace(queryParameters: queryParams);

      print('[ProductsMobile] Fetching${isSearchMode ? " (search=\"$search\")" : " page $page"} from: $uri');

      final response = await http.get(uri, headers: AuthProvider.getAuthHeaders());
      print('[ProductsMobile] Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        if (!mounted) return;
        await AuthProvider.handleSessionExpired(context);
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> items = jsonResponse['items'] ?? [];
        final int rawCount = items.length;

        // Always enforce active-only client-side as a safety net
        final fetched = items
            .map((json) => Product.fromJson(json))
            .where((p) => p.productState?.toLowerCase() == 'active')
            .toList();
        print('[ProductsMobile] ${fetched.length} active items fetched (raw: $rawCount)');

        if (!mounted) return;
        setState(() {
          _currentPage = page;

          if (isSearchMode) {
            // Server fetch refreshes the active cache with latest data, then
            // client-side filter is re-applied so typing still drives what's shown.
            // This handles backends that don't honour the search param correctly.
            _allActiveProducts = List.from(fetched);
            _hasMore = false;
            _applyFilters(search); // filters + sorts; sets _products/_productsOriginalOrder
          } else if (append) {
            // Paginated append — deduplicate by ID
            final existingIds = _allActiveProducts.map((p) => p.id).toSet();
            final newItems = fetched.where((p) => !existingIds.contains(p.id)).toList();
            _allActiveProducts.addAll(newItems);
            _productsOriginalOrder.addAll(newItems);
            _products.addAll(newItems);
            _hasMore = newItems.isEmpty ? false : rawCount >= _pageSize;
          } else {
            // First page, no search
            _allActiveProducts = List.from(fetched);
            _productsOriginalOrder = List.from(fetched);
            _products = fetched;
            _hasMore = rawCount >= _pageSize;
          }

          _applySorting();
          _isLoading = false;
          _isLoadingMore = false;
        });

        // Auto-trigger next page if content doesn't fill the viewport
        if (_hasMore && !isSearchMode) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (_scrollController.hasClients &&
                _scrollController.position.maxScrollExtent < 100) {
              _loadMore();
            }
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load products (${response.statusCode})';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('[ProductsMobile] Error: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  /// Instantly filters the master active products cache client-side.
  /// Called immediately on every keystroke for responsive feedback.
  void _applyFilters(String? query) {
    List<Product> filtered = List.from(_allActiveProducts);
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((p) {
        return (p.name?.toLowerCase().contains(q) ?? false) ||
            (p.description?.toLowerCase().contains(q) ?? false) ||
            (p.categoryName?.toLowerCase().contains(q) ?? false) ||
            (p.materialName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    _productsOriginalOrder = List.from(filtered);
    _products = filtered;
    _applySorting();
  }

  /// Search handler:
  /// 1. Instantly applies client-side filter on _allActiveProducts for immediate feedback.
  /// 2. Debounces a server-side call — uses retrieveAll=true (no pagination) so
  ///    the full result set is returned and there are no infinite-scroll issues.
  /// 3. Clearing the search restores normal infinite scroll from the cache.
  void _onSearchChanged(String value) {
    final query = value.trim();

    // Step 1: instant client-side filter
    setState(() {
      _activeSearchQuery = query;
      if (query.isEmpty) {
        // Restore the full cached list; resume infinite scroll
        _productsOriginalOrder = List.from(_allActiveProducts);
        _products = List.from(_allActiveProducts);
        _hasMore = _allActiveProducts.length >= _pageSize;
        _applySorting();
      } else {
        _applyFilters(query);
        _hasMore = false; // no infinite scroll while searching
      }
    });

    // Step 2: debounced server call for authoritative results
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        // Clearing search: only refetch from server if cache is empty
        if (_allActiveProducts.isEmpty) {
          setState(() {
            _currentPage = 0;
            _hasMore = true;
          });
          _fetchProducts();
        }
      } else {
        _fetchProducts(search: query);
      }
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
        // Restore backend insertion order
        _products = List.from(_productsOriginalOrder);
        break;
    }
  }

  /// Re-applies sort (and search filter if active) when sort option changes.
  void _onSortChanged(String value) {
    setState(() {
      _selectedSort = value;
      if (_activeSearchQuery.isNotEmpty) {
        _applyFilters(_activeSearchQuery); // re-filter + sort
      } else {
        _applySorting();
      }
    });
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

    // Clear any existing snackbars to prevent stacking/blocking
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 3),
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
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (_, value, __) => value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
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
                        _onSortChanged(option['value']);
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
                            search: _activeSearchQuery.isEmpty
                                ? null
                                : _activeSearchQuery,
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
                    onRefresh: () {
                      if (_activeSearchQuery.isNotEmpty) {
                        // Refresh search results
                        return _fetchProducts(search: _activeSearchQuery);
                      }
                      // Refresh normal paginated list from scratch
                      setState(() {
                        _currentPage = 0;
                        _hasMore = true;
                        _allActiveProducts = [];
                        _products = [];
                        _productsOriginalOrder = [];
                      });
                      return _fetchProducts();
                    },
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favoritesProvider, child) {
                        final itemCount =
                            _products.length + (_isLoadingMore ? 1 : 0);
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: itemCount,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            // Loading indicator at the bottom
                            if (index == _products.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final product = _products[index];
                            final isFavorite = favoritesProvider.isFavorite(
                              product.id,
                            );

                            return ProductCard(
                              product: product,
                              isFavorite: isFavorite,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
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
