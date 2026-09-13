import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  /// Full URL override: `--dart-define=API_BASE_URL=http://192.168.1.9:5000/api`
  static const String _lanOverride = String.fromEnvironment('API_BASE_URL');

  /// Your computer's Wi-Fi IP. Update this if it changes.
  /// Emulator-only alias `10.0.2.2` does not work on a real phone.
  static const String androidHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '192.168.1.9',
  );

  static String get origin {
    final api = baseUrl;
    return api.endsWith('/api') ? api.substring(0, api.length - 4) : api;
  }

  static String resolveMedia(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$origin$path';
  }

  static String get baseUrl {
    if (_lanOverride.isNotEmpty) return _lanOverride;

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://$androidHost:5000/api';
      default:
        return 'http://localhost:5000/api';
    }
  }
}
