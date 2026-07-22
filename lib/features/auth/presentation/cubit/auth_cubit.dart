import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_request_result.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Holds the state for the phone → OTP → home sub-flow. Emits immutable
/// states so widgets can rebuild predictably.
class AuthState extends Equatable {
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isCheckingSubscription;
  final OtpRequestResult? lastOtpRequest;
  final AuthSession? session;
  final String? errorMessage;

  const AuthState({
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isCheckingSubscription = false,
    this.lastOtpRequest,
    this.session,
    this.errorMessage,
  });

  const AuthState.initial() : this();

  bool get isBusy => isSendingOtp || isVerifyingOtp;

  AuthState copyWith({
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isCheckingSubscription,
    OtpRequestResult? lastOtpRequest,
    AuthSession? session,
    String? errorMessage,
    bool clearError = false,
    bool clearRequest = false,
  }) {
    return AuthState(
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
        isCheckingSubscription:
          isCheckingSubscription ?? this.isCheckingSubscription,
      lastOtpRequest: clearRequest
          ? null
          : (lastOtpRequest ?? this.lastOtpRequest),
      session: session ?? this.session,
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isSendingOtp,
        isVerifyingOtp,
        isCheckingSubscription,
        lastOtpRequest,
        session,
        errorMessage,
      ];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required CheckSubscriptionUseCase checkSubscription,
    required SendOtpUseCase sendOtp,
    required VerifyOtpUseCase verifyOtp,
    required LogoutUseCase logout,
  })  : _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        _checkSubscription = checkSubscription,
        _logout = logout,
        super(const AuthState.initial());

  final CheckSubscriptionUseCase _checkSubscription;
  final SendOtpUseCase _sendOtp;
  final VerifyOtpUseCase _verifyOtp;
  final LogoutUseCase _logout;

  /// Decide whether to route directly home or continue to OTP.
  Future<String?> checkSubscription(String phoneNumber) async {
    if (state.isCheckingSubscription) return null;
    emit(state.copyWith(
      isCheckingSubscription: true,
      clearError: true,
      clearRequest: true,
    ));
    try {
      final result = await _checkSubscription(phoneNumber);
      emit(state.copyWith(isCheckingSubscription: false));
      return result.isRegistered ? 'home' : 'otp';
    } on ValidationFailure catch (e) {
      emit(state.copyWith(
        isCheckingSubscription: false,
        errorMessage: e.message,
      ));
      return null;
    } on NetworkFailure catch (e) {
      emit(state.copyWith(
        isCheckingSubscription: false,
        errorMessage: e.message,
      ));
      return null;
    } on ServerFailure catch (e) {
      emit(state.copyWith(
        isCheckingSubscription: false,
        errorMessage: e.message,
      ));
      return null;
    } on ParsingFailure catch (e) {
      emit(state.copyWith(
        isCheckingSubscription: false,
        errorMessage: e.message,
      ));
      return null;
    } catch (_) {
      const msg = 'Something went wrong. Please try again.';
      emit(state.copyWith(isCheckingSubscription: false, errorMessage: msg));
      return null;
    }
  }

  /// Request an OTP. Returns null on success, or a user-facing error
  /// message when something goes wrong.
  Future<String?> requestOtp(String phoneNumber) async {
    if (state.isSendingOtp) return null; // prevent rapid double-taps
    emit(state.copyWith(
      isSendingOtp: true,
      clearError: true,
      clearRequest: true,
    ));
    try {
      final result = await _sendOtp(phoneNumber);
      emit(state.copyWith(
        isSendingOtp: false,
        lastOtpRequest: result,
      ));
      return null;
    } on ValidationFailure catch (e) {
      emit(state.copyWith(isSendingOtp: false, errorMessage: e.message));
      return e.message;
    } on NetworkFailure catch (e) {
      emit(state.copyWith(isSendingOtp: false, errorMessage: e.message));
      return e.message;
    } on ServerFailure catch (e) {
      emit(state.copyWith(isSendingOtp: false, errorMessage: e.message));
      return e.message;
    } on ParsingFailure catch (e) {
      emit(state.copyWith(isSendingOtp: false, errorMessage: e.message));
      return e.message;
    } catch (_) {
      const msg = 'Something went wrong. Please try again.';
      emit(state.copyWith(isSendingOtp: false, errorMessage: msg));
      return msg;
    }
  }

  /// Verify the OTP. Returns null on success, an error message otherwise.
  Future<String?> submitOtp({
    required String phoneNumber,
    required String referenceNo,
    required String otp,
  }) async {
    if (state.isVerifyingOtp) return null;
    emit(state.copyWith(
      isVerifyingOtp: true,
      clearError: true,
    ));
    try {
      final session = await _verifyOtp(
        phoneNumber: phoneNumber,
        referenceNo: referenceNo,
        otp: otp,
      );
      emit(state.copyWith(isVerifyingOtp: false, session: session));
      return null;
    } on ValidationFailure catch (e) {
      emit(state.copyWith(isVerifyingOtp: false, errorMessage: e.message));
      return e.message;
    } on InvalidOtpFailure catch (e) {
      emit(state.copyWith(isVerifyingOtp: false, errorMessage: e.message));
      return e.message;
    } on NetworkFailure catch (e) {
      emit(state.copyWith(isVerifyingOtp: false, errorMessage: e.message));
      return e.message;
    } on ServerFailure catch (e) {
      emit(state.copyWith(isVerifyingOtp: false, errorMessage: e.message));
      return e.message;
    } on ParsingFailure catch (e) {
      emit(state.copyWith(isVerifyingOtp: false, errorMessage: e.message));
      return e.message;
    } catch (_) {
      const msg = 'Something went wrong. Please try again.';
      emit(state.copyWith(isVerifyingOtp: false, errorMessage: msg));
      return msg;
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(AuthState.initial());
  }

  /// Clear any shown error — used when the screen rebuilds or the user
  /// edits the input.
  void clearError() => emit(state.copyWith(clearError: true));
}
