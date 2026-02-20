import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/blog_post.dart';
import '../models/blog_post_requests.dart';
import '../models/blog_image.dart';
import '../models/blog_image_upload_request.dart';
import 'base_provider.dart';
import 'auth_provider.dart';

class BlogPostProvider extends BaseProvider {
  final String apiUrl;
  BlogPostProvider(String endpoint, {required this.apiUrl}) : super(endpoint);

  Future<List<BlogPost>> fetchBlogPosts(
    BuildContext context, {
    BlogPostSearch? search,
  }) async {
    try {
      final token = AuthProvider.token;
      final uri = Uri.parse(
        '$apiUrl/BlogPost',
      ).replace(queryParameters: search?.toJson());

      print('🔵 [BlogPost] Fetching blog posts from: $uri');
      print('🔵 [BlogPost] Token available: ${token != null}');

      final response = await http.get(uri, headers: _headers(token!));

      print('🔵 [BlogPost] Response status: ${response.statusCode}');
      print('🔵 [BlogPost] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print(
          '🔵 [BlogPost] Decoded response type: ${decodedResponse.runtimeType}',
        );

        // Check if response is a List or a wrapped object
        final List data;
        if (decodedResponse is List) {
          data = decodedResponse;
        } else if (decodedResponse is Map<String, dynamic>) {
          // API returns wrapped response like { "items": [...], "totalCount": 10 }
          data = decodedResponse['items'] ?? decodedResponse['data'] ?? [];
          print(
            '🔵 [BlogPost] Extracted ${data.length} items from wrapped response',
          );
        } else {
          throw Exception(
            'Unexpected response format: ${decodedResponse.runtimeType}',
          );
        }

        print('✅ [BlogPost] Successfully loaded ${data.length} blog posts');
        return data.map((e) => BlogPost.fromJson(e)).toList();
      } else {
        print(
          '❌ [BlogPost] Failed with status ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'Failed to load blog posts: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [BlogPost] Error fetching blog posts: $e');
      print('❌ [BlogPost] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<BlogPost> getBlogPost(BuildContext context, int id) async {
    try {
      final token = AuthProvider.token;
      final uri = Uri.parse('$apiUrl/BlogPost/$id');

      print('🔵 [BlogPost] Fetching blog post $id from: $uri');

      final response = await http.get(uri, headers: _headers(token!));

      print('🔵 [BlogPost] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [BlogPost] Successfully loaded blog post $id');
        return BlogPost.fromJson(json.decode(response.body));
      } else {
        print(
          '❌ [BlogPost] Failed with status ${response.statusCode}: ${response.body}',
        );
        throw Exception('Failed to load blog post: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [BlogPost] Error fetching blog post $id: $e');
      print('❌ [BlogPost] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<BlogPost> insertBlogPost(
    BuildContext context,
    BlogPostInsertRequest request,
  ) async {
    try {
      final token = AuthProvider.token;
      final uri = Uri.parse('$apiUrl/BlogPost');

      print('🔵 [BlogPost] Inserting blog post to: $uri');
      print('🔵 [BlogPost] Request data: ${json.encode(request.toJson())}');

      final response = await http.post(
        uri,
        headers: _headers(token!),
        body: json.encode(request.toJson()),
      );

      print('🔵 [BlogPost] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [BlogPost] Successfully inserted blog post');
        return BlogPost.fromJson(json.decode(response.body));
      } else {
        print(
          '❌ [BlogPost] Failed with status ${response.statusCode}: ${response.body}',
        );
        throw Exception('Failed to insert blog post: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [BlogPost] Error inserting blog post: $e');
      print('❌ [BlogPost] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<BlogPost> updateBlogPost(
    BuildContext context,
    int id,
    BlogPostUpdateRequest request,
  ) async {
    final token = AuthProvider.token;
    final uri = Uri.parse('$apiUrl/BlogPost/$id');
    final response = await http.put(
      uri,
      headers: _headers(token!),
      body: json.encode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return BlogPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update blog post');
    }
  }

  Future<void> deleteBlogPost(BuildContext context, int id) async {
    final token = AuthProvider.token;
    final uri = Uri.parse('$apiUrl/BlogPost/$id');
    final response = await http.delete(uri, headers: _headers(token!));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete blog post');
    }
  }

  Future<BlogImageResponse> uploadBlogImage(
    BuildContext context,
    int postId,
    BlogImageUploadRequest request,
  ) async {
    try {
      final token = AuthProvider.token;
      final uri = Uri.parse('$apiUrl/BlogPost/$postId/images');

      print('🔵 [BlogPost] Uploading image for post $postId to: $uri');

      var req = http.MultipartRequest('POST', uri);
      req.headers.addAll(_headers(token!, isMultipart: true));
      req.files.add(
        await http.MultipartFile.fromPath('file', request.filePath),
      );
      req.fields.addAll(request.toFields());

      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);

      print('🔵 [BlogPost] Upload response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [BlogPost] Image uploaded successfully');
        return BlogImageResponse.fromJson(json.decode(response.body));
      } else {
        print('❌ [BlogPost] Upload failed: ${response.body}');
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [BlogPost] Error uploading image: $e');
      print('❌ [BlogPost] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> uploadFeaturedImage(
    BuildContext context,
    File imageFile,
  ) async {
    try {
      final token = AuthProvider.token;
      final uri = Uri.parse('$apiUrl/BlogPost/upload-featured');

      print('🔵 [BlogPost] Uploading featured image to: $uri');

      var req = http.MultipartRequest('POST', uri);
      req.headers.addAll(_headers(token!, isMultipart: true));
      req.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamed = await req.send();
      final response = await http.Response.fromStream(streamed);

      print('🔵 [BlogPost] Upload response status: ${response.statusCode}');
      print('🔵 [BlogPost] Upload response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final imageUrl = data['imageUrl'] ?? data['url'];
        print('✅ [BlogPost] Featured image uploaded: $imageUrl');
        return imageUrl;
      } else {
        print('❌ [BlogPost] Upload failed: ${response.body}');
        throw Exception('Failed to upload featured image');
      }
    } catch (e, stackTrace) {
      print('❌ [BlogPost] Error uploading featured image: $e');
      print('❌ [BlogPost] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteBlogImage(
    BuildContext context,
    int postId,
    int imageId,
  ) async {
    final token = AuthProvider.token;
    final uri = Uri.parse('$apiUrl/BlogPost/$postId/images/$imageId');
    final response = await http.delete(uri, headers: _headers(token!));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete image');
    }
  }

  /// Increment the view count for a blog post
  /// This should be called when a user views the post detail
  /// Returns true if successful, false otherwise (fails silently)
  Future<bool> incrementViewCount(int postId) async {
    try {
      final token = AuthProvider.token;
      if (token == null) {
        print('⚠️ [BlogPost] No token available for view tracking');
        return false;
      }

      final uri = Uri.parse('$apiUrl/BlogPost/$postId/increment-view-count');
      print('🔵 [BlogPost] Incrementing view count for post $postId');

      final response = await http.patch(uri, headers: _headers(token));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [BlogPost] View count incremented for post $postId');
        return true;
      } else {
        print(
          '⚠️ [BlogPost] View increment returned status ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      // Fail silently - view tracking shouldn't break the user experience
      print('⚠️ [BlogPost] Error incrementing view count: $e');
      return false;
    }
  }

  Map<String, String> _headers(String token, {bool isMultipart = false}) => {
    'Authorization': 'Bearer $token',
    if (!isMultipart) 'Content-Type': 'application/json',
  };
}
