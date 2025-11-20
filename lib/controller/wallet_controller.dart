// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/model/wallet_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class WalletController extends GetxController implements GetxService {
  HomePageController homePageController = Get.find();

  WalletInfo? walletInfo;
  bool isLoading = false;

  TextEditingController amount = TextEditingController();

  String results = "";
  String walletMsg = "";

  String rCode = "";
  String signupcredit = "";
  String refercredit = "";
  int tex = 0;
  getWalletReportData() async {
    try {
      isLoading = false;

      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      Uri uri = Uri.parse(Config.path + Config.walletReportApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        walletInfo = WalletInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getWalletUpdateData() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "wallet": amount.text,
      };
      Uri uri = Uri.parse(Config.path + Config.walletUpdateApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        results = result["Result"];
        walletMsg = result["ResponseMsg"];
        if (results == "true") {
          getWalletReportData();
          homePageController.getHomeDataApi(
            countryId: getData.read("countryId"),
          );
          Get.back();
          showToastMessage(walletMsg);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getReferData() async {
    try {
      isLoading = false;
      update();
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      Uri uri = Uri.parse(Config.path + Config.referDataGetApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print(response.body.toString());
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        rCode = result["code"];
        signupcredit = result["signupcredit"];
        refercredit = result["refercredit"];
        tex = int.parse(result["tax"]);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  addAmount({String? price}) {
    amount.text = price ?? "";
    update();
  }
}
