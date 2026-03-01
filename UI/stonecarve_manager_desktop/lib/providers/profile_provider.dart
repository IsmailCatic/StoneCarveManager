import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/profile.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/providers/user_provider.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfileResponse? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileResponse? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const String _baseUrl = "http://localhost:5021";

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

      // Use userId-based endpoint
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
      } else {
        throw HttpErrorHandler.createException(response, 'load profile');
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
      } else {
        throw HttpErrorHandler.createException(response, 'update profile');
      }
    } catch (e) {
      _errorMessage = e.toString();
      print('[ProfileProvider] ❌ Update failed: $e');
      notifyListeners();
      return false;
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
      } else {
        throw HttpErrorHandler.createException(response, 'change password');
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

  /// Clear profile data (on logout)
  void clearProfile() {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Upload profile image
  Future<bool> uploadProfileImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = AuthProvider.userId;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      final userProvider = UserProvider();
      await userProvider.uploadUserProfileImage(userId, imageFile);

      // Refresh profile to get updated image URL
      await fetchCurrentUserProfile();
      return true;
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

  /// Delete profile image
  Future<bool> deleteProfileImage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = AuthProvider.userId;
      if (userId == null) {
        throw Exception('Not authenticated');
      }

      final userProvider = UserProvider();
      await userProvider.deleteUserProfileImage(userId);

      // Refresh profile to clear image URL
      await fetchCurrentUserProfile();
      return true;
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
}
