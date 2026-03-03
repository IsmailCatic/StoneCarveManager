import 'package:flutter/material.dart';
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
