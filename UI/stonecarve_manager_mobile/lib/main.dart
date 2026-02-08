import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/screens/login_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/mobile_home_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/products_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/portfolio_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/api_test_screen.dart';
import 'package:stonecarve_manager_mobile/screens/products_screen.dart';
import 'package:stonecarve_manager_mobile/screens/services_screen.dart';
import 'package:stonecarve_manager_mobile/screens/materials_screen.dart';
import 'package:stonecarve_manager_mobile/screens/categories_screen.dart';
import 'package:stonecarve_manager_mobile/screens/blog_post_list_screen.dart';
import 'package:stonecarve_manager_mobile/screens/orders_screen.dart';
import 'package:stonecarve_manager_mobile/screens/orders_monthly_view_screen.dart';
import 'package:stonecarve_manager_mobile/screens/users_screen.dart';
import 'package:stonecarve_manager_mobile/screens/analytics_screen.dart';
import 'package:stonecarve_manager_mobile/screens/portfolio_modern_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Potrebno za async operacije prije runApp

  // Učitaj token iz storage prije pokretanja app-a
  await AuthProvider.loadToken();

  runApp(const StoneCarveManagerApp());
}

class StoneCarveManagerApp extends StatelessWidget {
  const StoneCarveManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoneCarve Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MobileHomeScreen(),
        '/products-mobile': (context) => const ProductsMobileScreen(),
        '/portfolio-mobile': (context) => const PortfolioMobileScreen(),
        '/api-test': (context) => const ApiTestScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/orders/monthly': (context) => const OrdersMonthlyViewScreen(),
        '/products': (context) => const ProductsScreen(),
        '/services': (context) => const ServicesScreen(),
        '/materials': (context) => const MaterialsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/users': (context) => const UsersScreen(),
        '/portfolio': (context) => const PortfolioModernScreen(),
        '/blog': (context) => BlogPostListScreen(authProvider: AuthProvider()),
        '/analytics': (context) => const AnalyticsScreen(),
      },
    );
  }
}
