/// Base failure type used by the data layer. The presentation layer
/// maps these to user-facing messages.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType($message)';
}

/// Raised when the network is unreachable, the request times out, or
/// the server returns a malformed body.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Internet connection unavailable. Please try again.',
  ]);
}

/// Raised when the server responds with a non-2xx status code.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Raised when the API returns a payload that cannot be parsed.
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Unexpected response from server.']);
}

/// Raised when the OTP verification is rejected (wrong / expired code).
class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure([
    super.message = 'Incorrect OTP. Please try again.',
  ]);
}

/// Raised when input does not match local validation rules.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}