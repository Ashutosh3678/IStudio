import 'dart:convert';
import 'package:http/http.dart' as http;

class ParsedCoordinates {
  const ParsedCoordinates({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.source = 'coordinates',
  });

  final double latitude;
  final double longitude;
  final String? placeName;
  final String source;

  @override
  String toString() => '$latitude, $longitude';
}

class GoogleMapsLocationParser {
  GoogleMapsLocationParser({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Regex for raw decimal coordinates: "17.372605, 78.459720" or "17.372605 78.459720"
  static final _rawCoordsRegex = RegExp(
    r'([-+]?\d{1,2}(?:\.\d+)?)[,\s]+([-+]?\d{1,3}(?:\.\d+)?)',
  );

  /// Regex for Degrees Minutes Seconds (DMS): 17°22'21.4"N 78°27'35.0"E
  static final _dmsRegex = RegExp(
    r'''(\d+)[°\s]+(\d+)['\s]+([\d.]+)"?\s*([NSns])[,\s]+(\d+)[°\s]+(\d+)['\s]+([\d.]+)"?\s*([EWew])''',
  );

  /// Regex for @lat,lng in Google Maps URLs: .../@17.372605,78.459720,17z...
  static final _atCoordsRegex = RegExp(
    r'@([-+]?\d{1,2}\.\d+),([-+]?\d{1,3}\.\d+)',
  );

  /// Regex for ?q=lat,lng or &q=lat,lng or &ll=lat,lng
  static final _queryCoordsRegex = RegExp(
    r'[?&](?:q|ll|query|saddr|daddr)=([-+]?\d{1,2}\.\d+)[,+ ]([-+]?\d{1,3}\.\d+)',
  );

  /// Regex for /search/lat,lng
  static final _searchCoordsRegex = RegExp(
    r'/search/([-+]?\d{1,2}\.\d+)[,+ ]([-+]?\d{1,3}\.\d+)',
  );

  /// Regex for staticmap / metadata: center=lat%2Clng or center=lat,lng
  static final _centerCoordsRegex = RegExp(
    r'center=([-+]?\d{1,2}\.\d+)(?:%2C|%2c|,)([-+]?\d{1,3}\.\d+)',
  );

  /// Regex for protobuf parameters in HTML: !3d(lat)!2d(lng) or !2d(lng)!3d(lat)
  static final _pbLatThenLngRegex = RegExp(
    r'!3d([-+]?\d{1,2}\.\d+)!2d([-+]?\d{1,3}\.\d+)',
  );
  static final _pbLngThenLatRegex = RegExp(
    r'!2d([-+]?\d{1,3}\.\d+)!3d([-+]?\d{1,2}\.\d+)',
  );

  /// Regex for /place/Place+Name/...
  static final _placeNameRegex = RegExp(
    r'/place/([^/@?#]+)',
  );

  /// Checks if the input string contains or represents a Google Maps URL.
  static bool isGoogleMapsUrl(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return false;
    return text.contains('maps.app.goo.gl') ||
        text.contains('goo.gl/maps') ||
        text.contains('google.com/maps') ||
        text.contains('maps.google.com');
  }

  /// Normalizes user input (handles missing https://, trims spaces, extracts URL if surrounded by text)
  static String normalizeInput(String input) {
    var text = input.trim();
    if (text.isEmpty) return '';

    // If text contains a URL (e.g. "Check out this place: https://maps.app.goo.gl/xxx"), extract it
    final urlMatch = RegExp(r'(https?://[^\s]+)').firstMatch(text);
    if (urlMatch != null) {
      return urlMatch.group(1)!;
    }

    // If starts with maps.app.goo.gl, goo.gl, or google.com/maps without https://
    if (text.startsWith('maps.app.goo.gl/') ||
        text.startsWith('goo.gl/maps/') ||
        text.startsWith('www.google.com/maps') ||
        text.startsWith('maps.google.com')) {
      return 'https://$text';
    }

    return text;
  }

  /// Tries to parse coordinates synchronously without network calls.
  static ParsedCoordinates? parseSync(String input) {
    final text = normalizeInput(input);
    if (text.isEmpty) return null;

    // 1. Try DMS coordinates
    final dmsMatch = _dmsRegex.firstMatch(text);
    if (dmsMatch != null) {
      final latDeg = double.tryParse(dmsMatch.group(1)!) ?? 0;
      final latMin = double.tryParse(dmsMatch.group(2)!) ?? 0;
      final latSec = double.tryParse(dmsMatch.group(3)!) ?? 0;
      final latHem = dmsMatch.group(4)!.toUpperCase();

      final lngDeg = double.tryParse(dmsMatch.group(5)!) ?? 0;
      final lngMin = double.tryParse(dmsMatch.group(6)!) ?? 0;
      final lngSec = double.tryParse(dmsMatch.group(7)!) ?? 0;
      final lngHem = dmsMatch.group(8)!.toUpperCase();

      var lat = latDeg + (latMin / 60) + (latSec / 3600);
      if (latHem == 'S') lat = -lat;

      var lng = lngDeg + (lngMin / 60) + (lngSec / 3600);
      if (lngHem == 'W') lng = -lng;

      if (_isValidLat(lat) && _isValidLng(lng)) {
        return ParsedCoordinates(
          latitude: lat,
          longitude: lng,
          source: 'dms',
        );
      }
    }

    // 2. Try URL coordinates (@lat,lng)
    final atMatch = _atCoordsRegex.firstMatch(text);
    if (atMatch != null) {
      final lat = double.tryParse(atMatch.group(1)!);
      final lng = double.tryParse(atMatch.group(2)!);
      if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
        return ParsedCoordinates(
          latitude: lat,
          longitude: lng,
          placeName: _extractPlaceName(text),
          source: 'google_maps_url',
        );
      }
    }

    // 3. Try URL query coordinates (?q=lat,lng)
    final queryMatch = _queryCoordsRegex.firstMatch(text);
    if (queryMatch != null) {
      final lat = double.tryParse(queryMatch.group(1)!);
      final lng = double.tryParse(queryMatch.group(2)!);
      if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
        return ParsedCoordinates(
          latitude: lat,
          longitude: lng,
          placeName: _extractPlaceName(text),
          source: 'google_maps_url',
        );
      }
    }

    // 4. Try URL /search/lat,lng
    final searchMatch = _searchCoordsRegex.firstMatch(text);
    if (searchMatch != null) {
      final lat = double.tryParse(searchMatch.group(1)!);
      final lng = double.tryParse(searchMatch.group(2)!);
      if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
        return ParsedCoordinates(
          latitude: lat,
          longitude: lng,
          source: 'google_maps_url',
        );
      }
    }

