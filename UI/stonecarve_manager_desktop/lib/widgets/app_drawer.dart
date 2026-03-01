import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/providers/profile_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/user_profile_avatar.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({Key? key, required this.currentRoute}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final ProfileProvider _profileProvider = ProfileProvider();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (AuthProvider.isAuthenticated()) {
      await _profileProvider.fetchCurrentUserProfile();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _profileProvider.currentUser;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.architecture,
                      size: 48,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    if (!_isLoading && currentUser != null)
                      UserProfileAvatar(
                        imageUrl: currentUser.profileImageUrl,
                        firstName: currentUser.firstName,
                        lastName: currentUser.lastName,
                        radius: 24,
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'StoneCarve Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (!_isLoading && currentUser != null)
                      Text(
                        currentUser.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      const Text(
                        'Admin Dashboard',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.receipt_long,
            title: 'Orders',
            route: '/orders',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/orders'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: _DrawerItem(
              icon: Icons.design_services,
              title: 'Custom Orders',
              route: '/custom-orders',
              currentRoute: widget.currentRoute,
              onTap: () => _navigateTo(context, '/custom-orders'),
            ),
          ),
          // My Orders - visible only for Employee and Admin
          if (AuthProvider.isEmployee || AuthProvider.isAdmin)
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: _DrawerItem(
                icon: Icons.assignment,
                title: 'My Orders',
                route: '/my-orders',
                currentRoute: widget.currentRoute,
                onTap: () => _navigateTo(context, '/my-orders'),
              ),
            ),
          _DrawerItem(
            icon: Icons.inventory,
            title: 'Products',
            route: '/products',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/products'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: _DrawerItem(
              icon: Icons.assignment_turned_in,
              title: 'Custom Order Products',
              route: '/custom-order-products',
              currentRoute: widget.currentRoute,
              onTap: () => _navigateTo(context, '/custom-order-products'),
            ),
          ),
          _DrawerItem(
            icon: Icons.build_circle,
            title: 'Services',
            route: '/services',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/services'),
          ),
          _DrawerItem(
            icon: Icons.terrain,
            title: 'Materials',
            route: '/materials',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/materials'),
          ),
          _DrawerItem(
            icon: Icons.category,
            title: 'Categories',
            route: '/categories',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/categories'),
          ),
          // Users - visible only for Admins
          if (AuthProvider.isAdmin)
            _DrawerItem(
              icon: Icons.people,
              title: 'Users',
              route: '/users',
              currentRoute: widget.currentRoute,
              onTap: () => _navigateTo(context, '/users'),
            ),
          _DrawerItem(
            icon: Icons.workspaces,
            title: 'Portfolio',
            route: '/portfolio',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/portfolio'),
          ),
          _DrawerItem(
            icon: Icons.article,
            title: 'Blog Posts',
            route: '/blog',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/blog'),
          ),
          // Analytics - visible only for Admins
          if (AuthProvider.isAdmin)
            _DrawerItem(
              icon: Icons.analytics,
              title: 'Analytics',
              route: '/analytics',
              currentRoute: widget.currentRoute,
              onTap: () => _navigateTo(context, '/analytics'),
            ),
          // Payments - visible only for Admins
          if (AuthProvider.isAdmin)
            _DrawerItem(
              icon: Icons.payment,
              title: 'Payments',
              route: '/payments',
              currentRoute: widget.currentRoute,
              onTap: () => _navigateTo(context, '/payments'),
            ),
          _DrawerItem(
            icon: Icons.rate_review,
            title: 'Reviews',
            route: '/reviews',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/reviews'),
          ),
          _DrawerItem(
            icon: Icons.help_outline,
            title: 'FAQ',
            route: '/faq',
            currentRoute: widget.currentRoute,
            onTap: () => _navigateTo(context, '/faq'),
          ),
          if (AuthProvider.isAdmin)
            _DrawerItem(
              icon: Icons.admin_panel_settings,
              title: 'CRUD',
              route: '/crud',
              currentRoute: widget.currentRoute,
              onTap: () => _navigateTo(context, '/crud'),
            ),
          const Divider(height: 32, thickness: 1),
          // My Profile with user avatar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: widget.currentRoute == '/profile'
                  ? Colors.blue.shade50
                  : null,
            ),
            child: ListTile(
              leading: currentUser != null
                  ? UserProfileAvatar(
                      imageUrl: currentUser.profileImageUrl,
                      firstName: currentUser.firstName,
                      lastName: currentUser.lastName,
                      radius: 18,
                    )
                  : const Icon(Icons.account_circle, color: Colors.grey),
              title: Text(
                'My Profile',
                style: TextStyle(
                  color: widget.currentRoute == '/profile'
                      ? Colors.blue.shade700
                      : Colors.grey.shade900,
                  fontWeight: widget.currentRoute == '/profile'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: widget.currentRoute == '/profile',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () => _navigateTo(context, '/profile'),
            ),
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
    if (widget.currentRoute == route) return;

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
