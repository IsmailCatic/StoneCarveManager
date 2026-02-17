import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';

/// Diagnostic utility to test favorites API connectivity and authentication
class FavoritesDiagnostic {
  /// Run comprehensive diagnostics and return a report
  static Future<String> runDiagnostics() async {
    final report = StringBuffer();
    report.writeln('🔍 Favorites API Diagnostics');
    report.writeln('=' * 50);
    report.writeln('');

    // 1. Check authentication
    report.writeln('1️⃣ Authentication Check:');
    report.writeln('   Is authenticated: ${AuthProvider.isAuthenticated()}');
    report.writeln('   Token present: ${AuthProvider.token != null}');
    if (AuthProvider.token != null) {
      final tokenPreview = AuthProvider.token!.length > 20
          ? '${AuthProvider.token!.substring(0, 20)}...'
          : AuthProvider.token;
      report.writeln('   Token preview: $tokenPreview');
    }
    report.writeln('   User ID: ${AuthProvider.userId}');
    report.writeln('');

    // 2. Check base URL configuration
    report.writeln('2️⃣ API Configuration:');
    report.writeln('   Base URL: ${BaseProvider.baseUrl}');
    report.writeln(
      '   Favorites endpoint: ${BaseProvider.baseUrl}/api/Favorite',
    );
    report.writeln('   IDs endpoint: ${BaseProvider.baseUrl}/api/Favorite/ids');
    report.writeln('');

    // 3. Test backend connectivity
    report.writeln('3️⃣ Backend Connectivity Test:');
    try {
      final url = '${BaseProvider.baseUrl}/api/Favorite/ids';
      debugPrint('   Testing GET $url');

      final response = await http
          .get(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      report.writeln('   ✅ Backend reachable');
      report.writeln('   Status: ${response.statusCode}');
      report.writeln('   Response length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          report.writeln('   Response type: ${data.runtimeType}');
          if (data is List) {
            report.writeln('   Favorites count: ${data.length}');
            if (data.isNotEmpty) {
              report.writeln('   Sample IDs: ${data.take(5).toList()}');
            }
          }
        } catch (e) {
          report.writeln('   ⚠️ Response parse error: $e');
        }
      } else if (response.statusCode == 401) {
        report.writeln('   ❌ Authentication failed (401 Unauthorized)');
        report.writeln('   This means the token is invalid or expired');
      } else {
        report.writeln('   ⚠️ Unexpected status code: ${response.statusCode}');
        report.writeln(
          '   Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
        );
      }
    } catch (e) {
      report.writeln('   ❌ Connection failed');
      report.writeln('   Error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        report.writeln('   🔧 Possible fixes:');
        report.writeln('      - Check if backend server is running');
        report.writeln('      - Verify base URL (${BaseProvider.baseUrl})');
        report.writeln(
          '      - For emulator: use 10.0.2.2 (Android) or localhost (iOS)',
        );
        report.writeln(
          '      - For physical device: use your computer\'s IP address',
        );
      }
    }
    report.writeln('');

    // 4. Test adding a favorite (POST)
    report.writeln('4️⃣ Test Adding Favorite (POST):');
    try {
      final testProductId = 1; // Use a test product ID
      final url = '${BaseProvider.baseUrl}/api/Favorite/$testProductId';
      debugPrint('   Testing POST $url');

      final response = await http
          .post(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      report.writeln('   Status: ${response.statusCode}');
      report.writeln('   Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        report.writeln('   ✅ POST request successful');
      } else if (response.statusCode == 401) {
        report.writeln('   ❌ Authentication failed');
      } else if (response.statusCode == 404) {
        report.writeln('   ⚠️ Endpoint not found (check backend routing)');
      } else {
        report.writeln('   ⚠️ Unexpected response');
      }
    } catch (e) {
      report.writeln('   ❌ POST request failed: $e');
    }
    report.writeln('');

    // 5. Headers inspection
    report.writeln('5️⃣ Request Headers:');
    final headers = AuthProvider.getAuthHeaders();
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        report.writeln(
          '   $key: Bearer ${value.replaceAll('Bearer ', '').substring(0, 20)}...',
        );
      } else {
        report.writeln('   $key: $value');
      }
    });
    report.writeln('');

    report.writeln('=' * 50);
    report.writeln('End of diagnostics');

    final reportStr = report.toString();
    debugPrint(reportStr);
    return reportStr;
  }

  /// Quick test for a specific product ID
  static Future<void> testToggleFavorite(int productId) async {
    debugPrint('🧪 Testing toggle favorite for product $productId');

    try {
      // Add to favorites
      final addUrl = '${BaseProvider.baseUrl}/api/Favorite/$productId';
      debugPrint('POST $addUrl');
      debugPrint('Headers: ${AuthProvider.getAuthHeaders()}');

      final addResponse = await http
          .post(Uri.parse(addUrl), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'Add Response: ${addResponse.statusCode} - ${addResponse.body}',
      );

      // Wait a second
      await Future.delayed(const Duration(seconds: 1));

      // Remove from favorites
      final removeUrl = '${BaseProvider.baseUrl}/api/Favorite/$productId';
      debugPrint('DELETE $removeUrl');

      final removeResponse = await http
          .delete(Uri.parse(removeUrl), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      debugPrint(
        'Remove Response: ${removeResponse.statusCode} - ${removeResponse.body}',
      );

      if (addResponse.statusCode == 200 && removeResponse.statusCode == 200) {
        debugPrint('✅ Toggle favorite test PASSED');
      } else {
        debugPrint('❌ Toggle favorite test FAILED');
      }
    } catch (e) {
      debugPrint('❌ Test error: $e');
    }
  }
}
