// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/bottombar_screen.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add property/membarship_screen.dart';
import 'home_screen.dart' show lat, long, currency;

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});

  @override
  State<SpleshScreen> createState() => _SpleshScreenState();
}

class _SpleshScreenState extends State<SpleshScreen> {
  HomePageController homePageController = Get.find();
  SelectCountryController selectCountryController = Get.find();
  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  @override
  void initState() {
    super.initState();
    currency = getData.read("currency");
    getData.remove("lCode");
    save("lanValue", 0);
    _initCountryAndNavigate();
  }

  /// Full startup flow:
  ///   1. Load country list from DB (needed for matching & selector screen)
  ///   2. If no country stored yet → auto-detect by location
  ///      a. Detection success → use detected country
  ///      b. Detection fail   → show manual country selector after login
  ///   3. If country already stored → use it directly
  ///   4. Kick off home-data prefetch
  ///   5. After splash delay navigate to login (or home if remembered)
  Future<void> _initCountryAndNavigate() async {
    // Always load the country list so the selector screen is populated
    await selectCountryController.getCountryApi();

    String? storedCountryId = (getData.read("countryId") ?? "").toString();
    final bool alreadyHasCountry = storedCountryId.isNotEmpty && storedCountryId != "0";

    if (!alreadyHasCountry) {
      // First launch (or country was cleared) → try to auto-detect
      debugPrint('[Splash] No stored country — attempting auto-detection…');
      final detected = await selectCountryController.autoDetectAndSetCountry();
      storedCountryId = (getData.read("countryId") ?? "1").toString();

      if (detected) {
        final name = getData.read("countryName") ?? "";
        debugPrint('[Splash] Auto-detected: $name (id=$storedCountryId)');
      } else {
        debugPrint('[Splash] Auto-detection failed — will show country selector.');
        // Leave storedCountryId as "1" (first DB country as neutral default)
        // The selector will be shown after login via _needsCountrySelection flag
      }
    } else {
      debugPrint('[Splash] Using stored country id=$storedCountryId');
    }

    // Prefetch home data with whatever country we resolved
    homePageController.getHomeDataApi(countryId: storedCountryId);
    homePageController.getCatWiseData(cId: "0", countryId: storedCountryId);

    _scheduleNavigation(autoDetectionFailed: !alreadyHasCountry && !selectCountryController.autoDetected);
  }

  void _scheduleNavigation({required bool autoDetectionFailed}) async {
    final prefs = await SharedPreferences.getInstance();
    Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;
        if (prefs.getBool('Remember') != true) {
          // Not logged in — go to login screen
          // The login/onboarding flow will push SelectCountry if needed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        } else if (getData.read("userType") == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MembershipScreen()),
          );
        } else if (autoDetectionFailed) {
          // Returning user but country was wiped — send to country selector
          Get.offAllNamed(Routes.selectCountryScreen);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottoBarScreen()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Get.height * 0.1),
              Center(
                child: Image.asset("assets/images/LogoMain.png", height: 100),
              ),
              SizedBox(height: Get.height * 0.03),
              Text(
                "".tr,
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontFamily: FontFamily.gilroyBold),
              ),
              SizedBox(height: Get.height * 0.03),
              Text(
                "The Perfect Home For Mom & Dad\nIs Just A Click Away".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontFamily: FontFamily.gilroyMedium),
              ),
              SizedBox(height: Get.height * 0.03),
              // Subtle country detection indicator
              GetBuilder<SelectCountryController>(builder: (ctrl) {
                if (ctrl.autoDetected) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 16),
                      SizedBox(width: 4),
                      Text(
                        getData.read("countryName") ?? "",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.withOpacity(0.8),
                          fontFamily: FontFamily.gilroyMedium,
                        ),
                      ),
                    ],
                  );
                }
                return SizedBox.shrink();
              }),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              "assets/images/spleshimage.png",
              height: Get.height * 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Standalone GPS helper (retained for other uses) ─────────────────────────
Future<void> getLocation() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    lat = 0.0;
    long = 0.0;
  }
}
