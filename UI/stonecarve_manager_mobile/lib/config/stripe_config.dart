/// Stripe Configuration
///
/// IMPORTANT: This uses TEST keys for development.
/// Before going to production, replace with LIVE keys and move to environment variables.
class StripeConfig {
  // Stripe Publishable Key (Safe to expose in client-side code)
  // Get this from: https://dashboard.stripe.com/test/apikeys
  static const String publishableKey =
      'pk_test_51QkXtqP3Qv3nEfp1dqHhz0AYPuCnoamCT1X95IDpOFXrC9jgC6AUxlKglJQ8cSaxlP0ghKO0Tl9SQFxA39LzE6uq00FZI0QiVe';

  // Merchant identifier (for Apple Pay - optional)
  static const String merchantIdentifier = 'merchant.com.stonecarve.manager';

  // URL scheme for return URL (for 3D Secure redirects)
  static const String urlScheme = 'stonecarve';

  /// Test card numbers for Stripe Test Mode:
  /// - Success: 4242 4242 4242 4242
  /// - Decline: 4000 0000 0000 0002
  /// - Requires Authentication (3D Secure): 4000 0027 6000 3184
  /// - Insufficient Funds: 4000 0000 0000 9995
  ///
  /// Use any future expiry date, any 3 digits for CVC, and any 5 digits for ZIP.
}
