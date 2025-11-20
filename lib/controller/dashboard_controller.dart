// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add%20property%20model/dashboard_info.dart';
import 'package:gotocarefinder/model/add%20property%20model/facility_info.dart';
import 'package:gotocarefinder/model/add%20property%20model/protype_info.dart';
import 'package:gotocarefinder/model/add%20property%20model/subdetails_info.dart';
import 'package:http/http.dart' as http;

class DashBoardController extends GetxController implements GetxService {
  DashBoardInfo? dashBoardInfo;
  ProTypeInfo? proTypeInfo;
  ProTypeInfo? propartyTypeInfo;
  FacilityInfo? facilityInfo;
  FacilityInfo? propartyFacilityInfo;
  SubDetailsInfo? subDetailsInfo;

  List<String> typeList = [];
  List<String> propartyTypeList = [];
  List<String> membershipData = [];

  String payOut = "";

  bool isLoading = false;
  bool isSubLoading = false;

  DashBoardController() {
    getDashBoardData();
    getPropartyTypeList();
    getPropartiTypeList();
    getFacilityList();
    getPropartyFacilityList();
  }

  Future getDashBoardData() async {
    try {
      isLoading = false;
      update();
      print(
          "USERID<> < > < >< > < > < > < >? < >${getData.read("UserLogin")["id"]}");
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.dashboardApi);
      print(" SD:JSLDJSLJLSJDLSJDLSJDLSJDLSJDSLJDSLDJ");
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        membershipData = [];
        for (var element in result["member_data"]) {
          membershipData.add(element["report_data"].toString());
          print("?????????????????????????? ${result["member_data"]}");
        }
        for (var element in result["report_data"]) {
          if (element["title"] == "My Earning") {
            payOut = element["report_data"].toString();
          }
        }

        dashBoardInfo = DashBoardInfo.fromJson(result);
        print(
            "USEWRLOGIN OR NOT > <> <> <> <> <> <> <> <> <> ${dashBoardInfo}");
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getPropartyTypeList() async {
    try {
      isLoading = false;
      update();
      Uri uri = Uri.parse(Config.path + Config.propertyType);
      var response = await http.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        for (var element in result["typelist"]) {
          typeList.add(element["title"]);
        }
        proTypeInfo = ProTypeInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getPropartiTypeList() async {
    try {
      isLoading = false;
      update();
      Uri uri = Uri.parse(Config.path + Config.propartyType);
      var response = await http.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        for (var element in result["typelist"]) {
          propartyTypeList.add(element["title"]);
        }
        propartyTypeInfo = ProTypeInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getFacilityList() async {
    try {
      isLoading = false;
      update();
      Uri uri = Uri.parse(Config.path + Config.facilityList);
      var response = await http.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        facilityInfo = FacilityInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getPropartyFacilityList() async {
    try {
      isLoading = false;
      update();
      Uri uri = Uri.parse(Config.path + Config.propartyFacilityList);
      var response = await http.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        propartyFacilityInfo = FacilityInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getSubScribeDetails() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.subScribeDetails);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        subDetailsInfo = SubDetailsInfo.fromJson(result);
      }
      isSubLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
