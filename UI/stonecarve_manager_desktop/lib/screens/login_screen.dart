import 'package:flutter/material.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/screens/analytics_dashboard_screen_comprehensive.dart';
import 'package:stonecarve_manager_flutter/screens/orders_monthly_view_screen.dart';
import 'package:stonecarve_manager_flutter/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Block regular users from desktop app
      if (AuthProvider.isUser &&
          !AuthProvider.isAdmin &&
          !AuthProvider.isEmployee) {
        await AuthProvider.logout();
        throw Exception(
          'ACCESS_DENIED: This application is for staff only. Please use the customer mobile app to place orders and track your purchases.',
        );
      }

      if (mounted) {
        // Role-based redirect
        Widget destinationScreen;

        if (AuthProvider.isAdmin) {
          // Admins see analytics dashboard with all business metrics
          destinationScreen = const AnalyticsDashboardScreen();
          print('[Login] Redirecting Admin to Analytics Dashboard');
        } else {
          // Employees see orders monthly view screen (their main work area)
          destinationScreen = const OrdersMonthlyViewScreen();
          print(
            '[Login] Redirecting ${AuthProvider.userRole} to Orders Monthly View',
          );
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login failed: $e';
        Duration duration = const Duration(seconds: 4);
        Color backgroundColor = Colors.red;

        // Handle access denied (regular users)
        if (e.toString().contains('ACCESS_DENIED')) {
          errorMessage = e.toString().replaceFirst(
            'Exception: ACCESS_DENIED: ',
            '',
          );
          duration = const Duration(seconds: 15);
          backgroundColor = Colors.orange.shade900;

          // Show dialog for access denied
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                icon: const Icon(
                  Icons.mobile_off,
                  color: Colors.orange,
                  size: 48,
                ),
                title: const Text('Access Denied'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Download the customer mobile app:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_android, size: 20),
                        SizedBox(width: 8),
                        Text('iOS & Android'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
        // Handle blocked account
        else if (e.toString().contains('ACCOUNT_BLOCKED')) {
          errorMessage = e.toString().replaceFirst(
            'Exception: ACCOUNT_BLOCKED: ',
            '',
          );
          duration = const Duration(seconds: 10);
          backgroundColor = Colors.orange.shade900;

          // Show dialog for blocked accounts
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                icon: const Icon(Icons.block, color: Colors.red, size: 48),
                title: const Text('Account Blocked'),
                content: Text(errorMessage, textAlign: TextAlign.center),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
        // Show specific guidance for connection issues
        else if (e.toString().contains('connect to server') ||
            e.toString().contains('Connection refused')) {
          errorMessage =
              '🚨 Backend not running!\n\nStart backend in Visual Studio (F5), then try again.\n\nClick "Test Backend Connection" below for help.';
          duration = const Duration(seconds: 8);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: backgroundColor,
              duration: duration,
              action: SnackBarAction(
                label: 'Test Connection',
                textColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, '/test'),
              ),
            ),
          );
        } else {
          // Show generic error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: backgroundColor,
              duration: duration,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.architecture,
                        size: 64,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'StoneCarve Manager',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                      const SizedBox(height: 8),
                      // Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/forgot-password');
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Don\'t have an account? Register here',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
