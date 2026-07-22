import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/failures.dart';
import '../../../../core/utils/phone_validator.dart';
import '../entities/auth_session.dart';
import '../entities/otp_request_result.dart';
import '../repositories/auth_repository.dart';

/// Use-case: check whether the phone number is already subscribed.
class CheckSubscriptionUseCase {
  final AuthRepository _repository;
  const CheckSubscriptionUseCase(this._repository);

  Future<SubscriptionStatusResult> call(String phoneNumber) async {
    final err = PhoneValidator.validate(phoneNumber);
    if (err != null) {
      throw ValidationFailure(err);
    }
    final normalized = PhoneValidator.sanitize(phoneNumber);
    return _repository.checkSubscription(normalized);
  }
}

/// Use-case: send an OTP to a Bangladeshi Robi/Airtel number.
///
/// Validates the number locally first so that the user gets instant
/// feedback without burning a network round-trip.
class SendOtpUseCase {
  final AuthRepository _repository;
  const SendOtpUseCase(this._repository);

  Future<OtpRequestResult> call(String phoneNumber) async {
    final err = PhoneValidator.validate(phoneNumber);
    if (err != null) {
      throw ValidationFailure(err);
    }
    final normalized = PhoneValidator.sanitize(phoneNumber);
    return _repository.sendOtp(normalized);
  }
}

/// Use-case: verify the 6-digit OTP issued by BDApps.
class VerifyOtpUseCase {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  Future<AuthSession> call({
    required String phoneNumber,
    required String referenceNo,
    required String otp,
  }) {
    if (otp.trim().length < 4) {
      throw const ValidationFailure('Please enter the OTP sent to your phone');
    }
    return _repository.verifyOtp(
      phoneNumber: PhoneValidator.sanitize(phoneNumber),
      referenceNo: referenceNo,
      otp: otp.trim(),
    );
  }
}

/// Use-case: log the user out without touching the onboarding flag.
class LogoutUseCase {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}

/// Use-case: short-circuit the splash screen.
class BootstrapDecision {
  final LocalStorageService _storage;
  const BootstrapDecision(this._storage);

  /// First install → onboarding. Logged in → home. Otherwise → phone.
  Future<BootstrapTarget> resolve() async {
    if (!_storage.isOnboardingCompleted) {
      return BootstrapTarget.onboarding;
    }
    if (_storage.isLoggedIn) {
      return BootstrapTarget.home;
    }
    return BootstrapTarget.phone;
  }
}

enum BootstrapTarget { onboarding, phone, home }
