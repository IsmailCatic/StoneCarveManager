import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/auth.dart';
import 'package:stonecarve_manager_flutter/utils/api_config.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';

class AuthProvider {
  static String? _token;
  static String? _username;
  static int? _userId;
  static List<String>? _roles;
  static bool _isLoggedIn = false;

  static String get _baseUrl => ApiConfig.baseUrl;

  // Getters
  static String? get username => _username;
  static int? get userId => _userId;
  static List<String>? get roles => _roles;
  static bool get isLoggedIn => _isLoggedIn;

  // Role helper methods
  static bool hasRole(String role) => _roles?.contains(role) ?? false;
  static bool get isAdmin => hasRole('Admin');
  static bool get isEmployee => hasRole('Employee');
  static bool get isUser => hasRole('User');

  // Get user role (primary role for display)
  static String get userRole {
    if (_roles == null || _roles!.isEmpty) return 'Unknown';
    if (_roles!.contains('Admin')) return 'Admin';
    if (_roles!.contains('Employee')) return 'Employee';
    if (_roles!.contains('User')) return 'User';
    return _roles!.first;
  }

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Getter za token
  static String? get token => _token;

  // Login method
  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      print("Attempting login with email: $email"); // Debug log
      print("Request URL: ${_baseUrl}auth/login"); // Debug log

      final response = await http
          .post(
            Uri.parse('${_baseUrl}auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(loginRequest.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Login request timeout'),
          );

      // print("Login response status: ${response.statusCode}"); // Debug log
      // print("Login response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Store auth data
        _token = authResponse.token;
        _username = email; // Store email as username for display
        _userId = authResponse.userId;
        _roles = authResponse.roles;
        _isLoggedIn = true;

        await _storage.write(key: 'auth_token', value: authResponse.token);

        print('AuthProvider.token after login: \'$_token\'');
        print('AuthProvider roles after login: $_roles');

        return authResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else if (response.statusCode == 403) {
        // Account is blocked
        final responseBody = jsonDecode(response.body);
        final message =
            responseBody['message'] ??
            responseBody['error'] ??
            'Your account has been blocked. Please contact an administrator.';
        throw Exception('ACCOUNT_BLOCKED: $message');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid request format');
      } else {
        throw Exception(
          'Login failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print("Login error: $e"); // Debug log
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          "Cannot connect to server. Please make sure the backend is running on ${ApiConfig.baseUrl}",
        );
      }
      rethrow;
    }
  }

  // Register method
  static Future<AuthResponse?> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

        // Store auth data
        _token = authResponse.token;
        _username = authResponse.username;
        _userId = authResponse.userId;
        _roles = authResponse.roles;
        _isLoggedIn = true;

        await _storage.write(key: 'auth_token', value: authResponse.token);

        return authResponse;
      } else {
        throw HttpErrorHandler.createException(response, 'register user');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Logout method
  static Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('${_baseUrl}auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API error: $e');
    } finally {
      // Clear all auth data
      _token = null;
      _username = null;
      _userId = null;
      _roles = null;
      _isLoggedIn = false;

      // Obrisi token iz secure storage
      await _storage.delete(key: 'auth_token');
    }
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _token != null && _isLoggedIn;
  }

  // Get authorization header for API calls
  static Map<String, String> getAuthHeaders() {
    if (_token != null) {
      return {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // Add method to load token from storage on app start
  static Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      _isLoggedIn = true;
      // If you have other data, you can load it here, but for now just the token
    }
  }

  // Request password reset - sends verification code to email
  static Future<String> requestPasswordReset(String email) async {
    try {
      print('[AuthProvider] 📤 Requesting password reset for: $email');

      final response = await http.post(
        Uri.parse('${_baseUrl}auth/request-password-reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print(
        '[AuthProvider] Password reset request: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ??
            'If an account exists with this email, a verification code has been sent.';
      } else if (response.statusCode == 400) {
        throw Exception('Invalid email format');
      } else {
        throw HttpErrorHandler.createException(
          response,
          'send password reset request',
        );
      }
    } catch (e) {
      print('[AuthProvider] Password reset request error: $e');
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        throw Exception('Unable to connect to server');
      }
      rethrow;
    }
  }

  // Reset password using verification code
  static Future<String> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      final requestBody = {
        'email': email,
        'verificationCode': verificationCode,
        'newPassword': newPassword,
      };

      print('[AuthProvider] 📤 Sending password reset request:');
      print('   Email: $email');
      print('   VerificationCode: $verificationCode');
      print('   Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${_baseUrl}auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(
        '[AuthProvider] Password reset: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ??
            'Password changed successfully. You can now log in with your new password.';
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Invalid verification code or request',
        );
      } else {
        throw HttpErrorHandler.createException(response, 'reset password');
      }
    } catch (e) {
      print('[AuthProvider] Password reset error: $e');
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        throw Exception('Unable to connect to server');
      }
      rethrow;
    }
  }
}
