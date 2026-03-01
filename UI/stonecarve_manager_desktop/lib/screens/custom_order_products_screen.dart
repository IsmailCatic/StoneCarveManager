import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/product.dart';
import 'package:stonecarve_manager_flutter/providers/project_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/product_state_chip.dart';
import 'package:stonecarve_manager_flutter/widgets/product_action_buttons.dart';
import 'package:stonecarve_manager_flutter/widgets/optimized_image.dart';

class CustomOrderProductsScreen extends StatefulWidget {
  const CustomOrderProductsScreen({super.key});

  @override
  State<CustomOrderProductsScreen> createState() =>
      _CustomOrderProductsScreenState();
}

class _CustomOrderProductsScreenState extends State<CustomOrderProductsScreen> {
  final ProductProvider _productProvider = ProductProvider();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _products = [];
      });
      final products = await _productProvider.getCustomOrderProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  void _showStateManagementDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Manage Product State'),
              const SizedBox(height: 8),
              Text(
                product.name ?? 'Unknown Product',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: ProductActionButtons(
              productId: product.id!,
              currentState: product.productState ?? 'custom_order',
              onActionCompleted: () {
                Navigator.of(context).pop();
                _loadProducts();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Custom Order Products',
      currentRoute: '/custom-order-products',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custom Order Products',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                'The products in this screen are custom order products that aren\'t available to customers usually. By changing the state, we can add them to the portfolio to be displayed, or later on to the active state like regular products and offer them as normal stock products.',
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                  ? const Center(child: Text('No custom order products found'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      cacheExtent: 200,
                      addAutomaticKeepAlives: true,
                      addRepaintBoundaries: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1400
                            ? 4
                            : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        String? displayImageUrl;
                        if (product.images != null &&
                            product.images!.isNotEmpty) {
                          final primaryImage = product.images!.firstWhere(
                            (img) => img.isPrimary == true,
                            orElse: () => product.images!.first,
                          );
                          displayImageUrl = primaryImage.imageUrl;
                        }
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _showStateManagementDialog(product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 7,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.grey[100],
                                        child:
                                            displayImageUrl != null &&
                                                displayImageUrl.isNotEmpty
                                            ? OptimizedImage(
                                                imageUrl: displayImageUrl,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                errorWidget: Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                Icons.image_not_supported,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: ProductStateChip(
                                          state: product.productState,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name ?? 'Unknown Product',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          product.description ??
                                              'No description',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[700],
                                                fontSize: 16,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    product.stockQuantity !=
                                                            null &&
                                                        product.stockQuantity! >
                                                            0
                                                    ? Colors.green[50]
                                                    : Colors.red[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Stock: ${product.stockQuantity ?? 0}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      product.stockQuantity !=
                                                              null &&
                                                          product.stockQuantity! >
                                                              0
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                                ),
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
