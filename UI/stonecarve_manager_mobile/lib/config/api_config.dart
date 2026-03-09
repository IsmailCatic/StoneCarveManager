/// 🎯 Centralized API Configuration — single source of truth.
///
/// Host and port are supplied via --dart-define at build / run time:
///   flutter run --dart-define=API_HOST=10.0.2.2 --dart-define=API_PORT=8080
///
/// The defaults below target the Android emulator → host-machine mapping.
///
/// **Android Emulator:**
/// - `http://10.0.2.2:<port>` - maps to localhost on the host machine
///
/// **iOS Simulator:**
/// - `http://localhost:<port>` - works directly
///
/// **Physical Device (same network):**
/// - `http://YOUR_COMPUTER_IP:<port>` - find IP with `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
///
/// **Production:**
/// - Override API_HOST and API_PORT (or the full scheme) via --dart-define.

class ApiConfig {
  // Override with: --dart-define=API_HOST=<host>
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2',
  );

  // Override with: --dart-define=API_PORT=<port>
  static const String _apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '8080',
  );

  /// Root URL (no trailing path). Example: http://10.0.2.2:8080
  static String get baseUrl => 'http://$_apiHost:$_apiPort';

  // API endpoints
  static const String apiPath = '/api/';
  static const String authPath = '/auth/';

  // Full URLs
  static String get apiBaseUrl => '$baseUrl$apiPath';
  static String get authBaseUrl => '$baseUrl$authPath';

  // Helper methods for common endpoints
  static String endpoint(String path) => '$apiBaseUrl$path';
  static String authEndpoint(String path) => '$baseUrl/auth/$path';
}
