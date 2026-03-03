import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class AppDrawerMobile extends StatelessWidget {
  const AppDrawerMobile({Key? key}) : super(key: key);

  String _getInitials(String? username) {
    if (username == null || username.isEmpty) return 'U';
    final parts = username.split('@')[0].split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final username = AuthProvider.username ?? 'Guest';
    final userRole = AuthProvider.roles?.isNotEmpty == true
        ? AuthProvider.roles!.first
        : 'Customer';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Profile Header (clickable to go to profile)
          InkWell(
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushNamed(context, '/profile');
            },
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final profileImageUrl =
                    profileProvider.currentUser?.profileImageUrl;

                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              profileImageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                _getInitials(username),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            _getInitials(username),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                  ),
                  accountName: Text(
                    username.split('@')[0], // Show part before @
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Row(
                    children: [
                      Icon(
                        userRole.toLowerCase() == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.account_circle,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(userRole),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                );
              },
            ),
          ),

          // Main navigation items
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Shop'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.build_circle),
            title: const Text('Services'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/services');
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Portfolio'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/portfolio');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/orders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('My Payments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/payments');
            },
          ),
          const Divider(),

          // Secondary actions
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Shopping Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('My Favorites'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Reviews & Ratings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reviews');
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Blog'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/blog');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/faq');
            },
          ),

          const Divider(),

          // Special actions
          ListTile(
            leading: const Icon(Icons.design_services, color: Colors.blue),
            title: const Text(
              'Custom Order',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/custom-order');
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              // Clear any lingering SnackBars so they don't persist on the login screen
              ScaffoldMessenger.of(context).clearSnackBars();
              await AuthProvider.logout();
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
