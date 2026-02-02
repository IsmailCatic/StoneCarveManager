import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.purple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.architecture, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'StoneCarve Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            route: '/',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/'),
          ),
          _DrawerItem(
            icon: Icons.receipt_long,
            title: 'Orders',
            route: '/orders',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/orders'),
          ),
          _DrawerItem(
            icon: Icons.inventory,
            title: 'Products',
            route: '/products',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/products'),
          ),
          _DrawerItem(
            icon: Icons.terrain,
            title: 'Materials',
            route: '/materials',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/materials'),
          ),
          _DrawerItem(
            icon: Icons.category,
            title: 'Categories',
            route: '/categories',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/categories'),
          ),
          _DrawerItem(
            icon: Icons.people,
            title: 'Users',
            route: '/users',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/users'),
          ),
          _DrawerItem(
            icon: Icons.workspaces,
            title: 'Portfolio',
            route: '/portfolio',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/portfolio'),
          ),
          _DrawerItem(
            icon: Icons.article,
            title: 'Blog Posts',
            route: '/blog',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/blog'),
          ),
          _DrawerItem(
            icon: Icons.analytics,
            title: 'Analytics',
            route: '/analytics',
            currentRoute: currentRoute,
            onTap: () => _navigateTo(context, '/analytics'),
          ),
          const Divider(height: 32, thickness: 1),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade400)),
            onTap: () {
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    // Close drawer
    Navigator.pop(context);

    // Don't navigate if already on this route
    if (currentRoute == route) return;

    // Navigate to the route
    Navigator.pushReplacementNamed(context, route);
  }

  void _logout(BuildContext context) {
    // Clear auth state
    AuthProvider.logout();

    // Navigate to login and clear all routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.shade50 : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade900,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
