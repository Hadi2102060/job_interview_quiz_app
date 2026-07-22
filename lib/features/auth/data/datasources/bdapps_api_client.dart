import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/api_constants.dart';
import '../../../../core/utils/failures.dart';
import '../models/send_otp_response.dart';

/// Talks to the BDApps PHP gateway over HTTPS. The gateway proxies the
/// real `developer.bdapps.com` endpoints, so this class only has to
/// translate between Dart exceptions and the lightweight [Failure] types.
class BdappsApiClient {
  BdappsApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// POST `user_mobile=<digits>` to `check_subscription.php` and return
  /// the parsed response.
  Future<CheckSubscriptionResponse> checkSubscription(String phoneNumber) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.checkSubscriptionEndpoint),
            headers: ApiConstants.formHeaders,
            body: {'user_mobile': phoneNumber},
          )
          .timeout(ApiConstants.requestTimeout);

      final body = _safeDecode(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CheckSubscriptionResponse.fromJson(body);
      }
      throw ServerFailure(
        body['message']?.toString() ??
            'Failed to check subscription (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const NetworkFailure(
        'Request timed out. Please check your internet connection.',
      );
    } on SocketException {
      throw const NetworkFailure(
        'No internet connection. Please reconnect and try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } on FormatException {
      throw const ParsingFailure();
    }
  }

  /// POST `user_mobile=<digits>` to `send_otp.php` and return the parsed
  /// response.
  Future<SendOtpResponse> sendOtp(String phoneNumber) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.sendOtpEndpoint),
            headers: ApiConstants.formHeaders,
            body: {'user_mobile': phoneNumber},
          )
          .timeout(ApiConstants.requestTimeout);

      final body = _safeDecode(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SendOtpResponse.fromJson(body);
      }
      throw ServerFailure(
        body['message']?.toString() ??
            'Failed to send OTP (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const NetworkFailure(
        'Request timed out. Please check your internet connection.',
      );
    } on SocketException {
      throw const NetworkFailure(
        'No internet connection. Please reconnect and try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } on FormatException {
      throw const ParsingFailure();
    }
  }

  /// POST `Otp=<code>&referenceNo=<ref>` to `verify_otp.php`.
  Future<VerifyOtpResponse> verifyOtp({
    required String referenceNo,
    required String otp,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.verifyOtpEndpoint),
            headers: ApiConstants.formHeaders,
            body: {'Otp': otp, 'referenceNo': referenceNo},
          )
          .timeout(ApiConstants.requestTimeout);

      final body = _safeDecode(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerFailure(
          body['message']?.toString() ??
              'Failed to verify OTP (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
      return VerifyOtpResponse.fromJson(body);
    } on TimeoutException {
      throw const NetworkFailure(
        'Request timed out. Please check your internet connection.',
      );
    } on SocketException {
      throw const NetworkFailure(
        'No internet connection. Please reconnect and try again.',
      );
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } on FormatException {
      throw const ParsingFailure();
    }
  }

  Map<String, dynamic> _safeDecode(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'raw': decoded};
    } on FormatException {
      throw ParsingFailure('Server returned an invalid response.');
    }
  }
}