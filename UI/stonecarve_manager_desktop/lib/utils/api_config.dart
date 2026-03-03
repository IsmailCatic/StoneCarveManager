/// Centralized API configuration
///
/// Reads `API_HOST` and `API_PORT` from compile-time environment variables
/// (via `--dart-define`) with sensible defaults for local development.
class ApiConfig {
  ApiConfig._();

  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );

  static const String _port = String.fromEnvironment(
    'API_PORT',
    defaultValue: '8080',
  );

  /// Root URL of the backend, e.g. `http://localhost:5199/`
  static String get baseUrl => 'http://$_host:$_port/';

  /// API URL with the `/api/` prefix, e.g. `http://localhost:5199/api`
  static String get apiUrl => 'http://$_host:$_port/api';

  /// API URL with trailing slash, e.g. `http://localhost:5199/api/`
  static String get apiUrlWithSlash => 'http://$_host:$_port/api/';
}
