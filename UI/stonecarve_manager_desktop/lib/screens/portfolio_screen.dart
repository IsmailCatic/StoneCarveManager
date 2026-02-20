import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/screens/add_product_screen.dart';
import 'package:stonecarve_manager_flutter/screens/product_form_screen.dart';
import 'package:stonecarve_manager_flutter/widgets/app_drawer.dart';
// Import your models and providers
import '../models/product.dart';
import '../providers/product_provider.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late Future<List<Product>> _portfolioProducts;

  @override
  void initState() {
    super.initState();
    _portfolioProducts = ProductProvider().fetchPortfolioProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              );
              if (result == true) {
                setState(() {
                  _portfolioProducts = ProductProvider()
                      .fetchPortfolioProducts();
                });
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/portfolio'),
      body: FutureBuilder<List<Product>>(
        future: _portfolioProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Portfolio is empty.'));
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: product.images != null && product.images!.isNotEmpty
                      ? Image.network(
                          product.images!.first.imageUrl ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 60),
                  title: Text(product.name ?? ''),
                  subtitle: Text(product.description ?? ''),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductFormScreen(
                              product: product,
                              isEdit: true,
                            ),
                          ),
                        );
                        if (result == true) {
                          setState(() {
                            _portfolioProducts = ProductProvider()
                                .fetchPortfolioProducts();
                          });
                        }
                      } else if (value == 'delete') {
                        // TODO: Delete product
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Show product details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
