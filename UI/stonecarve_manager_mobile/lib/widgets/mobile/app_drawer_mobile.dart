import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';

class AppDrawerMobile extends StatelessWidget {
  const AppDrawerMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  'StoneCarve Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mobile App',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Navigate to home, removing all routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Products'),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/products') {
                Navigator.pushNamed(context, '/products');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Shopping Cart'),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/cart') {
                Navigator.pushNamed(context, '/cart');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('My Favorites'),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/favorites') {
                Navigator.pushNamed(context, '/favorites');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Reviews & Ratings'),
            onTap: () {
              // Check current route before closing drawer
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context); // Close drawer

              // Only navigate if not already on reviews screen
              if (currentRoute != '/reviews') {
                Navigator.pushNamed(context, '/reviews');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Blog'),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/blog') {
                Navigator.pushNamed(context, '/blog');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('My Orders'),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/orders') {
                Navigator.pushNamed(context, '/orders');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Portfolio'),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/portfolio') {
                Navigator.pushNamed(context, '/portfolio');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.design_services, color: Colors.blue),
            title: const Text(
              'Custom Order',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            onTap: () {
              final currentRoute = ModalRoute.of(context)?.settings.name;
              Navigator.pop(context);

              if (currentRoute != '/custom-order') {
                Navigator.pushNamed(context, '/custom-order');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.orange),
            title: const Text('API Test'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/api-test');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context); // Close drawer

              // Clear auth state
              await AuthProvider.logout();

              // Navigate to login and clear all routes
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
