// lib/services/location_service.dart
//
// Auto-detects the user's country using a 3-step cascade:
//   1) GPS + geocoding package      (silent check by default)
//   2) IP fallback (ipapi.co)
//   3) Backend IP detection         (u_detect_country.php)
//
// The result contains both matched DB country_id and title.

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetectedCountry {
  final String id;
  final String title;
  final String source; // 'gps' | 'ip' | 'none'

  const DetectedCountry({
    required this.id,
    required this.title,
    required this.source,
  });

  @override
  String toString() => 'DetectedCountry(id=$id, title=$title, source=$source)';
}

class LocationService {
  static const String _cachedCountryId = 'cached_country_id';
  static const String _cachedCountryTitle = 'cached_country_title';
  static const String _cachedCountrySource = 'cached_country_source';
  static const String _cachedCountryExpiry = 'cached_country_expiry';

  static Future<DetectedCountry?> detectCountry({bool withPrompt = false}) async {
    final cached = await _getCachedCountry();
    if (cached != null) {
      return cached;
    }

    // Step 1: GPS + device geocoder
    try {
      final gpsResult = await _detectViaGps(withPrompt: withPrompt);
      if (gpsResult != null) {
        await _cacheCountry(gpsResult);
        return gpsResult;
      }
    } catch (e) {
      print('[LocationService] GPS step failed: $e');
    }

    // Step 2: Public IP geolocation API
    try {
      final ipApiResult = await _detectViaPublicIpApi();
      if (ipApiResult != null) {
        await _cacheCountry(ipApiResult);
        return ipApiResult;
      }
    } catch (e) {
      print('[LocationService] ipapi step failed: $e');
    }

    // Step 3: Backend IP detection
    try {
      final backendIpResult = await _detectViaIp();
      if (backendIpResult != null) {
        await _cacheCountry(backendIpResult);
        return backendIpResult;
      }
    } catch (e) {
      print('[LocationService] backend IP step failed: $e');
    }

    return null;
  }

  static Future<DetectedCountry?> detectCountryWithPrompt() {
    return detectCountry(withPrompt: true);
  }

  static Future<DetectedCountry?> _detectViaGps({required bool withPrompt}) async {
    LocationPermission perm = await Geolocator.checkPermission();

    if (withPrompt && perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      print('[LocationService] Location permission not granted.');
      return null;
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );

    print('[LocationService] GPS: ${pos.latitude}, ${pos.longitude}');

    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    if (placemarks.isEmpty) {
      return null;
    }

    final place = placemarks.first;
    final countryName = (place.country ?? '').trim();
    final countryCode = (place.isoCountryCode ?? '').trim();

    if (countryName.isEmpty && countryCode.isEmpty) {
      return null;
    }

    print('[LocationService] GPS country: $countryName ($countryCode)');
    return _matchCountryInDb(
      countryName: countryName,
      countryCode: countryCode,
      source: 'gps',
    );
  }

  static Future<DetectedCountry?> _detectViaPublicIpApi() async {
    final uri = Uri.parse('https://ipapi.co/json/');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final countryName = (data['country_name'] ?? '').toString().trim();
    final countryCode = (data['country_code'] ?? '').toString().trim();

    if (countryName.isEmpty && countryCode.isEmpty) {
      return null;
    }

    print('[LocationService] ipapi country: $countryName ($countryCode)');
    return _matchCountryInDb(
      countryName: countryName,
      countryCode: countryCode,
      source: 'ip',
    );
  }

  static Future<DetectedCountry?> _detectViaIp() async {
    final uri = Uri.parse(Config.path + Config.detectCountryApi);
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['Result'] == 'true' &&
        (data['country_id'] as String?)?.isNotEmpty == true) {
      print('[LocationService] Backend IP country: ${data['detected_country']}');
      return DetectedCountry(
        id: data['country_id'].toString(),
        title: data['detected_country'].toString(),
        source: 'ip',
      );
    }
    return null;
  }

  static Future<DetectedCountry?> _matchCountryInDb(
    {
    required String countryName,
    required String countryCode,
    required String source,
  }) async {
    try {
      final uri = Uri.parse(Config.path + Config.detectCountryApi);
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final countries = data['CountryData'] as List<dynamic>? ?? [];
      final targetName = countryName.toLowerCase().trim();
      final targetCode = countryCode.toUpperCase().trim();

      // Exact name match first.
      for (final c in countries) {
        final dbName = (c['title'] as String? ?? '').toLowerCase().trim();
        if (dbName.isNotEmpty && dbName == targetName) {
          return DetectedCountry(
            id: c['id'].toString(),
            title: c['title'].toString(),
            source: source,
          );
        }
      }

      // Match by ISO code when present.
      if (targetCode.isNotEmpty) {
        for (final c in countries) {
          final dbCode = (c['ccode'] ?? '').toString().toUpperCase().trim();
          if (dbCode.isNotEmpty && dbCode == targetCode) {
            return DetectedCountry(
              id: c['id'].toString(),
              title: c['title'].toString(),
              source: source,
            );
          }
        }
      }

      // Loose match for naming differences.
      for (final c in countries) {
        final dbName = (c['title'] as String? ?? '').toLowerCase().trim();
        if (targetName.isNotEmpty &&
            (targetName.contains(dbName) || dbName.contains(targetName))) {
          return DetectedCountry(
            id: c['id'].toString(),
            title: c['title'].toString(),
            source: source,
          );
        }
      }
    } catch (e) {
      print('[LocationService] _matchCountryInDb error: $e');
    }
    return null;
  }

  static Future<DetectedCountry?> _getCachedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_cachedCountryExpiry) ?? 0;

    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      return null;
    }

    final id = prefs.getString(_cachedCountryId) ?? '';
    final title = prefs.getString(_cachedCountryTitle) ?? '';
    final source = prefs.getString(_cachedCountrySource) ?? 'cache';

    if (id.isEmpty || title.isEmpty) {
      return null;
    }

    return DetectedCountry(id: id, title: title, source: source);
  }

  static Future<void> _cacheCountry(DetectedCountry country) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(hours: 24));

    await prefs.setString(_cachedCountryId, country.id);
    await prefs.setString(_cachedCountryTitle, country.title);
    await prefs.setString(_cachedCountrySource, country.source);
    await prefs.setInt(_cachedCountryExpiry, expiry.millisecondsSinceEpoch);
  }
}
