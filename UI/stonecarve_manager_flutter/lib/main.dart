import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/screens/login_screen.dart';
import 'package:stonecarve_manager_flutter/screens/dashboard_screen.dart';
import 'package:stonecarve_manager_flutter/screens/products_screen.dart';
import 'package:stonecarve_manager_flutter/screens/materials_screen.dart';
import 'package:stonecarve_manager_flutter/screens/categories_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();  // Potrebno za async operacije prije runApp
  
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
        '/': (context) => const DashboardScreen(),
        '/products': (context) => const ProductsScreen(),
        '/materials': (context) => const MaterialsScreen(),
        '/categories': (context) => const CategoriesScreen(),
      },
    );
  }
}
