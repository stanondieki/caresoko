// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, prefer_if_null_operators, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/proparty/catwise_info.dart';
import 'package:gotocarefinder/model/proparty/favourite_info.dart';
import 'package:gotocarefinder/model/proparty/homedata_info.dart';
import 'package:gotocarefinder/model/proparty/map_info.dart';
import 'package:gotocarefinder/model/proparty/propetydetails_Info.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as osm;

import '../../screen/home_screen.dart';

class PropartyHomePageController extends GetxController implements GetxService {
  HomeDatatInfo? homeDatatInfo;
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

  final osm.LatLng kMapCenter = osm.LatLng(21.2381962, 72.8879607);

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  PropartyHomePageController() {
    final storedCountryId = (getData.read("countryId") ?? "").toString();
    final safeCountryId = storedCountryId.isEmpty ? "0" : storedCountryId;
    getHomeDataApi(countryId: safeCountryId);
    getCatWiseData(cId: "0", countryId: safeCountryId);
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
    final storedCountryId = (getData.read("countryId") ?? "").toString();
    final safeCountryId = (countryId ?? "").toString().isNotEmpty
        ? countryId!.toString()
        : (storedCountryId.isEmpty ? "0" : storedCountryId);

    print(">>>>>>>>>>>>>>>>>>>>>>>>>>COUNTRy CODE $safeCountryId");
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin") == null ? "0"
            : "${getData.read("UserLogin")["id"]}",
        "country_id": safeCountryId,
      };
      print("--------(Map)-------->>" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.propartyHomeDataApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      log(">>>>>>>>>>>>>>>>>>>>>>>> ????????????????????? ${response.body}");
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded["Result"]?.toString() == "true") {
          homeDatatInfo =
              HomeDatatInfo.fromJson(Map<String, dynamic>.from(decoded));
          addProp = homeDatatInfo?.homeData?.showAddProperty ?? "";
          currency = homeDatatInfo?.homeData?.currency ?? "";
        } else {
          homeDatatInfo = null;
          addProp = "";
        }
        update();
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getPropertyDetailsApi({String? id}) async {
    try {
      isProperty = false;
      update();
      Map map = {
        "pro_id": id,
        "uid": getData.read("UserLogin") == null
            ? "0"
            : "${getData.read("UserLogin")["id"]}",
      };

      print("(Map)------------->>" + map.toString());

      Uri uri = Uri.parse(Config.path + Config.propartyDetails);

      var response = await http.post(uri, body: jsonEncode(map),
      );

      print("DDDDDDDDDDDDDDDD ${response.statusCode}");

      if (response.statusCode == 200) {
        print("DATA GATED >>>>>>>>>>>>> ${response.body}");
        var result = json.decode(response.body);
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $result");
        propetydetailsInfo = PropetydetailsInfo.fromJson(result);
        print("> <> <> <> <> <><> <> <> $propetydetailsInfo");
      }

      isProperty = true;
      update();
    } catch (e, stackTrace) {
      debugPrint("Error in proparty getPropertyDetailsApi: $e\nStack Trace: $stackTrace");
    } finally {
      // ALWAYS set isProperty to true to stop loading animation even on error
      isProperty = true;
      update();
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
        getPropertyDetailsApi(id: pid);
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

  Future getCatWiseData({required String? cId, required String? countryId}) async {

    print("++++++ -------- %##%#%#%#%# $countryId");
      Map map = {
        "cid": cId ?? "0",
        "uid": getData.read("UserLogin") == null
            ? "0"
            : getData.read("UserLogin")["id"].toString(),
        "country_id": countryId,
      };

      Uri uri = Uri.parse(Config.path + Config.propartyCatWiseData);

      print("++++++ -------- +++++++ ------- ++++++$map");
      print("++++++ -------- +++++++ ------- ++++++$uri");

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
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
