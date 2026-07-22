import '../entities/auth_session.dart';
import '../entities/otp_request_result.dart';

/// Subscription lookup result from BDApps.
class SubscriptionStatusResult {
  final String phoneNumber;
  final bool isRegistered;
  final String? statusCode;
  final String? statusDetail;
  final String? subscriptionStatus;

  const SubscriptionStatusResult({
    required this.phoneNumber,
    required this.isRegistered,
    this.statusCode,
    this.statusDetail,
    this.subscriptionStatus,
  });
}

/// Contract that the presentation layer talks to. Concrete implementations
/// live in `data/` and orchestrate the network + storage services.
abstract class AuthRepository {
  /// Check whether [phoneNumber] is already subscribed in BDApps.
  Future<SubscriptionStatusResult> checkSubscription(String phoneNumber);

  /// Ask BDApps to send an OTP to [phoneNumber]. Throws a [Failure]
  /// subclass on validation, network or server errors.
  Future<OtpRequestResult> sendOtp(String phoneNumber);

  /// Verify [otp] against the previously issued [referenceNo].
  /// On success the session is persisted and returned.
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String referenceNo,
    required String otp,
  });

  /// Wipe login state but keep the onboarding flag.
  Future<void> logout();

  /// True when the user has a persisted session.
  Future<bool> isLoggedIn();

  /// True when the onboarding flow has been completed at least once.
  Future<bool> isOnboardingCompleted();
}