import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:stonecarve_manager_mobile/models/product.dart';
import 'package:stonecarve_manager_mobile/providers/product_provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/providers/favorites_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductProvider _productProvider = ProductProvider();
  final PageController _imagePageController = PageController();

  List<Product> _recommendations = [];
  bool _loadingRecs = true;
  int _currentImageIndex = 0;

  // Lazily resolved full product (with images) if the initial product
  // was passed from the list without embedded images.
  late Product _product;
  bool _loadingProduct = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadProduct();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  /// If the product came from the list it may lack `images`. Re-fetch it.
  Future<void> _loadProduct() async {
    if (_product.id == null) return;
    // Only re-fetch if no images loaded yet
    if (_product.images != null) return;

    setState(() => _loadingProduct = true);

    try {
      final uri = Uri.parse(
        '${BaseProvider.baseUrl}/api/Product/${_product.id}',
      );
      final response = await http.get(
        uri,
        headers: AuthProvider.getAuthHeaders(),
      );
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _product = Product.fromJson(json.decode(response.body));
          _loadingProduct = false;
        });
      } else {
        if (mounted) setState(() => _loadingProduct = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProduct = false);
    }
  }

  Future<void> _loadRecommendations() async {
    if (_product.id == null) {
      setState(() => _loadingRecs = false);
      return;
    }
    try {
      final recs = await _productProvider.fetchRecommendations(
        _product.id!,
        count: 6,
      );
      if (mounted) setState(() => _recommendations = recs);
    } catch (e) {
      print('[ProductDetail] Recommendations error: $e');
    } finally {
      if (mounted) setState(() => _loadingRecs = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_product.id == null) return;
    final favoritesProvider = context.read<FavoritesProvider>();
    final isNow = await favoritesProvider.toggleFavorite(_product.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNow ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(_product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product.name} added to cart'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _product.images ?? [];
    final hasImages = images.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ─── Collapsing App Bar with image carousel ───────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(images, hasImages),
            ),
          ),

          // ─── Product Details ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Favorite
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _product.name ?? 'Unnamed Product',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Consumer<FavoritesProvider>(
                        builder: (context, fav, _) {
                          final isFav = fav.isFavorite(_product.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey[400],
                              size: 28,
                            ),
                            onPressed: _toggleFavorite,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    '\$${_product.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category + Material chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (_product.categoryName != null)
                        _chip(
                          Icons.category_outlined,
                          _product.categoryName!,
                          Colors.blue.shade50,
                          Colors.blue.shade700,
                        ),
                      if (_product.materialName != null)
                        _chip(
                          Icons.layers_outlined,
                          _product.materialName!,
                          Colors.grey.shade100,
                          Colors.grey.shade700,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  if (_product.averageRating != null &&
                      _product.averageRating! > 0) ...[
                    _ratingRow(_product.averageRating!, _product.reviewCount),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (_product.description != null &&
                      _product.description!.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _product.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Specs grid
                  _buildSpecsGrid(),
                  const SizedBox(height: 24),

                  // Add to Cart
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Recommendations ──────────────────────────────────
                  const Text(
                    'You May Also Like',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendations(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildImageCarousel(List<ProductImage> images, bool hasImages) {
    if (!hasImages) {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.image, size: 80, color: Colors.grey[400]),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _imagePageController,
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _currentImageIndex = i),
          itemBuilder: (context, i) {
            return Image.network(
              images[i].imageUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _currentImageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildSpecsGrid() {
    final specs = <Map<String, String>>[];

    if (_product.dimensions != null && _product.dimensions!.isNotEmpty) {
      specs.add({'label': 'Dimensions', 'value': _product.dimensions!});
    }
    if (_product.weight != null) {
      specs.add({'label': 'Weight', 'value': '${_product.weight} kg'});
    }
    if (_product.estimatedDays != null) {
      specs.add({
        'label': 'Est. Delivery',
        'value': '${_product.estimatedDays} days',
      });
    }
    if (_product.stockQuantity != null) {
      specs.add({
        'label': 'In Stock',
        'value': '${_product.stockQuantity} units',
      });
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: specs
            .map(
              (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    s['value']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRecommendations() {
    if (_loadingRecs) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendations.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'No similar products found.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final rec = _recommendations[index];
          return _RecommendationCard(
            product: rec,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: rec),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(double rating, int? reviewCount) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star, color: Colors.amber, size: 18);
          } else if (i < rating) {
            return const Icon(Icons.star_half, color: Colors.amber, size: 18);
          } else {
            return Icon(Icons.star_border, color: Colors.grey[400], size: 18);
          }
        }),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        if (reviewCount != null && reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount reviews)',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Small recommendation card shown in the horizontal scroller
// ──────────────────────────────────────────────────────────────────────────────
class _RecommendationCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _RecommendationCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images?.isNotEmpty == true
        ? product.images!.first.imageUrl
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
