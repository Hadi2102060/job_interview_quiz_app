import '../../domain/entities/otp_request_result.dart';
import '../../domain/repositories/auth_repository.dart';

/// Raw response from `send_otp.php` — the server returns a `success`
/// flag plus a `referenceNo` we must hand back to `verify_otp.php`.
class SendOtpResponse {
  final bool success;
  final String? referenceNo;
  final String? statusCode;
  final String? statusDetail;
  final String? message;

  const SendOtpResponse({
    required this.success,
    this.referenceNo,
    this.statusCode,
    this.statusDetail,
    this.message,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] == true,
      referenceNo: json['referenceNo']?.toString(),
      statusCode: json['statusCode']?.toString(),
      statusDetail: json['statusDetail']?.toString(),
      message: json['message']?.toString(),
    );
  }

  OtpRequestResult toEntity(String phoneNumber) {
    return OtpRequestResult(
      phoneNumber: phoneNumber,
      referenceNo: referenceNo ?? '',
      statusCode: statusCode,
      statusDetail: statusDetail,
    );
  }
}

/// Raw response from `check_subscription.php`.
class CheckSubscriptionResponse {
  final bool isSubscribed;
  final String subscriptionStatus;
  final String? statusCode;
  final String? statusDetail;

  const CheckSubscriptionResponse({
    required this.isSubscribed,
    required this.subscriptionStatus,
    this.statusCode,
    this.statusDetail,
  });

  factory CheckSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    final status = json['subscriptionStatus']?.toString() ?? '';
    final isSubscribed = json['isSubscribed'] == true ||
        status.toUpperCase() == 'REGISTERED';
    return CheckSubscriptionResponse(
      isSubscribed: isSubscribed,
      subscriptionStatus: status.isNotEmpty
          ? status
          : (isSubscribed ? 'REGISTERED' : 'UNREGISTERED'),
      statusCode: json['statusCode']?.toString(),
      statusDetail: json['statusDetail']?.toString(),
    );
  }

  SubscriptionStatusResult toEntity(String phoneNumber) {
    return SubscriptionStatusResult(
      phoneNumber: phoneNumber,
      isRegistered: isSubscribed,
      statusCode: statusCode,
      statusDetail: statusDetail,
      subscriptionStatus: subscriptionStatus,
    );
  }
}

/// Raw response from `verify_otp.php`. Success is signalled by
/// `statusCode == "S1000"` and `subscriptionStatus == "REGISTERED"`.
class VerifyOtpResponse {
  final String statusCode;
  final String statusDetail;
  final String subscriptionStatus;
  final String subscriberId;
  final String version;
  final String? message;

  const VerifyOtpResponse({
    required this.statusCode,
    required this.statusDetail,
    required this.subscriptionStatus,
    required this.subscriberId,
    required this.version,
    this.message,
  });

  bool get isSuccess =>
      statusCode.toUpperCase() == 'S1000' &&
      subscriptionStatus.toUpperCase() == 'REGISTERED';

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      statusCode: json['statusCode']?.toString() ?? 'FAILED',
      statusDetail: json['statusDetail']?.toString() ?? '',
      subscriptionStatus:
          json['subscriptionStatus']?.toString() ?? 'UNREGISTERED',
      subscriberId: json['subscriberId']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }
}