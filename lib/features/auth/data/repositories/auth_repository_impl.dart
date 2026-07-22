import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_request_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/bdapps_api_client.dart';

/// Production [AuthRepository] backed by [BdappsApiClient] and
/// [LocalStorageService].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required BdappsApiClient apiClient,
    required LocalStorageService storage,
  })  : _api = apiClient,
        _storage = storage;

  final BdappsApiClient _api;
  final LocalStorageService _storage;

  @override
  Future<SubscriptionStatusResult> checkSubscription(String phoneNumber) async {
    final response = await _api.checkSubscription(phoneNumber);
    if (response.isSubscribed) {
      await _storage.setLoggedIn(true);
      await _storage.setSubscriberId('tel:88$phoneNumber');
      await _storage.setLastPhoneNumber(phoneNumber);
    }
    return response.toEntity(phoneNumber);
  }

  @override
  Future<OtpRequestResult> sendOtp(String phoneNumber) async {
    final response = await _api.sendOtp(phoneNumber);
    if (!response.success || (response.referenceNo ?? '').isEmpty) {
      throw ServerFailure(
        response.message ??
            response.statusDetail ??
            'Unable to send OTP. Please try again.',
      );
    }
    final result = response.toEntity(phoneNumber);
    await _storage.setLastPhoneNumber(phoneNumber);
    await _storage.setLastReferenceNo(result.referenceNo);
    return result;
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phoneNumber,
    required String referenceNo,
    required String otp,
  }) async {
    final response = await _api.verifyOtp(
      referenceNo: referenceNo,
      otp: otp,
    );
    if (!response.isSuccess) {
      throw InvalidOtpFailure(
        response.statusDetail.isNotEmpty
            ? response.statusDetail
            : 'Incorrect OTP. Please try again.',
      );
    }
    final session = AuthSession(
      phoneNumber: phoneNumber,
      subscriberId: response.subscriberId.isNotEmpty
          ? response.subscriberId
          : 'tel:88$phoneNumber',
      referenceNo: referenceNo,
      subscriptionStatus: response.subscriptionStatus,
    );
    await _persistSession(session);
    return session;
  }

  @override
  Future<void> logout() => _storage.logout();

  @override
  Future<bool> isLoggedIn() async => _storage.isLoggedIn;

  @override
  Future<bool> isOnboardingCompleted() async =>
      _storage.isOnboardingCompleted;

  Future<void> _persistSession(AuthSession session) async {
    await _storage.setLoggedIn(true);
    await _storage.setSubscriberId(session.subscriberId);
    if (session.accessToken != null) {
      await _storage.setAccessToken(session.accessToken);
    }
    if (session.refreshToken != null) {
      await _storage.setRefreshToken(session.refreshToken);
    }
    await _storage.clearLastReferenceNo();
  }
}