import 'dart:convert';

import 'package:stonecarve_manager_flutter/models/search_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:http/http.dart';
import 'package:stonecarve_manager_flutter/utils/http_error_handler.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5021/api/",
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    try {
      var url = "$_baseUrl$_endpoint";

      if (filter != null) {
        var queryString = getQueryString(filter);
        // Remove leading & if present
        if (queryString.startsWith('&')) {
          queryString = queryString.substring(1);
        }
        url = "$url?$queryString";
      }

      var uri = Uri.parse(url);
      var headers = createHeaders();

      var response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);

        var result = SearchResult<T>();

        result.totalCount = data['totalCount'];
        result.items = List<T>.from(data["items"].map((e) => fromJson(e)));

        return result;
      } else {
        throw HttpErrorHandler.createException(response, 'fetch $_endpoint');
      }
    } catch (e) {
      print("Error in BaseProvider.get(): $e"); // Debug log
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          "Cannot connect to server. Please make sure the backend is running on http://localhost:5021",
        );
      }
      rethrow;
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var jsonRequest = jsonEncode(request);
      var response = await http.post(uri, headers: headers, body: jsonRequest);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw new Exception("Unknown error");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      var jsonRequest = jsonEncode(request);
      var response = await http.put(uri, headers: headers, body: jsonRequest);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw new Exception("Unknown error");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(int id) async {
    var url = "$_baseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    if (isValidResponse(response)) {
      return true;
    } else {
      throw new Exception("Failed to delete item");
    }
  }

  T fromJson(data) {
    throw Exception("Method not implemented");
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw new Exception("Unauthorized");
    } else {
      print(response.body);

      // Try to parse validation errors from response
      try {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map && responseBody.containsKey('errors')) {
          final errors = responseBody['errors'] as Map;
          final errorMessages = <String>[];

          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });

          if (errorMessages.isNotEmpty) {
            throw new Exception(errorMessages.join('\n'));
          }
        }

        // Check for title or detail fields
        if (responseBody is Map && responseBody.containsKey('title')) {
          throw new Exception(responseBody['title']);
        }

        // Check for message field (e.g. InvalidOperationException from backend)
        if (responseBody is Map && responseBody.containsKey('message')) {
          throw new Exception(responseBody['message']);
        }
      } catch (e) {
        // If it's already an Exception, rethrow it
        if (e is Exception) {
          rethrow;
        }
      }

      throw new Exception(
        "Something bad happened (HTTP ${response.statusCode})",
      );
    }
  }

  Map<String, String> createHeaders() {
    return AuthProvider.getAuthHeaders();
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
    String query = '';
    params.forEach((key, value) {
      if (inRecursion) {
        if (key is int) {
          key = '[$key]';
        } else if (value is List || value is Map) {
          key = '.$key';
        } else {
          key = '.$key';
        }
      }
      if (value is String || value is int || value is double || value is bool) {
        var encoded = value;
        if (value is String) {
          encoded = Uri.encodeComponent(value);
        }
        query += '$prefix$key=$encoded';
      } else if (value is DateTime) {
        query += '$prefix$key=${(value as DateTime).toIso8601String()}';
      } else if (value is List || value is Map) {
        if (value is List) value = value.asMap();
        value.forEach((k, v) {
          query += getQueryString(
            {k: v},
            prefix: '$prefix$key',
            inRecursion: true,
          );
        });
      }
    });
    return query;
  }
}
