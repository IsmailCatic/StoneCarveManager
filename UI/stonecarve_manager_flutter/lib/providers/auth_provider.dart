import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/auth.dart';

class AuthProvider {
  static String? _token;
  static String? _username;
  static int? _userId;
  static List<String>? _roles;
  static bool _isLoggedIn = false;

  static const String _baseUrl = "http://localhost:5021/";

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
          "Cannot connect to server. Please make sure the backend is running on http://localhost:5021",
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
        throw Exception('Registration failed: ${response.body}');
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

  // Dodaj metodu za učitavanje tokena iz storage prilikom pokretanja app-a
  static Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      _isLoggedIn = true;
      // Ako imaš i druge podatke, možeš ih učitati ovdje, ali za sada samo token
    }
  }
}
