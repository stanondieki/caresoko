// lib/services/location_service.dart
//
// Auto-detects the user's country using a 3-step cascade:
//   1) GPS + Google Geocoding API  (mobile & web, requires location permission)
//   2) Server-side IP detection     (u_detect_country.php, no permission needed)
//   3) Returns null                 → caller shows manual country selector
//
// The result contains both the matched DB country_id and title so the caller
// can save them directly without an extra API round-trip.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:gotocarefinder/Api/config.dart';

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
  // ─────────────────────────────────────────────────────────────────────────
  // Public entry-point. Returns null when no country could be resolved.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<DetectedCountry?> detectCountry() async {
    // Step 1 – GPS + Google Geocoding (skipped on web to avoid browser
    //          permission pop-up delay; web falls straight to Step 2)
    if (!kIsWeb) {
      try {
        final result = await _detectViaGps();
        if (result != null) return result;
      } catch (e) {
        print('[LocationService] GPS step failed: $e');
      }
    }

    // Step 2 – Server-side IP detection
    try {
      final result = await _detectViaIp();
      if (result != null) return result;
    } catch (e) {
      print('[LocationService] IP step failed: $e');
    }

    // Step 3 – Nothing worked
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 1: GPS coordinates → Google Geocoding API
  // ─────────────────────────────────────────────────────────────────────────
  static Future<DetectedCountry?> _detectViaGps() async {
    // Check & request permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      print('[LocationService] Location permission denied.');
      return null;
    }

    // Get coordinates (low accuracy is fine for country-level)
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );

    print('[LocationService] GPS: ${pos.latitude}, ${pos.longitude}');

    // Reverse-geocode with Google Maps Geocoding API (works on all platforms)
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=${pos.latitude},${pos.longitude}'
      '&result_type=country'
      '&key=${Config.googleKey}',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') return null;

    final results = data['results'] as List<dynamic>? ?? [];
    for (final r in results) {
      final components = r['address_components'] as List<dynamic>? ?? [];
      for (final c in components) {
        final types = (c['types'] as List<dynamic>? ?? []).cast<String>();
        if (types.contains('country')) {
          final countryName = c['long_name'] as String? ?? '';
          print('[LocationService] GPS country: $countryName');
          // Now match against DB countries (via IP endpoint which also returns CountryData)
          return await _matchCountryInDb(countryName, source: 'gps');
        }
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step 2: Backend IP detection → returns country_id + CountryData
  // ─────────────────────────────────────────────────────────────────────────
  static Future<DetectedCountry?> _detectViaIp() async {
    final uri = Uri.parse(Config.path + Config.detectCountryApi);
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['Result'] == 'true' && (data['country_id'] as String?)?.isNotEmpty == true) {
      print('[LocationService] IP country: ${data['detected_country']}');
      return DetectedCountry(
        id: data['country_id'].toString(),
        title: data['detected_country'].toString(),
        source: 'ip',
      );
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  // Fetch CountryData from the detect endpoint and fuzzy-match a given name.
  static Future<DetectedCountry?> _matchCountryInDb(
    String countryName, {
    required String source,
  }) async {
    try {
      final uri = Uri.parse(Config.path + Config.detectCountryApi);
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final countries = data['CountryData'] as List<dynamic>? ?? [];

      final target = countryName.toLowerCase().trim();

      // Exact match first
      for (final c in countries) {
        final dbName = (c['title'] as String? ?? '').toLowerCase().trim();
        if (dbName == target) {
          return DetectedCountry(
            id: c['id'].toString(),
            title: c['title'].toString(),
            source: source,
          );
        }
      }
      // Substring match
      for (final c in countries) {
        final dbName = (c['title'] as String? ?? '').toLowerCase().trim();
        if (target.contains(dbName) || dbName.contains(target)) {
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
}
