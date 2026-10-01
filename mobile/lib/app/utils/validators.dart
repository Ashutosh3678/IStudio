class Validators {
  const Validators._();

  static final _phoneDigits = RegExp(r'^\d{10}$');
  static final _username = RegExp(r'^[A-Za-z0-9_]{3,24}$');
  static final _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }
    return digits;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your email address';
    if (!_email.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? username(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter a username';
    if (!_username.hasMatch(trimmed)) {
      return 'Use 3-24 letters, numbers, or underscores';
    }
    return null;
  }

  static String? phone(String? value) {
    final digits = normalizePhone(value ?? '');
    if (digits.isEmpty) return 'Enter your phone number';
    if (!_phoneDigits.hasMatch(digits)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? password(String? value, {bool isNew = false}) {
    final password = value ?? '';
    if (password.isEmpty) {
      return isNew ? 'Create a password' : 'Enter your password';
    }
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static final _scheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://');
  static final _host = RegExp(r'^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}$');
  static final _handle = RegExp(r'^@?[A-Za-z0-9._-]{1,50}$');

  /// Parses a web link, adding `https://` when the scheme is omitted.
  /// Returns null unless it is an http(s) URL with a real domain.
  static Uri? parseUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'\s'))) return null;
    final uri = Uri.tryParse(
      _scheme.hasMatch(trimmed) ? trimmed : 'https://$trimmed',
    );
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    if (!_host.hasMatch(uri.host.toLowerCase())) return null;
    return uri;
  }

  static const instagramDomains = ['instagram.com', 'instagr.am'];
  static const youtubeDomains = ['youtube.com', 'youtu.be'];

  /// True when [value] is a link rather than a bare handle. Handles may
  /// contain dots, so only a scheme, a path or a known domain counts.
  static bool looksLikeUrl(String value, {List<String> domains = const []}) {
    final lower = value.toLowerCase();
    return _scheme.hasMatch(value) ||
        value.contains('/') ||
        domains.any(lower.contains);
  }

  static String? url(
    String? value, {
    String label = 'link',
    bool required = false,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return required ? 'Enter your $label' : null;
    if (parseUrl(trimmed) == null) {
      return 'Enter a valid $label (e.g. yourstudio.com)';
    }
    return null;
  }

  /// Accepts either a handle (`@yourstudio`) or a link on one of [domains].
  static String? socialLink(
    String? value, {
    required String label,
    required List<String> domains,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final example = '@yourstudio or ${domains.first}/yourstudio';
    if (!looksLikeUrl(trimmed, domains: domains)) {
      return _handle.hasMatch(trimmed)
          ? null
          : 'Enter a valid $label handle or link ($example)';
    }
    final uri = parseUrl(trimmed);
    final host = uri?.host.toLowerCase().replaceFirst(
      RegExp(r'^(www|m)\.'),
      '',
    );
    final onDomain =
        host != null && domains.any((d) => host == d || host.endsWith('.$d'));
    if (!onDomain) return 'Enter a valid $label link ($example)';
    return null;
  }

  static String? instagram(String? value) =>
      socialLink(value, label: 'Instagram', domains: instagramDomains);

  static String? youtube(String? value) =>
      socialLink(value, label: 'YouTube', domains: youtubeDomains);

  static String? website(String? value) => url(value, label: 'website link');
}
