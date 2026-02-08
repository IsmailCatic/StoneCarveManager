import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/screens/orders_screen.dart';
import 'package:stonecarve_manager_flutter/screens/products_screen.dart';
import 'package:stonecarve_manager_flutter/screens/materials_screen.dart';
import 'package:stonecarve_manager_flutter/screens/categories_screen.dart';
import 'package:stonecarve_manager_flutter/screens/users_screen.dart';
import 'package:stonecarve_manager_flutter/screens/analytics_screen.dart';
import 'package:stonecarve_manager_flutter/screens/blog_post_list_screen.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/widgets/app_drawer.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.currentRoute = '/',
  });

  final Widget child;
  final String title;
  final String currentRoute;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      drawer: AppDrawer(currentRoute: widget.currentRoute),
      body: widget.child,
    );
  }
}
