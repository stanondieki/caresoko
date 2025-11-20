// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/proparty/pagelist_info.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:http/http.dart' as http;

class PropartyPageListController extends GetxController implements GetxService {
  PageListInfo? pageListInfo;
  bool isLodding = false;

  PageListController() {
    getPageListData();
  }

  getPageListData() async {
    try {
      Uri uri = Uri.parse(Config.path + Config.pageListApi);
      var response = await http.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        pageListInfo = PageListInfo.fromJson(result);
        isLodding = true;
        update();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  deletAccount() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.deletAccount);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        Get.offAll(LoginScreen());
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
