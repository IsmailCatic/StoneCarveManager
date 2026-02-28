import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/screens/login_screen.dart';
import 'package:stonecarve_manager_flutter/screens/products_screen.dart';
import 'package:stonecarve_manager_flutter/screens/services_screen.dart';
import 'package:stonecarve_manager_flutter/screens/materials_screen.dart';
import 'package:stonecarve_manager_flutter/screens/categories_screen.dart';
import 'package:stonecarve_manager_flutter/screens/blog_post_list_screen.dart';
import 'package:stonecarve_manager_flutter/screens/orders_monthly_view_screen.dart';
import 'package:stonecarve_manager_flutter/screens/custom_orders_screen.dart';
import 'package:stonecarve_manager_flutter/screens/my_orders_screen.dart';
import 'package:stonecarve_manager_flutter/screens/users_screen.dart';
import 'package:stonecarve_manager_flutter/screens/analytics_dashboard_screen_comprehensive.dart';
import 'package:stonecarve_manager_flutter/screens/portfolio_modern_screen.dart';
import 'package:stonecarve_manager_flutter/screens/profile_screen.dart';
import 'package:stonecarve_manager_flutter/screens/forgot_password_screen.dart';
import 'package:stonecarve_manager_flutter/screens/reset_password_screen.dart';
import 'package:stonecarve_manager_flutter/screens/reviews_management_screen.dart';
import 'package:stonecarve_manager_flutter/screens/payments_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations before runApp

  // Load token from storage before starting the app
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
        '/orders': (context) => const OrdersMonthlyViewScreen(),
        '/custom-orders': (context) => const CustomOrdersScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
        '/products': (context) => const ProductsScreen(),
        '/services': (context) => const ServicesScreen(),
        '/materials': (context) => const MaterialsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/users': (context) => const UsersScreen(),
        '/portfolio': (context) => const PortfolioModernScreen(),
        '/blog': (context) => BlogPostListScreen(authProvider: AuthProvider()),
        '/analytics': (context) => const AnalyticsDashboardScreen(),
        '/payments': (context) => const PaymentsScreen(),
        '/reviews': (context) => const ReviewsManagementScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle reset-password route with arguments
        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: args?['email']),
          );
        }
        return null;
      },
    );
  }
}