    // 5. Try plain decimal coordinates (e.g. 17.372605, 78.459720)
    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      final rawMatch = _rawCoordsRegex.firstMatch(text);
      if (rawMatch != null) {
        final lat = double.tryParse(rawMatch.group(1)!);
        final lng = double.tryParse(rawMatch.group(2)!);
        if (lat != null &&
            lng != null &&
            _isValidLat(lat) &&
            _isValidLng(lng)) {
          return ParsedCoordinates(
            latitude: lat,
            longitude: lng,
            source: 'raw_coordinates',
          );
        }
      }
    }

    return null;
  }

  /// Parses coordinates from string or resolves shortened Google Maps links (maps.app.goo.gl, goo.gl).
  Future<ParsedCoordinates?> parseAsync(String input) async {
    final clean = normalizeInput(input);
    if (clean.isEmpty) return null;

    // 1. Try sync parse first
    final syncResult = parseSync(clean);
    if (syncResult != null) return syncResult;

    // 2. If it's a URL, resolve redirects and extract coordinates
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      try {
        final resolved = await _resolveGoogleMapsUrl(clean);
        if (resolved != null) return resolved;
      } catch (_) {}
    }

    return null;
  }

  /// Resolves shortened Google Maps links and parses coordinates from redirect Location or HTML body.
  Future<ParsedCoordinates?> _resolveGoogleMapsUrl(String initialUrl) async {
    try {
      final uri = Uri.parse(initialUrl);

      // Follow redirects up to 3 hops
      var currentUri = uri;
      String? destinationUrl;
      String? placeNameFromUrl;

      for (int i = 0; i < 3; i++) {
        final req = http.Request('GET', currentUri)..followRedirects = false;
        req.headers['User-Agent'] =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

        final streamed = await _client.send(req).timeout(const Duration(seconds: 6));
        final loc = streamed.headers['location'];

        if (streamed.statusCode >= 300 && streamed.statusCode < 400 && loc != null) {
          destinationUrl = loc;
          final syncCheck = parseSync(loc);
          if (syncCheck != null) return syncCheck;

          // Check if place name is in redirect URL
          placeNameFromUrl ??= _extractPlaceName(loc);

          currentUri = Uri.parse(loc);
          continue;
        }

        // We reached the final destination page (200 OK)
        destinationUrl = currentUri.toString();
        placeNameFromUrl ??= _extractPlaceName(destinationUrl);

        final response = await http.Response.fromStream(streamed);
        final body = response.body;

        // 1. Check center=lat%2Clng in staticmap / og:image meta tags
        final centerMatch = _centerCoordsRegex.firstMatch(body);
        if (centerMatch != null) {
          final lat = double.tryParse(centerMatch.group(1)!);
          final lng = double.tryParse(centerMatch.group(2)!);
          if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
            return ParsedCoordinates(
              latitude: lat,
              longitude: lng,
              placeName: placeNameFromUrl,
              source: 'google_staticmap_center',
            );
          }
        }

        // 2. Check protobuf !3d(lat)!2d(lng) in HTML
        final pb1 = _pbLatThenLngRegex.firstMatch(body);
        if (pb1 != null) {
          final lat = double.tryParse(pb1.group(1)!);
          final lng = double.tryParse(pb1.group(2)!);
          if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
            return ParsedCoordinates(
              latitude: lat,
              longitude: lng,
              placeName: placeNameFromUrl,
              source: 'google_pb_coords',
            );
          }
        }

        // 3. Check protobuf !2d(lng)!3d(lat) in HTML
        final pb2 = _pbLngThenLatRegex.firstMatch(body);
        if (pb2 != null) {
          final lng = double.tryParse(pb2.group(1)!);
          final lat = double.tryParse(pb2.group(2)!);
          if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
            return ParsedCoordinates(
              latitude: lat,
              longitude: lng,
              placeName: placeNameFromUrl,
              source: 'google_pb_coords',
            );
          }
        }

        // 4. Check @lat,lng in body
        final atMatch = _atCoordsRegex.firstMatch(body);
        if (atMatch != null) {
          final lat = double.tryParse(atMatch.group(1)!);
          final lng = double.tryParse(atMatch.group(2)!);
          if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
            return ParsedCoordinates(
              latitude: lat,
              longitude: lng,
              placeName: placeNameFromUrl,
              source: 'google_body_at_coords',
            );
          }
        }

        break;
      }

      // If coordinates not found in HTML, but we have a place name, fallback to geocoding the place name
      if (placeNameFromUrl != null && placeNameFromUrl.isNotEmpty) {
        final geocoded = await _geocodePlaceName(placeNameFromUrl);
        if (geocoded != null) return geocoded;
      }
    } catch (_) {}

    return null;
  }

  /// Fallback: Geocode place name extracted from `/place/Place+Name/` URL path
  Future<ParsedCoordinates?> _geocodePlaceName(String placeName) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(placeName)}&format=json&limit=1',
      );
      final res = await _client.get(
        uri,
        headers: {'User-Agent': 'iStudio-Photography-App/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List<dynamic>;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lng = double.tryParse(first['lon']?.toString() ?? '');
          if (lat != null && lng != null && _isValidLat(lat) && _isValidLng(lng)) {
            return ParsedCoordinates(
              latitude: lat,
              longitude: lng,
              placeName: placeName,
              source: 'nominatim_fallback',
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Reverse geocodes coordinates to a human-friendly address using Nominatim.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );
      final res = await _client.get(
        uri,
        headers: {'User-Agent': 'iStudio-Photography-App/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          final parts = displayName.split(',').map((s) => s.trim()).toList();
          if (parts.length > 3) {
            return parts.take(3).join(', ');
          }
          return displayName;
        }
      }
    } catch (_) {}
    return null;
  }

  static String? _extractPlaceName(String url) {
    try {
      final match = _placeNameRegex.firstMatch(url);
      if (match != null) {
        final raw = match.group(1)!;
        return Uri.decodeComponent(raw.replaceAll('+', ' ')).trim();
      }
    } catch (_) {}
    return null;
  }

  static bool _isValidLat(double lat) => lat >= -90.0 && lat <= 90.0;
  static bool _isValidLng(double lng) => lng >= -180.0 && lng <= 180.0;
}
