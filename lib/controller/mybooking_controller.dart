// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/ststuswisebook_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class MyBookingController extends GetxController implements GetxService {
  StatusWiseBookInfo? statusWiseBookInfo;

  String statusWiseBook = "active";
  bool isLoading = false;

  statusWiseBooking() async {
    try {
      isLoading = false;
      update();
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "status": statusWiseBook,
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.statusWiseBook);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("************" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        statusWiseBookInfo = StatusWiseBookInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  bookingCancle({String? bookId, reason}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "book_id": bookId,
        "cancle_reason": reason,
      };
      Uri uri = Uri.parse(Config.path + Config.bookingCancle);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          statusWiseBooking();
          Get.back();
        }
        showToastMessage(result["ResponseMsg"]);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
