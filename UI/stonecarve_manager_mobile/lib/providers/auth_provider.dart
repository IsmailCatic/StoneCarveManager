import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/models/auth.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/utils/jwt_decoder.dart';

class AuthProvider {
  static String? _token;
  static String? _username;
  static int? _userId;
  static List<String>? _roles;
  static bool _isLoggedIn = false;

  // Using centralized baseUrl from BaseProvider
  static String get _baseUrl => "${BaseProvider.baseUrl}/";

  // Getters
  static String? get username => _username;
  static int? get userId => _userId;
  static List<String>? get roles => _roles;
  static bool get isLoggedIn => _isLoggedIn;

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
        final jsonResponse = jsonDecode(response.body);
        print('[AuthProvider] 📦 Backend response: $jsonResponse');

        final authResponse = AuthResponse.fromJson(jsonResponse);

        // Store auth data in memory
        _token = authResponse.token;
        _userId = authResponse.userId; // -999 is valid for admin account
        _username = email; // Store email as username for display

        // 🔧 Extract roles from JWT token (more reliable than backend response)
        _roles = JwtDecoder.extractRoles(_token!);

        // Fallback to backend roles if JWT decode fails
        if (_roles == null || _roles!.isEmpty) {
          _roles = authResponse.roles ?? [];
          print(
            '[AuthProvider] ⚠️ Could not extract roles from JWT, using backend: $_roles',
          );
        } else {
          print('[AuthProvider] ✅ Roles from JWT: $_roles');
        }

        _isLoggedIn = true;

        // Store auth data in secure storage for persistence
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(key: 'user_id', value: _userId.toString());
        await _storage.write(key: 'username', value: _username);
        await _storage.write(key: 'roles', value: jsonEncode(_roles));

        print('[AuthProvider] ✅ Login successful:');
        print('  - Token: ${_token!.substring(0, 30)}...');
        print('  - UserId: $_userId');
        print('  - Username: $_username');
        print('  - Roles: $_roles');

        return authResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
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
          "Cannot connect to server. Please make sure the backend is running on ${BaseProvider.baseUrl}",
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

        // Store auth data in secure storage
        await _storage.write(key: 'auth_token', value: authResponse.token);
        await _storage.write(
          key: 'user_id',
          value: authResponse.userId.toString(),
        );
        await _storage.write(key: 'username', value: authResponse.username);
        await _storage.write(
          key: 'roles',
          value: jsonEncode(authResponse.roles),
        );

        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Request password reset email
  static Future<String> requestPasswordReset(String email) async {
    try {
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
        throw Exception('Error sending request: ${response.body}');
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

  // Reset password with verification code
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
        throw Exception('Error resetting password: ${response.body}');
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
      // Clear all auth data from memory
      _token = null;
      _username = null;
      _userId = null;
      _roles = null;
      _isLoggedIn = false;

      // Delete all auth data from secure storage
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'username');
      await _storage.delete(key: 'roles');
    }
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    // Must have token AND be logged in AND have userId (including -999 for admin)
    final hasValidToken = _token != null && _token!.isNotEmpty;
    final hasUserId = _userId != null;
    final result = hasValidToken && _isLoggedIn && hasUserId;

    return result;
  }

  /// Called whenever any API returns 401 Unauthorized.
  /// Clears the session and redirects to the login screen with a toast message.
  static Future<void> handleSessionExpired(BuildContext context) async {
    print(
      '[AuthProvider] 🔒 Session expired — logging out and redirecting to login',
    );
    await logout();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
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

  // Load auth data from secure storage on app startup
  static Future<void> loadToken() async {
    try {
      _token = await _storage.read(key: 'auth_token');

      if (_token != null && _token!.isNotEmpty) {
        // Check if stored token is already expired — clear session if so
        if (JwtDecoder.isExpired(_token!)) {
          print('[AuthProvider] ⚠️ Stored token is expired — clearing session');
          await logout();
          return;
        }
        // Try to load user data from storage first
        final userIdStr = await _storage.read(key: 'user_id');
        final username = await _storage.read(key: 'username');
        final rolesJson = await _storage.read(key: 'roles');

        if (userIdStr != null && userIdStr.isNotEmpty) {
          _userId = int.tryParse(userIdStr);
        }

        _username = username;

        if (rolesJson != null && rolesJson.isNotEmpty) {
          try {
            _roles = List<String>.from(jsonDecode(rolesJson));
          } catch (e) {
            print('[AuthProvider] Error parsing roles: $e');
            _roles = [];
          }
        }

        // 🔧 FALLBACK: Decode roles from JWT if missing in storage
        if (_roles == null || _roles!.isEmpty) {
          print(
            '[AuthProvider] 🔧 roles missing in storage, decoding from JWT...',
          );
          _roles = JwtDecoder.extractRoles(_token!);
        }

        // Only set logged in if we have required data (userId can be -999 for admin)
        if (_userId != null && _username != null) {
          _isLoggedIn = true;
          // Only log in debug mode - don't spam console
          print('[AuthProvider] ✅ Session restored (userId: $_userId)');
        } else {
          print('[AuthProvider] ⚠️ Incomplete auth data - clearing session');
          print('  - Token exists: ${_token != null}');
          print('  - UserId: $_userId');
          print('  - Username: $_username');
          // Clear incomplete session
          await logout();
        }
      } else {
        // Silent - no need to log missing token on fresh install
      }
    } catch (e) {
      print('[AuthProvider] Error loading token: $e');
      // Clear potentially corrupted data
      await logout();
    }
  }
}
