import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  /// Point this at your machine IP when testing on a physical phone.
  static const String _lanOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_lanOverride.isNotEmpty) return _lanOverride;

    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5000/api';
      default:
        return 'http://localhost:5000/api';
    }
  }
}
