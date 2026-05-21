import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:http/http.dart' as http;

import '../Api/data_store.dart';
import '../model/reviewmodel.dart';

class ReviewlistController extends GetxController implements GetxService {
  bool isLoading = true;

  RiviewInfo? reviewlistData;
  Future reviewlist() async {
    print(
        ">>>>>>>>>>>> POWEPWOEPWOPEWOEPWOPWOEPW ${getData.read("UserLogin")["id"]}");
    Map body = {
      "orag_id": getData.read("UserLogin") == null
          ? "0"
          : "${getData.read("UserLogin")["id"]}",
    };

    var response = await http.post(
      Uri.parse(Config.path + Config.reviewlist),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var reviewDecode = jsonDecode(response.body);
      if (reviewDecode["Result"] == "true") {
        print(">>>>>>>>>>>> POWEPWO $reviewDecode");
        reviewlistData = RiviewInfo.fromJson(reviewDecode);
        isLoading = false;
        update();
      }
      return reviewDecode;
    }
  }
}
