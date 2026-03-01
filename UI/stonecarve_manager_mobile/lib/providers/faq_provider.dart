import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/models/faq.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';

class FaqProvider {
  String get _baseUrl => '${BaseProvider.baseUrl}/api/Faq';

  /// Always include the auth token when one is available — some public endpoints
  /// still reject the request with 401 if the token is present but expired.
  /// For truly anonymous calls the token will simply be absent.
  Map<String, String> _headers({bool requiresAuth = false}) {
    return AuthProvider.getAuthHeaders();
  }

  /// Fetch FAQs — public endpoint
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
    final response = await http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // The API may return wrapped { items: [...] } or a plain list
      final List items = data is List
          ? data
          : (data['items'] as List? ?? data as List? ?? []);
      return items.map((e) => Faq.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(
      '[FaqProvider] fetchFaqs failed: ${response.statusCode} ${response.body}',
    );
  }

  /// Get a single FAQ by id — public
  Future<Faq> getFaq(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      return Faq.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('[FaqProvider] getFaq failed: ${response.statusCode}');
  }

  /// Create a new FAQ — Admin/Employee only
  Future<Faq> createFaq(FaqInsertRequest request) async {
    final uri = Uri.parse(_baseUrl);
    final response = await http.post(
      uri,
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
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.put(
      uri,
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
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.delete(
      uri,
      headers: _headers(requiresAuth: true),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        '[FaqProvider] deleteFaq failed: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Track a view when the user expands a FAQ — public
  Future<void> trackView(int id) async {
    final uri = Uri.parse('$_baseUrl/$id/view');
    // Fire and forget — don't throw on failure
    try {
      await http.post(uri, headers: _headers());
    } catch (_) {}
  }
}
