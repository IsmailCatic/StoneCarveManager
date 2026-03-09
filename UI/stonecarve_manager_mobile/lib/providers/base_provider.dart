import 'dart:convert';

import 'package:stonecarve_manager_mobile/config/api_config.dart';
import 'package:stonecarve_manager_mobile/models/search_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:http/http.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  /// Delegates to [ApiConfig] — the single source of truth.
  static String get baseUrl => ApiConfig.baseUrl;

  static String? _fullBaseUrl;
  String _endpoint = "";

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _fullBaseUrl = ApiConfig.apiBaseUrl;
  }

  String get endpoint => _endpoint;

  Future<SearchResult<T>> get({dynamic filter}) async {
    try {
      var url = "$_fullBaseUrl$_endpoint";

      if (filter != null) {
        var queryString = getQueryString(filter);
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
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          "Cannot connect to server. Please make sure the backend is running on $baseUrl",
        );
      }
      rethrow;
    }
  }

  Future<T> insert(dynamic request) async {
    var url = "$_fullBaseUrl$_endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<T> update(int id, [dynamic request]) async {
    var url = "$_fullBaseUrl$_endpoint/$id";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.put(uri, headers: headers, body: jsonRequest);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw new Exception("Unknown error");
    }
  }

  Future<bool> delete(int id) async {
    var url = "$_fullBaseUrl$_endpoint/$id";
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
      throw new Exception("Something bad happened please try again");
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
