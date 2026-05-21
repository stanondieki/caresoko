// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/model/add%20property%20model/subscribe_info.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class SubscribeController extends GetxController implements GetxService {
  DashBoardController dashBoardController = Get.find();
  SubscribeInfo? subscribeInfo;
  bool isLoading = false;

  //For signature collection
  TextEditingController representativeNameController = TextEditingController();

  int? currentIndex;
  String price = "";
  String planId = "";

  changeSubscribe(int index) {
    currentIndex = index;
    update();
  }

  getSubscribeDetailsList() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.subScribeList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["is_subscribe"] == 0) {
          //Get.offAndToNamed(Routes.subscribeScreen);
          Get.offAndToNamed(Routes.contractScreen);
        } else {
          Get.offAndToNamed(Routes.membershipScreen);
        }
        subscribeInfo = SubscribeInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  packagePurchaseApi({String? otid, String? pName}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "plan_id": planId,
        "transaction_id": otid,
        "pname": price != "0" ? pName : "Trial"
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.packagePurchase);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          dashBoardController.getDashBoardData();
          getSubscribeDetailsList();
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Save contract agreement with signature
  Future<bool> saveContractAgreement({
    required String representativeName,
    required String signatureBase64,
  }) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "representative_name": representativeName,
        "signature": signatureBase64,
      };
      print("Saving contract: $map");
      Uri uri = Uri.parse("${Config.path}u_save_contract.php");
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("Contract save response: $result");
        if (result["Result"] == "true") {
          showToastMessage(result["ResponseMsg"]);
          return true;
        } else {
          showToastMessage(result["ResponseMsg"] ?? "Failed to save contract");
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error saving contract: $e");
      return false;
    }
  }
}
