// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

import '../../model/add_proparty_model/porstatuswise_info.dart';
import '../../model/add_proparty_model/prodetails_info.dart';

class BookingController extends GetxController implements GetxService {
  ProStatusWiseInfo? proStatusWiseInfo;
  ProDetailsInfo? proDetailsInfo;

  TextEditingController ratingText = TextEditingController();
  double tRate = 1.0;

  String statusWiseBook = "active";

  bool isLoading = false;
  bool isDetails = false;

  totalRateUpdate(double rating) {
    tRate = rating;
    update();
  }

  getBookingStatusWise() async {
    try {
      isLoading = false;
      update();
      final String countryId = (getData.read("countryId") ?? "0").toString();
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "status": statusWiseBook,
        "country_id": countryId,
      };
      Uri uri = Uri.parse(Config.path + Config.proBookStatusWise);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(".........:::::::::::.........." + result.toString());
        proStatusWiseInfo = ProStatusWiseInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getBookingDetails({String? bookId}) async {
    try {
      Map map = {
        "book_id": bookId,
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      Uri uri = Uri.parse(Config.path + Config.proBookingDetails);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        proDetailsInfo = ProDetailsInfo.fromJson(result);
      }
      isDetails = true;
      update();
      return jsonDecode(response.body);
    } catch (e) {
      print(e.toString());
    }
  }

  getBookingConfrimed({String? bookId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "book_id": bookId,
      };
      print("^^^^^^^^^^^^^^^^" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.confirmedBooking);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getBookingDetails(bookId: bookId);
          showToastMessage(result["ResponseMsg"]);
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  getBookingCheckIn({String? bookId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "book_id": bookId,
      };
      Uri uri = Uri.parse(Config.path + Config.proCheckIN);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getBookingDetails(bookId: bookId);
          showToastMessage(result["ResponseMsg"]);
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future getBookingCheckOut({String? bookId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "book_id": bookId,
      };
      Uri uri = Uri.parse(Config.path + Config.proCheckOutConfirmed);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getBookingDetails(bookId: bookId);
          showToastMessage(result["ResponseMsg"]);
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
      return jsonEncode(response.body);
    } catch (e) {
      print(e.toString());
    }
  }

  getBookingCancle({String? bookId, reason}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "book_id": bookId,
        "cancle_reason": reason,
      };
      print("^^^^^^^^^^^^^^^^" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.proBookingCancle);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getBookingStatusWise();
          Get.back();
          showToastMessage(result["ResponseMsg"]);
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  reviewUpdateApi({String? bookId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "book_id": bookId,
        "total_rate": tRate.toString(),
        "rate_text": ratingText.text,
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.reviewApi);
      print(uri.toString());
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        String rResult = result["Result"];
        if (rResult == "true") {
          getBookingDetails(bookId: bookId);
          Get.back();
          showToastMessage(result["ResponseMsg"]);
        }
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
