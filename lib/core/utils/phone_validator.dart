/// Validates Bangladeshi mobile numbers for the BDApps subscription flow.
///
/// Only Robi (018, 016) and Airtel (013) prefixes are accepted because
/// those are the operators the app subscribes the user to.
class PhoneValidator {
  PhoneValidator._();

  /// Allowed operator prefixes — keep in sync with the requirement.
  static const List<String> supportedPrefixes = ['018', '016', '013'];

  /// Strip everything that isn't a digit. Useful because users sometimes
  /// paste numbers with spaces or dashes.
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'\D+'), '');
  }

  /// Returns true only if [phone] is a valid 11-digit BD number with one of
  /// the supported prefixes (013/016/018).
  static bool isValid(String phone) {
    final digits = sanitize(phone);
    if (digits.length != 11) return false;
    if (!digits.startsWith('01')) return false;
    final prefix = digits.substring(0, 3);
    return supportedPrefixes.contains(prefix);
  }

  /// Returns a user-friendly validation error message or `null` when valid.
  static String? validate(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final digits = sanitize(phone);
    if (digits.length != 11) {
      return 'Phone number must be 11 digits';
    }
    if (!digits.startsWith('01')) {
      return 'Phone number must start with 01';
    }
    final prefix = digits.substring(0, 3);
    if (!supportedPrefixes.contains(prefix)) {
      return 'Only Robi (018/016) and Airtel (013) numbers are supported';
    }
    return null;
  }

  /// Detect the operator from a valid phone number. Returns null if invalid.
  static String? operator(String phone) {
    if (!isValid(phone)) return null;
    final prefix = sanitize(phone).substring(0, 3);
    if (prefix == '013') return 'Airtel';
    return 'Robi';
  }
}