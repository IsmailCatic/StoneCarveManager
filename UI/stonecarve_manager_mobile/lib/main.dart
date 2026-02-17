import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/providers/favorites_provider.dart';
import 'package:stonecarve_manager_mobile/screens/login_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/mobile_home_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/api_test_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/cart_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/checkout_shipping_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/checkout_payment_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/checkout_confirmation_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/reviews_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/blog_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/products_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/favorites_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/my_orders_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/portfolio_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/custom_order_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load token from storage before running app
  await AuthProvider.loadToken();

  // Initialize favorites provider
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.loadFavorites();

  runApp(StoneCarveManagerApp(favoritesProvider: favoritesProvider));
}

class StoneCarveManagerApp extends StatelessWidget {
  final FavoritesProvider favoritesProvider;

  const StoneCarveManagerApp({super.key, required this.favoritesProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider.value(value: favoritesProvider),
      ],
      child: MaterialApp(
        title: 'StoneCarve Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const MobileHomeScreen(),
              );
            case '/cart':
              return MaterialPageRoute(builder: (_) => const CartScreen());
            case '/checkout-shipping':
              return MaterialPageRoute(
                builder: (_) => const CheckoutShippingScreen(),
              );
            case '/checkout-payment':
              return MaterialPageRoute(
                builder: (_) => const CheckoutPaymentScreen(),
              );
            case '/checkout-confirmation':
              return MaterialPageRoute(
                builder: (_) => const CheckoutConfirmationScreen(),
              );
            case '/api-test':
              return MaterialPageRoute(builder: (_) => const ApiTestScreen());
            case '/blog':
              return MaterialPageRoute(
                builder: (_) => const BlogMobileScreen(),
              );
            case '/reviews':
              return MaterialPageRoute(builder: (_) => const ReviewsScreen());
            case '/products':
              return MaterialPageRoute(
                builder: (_) => const ProductsMobileScreen(),
              );
            case '/favorites':
              return MaterialPageRoute(builder: (_) => const FavoritesScreen());
            case '/orders':
              return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
            case '/portfolio':
              return MaterialPageRoute(
                builder: (_) => const PortfolioMobileScreen(),
              );
            case '/custom-order':
              return MaterialPageRoute(
                builder: (_) => const CustomOrderFormScreen(),
              );
            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}
