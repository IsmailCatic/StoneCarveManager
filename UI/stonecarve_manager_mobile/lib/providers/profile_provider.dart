import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/models/profile.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfileResponse? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileResponse? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get _baseUrl => BaseProvider.baseUrl;

  /// Fetch current user profile
  Future<void> fetchCurrentUserProfile() async {
    // Don't make API call if not authenticated
    if (!AuthProvider.isAuthenticated()) {
      _errorMessage = 'Not authenticated';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = AuthProvider.token;
      final userId = AuthProvider.userId;

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // Use userId-based endpoint instead of /current if backend doesn't support it
      final url = '$_baseUrl/api/User/$userId';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserProfileResponse.fromJson(data);
        _errorMessage = null;
        print('[ProfileProvider] ✅ Profile loaded');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception(
          'User profile not found. Endpoint may not be implemented.',
        );
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('[ProfileProvider] ❌ Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = AuthProvider.token;
      final userId = AuthProvider.userId;

      if (token == null || userId == null) {
        throw Exception('Not authenticated');
      }

      final url = '$_baseUrl/api/User/$userId';
      final requestBody = jsonEncode(request.toJson());

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        print('[ProfileProvider] ✅ Profile updated');
        // Refresh profile after successful update
        await fetchCurrentUserProfile();
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to update this profile.');
      } else if (response.statusCode == 400) {
        // Try to parse validation errors
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] as Map<String, dynamic>?;
          if (errors != null) {
            final firstError = errors.values.first;
            final errorMessage = firstError is List
                ? firstError.first
                : firstError.toString();
            throw Exception(errorMessage);
          }
          throw Exception(errorData['message'] ?? 'Invalid request data');
        } catch (_) {
          throw Exception('Invalid request data');
        }
      } else {
        throw Exception('Failed to update profile (${response.statusCode})');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('[ProfileProvider] ❌ Update failed: $e');
      notifyListeners();
      return false; // ← DODATO: Mora vratiti false kada se desi error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change password
  Future<bool> changePassword(ChangePasswordRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = AuthProvider.token;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/User/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Current password is incorrect',
        );
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('Error changing password: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload user profile image
  Future<bool> uploadProfileImage(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = AuthProvider.token;
      final userId = AuthProvider.userId;

      if (token == null || userId == null) {
        throw Exception('Not authenticated');
      }

      final url = '$_baseUrl/api/User/$userId/profile-image';
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.files.add(await http.MultipartFile.fromPath('File', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('[ProfileProvider] ✅ Profile image uploaded');
        // Refresh profile to get updated image URL
        await fetchCurrentUserProfile();
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to upload this image.');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid image file');
      } else {
        throw Exception('Failed to upload image (${response.statusCode})');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('[ProfileProvider] ❌ Upload failed: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete user profile image
  Future<bool> deleteProfileImage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = AuthProvider.token;
      final userId = AuthProvider.userId;

      if (token == null || userId == null) {
        throw Exception('Not authenticated');
      }

      final url = '$_baseUrl/api/User/$userId/profile-image';

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('[ProfileProvider] ✅ Profile image deleted');
        // Refresh profile to update state
        await fetchCurrentUserProfile();
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have permission to delete this image.');
      } else if (response.statusCode == 404) {
        throw Exception('No profile image to delete');
      } else {
        throw Exception('Failed to delete image (${response.statusCode})');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('[ProfileProvider] ❌ Delete failed: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear profile data (on logout)
  void clearProfile() {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
