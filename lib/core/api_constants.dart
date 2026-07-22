/// Centralised constants for the BDApps SDK endpoints used by the
/// phone-OTP authentication flow.
///
/// Override `BDAPPS_GATEWAY_BASE_URL` with `--dart-define` when pointing
/// at a different gateway. Default is the production QuizForge API.
class ApiConstants {
  ApiConstants._();

  static const String productionBaseUrl =
      'https://bdapps.flicksize.com/QuizForge/api';

  static const String _configuredBaseUrl = String.fromEnvironment(
    'BDAPPS_GATEWAY_BASE_URL',
    defaultValue: '',
  );

  /// Base URL of the BDApps PHP gateway.
  ///
  /// Priority:
  /// 1. `--dart-define=BDAPPS_GATEWAY_BASE_URL=https://...`
  /// 2. Production QuizForge gateway
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
    return productionBaseUrl;
  }

  /// Send OTP endpoint — accepts `user_mobile` and returns a `referenceNo`.
  static String get sendOtpEndpoint => '$baseUrl/send_otp.php';

  /// Check subscription endpoint — returns whether the number is already registered.
  static String get checkSubscriptionEndpoint =>
      '$baseUrl/check_subscription.php';

  /// Verify OTP endpoint — accepts `Otp` and `referenceNo`.
  static String get verifyOtpEndpoint => '$baseUrl/verify_otp.php';

  /// Unsubscribe endpoint — accepts `user_mobile` and cancels BDApps subscription.
  /// Live URL: https://bdapps.flicksize.com/QuizForge/api/unsubscribe.php
  static String get unsubscribeEndpoint => '$baseUrl/unsubscribe.php';

  /// Common headers — PHP endpoints read form fields, not JSON.
  static const Map<String, String> formHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  /// Reasonable HTTP timeout — BDApps upstream can take a few seconds.
  static const Duration requestTimeout = Duration(seconds: 30);
}

/// SharedPreferences keys used by the auth flow.
class StorageKeys {
  StorageKeys._();

  static const String onboardingCompleted = 'onboardingCompleted';
  static const String isLoggedIn = 'isLoggedIn';
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String subscriberId = 'subscriberId';
  static const String lastPhoneNumber = 'lastPhoneNumber';
  static const String lastReferenceNo = 'lastReferenceNo';
}