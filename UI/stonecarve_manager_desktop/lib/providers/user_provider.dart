import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/utils/auth_client.dart';
import 'package:stonecarve_manager_flutter/providers/base_provider.dart';
import 'package:stonecarve_manager_flutter/models/user.dart';

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
      throw Exception("Failed to create user: ${response.body}");
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

  Future<bool> blockUser(int id, bool isBlocked) async {
    try {
      await update(id, {'isBlocked': isBlocked});
      return true;
    } catch (e) {
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
      throw Exception('Failed to load roles');
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
}
