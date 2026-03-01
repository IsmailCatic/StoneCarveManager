import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stonecarve_manager_mobile/config/stripe_config.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/cart_provider.dart';
import 'package:stonecarve_manager_mobile/providers/favorites_provider.dart';
import 'package:stonecarve_manager_mobile/providers/profile_provider.dart';
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
import 'package:stonecarve_manager_mobile/screens/mobile/my_payments_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/portfolio_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/custom_order_form_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/profile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/mobile/services_mobile_screen.dart';
import 'package:stonecarve_manager_mobile/screens/forgot_password_screen.dart';
import 'package:stonecarve_manager_mobile/screens/reset_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe
  Stripe.publishableKey = StripeConfig.publishableKey;
  Stripe.merchantIdentifier = StripeConfig.merchantIdentifier;
  Stripe.urlScheme = StripeConfig.urlScheme;
  await Stripe.instance.applySettings();

  // Load token from storage before running app
  await AuthProvider.loadToken();

  // Initialize favorites provider (but DON'T load yet!)
  final favoritesProvider = FavoritesProvider();
  // Only load from cache - NO backend calls until after login
  // Backend sync will happen after successful login

  runApp(StoneCarveManagerApp(favoritesProvider: favoritesProvider));
}

class StoneCarveManagerApp extends StatefulWidget {
  final FavoritesProvider favoritesProvider;

  const StoneCarveManagerApp({super.key, required this.favoritesProvider});

  @override
  State<StoneCarveManagerApp> createState() => _StoneCarveManagerAppState();
}

class _StoneCarveManagerAppState extends State<StoneCarveManagerApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinkListener() async {
    _appLinks = AppLinks();

    // Handle initial deep link (when app is launched from closed state)
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // Listen for deep links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    try {
      debugPrint('🔗 Deep link received: $uri');
      debugPrint('   Host: ${uri.host}');
      debugPrint('   Path: ${uri.path}');
      debugPrint('   Query params: ${uri.queryParameters}');

      // Note: Password reset now uses 6-digit verification code via email
      // Deep linking is reserved for future features (e.g., product sharing, order tracking)

      debugPrint('ℹ️ Deep link handler - no actions configured yet');
    } catch (e) {
      debugPrint('❌ Failed to handle deep link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider.value(value: widget.favoritesProvider),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
          // Parse URI for potential deep links
          // Note: Currently unused for password reset (uses verification codes)
          Uri? uri;

          if (settings.name != null && settings.name!.contains('?')) {
            uri = Uri.parse(settings.name!);
          }

          // Extract route name (before query params)
          final routeName = uri?.path ?? settings.name ?? '/login';

          switch (routeName) {
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
            case '/payments':
              return MaterialPageRoute(
                builder: (_) => const MyPaymentsScreen(),
              );
            case '/portfolio':
              return MaterialPageRoute(
                builder: (_) => const PortfolioMobileScreen(),
              );
            case '/services':
              return MaterialPageRoute(
                builder: (_) => const ServicesMobileScreen(),
              );
            case '/custom-order':
              return MaterialPageRoute(
                builder: (_) => const CustomOrderFormScreen(),
              );
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/forgot-password':
              return MaterialPageRoute(
                builder: (_) => const ForgotPasswordScreen(),
              );
            case '/reset-password':
              // Parse email from route arguments
              final args = settings.arguments as Map<String, dynamic>?;
              final email = args?['email'];

              return MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(email: email),
              );
            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}
