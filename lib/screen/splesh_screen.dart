// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/bottombar_screen.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/screen/onbording_screen.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add property/membarship_screen.dart';
import 'home_screen.dart';

class SpleshScreen extends StatefulWidget {
  const SpleshScreen({super.key});

  @override
  State<SpleshScreen> createState() => _SpleshScreenState();
}

class _SpleshScreenState extends State<SpleshScreen> {
  HomePageController homePageController = Get.find();
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

    // permissionRequest();
    currency = getData.read("currency");

    getData.remove("lCode");
    save("lanValue", 0);
    homePageController.getHomeDataApi(
      countryId: getData.read("countryId"),
    );
    homePageController.getCatWiseData(
      cId: "0",
      countryId: getData.read("countryId"),
    );
    setScreen();
  }

  setScreen() async {
    final prefs = await SharedPreferences.getInstance();
    Timer(
        const Duration(seconds: 3),
        () => prefs.getBool('Firstuser') != true
            ? Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => OnBordingScreen()))
            : prefs.getBool('Remember') != true
                ? Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()))
                : getData.read("userType") == "admin"
                    ? Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MembershipScreen()))
                    : Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottoBarScreen())));
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
                  child: Image.asset("assets/images/LogoMain.png", height: 100)),
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
                "The Perfect Home For Mom & Dad\nIs Just A Click Away"
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontFamily: FontFamily.gilroyMedium),
              ),
            ],
          ),
          Positioned(
              bottom: 0,
              child: Image.asset(
                "assets/images/spleshimage.png",
                height: Get.height * 0.5,
              ))
        ],
      ),
    );
  }
}
// permissionRequest() async {
//   await getStorage();
//   await getphone();
// }
//
// Future getStorage() async{
//   await Permission.storage.request();
// }
//
// Future getphone() async {
//    await Permission.phone.request();
// }

Future getLocation() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    lat = 0.0;
    long = 0.0;
  } else {}
}
