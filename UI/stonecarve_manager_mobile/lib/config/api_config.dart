/// 🎯 Centralized API Configuration
///
/// Change baseUrl based on your testing environment:
///
/// **Android Emulator:**
/// - `http://10.0.2.2:5021` - maps to localhost on host machine
///
/// **iOS Simulator:**
/// - `http://localhost:5021` - works directly
///
/// **Physical Device (same network):**
/// - `http://YOUR_COMPUTER_IP:5021` - find IP with `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
///
/// **Production:**
/// - `https://your-api-domain.com` - your deployed backend

class ApiConfig {
  // 🔧 Change this for different environments
  static const String baseUrl = "http://10.0.2.2:5021";

  // API endpoints
  static const String apiPath = "/api/";
  static const String authPath = "/auth/";

  // Full URLs
  static String get apiBaseUrl => "$baseUrl$apiPath";
  static String get authBaseUrl => "$baseUrl$authPath";

  // Helper methods for common endpoints
  static String endpoint(String path) => "$apiBaseUrl$path";
  static String authEndpoint(String path) => "$baseUrl/auth/$path";
}
