// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add%20property%20model/earning_info.dart';
import 'package:http/http.dart' as http;

class MyEarningController extends GetxController implements GetxService {
  EarningInfo? earningInfo;
  bool isLoading = false;
  MyEarningController() {
    getEarningsData();
  }
  Future getEarningsData() async {
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "status": "completed",
      };
      Uri uri = Uri.parse(Config.path + Config.proBookStatusWise);
      print(map.toString());
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        earningInfo = EarningInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
