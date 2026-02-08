import 'package:http/http.dart' as http;

/// Custom HTTP client that automatically adds Authorization and Content-Type headers.
class AuthClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Future<String?> Function() getToken;

  AuthClient({required this.getToken});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Content-Type'] = 'application/json';
    return _inner.send(request);
  }
}
