// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/bookdetails_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class BookingDetailsController extends GetxController implements GetxService {
  BookDetailsInfo? bookDetailsInfo;
  bool isLoading = false;
  TextEditingController ratingText = TextEditingController();

  double tRate = 1.0;

  totalRateUpdate(double rating) {
    tRate = rating;
    update();
  }

  getbookingDetails({String? bookId}) async {
    try {
      Map map = {
        "book_id": bookId,
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      print("---------------" + bookId.toString());
      Uri uri = Uri.parse(Config.path + Config.bookingDetails);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("************" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("%%%%%%%%%%%%%%" + result.toString());
        bookDetailsInfo = BookDetailsInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  reviewUpdateApi({String? bookId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
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
      print("££££££££££" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        String rResult = result["Result"];
        if (rResult == "true") {
          tRate = 1.0;
          ratingText.text = "";
          Get.back();
          getbookingDetails(bookId: bookId);
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
