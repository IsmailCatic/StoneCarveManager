import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/product.dart';
import 'package:stonecarve_manager_flutter/providers/project_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/product_state_chip.dart';
import 'package:stonecarve_manager_flutter/widgets/product_action_buttons.dart';
import 'package:stonecarve_manager_flutter/screens/add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
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
      });

      final result = await _productProvider.get();
      setState(() {
        _products = result.items ?? [];
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Products',
      currentRoute: '/products',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddProductDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('New Product'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final latestImageUrl =
                            (product.images != null &&
                                product.images!.isNotEmpty)
                            ? product.images!.last.imageUrl
                            : null;
                        return Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image at the top
                                SizedBox(
                                  height: 100,
                                  width: double.infinity,
                                  child:
                                      latestImageUrl != null &&
                                          latestImageUrl.isNotEmpty
                                      ? Image.network(
                                          latestImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.broken_image,
                                                    size: 60,
                                                  ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 60,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.inventory, size: 40),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
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
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ProductStateChip(state: product.productState),
                                const SizedBox(height: 4),
                                Text(
                                  product.description ?? 'No description',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: \$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                                ),
                                Text('Stock: ${product.stockQuantity ?? 0}'),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.swap_horiz),
                                      tooltip: 'Manage State',
                                      onPressed: () =>
                                          _showStateManagementDialog(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit',
                                      onPressed: () =>
                                          _showEditProductDialog(product),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Delete',
                                      onPressed: () =>
                                          _confirmDeleteProduct(product),
                                    ),
                                  ],
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

  Future<void> _showAddProductDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _showEditProductDialog(Product product) {
    _showProductDialog(product);
  }

  void _showProductDialog(Product? product) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: product?.stockQuantity?.toString() ?? '',
    );
    final dimensionsController = TextEditingController(
      text: product?.dimensions ?? '',
    );
    final weightController = TextEditingController(
      text: product?.weight?.toString() ?? '',
    );
    final estimatedDaysController = TextEditingController(
      text: product?.estimatedDays?.toString() ?? '',
    );
    final categoryIdController = TextEditingController(
      text: product?.categoryId?.toString() ?? '',
    );
    final materialIdController = TextEditingController(
      text: product?.materialId?.toString() ?? '',
    );

    bool isActive = product?.isActive ?? true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(product == null ? 'Add New Product' : 'Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price *'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: dimensionsController,
                      decoration: const InputDecoration(
                        labelText: 'Dimensions',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: estimatedDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Days',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryIdController,
                      decoration: const InputDecoration(
                        labelText: 'Category ID',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: materialIdController,
                      decoration: const InputDecoration(
                        labelText: 'Material ID',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Is Active'),
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in required fields'),
                        ),
                      );
                      return;
                    }

                    final newProduct = Product(
                      id: product?.id,
                      name: nameController.text,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      price: double.tryParse(priceController.text),
                      stockQuantity: int.tryParse(stockController.text) ?? 0,
                      dimensions: dimensionsController.text.isEmpty
                          ? null
                          : dimensionsController.text,
                      weight: double.tryParse(weightController.text),
                      estimatedDays: int.tryParse(estimatedDaysController.text),
                      categoryId: int.tryParse(categoryIdController.text),
                      materialId: int.tryParse(materialIdController.text),
                      isActive: isActive,
                      // Ako editujemo postojeći product, zadržavamo ostala polja
                      createdAt: product?.createdAt,
                      updatedAt: product?.updatedAt,
                      isInPortfolio: product?.isInPortfolio,
                      viewCount: product?.viewCount,
                      categoryName: product?.categoryName,
                      materialName: product?.materialName,
                      productState: product?.productState,
                      reviewCount: product?.reviewCount,
                      averageRating: product?.averageRating,
                      category: product?.category,
                      material: product?.material,
                      images: product?.images,
                      reviews: product?.reviews,
                    );

                    try {
                      if (product == null) {
                        await _productProvider.createProduct(newProduct);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product added successfully'),
                          ),
                        );
                      } else {
                        await _productProvider.updateProduct(
                          product.id!,
                          newProduct,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product updated successfully'),
                          ),
                        );
                      }
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      _loadProducts();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: Text(product == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );
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
              currentState: product.productState ?? 'draft',
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

  void _confirmDeleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _productProvider.deleteProduct(product.id!);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully'),
                    ),
                  );
                  _loadProducts();
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStateColor(String? state) {
    switch (state?.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'custom_order':
        return Colors.orange;
      case 'out_of_stock':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
