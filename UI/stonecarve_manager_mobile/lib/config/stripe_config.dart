/// Stripe Configuration
///
/// Keys are supplied via --dart-define at build / run time:
///   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
///
/// The defaults below are **test-mode** fallbacks for local development only.
class StripeConfig {
  // Stripe Publishable Key
  // Override with: --dart-define=STRIPE_PUBLISHABLE_KEY=<your_key>
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51QkXtqP3Qv3nEfp1dqHhz0AYPuCnoamCT1X95IDpOFXrC9jgC6AUxlKglJQ8cSaxlP0ghKO0Tl9SQFxA39LzE6uq00FZI0QiVe',
  );

  // Merchant identifier (for Apple Pay)
  // Override with: --dart-define=STRIPE_MERCHANT_ID=<your_id>
  static const String merchantIdentifier = String.fromEnvironment(
    'STRIPE_MERCHANT_ID',
    defaultValue: 'merchant.com.stonecarve.manager',
  );

  // URL scheme for return URL (for 3D Secure redirects)
  // Override with: --dart-define=STRIPE_URL_SCHEME=<your_scheme>
  static const String urlScheme = String.fromEnvironment(
    'STRIPE_URL_SCHEME',
    defaultValue: 'stonecarve',
  );

  /// Test card numbers for Stripe Test Mode:
  /// - Success: 4242 4242 4242 4242
  /// - Decline: 4000 0000 0000 0002
  /// - Requires Authentication (3D Secure): 4000 0027 6000 3184
  /// - Insufficient Funds: 4000 0000 0000 9995
  ///
  /// Use any future expiry date, any 3 digits for CVC, and any 5 digits for ZIP.
}
