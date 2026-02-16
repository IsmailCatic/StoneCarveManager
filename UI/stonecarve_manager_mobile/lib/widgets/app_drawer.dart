import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';

// NOTE: This drawer is for Desktop Admin Dashboard only.
// For mobile app, use AppDrawerMobile instead.
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
          // Desktop-only routes (not available in mobile app)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'This drawer is for desktop admin dashboard.\nMobile app uses AppDrawerMobile instead.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 32, thickness: 1),
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

  void _logout(BuildContext context) async {
    // Clear auth state
    await AuthProvider.logout();

    // Navigate to login and clear all routes
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
