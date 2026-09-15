class ApiConfig {
  const ApiConfig._();

  /// Deployed backend origin. Edit this when the Cloudflare URL changes.
  /// Do not include a trailing slash or `/api`.
  static const String backendUrl = 'https://istudio-1-txuo.onrender.com/';
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get origin {
    final api = baseUrl;
    return api.endsWith('/api') ? api.substring(0, api.length - 4) : api;
  }

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return '$backendUrl/api';
  }

  static String resolveMedia(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final p = path.trim();
    if (p.startsWith('http://') ||
        p.startsWith('https://') ||
        p.startsWith('data:image/') ||
        p.startsWith('file://') ||
        p.startsWith('content://')) {
      return p;
    }
    if (!p.startsWith('/')) {
      return '$origin/$p';
    }
    return '$origin$p';
  }
}
