import 'dart:convert';
import 'package:http/http.dart' as http;

/// Utility class for standardized HTTP error handling across all providers
class HttpErrorHandler {
  /// Extracts a meaningful error message from an HTTP response
  ///
  /// Handles different response formats:
  /// - JSON with validation errors (ASP.NET): {"errors": {"field": ["error message"]}}
  /// - JSON with validation errors (list): {"errors": [{"message": "..."}, ...]}
  /// - JSON with simple message: {"message": "error message"}
  /// - JSON Problem Details: {"title": "...", "message": "..."}
  /// - Plain text error messages
  /// - Default fallback messages for different status codes
  static String parseErrorResponse(http.Response response, String operation) {
    final statusCode = response.statusCode;

    // Handle specific status codes with meaningful messages
    switch (statusCode) {
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'This action conflicts with existing data.';
      case 422:
        return _parseValidationErrors(response.body);
      case 500:
        return 'Server error occurred. Please try again later.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
    }

    // Try to parse error message from response body
    if (response.body.isNotEmpty) {
      try {
        final errorData = jsonDecode(response.body);

        // Check for validation errors (multiple formats)
        if (errorData is Map && errorData.containsKey('errors')) {
          return _parseValidationErrors(response.body);
        }

        // Check for error message
        if (errorData is Map && errorData.containsKey('message')) {
          return errorData['message'].toString();
        }

        // Check for title (Problem Details format)
        if (errorData is Map && errorData.containsKey('title')) {
          return errorData['title'].toString();
        }

        // If it's a simple string in JSON
        if (errorData is String) {
          return errorData;
        }
      } catch (e) {
        // If JSON parsing fails, treat as plain text
        if (response.body.length < 200 && !response.body.contains('<')) {
          // Return plain text if it's short and not HTML
          return response.body;
        }
      }
    }

    // Fallback to generic message with status code
    return '$operation failed (${statusCode})';
  }

  /// Parses validation errors from multiple backend formats
  ///
  /// Supports:
  /// - ASP.NET Core format: {"errors": {"field": ["error message 1", "error message 2"]}}
  /// - List format: {"errors": [{"message": "error 1"}, {"message": "error 2"}]}
  /// - Simple message: {"message": "error message"}
  static String _parseValidationErrors(String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);

      if (errorData is Map && errorData.containsKey('errors')) {
        final errors = errorData['errors'];

        // Handle list format: [{"message": "..."}, ...]
        if (errors is List && errors.isNotEmpty) {
          final messages = errors
              .where((e) => e is Map && e.containsKey('message'))
              .map((e) => e['message'].toString())
              .toList();

          if (messages.isNotEmpty) {
            return messages.join(', ');
          }
        }

        // Handle ASP.NET format: {"field": ["error 1", "error 2"]}
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          // Get the first error message
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          } else if (firstError is String) {
            return firstError;
          }
        }
      }

      // Check if there's a direct message field
      if (errorData is Map && errorData.containsKey('message')) {
        return errorData['message'].toString();
      }
    } catch (e) {
      // Parsing failed, return generic message
    }

    return 'Invalid request data. Please check your input.';
  }

  /// Creates a standardized exception from an HTTP response
  static Exception createException(http.Response response, String operation) {
    return Exception(parseErrorResponse(response, operation));
  }

  /// Checks if the response is successful (2xx status code)
  static bool isSuccessful(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Validates response and throws exception if not successful
  static void validateResponse(http.Response response, String operation) {
    if (!isSuccessful(response)) {
      throw createException(response, operation);
    }
  }
}
