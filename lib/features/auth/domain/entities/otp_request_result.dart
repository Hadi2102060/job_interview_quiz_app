import 'package:equatable/equatable.dart';

/// Result returned from the `send_otp` endpoint. The repository hands
/// this back to the presentation layer along with the phone number
/// that was used (so the OTP screen can display it).
class OtpRequestResult extends Equatable {
  final String phoneNumber;
  final String referenceNo;
  final String? statusCode;
  final String? statusDetail;

  const OtpRequestResult({
    required this.phoneNumber,
    required this.referenceNo,
    this.statusCode,
    this.statusDetail,
  });

  @override
  List<Object?> get props =>
      [phoneNumber, referenceNo, statusCode, statusDetail];
}