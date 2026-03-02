import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stonecarve_manager_mobile/models/product.dart';
import 'package:stonecarve_manager_mobile/providers/favorites_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/product_card.dart';
import 'package:stonecarve_manager_mobile/widgets/mobile/app_drawer_mobile.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/cart_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  /// Loads favorite products from GET /api/Favorite — returns only this user's favorites
  Future<void> _fetchFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url = '${BaseProvider.baseUrl}/api/Favorite';
      final response = await http.get(
        Uri.parse(url),
        headers: AuthProvider.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = json.decode(response.body);
        setState(() {
          _favoriteProducts = items
              .where((j) => j['product'] != null)
              .map(
                (j) => Product.fromJson(j['product'] as Map<String, dynamic>),
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load favorites (${response.statusCode})';
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

  Future<void> _toggleFavorite(int productId) async {
    final favoritesProvider = context.read<FavoritesProvider>();
    final isNowFavorite = await favoritesProvider.toggleFavorite(productId);

    if (!mounted) return;

    // Re-fetch the list from backend to reflect the change
    await _fetchFavorites();

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
              'My Favorites',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                return Text(
                  '${favoritesProvider.favoriteCount} items',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _fetchFavorites,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Consumer<FavoritesProvider>(
              builder: (context, favoritesProvider, child) {
                final favoriteProducts = _favoriteProducts;

                if (favoriteProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Favorites Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start adding products to your favorites',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/products',
                            );
                          },
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('Browse Products'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Clear all button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${favoriteProducts.length} Products',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              // Confirm before clearing
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Clear All Favorites?'),
                                  content: const Text(
                                    'Are you sure you want to remove all products from your favorites?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Clear All',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                await favoritesProvider.clearAllFavorites();
                                if (mounted) {
                                  // Re-fetch to update the list
                                  await _fetchFavorites();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All favorites cleared'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Clear All'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Products list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchFavorites,
                        child: ListView.builder(
                          itemCount: favoriteProducts.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final product = favoriteProducts[index];

                            return ProductCard(
                              product: product,
                              isFavorite: favoritesProvider.isFavorite(
                                product.id,
                              ),
                              onTap: () {
                                // Navigate to product details
                              },
                              onToggleFavorite: () =>
                                  _toggleFavorite(product.id!),
                              onAddToCart: () => _addToCart(product),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      drawer: const AppDrawerMobile(),
    );
  }
}
