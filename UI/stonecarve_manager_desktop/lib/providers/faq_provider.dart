import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_flutter/models/faq.dart';
import 'package:stonecarve_manager_flutter/providers/auth_provider.dart';
import 'package:stonecarve_manager_flutter/utils/api_config.dart';

class FaqProvider {
  static String get _baseUrl => '${ApiConfig.apiUrl}/Faq';

  Map<String, String> _headers({bool requiresAuth = false}) {
    final token = AuthProvider.token;
    return {
      'Content-Type': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch FAQs — public endpoint.
  /// Results are sorted server-side: Category → DisplayOrder → Id.
  Future<List<Faq>> fetchFaqs({
    String? category,
    bool? isActive,
    String? fts,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    if (fts != null && fts.isNotEmpty) queryParams['fts'] = fts;

    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    print('[FaqProvider] GET $uri');
    print('[FaqProvider] Headers: ${_headers(requiresAuth: true)}');
    final response = await http.get(uri, headers: _headers(requiresAuth: true));

    print('[FaqProvider] Response status: ${response.statusCode}');
    print('[FaqProvider] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('[FaqProvider] Decoded type: ${data.runtimeType}');
      final List items = data is List
          ? data
          : (data['items'] as List? ?? data as List? ?? []);
      print('[FaqProvider] Parsed ${items.length} items');
      return items.map((e) => Faq.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(
      '[FaqProvider] fetchFaqs failed: ${response.statusCode} ${response.body}',
    );
  }

  /// Get a single FAQ by id — public
  Future<Faq> getFaq(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(requiresAuth: true),
    );
    if (response.statusCode == 200) {
      return Faq.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('[FaqProvider] getFaq failed: ${response.statusCode}');
  }

  /// Create a new FAQ — Admin/Employee only
  Future<Faq> createFaq(FaqInsertRequest request) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: _headers(requiresAuth: true),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Faq.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
      '[FaqProvider] createFaq failed: ${response.statusCode} ${response.body}',
    );
  }

  /// Update a FAQ — Admin/Employee only
  Future<Faq> updateFaq(int id, FaqUpdateRequest request) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(requiresAuth: true),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return Faq.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
      '[FaqProvider] updateFaq failed: ${response.statusCode} ${response.body}',
    );
  }

  /// Delete a FAQ — Admin/Employee only
  Future<void> deleteFaq(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: _headers(requiresAuth: true),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        '[FaqProvider] deleteFaq failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Increment view counter — public, fire-and-forget
  Future<void> trackView(int id) async {
    try {
      await http.post(Uri.parse('$_baseUrl/$id/view'), headers: _headers());
    } catch (_) {}
  }
}
