import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/products_mobile_screen.dart';

/// Mobile home screen - displays shop/products as default landing page
/// All navigation is handled through the side drawer (AppDrawerMobile)
class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply display the products screen
    // All other screens (Portfolio, Orders, Profile) are accessed via drawer
    return const ProductsMobileScreen();
  }
}
