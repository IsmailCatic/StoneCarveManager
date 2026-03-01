import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/layouts/master_screen.dart';
import 'package:stonecarve_manager_flutter/models/product.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/models/material.dart';
import 'package:stonecarve_manager_flutter/providers/project_provider.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/product_state_chip.dart';
import 'package:stonecarve_manager_flutter/widgets/product_action_buttons.dart';
import 'package:stonecarve_manager_flutter/screens/add_product_screen.dart';
import 'package:stonecarve_manager_flutter/widgets/optimized_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stonecarve_manager_flutter/providers/product_provider.dart'
    as prod_provider;

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductProvider _productProvider = ProductProvider();
  final prod_provider.ProductProvider _productProviderWithImages =
      prod_provider.ProductProvider();
  List<Product> _products = [];
  List<Category> _categories = [];
  List<StoneMaterial> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final categories = await CategoryProvider().getActiveCategories();
      final materials = await MaterialProvider().getAvailableMaterials();
      setState(() {
        _categories = categories;
        _materials = materials;
      });
    } catch (e) {
      print('Error loading dropdown data: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _products = [];
      });

      // Backend filtering: exclude custom_order products using ProductStateExclude filter
      final products = await _productProvider.getRegularProducts();

      print(
        '[ProductsScreen] Loaded regular products: ${products.length} items',
      );

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

  Future<void> _pickAndUploadImage(Product product) async {
    if (product.id == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        await _productProviderWithImages.uploadProductImage(
          product.id!,
          pickedFile.path,
        );
        // Reload data immediately to show the new image
        await _loadProducts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product image uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload product image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteProductImage(int productId, int imageId) async {
    try {
      await _productProviderWithImages.deleteProductImage(productId, imageId);
      // Reload data immediately to reflect the deletion
      await _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product image removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setPrimaryImage(int productId, int imageId) async {
    try {
      await _productProviderWithImages.setPrimaryImage(productId, imageId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primary product image set successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set primary image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageManagementDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Images: ${product.name}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upload new image button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(product);
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Upload New Image'),
              ),
              const SizedBox(height: 16),
              // Existing images
              if (product.images != null && product.images!.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Existing Images:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap an image to set it as primary (shown first)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: product.images!.length,
                    itemBuilder: (context, index) {
                      final image = product.images![index];
                      final isPrimary = image.isPrimary == true;
                      return Stack(
                        children: [
                          InkWell(
                            onTap: () async {
                              if (!isPrimary &&
                                  product.id != null &&
                                  image.id != null) {
                                Navigator.pop(context);
                                await _setPrimaryImage(product.id!, image.id!);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: isPrimary
                                    ? Border.all(color: Colors.green, width: 3)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: OptimizedImage(
                                  imageUrl: image.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorWidget: Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isPrimary)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PRIMARY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.all(4),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Image'),
                                    content: const Text(
                                      'Are you sure you want to delete this image?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true &&
                                    product.id != null &&
                                    image.id != null) {
                                  Navigator.pop(context);
                                  await _deleteProductImage(
                                    product.id!,
                                    image.id!,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ] else
                const Text('No images uploaded yet'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                      padding: const EdgeInsets.all(16),
                      // Performance optimizations
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
                        // Get primary image or first image
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
                            onTap: () => _showEditProductDialog(product),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product image at the top (70% of card height)
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
                                      // State chip overlay
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
                                // Product details (30% of card height)
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
                                // Action buttons
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      top: BorderSide(color: Colors.grey[200]!),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.swap_horiz,
                                          size: 20,
                                          color: Colors.blue[700],
                                        ),
                                        tooltip: 'Manage State',
                                        onPressed: () =>
                                            _showStateManagementDialog(product),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: Colors.grey[300],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.orange[700],
                                        ),
                                        tooltip: 'Edit',
                                        onPressed: () =>
                                            _showEditProductDialog(product),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: Colors.grey[300],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.image,
                                          size: 20,
                                          color: Colors.purple[700],
                                        ),
                                        tooltip: 'Manage Images',
                                        onPressed: () =>
                                            _showImageManagementDialog(product),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 24,
                                        color: Colors.grey[300],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red[700],
                                        ),
                                        tooltip: 'Delete',
                                        onPressed: () =>
                                            _confirmDeleteProduct(product),
                                      ),
                                    ],
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

    // Normalize 0 to null and validate IDs exist in dropdown lists
    int? selectedCategoryId =
        (product?.categoryId == null || product?.categoryId == 0)
        ? null
        : product?.categoryId;
    // Check if category exists in the list, if not set to null
    if (selectedCategoryId != null &&
        !_categories.any((cat) => cat.id == selectedCategoryId)) {
      selectedCategoryId = null;
    }

    int? selectedMaterialId =
        (product?.materialId == null || product?.materialId == 0)
        ? null
        : product?.materialId;
    // Check if material exists in the list, if not set to null
    if (selectedMaterialId != null &&
        !_materials.any((mat) => mat.id == selectedMaterialId)) {
      selectedMaterialId = null;
    }

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
                    DropdownButtonFormField<int?>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Not assigned'),
                        ),
                        ...{
                          for (var cat in _categories)
                            if (cat.id != null && cat.id! > 0) cat.id: cat,
                        }.values.map(
                          (cat) => DropdownMenuItem<int?>(
                            value: cat.id,
                            child: Text(cat.name ?? ''),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int?>(
                      value: selectedMaterialId,
                      decoration: const InputDecoration(
                        labelText: 'Material (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Not assigned'),
                        ),
                        ...{
                          for (var mat in _materials)
                            if (mat.id != null && mat.id! > 0) mat.id: mat,
                        }.values.map(
                          (mat) => DropdownMenuItem<int?>(
                            value: mat.id,
                            child: Text(mat.name ?? ''),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedMaterialId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // ...removed isActive checkbox...
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
                    // Basic field validation
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
                      categoryId: selectedCategoryId,
                      materialId: selectedMaterialId,
                      // If editing an existing product, keep other fields
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
                            content: Text('Product created successfully'),
                            backgroundColor: Colors.green,
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
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      _loadProducts();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save product: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
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
                      content: Text('Product removed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadProducts();
                } catch (e) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete product: $e'),
                      backgroundColor: Colors.red,
                    ),
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
