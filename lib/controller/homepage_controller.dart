// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, prefer_if_null_operators, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/catwise_info.dart';
import 'package:gotocarefinder/model/favourite_info.dart';
import 'package:gotocarefinder/model/homedata_info.dart';
import 'package:gotocarefinder/model/map_info.dart';
import 'package:gotocarefinder/model/propetydetails_Info.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

import '../screen/home_screen.dart';

class HomePageController extends GetxController implements GetxService {
  HomeDatatInfo? homeDatatInfo;
  HomecareAgencyDetailsInfo? homecareAgencyDetailsInfo;
  PropetydetailsInfo? propetydetailsInfo;
  FavouriteInfo? favouriteInfo;

  List<MapInfo> mapInfo = [];

  String searchLocation = "";

  String rate = "";

  CatWiseInfo? catWiseInfo;

  List<int> selectedIndex = [];

  int currentIndex = 0;
  int catCurrentIndex = 0;
  int ourCurrentIndex = 0;

  bool isLoading = false;
  bool isProperty = false;
  bool isfevorite = false;
  bool isCatWise = false;

  String fevResult = "";
  String fevMsg = "";
  String enquiry = "";

  PageController pageController = PageController();

  CameraPosition kGoogle = CameraPosition(
    target: LatLng(47.751076, -120.740135),
    zoom: 5,
  );

  List<Marker> markers = <Marker>[];

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  HomePageController() {
    getHomeDataApi();
    getCatWiseData(cId: "0", countryId: getData.read("countryId"));
  }

  chnageObjectIndex(int index) {
    currentIndex = 0;
    currentIndex = index;
    update();
  }

  changeCategoryIndex(int index) {
    catCurrentIndex = 0;
    catCurrentIndex = index;
    update();
  }

  changeOurCurrentIndex(int index) {
    ourCurrentIndex = index;
    update();
  }

  getChangeLocation(String location) {
    searchLocation = location;
    Get.back();

    update();
  }

  updateMapPosition({int? index}) {
    pageController.animateToPage(index ?? 0,
        duration: Duration(seconds: 1), curve: Curves.decelerate);
    update();
  }

  String addProp = "";
  Future getHomeDataApi({String? countryId}) async {
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>COUNTRy CODE ${countryId}");
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin") == null
            ? "0"
            : "${getData.read("UserLogin")["id"]}",
        "country_id": countryId,
      };
      print("--------(Map)-------->>" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.homeDataApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("HOME DATA QUERY RESPONSE ${response.body}");
      log(">>>>>>>>>>>>>>>>>>>>>>>> ????????????????????? ${response.body}");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        homeDatatInfo = HomeDatatInfo.fromJson(result);
        addProp = homeDatatInfo?.homeData!.showAddProperty ?? "";
        print("ADDDPORP >>>>>>>>>>>>>>>>>> ${addProp}");
        var maplist = mapInfo.reversed.toList();
        currency = homeDatatInfo?.homeData!.currency ?? "";

        update();
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getPropertyDetailsApi({String? id, String? ptype}) async {
    try {
      isProperty = false;
      update();
      Map map = {
        "pro_id": id,
        "ptype": ptype,
        "uid": getData.read("UserLogin") == null
            ? "0"
            : "${getData.read("UserLogin")["id"]}",
      };

      print("(Map)------------->>" + map.toString());

      Uri uri;
      if (ptype == "3") {
        uri = Uri.parse(Config.path + Config.homecareDetails);
      } else {
        uri = Uri.parse(Config.path + Config.propertyDetails);
      }

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      print("PROPERTY DETAILS FETCHED ->  ${response.body}");
      print("DDDDDDDDDDDDDDDD ${response.statusCode}");

      if (response.statusCode == 200) {
        print("DATA FETCHED >>>>>>>>>>>>> ${response.body}");
        var result = json.decode(response.body);
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $result");
        if (ptype == "3") {
          homecareAgencyDetailsInfo =
              HomecareAgencyDetailsInfo.fromJson(result);
          print("> <> <> <> <> <><> <> <> ${homecareAgencyDetailsInfo}");
        } else {
          propetydetailsInfo = PropetydetailsInfo.fromJson(result);
          print("> <> <> <> <> <><> <> <> ${propetydetailsInfo}");
        }
      }

      isProperty = true;
      update();
    } catch (e, stackTrace) {
      //print(e.toString());
      debugPrint("Error: $e\nStack Trace: $stackTrace");
    }
  }

  addFavouriteList({String? pid, String? propertyType}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "pid": pid,
        "property_type": propertyType,
      };

      Uri uri = Uri.parse(Config.path + Config.addAndRemoveFavourite);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        fevResult = result["Result"];
        fevMsg = result["ResponseMsg"];
        getPropertyDetailsApi(id: pid, ptype: propertyType);
        getFavouriteList(countryId: getData.read("countryId"));
        showToastMessage(fevMsg);
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getFavouriteList({String? countryId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "property_type": "0",
        "country_id": countryId,
      };
      print("AAAAAAAAAAAAAAA" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.favouriteList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("-------==========" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        favouriteInfo = FavouriteInfo.fromJson(result);
      }
      isfevorite = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  Future getCatWiseData(
      {required String? cId, required String? countryId}) async {
    print("++++++ -------- %##%#%#%#%# ${countryId}");
    Map map = {
      "cid": cId ?? "0",
      "uid": getData.read("UserLogin") == null
          ? "0"
          : getData.read("UserLogin")["id"].toString(),
      "country_id": countryId,
    };

    Uri uri = Uri.parse(Config.path + Config.catWiseData);

    print("++++++ -------- +++++++ ------- ++++++${map}");
    print("++++++ -------- +++++++ ------- ++++++${uri}");

    var response = await http.post(
      uri,
      body: jsonEncode(map),
    );

    print("CATWISE DATA QUERY RESPONSE ${response.body}");

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      catWiseInfo = CatWiseInfo.fromJson(result);
      isCatWise = true;
      update();
      print("< >? < > < > < > < > < > < > < > <>?${catWiseInfo!.responseMsg}>");
    }
  }

  enquirySetApi({String? pId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "prop_id": pId,
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.enquiry);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("---------------" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("+++++++++++++++" + result.toString());
        enquiry = result["Result"];
        showToastMessage(result["ResponseMsg"].toString());
        update();
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
