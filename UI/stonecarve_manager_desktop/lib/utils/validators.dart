/// Input validation utility class
/// Provides reusable validators for common form fields
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email je obavezan';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Password validation - minimum 6 characters
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  // Strong password validation - requires uppercase, lowercase, number
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }

    return null;
  }

  // Required text field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }

    if (value.trim().length < minLength) {
      return fieldName != null
          ? '$fieldName must be at least $minLength characters'
          : 'Must be at least $minLength characters';
    }

    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.trim().length > maxLength) {
      return fieldName != null
          ? '$fieldName can be maximum $maxLength characters'
          : 'Can be maximum $maxLength characters';
    }

    return null;
  }

  // Range length validation (min and max)
  static String? validateLengthRange(
    String? value,
    int minLength,
    int maxLength, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : 'This field is required';
    }

    final length = value.trim().length;

    if (length < minLength || length > maxLength) {
      return fieldName != null
          ? '$fieldName must be between $minLength and $maxLength characters'
          : 'Must be between $minLength and $maxLength characters';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    // Remove spaces, dashes, and parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?[0-9]{6,15}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // Positive number validation
  static String? validatePositiveNumber(
    String? value, {
    String? fieldName,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? (fieldName != null
                ? '$fieldName is required'
                : 'This field is required')
          : null;
    }

    final number = double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number <= 0) {
      return fieldName != null
          ? '$fieldName must be greater than 0'
          : 'Must be greater than 0';
    }

    return null;
  }

  // Non-negative number validation (0 or greater)
  static String? validateNonNegativeNumber(
    String? value, {
    String? fieldName,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? (fieldName != null
                ? '$fieldName is required'
                : 'This field is required')
          : null;
    }

    final number = double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return fieldName != null
          ? '$fieldName cannot be negative'
          : 'Cannot be negative';
    }

    return null;
  }

  // Integer validation
  static String? validateInteger(
    String? value, {
    String? fieldName,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? (fieldName != null
                ? '$fieldName is required'
                : 'This field is required')
          : null;
    }

    if (int.tryParse(value.trim()) == null) {
      return 'Enter a valid integer';
    }

    return null;
  }

  // Positive integer validation
  static String? validatePositiveInteger(
    String? value, {
    String? fieldName,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required
          ? (fieldName != null
                ? '$fieldName is required'
                : 'This field is required')
          : null;
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid integer';
    }

    if (number <= 0) {
      return fieldName != null
          ? '$fieldName must be greater than 0'
          : 'Must be greater than 0';
    }

    return null;
  }

  // Year validation (1900-current year + 10)
  static String? validateYear(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Year is required' : null;
    }

    final year = int.tryParse(value.trim());

    if (year == null) {
      return 'Enter a valid year';
    }

    final currentYear = DateTime.now().year;

    if (year < 1900 || year > currentYear + 10) {
      return 'Year must be between 1900 and ${currentYear + 10}';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL is required' : null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL (must start with http:// or https://)';
    }

    return null;
  }

  // Price validation (positive decimal with max 2 decimal places)
  static String? validatePrice(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Price is required' : null;
    }

    final price = double.tryParse(value.trim());

    if (price == null) {
      return 'Enter a valid price';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    // Check for max 2 decimal places
    if (value.contains('.') && value.split('.')[1].length > 2) {
      return 'Price can have a maximum of 2 decimal places';
    }

    return null;
  }

  // Username validation (alphanumeric, underscore, dot)
  static String? validateUsername(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < minLength) {
      return 'Username must be at least $minLength characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, dots and underscores';
    }

    return null;
  }

  // Name validation (letters, spaces, hyphens)
  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName is required' : 'Name is required';
    }

    if (value.trim().length < 2) {
      return fieldName != null
          ? '$fieldName must be at least 2 characters'
          : 'Must be at least 2 characters';
    }

    if (!RegExp(r'^[a-zA-ZčćđšžČĆĐŠŽ\s\-]+$').hasMatch(value.trim())) {
      return fieldName != null
          ? '$fieldName can only contain letters, spaces and hyphens'
          : 'Can only contain letters, spaces and hyphens';
    }

    return null;
  }

  // Dropdown validation
  static String? validateDropdown<T>(T? value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null
          ? 'Molimo odaberite $fieldName'
          : 'Molimo odaberite opciju';
    }
    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
