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
      return 'Unesite validnu email adresu';
    }

    return null;
  }

  // Password validation - minimum 6 characters
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Lozinka je obavezna';
    }

    if (value.length < minLength) {
      return 'Lozinka mora imati najmanje $minLength karaktera';
    }

    return null;
  }

  // Strong password validation - requires uppercase, lowercase, number
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lozinka je obavezna';
    }

    if (value.length < 8) {
      return 'Lozinka mora imati najmanje 8 karaktera';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Lozinka mora sadržavati bar jedno veliko slovo';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Lozinka mora sadržavati bar jedno malo slovo';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Lozinka mora sadržavati bar jednu cifru';
    }

    return null;
  }

  // Required text field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName je obavezan'
          : 'Ovo polje je obavezno';
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
          ? '$fieldName je obavezan'
          : 'Ovo polje je obavezno';
    }

    if (value.trim().length < minLength) {
      return fieldName != null
          ? '$fieldName mora imati najmanje $minLength karaktera'
          : 'Mora imati najmanje $minLength karaktera';
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
          ? '$fieldName može imati maksimalno $maxLength karaktera'
          : 'Može imati maksimalno $maxLength karaktera';
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
          ? '$fieldName je obavezan'
          : 'Ovo polje je obavezno';
    }

    final length = value.trim().length;

    if (length < minLength || length > maxLength) {
      return fieldName != null
          ? '$fieldName mora imati između $minLength i $maxLength karaktera'
          : 'Mora imati između $minLength i $maxLength karaktera';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Broj telefona je obavezan' : null;
    }

    // Remove spaces, dashes, and parentheses
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it contains only digits and optional + at start
    if (!RegExp(r'^\+?[0-9]{6,15}$').hasMatch(cleaned)) {
      return 'Unesite validan broj telefona';
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
                ? '$fieldName je obavezan'
                : 'Ovo polje je obavezno')
          : null;
    }

    final number = double.tryParse(value.trim());

    if (number == null) {
      return 'Unesite validan broj';
    }

    if (number <= 0) {
      return fieldName != null
          ? '$fieldName mora biti veći od 0'
          : 'Mora biti veći od 0';
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
                ? '$fieldName je obavezan'
                : 'Ovo polje je obavezno')
          : null;
    }

    final number = double.tryParse(value.trim());

    if (number == null) {
      return 'Unesite validan broj';
    }

    if (number < 0) {
      return fieldName != null
          ? '$fieldName ne može biti negativan'
          : 'Ne može biti negativan';
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
                ? '$fieldName je obavezan'
                : 'Ovo polje je obavezno')
          : null;
    }

    if (int.tryParse(value.trim()) == null) {
      return 'Unesite validan cijeli broj';
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
                ? '$fieldName je obavezan'
                : 'Ovo polje je obavezno')
          : null;
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Unesite validan cijeli broj';
    }

    if (number <= 0) {
      return fieldName != null
          ? '$fieldName mora biti veći od 0'
          : 'Mora biti veći od 0';
    }

    return null;
  }

  // Year validation (1900-current year + 10)
  static String? validateYear(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Godina je obavezna' : null;
    }

    final year = int.tryParse(value.trim());

    if (year == null) {
      return 'Unesite validnu godinu';
    }

    final currentYear = DateTime.now().year;

    if (year < 1900 || year > currentYear + 10) {
      return 'Godina mora biti između 1900 i ${currentYear + 10}';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'URL je obavezan' : null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Unesite validan URL (mora počinjati sa http:// ili https://)';
    }

    return null;
  }

  // Price validation (positive decimal with max 2 decimal places)
  static String? validatePrice(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Cijena je obavezna' : null;
    }

    final price = double.tryParse(value.trim());

    if (price == null) {
      return 'Unesite validnu cijenu';
    }

    if (price < 0) {
      return 'Cijena ne može biti negativna';
    }

    // Check for max 2 decimal places
    if (value.contains('.') && value.split('.')[1].length > 2) {
      return 'Cijena može imati maksimalno 2 decimale';
    }

    return null;
  }

  // Username validation (alphanumeric, underscore, dot)
  static String? validateUsername(String? value, {int minLength = 3}) {
    if (value == null || value.trim().isEmpty) {
      return 'Korisničko ime je obavezno';
    }

    if (value.trim().length < minLength) {
      return 'Korisničko ime mora imati najmanje $minLength karaktera';
    }

    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value.trim())) {
      return 'Korisničko ime može sadržavati samo slova, brojeve, tačke i donje crte';
    }

    return null;
  }

  // Name validation (letters, spaces, hyphens)
  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName je obavezan' : 'Ime je obavezno';
    }

    if (value.trim().length < 2) {
      return fieldName != null
          ? '$fieldName mora imati najmanje 2 karaktera'
          : 'Mora imati najmanje 2 karaktera';
    }

    if (!RegExp(r'^[a-zA-ZčćđšžČĆĐŠŽ\s\-]+$').hasMatch(value.trim())) {
      return fieldName != null
          ? '$fieldName može sadržavati samo slova, razmake i crtice'
          : 'Može sadržavati samo slova, razmake i crtice';
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
