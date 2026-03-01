import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/utils/auth_client.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';
import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/user.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';

class UserProvider extends BaseProvider<User> {
  UserProvider() : super("User");

  final _storage = FlutterSecureStorage();

  @override
  User fromJson(data) {
    return User.fromJson(data, roles: []);
  }

  Future<User> createUser(User user) async {
    // Use the special endpoint and correct payload for user creation
    var url = "http://localhost:5021/api/User/add-user";
    var headers = createHeaders();
    var jsonRequest = jsonEncode(user.toInsertJson());
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonRequest,
    );
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw HttpErrorHandler.createException(response, 'create user');
    }
  }

  // Future<User> createUser(User user) async {
  //   return await insert(user.toInsertJson());
  // }

  Future<User> updateUser(int id, User user) async {
    return await update(id, user.toJson());
  }

  Future<bool> deleteUser(int id) async {
    return await delete(id);
  }

  Future<bool> blockUser(int id, bool isBlocked, String role) async {
    try {
      // Backend requires Role field (capital R) when updating user
      await update(id, {
        'isBlocked': isBlocked,
        'Role': role, // Backend expects capital R
      });
      return true;
    } catch (e) {
      print('❌ [UserProvider] blockUser failed: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  // Dummy getToken for demonstration; replace with your real token retrieval
  // Future<String?> getToken() async {

  //   return null;
  // }

  Future<List<String>> getRoles() async {
    print('Calling backend for roles...');
    final client = AuthClient(getToken: getToken);
    final response = await client.get(
      Uri.parse('http://localhost:5021/api/Role'),
    );
    print('Roles response status: ${response.statusCode}');
    print('Roles response body: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      final roles = items.map((role) => role['name'] as String).toList();
      print('Parsed roles: $roles');
      return roles;
    } else {
      print('Failed to load roles, status: ${response.statusCode}');
      throw HttpErrorHandler.createException(response, 'load roles');
    }
  }

  Future<List<User>> getActiveUsers() async {
    var filter = {"isActive": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<User>> getBlockedUsers() async {
    var filter = {"isBlocked": true};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<User>> getUsersByRole(String role) async {
    var filter = {"role": role};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  Future<List<User>> searchUsers(String searchTerm) async {
    var filter = {"search": searchTerm};
    var result = await get(filter: filter);
    return result.items ?? [];
  }

  /// Upload user profile image
  /// Returns the image URL
  Future<String> uploadUserProfileImage(int userId, File imageFile) async {
    final url = "http://localhost:5021/api/User/$userId/profile-image";
    final request = http.MultipartRequest('POST', Uri.parse(url));

    final token = AuthProvider.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Detect correct MIME type based on file extension
    String? contentType;
    final extension = imageFile.path.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg';
        break;
      case 'png':
        contentType = 'image/png';
        break;
      case 'gif':
        contentType = 'image/gif';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: contentType != null
            ? http.MediaType.parse(contentType)
            : null,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl'];
    } else {
      throw HttpErrorHandler.createException(response, 'upload profile image');
    }
  }

  /// Delete user profile image
  /// Returns true if successful
  Future<bool> deleteUserProfileImage(int userId) async {
    final url = "http://localhost:5021/api/User/$userId/profile-image";
    final token = AuthProvider.token;

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw HttpErrorHandler.createException(response, 'delete profile image');
    }
  }

  /// Get list of employees (users with Employee or Admin role)
  Future<List<User>> getEmployees() async {
    final url = "http://localhost:5021/api/User/employees";
    final token = AuthProvider.token;

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json, roles: [])).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Access denied');
    } else {
      throw HttpErrorHandler.createException(response, 'load employees');
    }
  }
}
