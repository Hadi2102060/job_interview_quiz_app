import 'package:equatable/equatable.dart';

/// Result of a successful OTP verification. Contains the BDApps
/// subscription metadata and any tokens that were returned.
class AuthSession extends Equatable {
  final String phoneNumber;
  final String subscriberId;
  final String? referenceNo;
  final String? subscriptionStatus;
  final String? accessToken;
  final String? refreshToken;

  const AuthSession({
    required this.phoneNumber,
    required this.subscriberId,
    this.referenceNo,
    this.subscriptionStatus,
    this.accessToken,
    this.refreshToken,
  });

  bool get isActive =>
      subscriptionStatus != null &&
      subscriptionStatus!.toUpperCase() == 'REGISTERED';

  @override
  List<Object?> get props => [
        phoneNumber,
        subscriberId,
        referenceNo,
        subscriptionStatus,
        accessToken,
        refreshToken,
      ];
}