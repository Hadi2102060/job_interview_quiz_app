import 'package:shared_preferences/shared_preferences.dart';

import '../api_constants.dart';

/// Thin wrapper over [SharedPreferences] that keeps every persistence
/// concern for the auth flow in a single place.
///
/// Repositories depend on this — never on [SharedPreferences] directly.
class LocalStorageService {
  LocalStorageService._(this._prefs);

  final SharedPreferences _prefs;

  /// Build a service backed by the singleton SharedPreferences instance.
  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  // -------- Onboarding --------

  bool get isOnboardingCompleted =>
      _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(StorageKeys.onboardingCompleted, value);

  // -------- Login state --------

  bool get isLoggedIn => _prefs.getBool(StorageKeys.isLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(StorageKeys.isLoggedIn, value);

  // -------- Tokens --------

  String? get accessToken => _prefs.getString(StorageKeys.accessToken);

  Future<void> setAccessToken(String? value) async {
    if (value == null) {
      await _prefs.remove(StorageKeys.accessToken);
    } else {
      await _prefs.setString(StorageKeys.accessToken, value);
    }
  }

  String? get refreshToken => _prefs.getString(StorageKeys.refreshToken);

  Future<void> setRefreshToken(String? value) async {
    if (value == null) {
      await _prefs.remove(StorageKeys.refreshToken);
    } else {
      await _prefs.setString(StorageKeys.refreshToken, value);
    }
  }

  String? get subscriberId => _prefs.getString(StorageKeys.subscriberId);

  Future<void> setSubscriberId(String? value) async {
    if (value == null) {
      await _prefs.remove(StorageKeys.subscriberId);
    } else {
      await _prefs.setString(StorageKeys.subscriberId, value);
    }
  }

  // -------- OTP flow helpers --------

  String? get lastPhoneNumber => _prefs.getString(StorageKeys.lastPhoneNumber);

  Future<void> setLastPhoneNumber(String value) =>
      _prefs.setString(StorageKeys.lastPhoneNumber, value);

  String? get lastReferenceNo =>
      _prefs.getString(StorageKeys.lastReferenceNo);

  Future<void> setLastReferenceNo(String value) =>
      _prefs.setString(StorageKeys.lastReferenceNo, value);

  Future<void> clearLastReferenceNo() =>
      _prefs.remove(StorageKeys.lastReferenceNo);

  /// Logout — wipes login state and transient OTP session data but
  /// preserves the onboarding flag.
  Future<void> logout() async {
    await _prefs.setBool(StorageKeys.isLoggedIn, false);
    await _prefs.remove(StorageKeys.accessToken);
    await _prefs.remove(StorageKeys.refreshToken);
    await _prefs.remove(StorageKeys.subscriberId);
    await _prefs.remove(StorageKeys.lastReferenceNo);
    // onboardingCompleted and lastPhoneNumber intentionally preserved.
  }

  /// Used by automated tests.
  Future<void> clearAll() => _prefs.clear();
}