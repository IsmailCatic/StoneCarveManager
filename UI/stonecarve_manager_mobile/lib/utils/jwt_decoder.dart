import 'dart:convert';

class JwtDecoder {
  /// Decode JWT token and extract payload
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('[JwtDecoder] Invalid token format');
        return null;
      }

      // JWT payload is the second part (index 1)
      final payload = parts[1];

      // Add padding if needed for base64 decoding
      final normalized = base64.normalize(payload);

      // Decode base64
      final decoded = utf8.decode(base64.decode(normalized));

      // Parse JSON
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('[JwtDecoder] Error decoding token: $e');
      return null;
    }
  }

  /// Extract userId from JWT token
  /// Common claim names: "sub", "userId", "nameid", "user_id"
  static int? extractUserId(String token) {
    final payload = decode(token);
    if (payload == null) return null;

    // Try different common claim names
    final claims = [
      'sub', // Standard JWT subject claim
      'userId', // Custom claim
      'nameid', // ASP.NET Identity default
      'user_id', // Alternative
      'id', // Simple name
    ];

    for (final claim in claims) {
      if (payload.containsKey(claim)) {
        final value = payload[claim];
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
      }
    }

    print('[JwtDecoder] UserId not found in token claims: ${payload.keys}');
    return null;
  }

  /// Extract username/email from JWT token
  static String? extractUsername(String token) {
    final payload = decode(token);
    if (payload == null) return null;

    // Try different common claim names
    final claims = ['email', 'username', 'name', 'unique_name'];

    for (final claim in claims) {
      if (payload.containsKey(claim)) {
        return payload[claim]?.toString();
      }
    }

    return null;
  }

  /// Check whether the JWT token is expired based on the 'exp' claim.
  /// Returns true if expired or if the token cannot be decoded.
  static bool isExpired(String token) {
    try {
      final payload = decode(token);
      if (payload == null) return true;

      final exp = payload['exp'];
      if (exp == null) return false; // No expiry claim — treat as valid

      final expiry = DateTime.fromMillisecondsSinceEpoch(
        (exp as int) * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (e) {
      print('[JwtDecoder] Error checking token expiry: $e');
      return true; // Treat decode failures as expired
    }
  }

  /// Extract roles from JWT token
  static List<String> extractRoles(String token) {
    final payload = decode(token);
    if (payload == null) return [];

    // Try different common claim names
    final claims = ['role', 'roles'];

    for (final claim in claims) {
      if (payload.containsKey(claim)) {
        final value = payload[claim];
        if (value is List) {
          return value.map((e) => e.toString()).toList();
        }
        if (value is String) {
          return [value];
        }
      }
    }

    return [];
  }
}
