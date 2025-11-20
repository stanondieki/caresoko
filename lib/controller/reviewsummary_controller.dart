// ignore_for_file: unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/model/payment_info.dart';
import 'package:http/http.dart' as http;

class ReviewSummaryController extends GetxController implements GetxService {
  TextEditingController note = TextEditingController();

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController gmail = TextEditingController();
  TextEditingController mobile = TextEditingController();

  PaymentInfo? paymentInfo;
  bool isLodding = false;

  String pImage = "";
  String pTitle = "";
  String pCity = "";
  String pType = "";
  String id = "";
  String plimit = "";

  ReviewSummaryController() {
    getpaymentgatewayList();
  }

  cleanOtherDetails() {
    note.text = '';
    firstName.text = '';
    lastName.text = '';
    gmail.text = '';
    mobile.text = '';
    update();
  }

  getpaymentgatewayList() async {
    try {
      Uri uri = Uri.parse(Config.path + Config.paymentgatewayApi);
      var response = await http.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        paymentInfo = PaymentInfo.fromJson(result);
        isLodding = true;
        update();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getProductObject({
    String? pim,
    String? pti,
    String? pci,
    String? pPty,
    String? pId,
    String? pLimit,
  }) {
    pImage = pim ?? "";
    pTitle = pti ?? "";
    pCity = pci ?? "";
    pType = pPty ?? "";
    id = pId ?? "";
    plimit = pLimit ?? "";
    print("::::::::::" + pImage);
    print("::::::::::" + pTitle);
    print("::::::::::" + pCity);
    print("::::::::::" + pType);
    print("::::::::::" + id);
    update();
  }
}
