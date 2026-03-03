import 'dart:convert';
import 'dart:io';

/// Centralised error message parser for the app.
///
/// Handles:
///  - FluentValidation array format:   {"errors":[{"field":"X","message":"Y"}]}
///  - ASP.NET ModelState map format:   {"errors":{"Field":["message"]}}
///  - Simple message body:             {"message":"..."}  or  {"title":"..."}
///  - Network errors (SocketException, timeout, connection refused)
///  - Strips the "Exception: " prefix that Dart adds automatically
class AppErrorParser {
  /// Parse a raw HTTP response body into a human-readable error message.
  static String fromBody(String body, {int? statusCode}) {
    if (body.isEmpty) {
      return _statusFallback(statusCode);
    }

    try {
      final data = jsonDecode(body);

      if (data is Map<String, dynamic>) {
        final errors = data['errors'];

        // FluentValidation: errors is a List of {field, message}
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is Map<String, dynamic>) {
            return first['message']?.toString() ?? errors.toString();
          }
          return errors.join(', ');
        }

        // ASP.NET ModelState: errors is a Map<field, [messages]>
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final firstValue = errors.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            return firstValue.first.toString();
          }
          return firstValue.toString();
        }

        // Simple message / title fields
        final msg = data['message'] ?? data['title'] ?? data['detail'];
        if (msg != null && msg.toString().isNotEmpty) {
          return msg.toString();
        }
      }
    } catch (_) {
      // Body is not JSON — fall through and return as-is if short enough
    }

    // Plain-text body (not too long)
    if (body.length < 200) return body;
    return _statusFallback(statusCode);
  }

  /// Parse an exception (typically thrown by a provider) into a display string.
  static String fromException(Object e) {
    final raw = e.toString();

    // Network-level errors
    if (e is SocketException ||
        raw.contains('Failed host lookup') ||
        raw.contains('Connection refused') ||
        raw.contains('connect to server')) {
      return 'Could not connect to the server. Please check your connection and try again.';
    }

    if (raw.contains('timeout') || raw.contains('Timeout')) {
      return 'The request timed out. Please try again.';
    }

    // Strip Dart's automatic "Exception: " prefix
    return raw.replaceFirst('Exception: ', '');
  }

  static String _statusFallback(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'A conflict occurred. The resource may already exist.';
      case 500:
        return 'A server error occurred. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
