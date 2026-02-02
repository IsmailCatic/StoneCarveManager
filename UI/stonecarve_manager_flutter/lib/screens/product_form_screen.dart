import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/models/category.dart';
import 'package:stonecarve_manager_flutter/models/material.dart';
import 'package:stonecarve_manager_flutter/providers/category_provider.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import 'package:stonecarve_manager_flutter/providers/product_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stonecarve_manager_flutter/providers/stone_provider.dart';
import '../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final bool isEdit;

  const ProductFormScreen({Key? key, this.product, this.isEdit = false})
    : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dimensionsController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _estimatedDaysController;
  late TextEditingController _weightController;

  List<Category> _categories = [];
  List<StoneMaterial> _materials = [];
  int? _selectedCategoryId;
  int? _selectedMaterialId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _dimensionsController = TextEditingController(
      text: widget.product?.dimensions ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity?.toString() ?? '',
    );
    _estimatedDaysController = TextEditingController(
      text: widget.product?.estimatedDays?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.product?.weight?.toString() ?? '',
    );

    _selectedCategoryId = widget.product?.categoryId;
    _selectedMaterialId = widget.product?.materialId;
    _images = List<ProductImage>.from(widget.product?.images ?? []);
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final categories = await CategoryProvider().getActiveCategories();
    final materials = await MaterialProvider().getAvailableMaterials();
    setState(() {
      _categories = categories;
      _materials = materials;
    });
  }

  Future<void> _deleteImage(int? productId, int imageId) async {
    if (productId != null) {
      try {
        await ProductProvider().deleteProductImage(productId, imageId);
        setState(() {
          _images.removeWhere((img) => img.id == imageId);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri brisanju slike: $e')),
        );
      }
    }
  }

  List<ProductImage> _images = [];

  Future<void> _pickAndUploadImage(int? productId) async {
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spremite rad prije dodavanja slike.')),
      );
      return;
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        final uploadedImage = await ProductProvider().uploadProductImage(
          productId,
          pickedFile.path,
        );
        setState(() {
          _images.add(uploadedImage);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri dodavanju slike: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dimensionsController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _estimatedDaysController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        dimensions: _dimensionsController.text,
        price: double.tryParse(_priceController.text),
        stockQuantity: int.tryParse(_stockController.text),
        estimatedDays: int.tryParse(_estimatedDaysController.text),
        weight: double.tryParse(_weightController.text),
        categoryId: _selectedCategoryId,
        materialId: _selectedMaterialId,
        isInPortfolio: true,
      );
      try {
        if (widget.isEdit && product.id != null) {
          await ProductProvider().updateProduct(product.id!, product);
        } else {
          final newProduct = await ProductProvider().addProduct(product);
          // After adding, allow image upload
          setState(() {
            _images = newProduct.images ?? [];
          });
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Greška: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Uredi rad' : 'Dodaj novi rad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Naziv rada'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Unesite naziv' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis rada'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _dimensionsController,
                decoration: const InputDecoration(labelText: 'Dimenzije'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Cijena'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Količina na stanju',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _estimatedDaysController,
                decoration: const InputDecoration(
                  labelText: 'Procijenjeni dani izrade',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Težina (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Kategorija'),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Odaberite kategoriju' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _selectedMaterialId,
                decoration: const InputDecoration(labelText: 'Materijal'),
                items: _materials
                    .map(
                      (mat) => DropdownMenuItem(
                        value: mat.id,
                        child: Text(mat.name ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMaterialId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Odaberite materijal' : null,
              ),
              const SizedBox(height: 24),
              Text('Slike:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _images.length) {
                      final img = _images[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: [
                            img.imageUrl != null && img.imageUrl!.isNotEmpty
                                ? Image.network(
                                    img.imageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey,
                                  ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Obriši sliku'),
                                      content: const Text('Jeste li sigurni da želite obrisati ovu sliku?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Ne'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Da'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final success = await ProductProvider().deleteProductImage(widget.product?.id ?? 0, img.id!);
                                    if (success) {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Slika obrisana!')),
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Greška pri brisanju slike!')),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Add image button
                      return GestureDetector(
                        onTap: () async {
                          await _pickAndUploadImage(widget.product?.id);
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.add_a_photo),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.isEdit ? 'Spremi promjene' : 'Dodaj rad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
