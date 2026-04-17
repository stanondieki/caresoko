// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/country_info.dart';
import 'package:gotocarefinder/services/location_service.dart';
import 'package:http/http.dart' as http;

class SelectCountryController extends GetxController implements GetxService {
  CountryInfo? countryInfo;
  List<String> countryList = [];

  int? currentIndex;

  bool isLoading = false;

  // Whether auto-detection succeeded
  bool autoDetected = false;
  String autoDetectedSource = ''; // 'gps' | 'ip' | ''

  Future changeCountryIndex(int index) async {
    currentIndex = index;
    save("currentIndex", currentIndex);
    update();
  }

  Future getCountryApi() async {
    try {
      Uri uri = Uri.parse(Config.path + Config.allCountry);
      var response = await http.get(uri).timeout(const Duration(seconds: 10));
      print("<><><><><><> Country API ${response.body} >>");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["CountryData"] != null) {
          countryList = [];
          for (var element in result["CountryData"]) {
            countryList.add(element["title"]);
          }
          countryInfo = CountryInfo.fromJson(result);
        } else {
          _setFallbackCountry();
        }
      } else {
        _setFallbackCountry();
      }
      isLoading = true;
      update();
    } catch (e) {
      print("Country API Error: ${e.toString()}");
      _setFallbackCountry();
      isLoading = true;
      update();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Auto-detect the user's country by location (GPS → IP).
  //
  // Returns true  → country was detected & saved; caller can skip the
  //                 manual country selector and go straight to home.
  // Returns false → could not detect; caller should show country selector.
  // ─────────────────────────────────────────────────────────────────────────
  Future<bool> autoDetectAndSetCountry() async {
    try {
      final detected = await LocationService.detectCountry();

      if (detected != null) {
        // Save to persistent storage
        save("countryId", detected.id);
        save("countryName", detected.title);

        // Keep the current-index in sync if countries are already loaded
        if (countryInfo != null) {
          final items = countryInfo!.countryData ?? [];
          for (int i = 0; i < items.length; i++) {
            if (items[i].id.toString() == detected.id) {
              currentIndex = i;
              save("currentIndex", i);
              break;
            }
          }
        }

        autoDetected = true;
        autoDetectedSource = detected.source;
        print('[SelectCountryController] Auto-detected: ${detected.title} (${detected.source})');
        update();
        return true;
      }
    } catch (e) {
      print('[SelectCountryController] autoDetectAndSetCountry error: $e');
    }

    autoDetected = false;
    update();
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fallback: keep whatever is stored, or default to first country in the DB
  // ─────────────────────────────────────────────────────────────────────────
  void _setFallbackCountry() {
    print("Using fallback country logic");
    if ((getData.read("countryId") ?? "").toString().isEmpty) {
      save("countryId", "1");
      save("countryName", "");
    }
    countryList = [];
  }
}
