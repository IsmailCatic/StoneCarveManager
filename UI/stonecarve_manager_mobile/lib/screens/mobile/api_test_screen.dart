import 'package:flutter/material.dart';
import 'package:stonecarve_manager_mobile/providers/base_provider.dart';
import 'package:stonecarve_manager_mobile/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _result = 'Press test button to check API connection...';
  bool _testing = false;

  Future<void> _testApi() async {
    setState(() {
      _testing = true;
      _result = 'Testing...';
    });

    final buffer = StringBuffer();
    buffer.writeln('🔧 API Configuration Test\n');
    buffer.writeln('BaseURL: ${BaseProvider.baseUrl}');
    buffer.writeln(
      'Auth Token: ${AuthProvider.token != null ? "✅ Present" : "❌ Missing"}',
    );
    buffer.writeln('User: ${AuthProvider.username ?? "Not logged in"}');
    buffer.writeln('\n📡 Testing Endpoints:\n');

    // Test 1: Product endpoint
    try {
      final url = '${BaseProvider.baseUrl}/api/Product';
      buffer.writeln('Testing: $url');

      final response = await http
          .get(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 5));

      buffer.writeln('✅ Status: ${response.statusCode}');
      buffer.writeln('   Body length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        buffer.writeln('   ✅ Products endpoint OK');
      } else {
        buffer.writeln('   ⚠️ Status: ${response.statusCode}');
        buffer.writeln('   Body: ${response.body}');
      }
    } catch (e) {
      buffer.writeln('❌ Error: $e');
    }

    buffer.writeln('\n');

    // Test 2: Portfolio endpoint
    try {
      final url = '${BaseProvider.baseUrl}/api/Product/portfolio';
      buffer.writeln('Testing: $url');

      final response = await http
          .get(Uri.parse(url), headers: AuthProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 5));

      buffer.writeln('✅ Status: ${response.statusCode}');
      buffer.writeln('   Body length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        buffer.writeln('   ✅ Portfolio endpoint OK');
      } else {
        buffer.writeln('   ⚠️ Status: ${response.statusCode}');
      }
    } catch (e) {
      buffer.writeln('❌ Error: $e');
    }

    setState(() {
      _result = buffer.toString();
      _testing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Connection Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _testing ? null : _testApi,
              icon: _testing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_testing ? 'Testing...' : 'Test API Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
