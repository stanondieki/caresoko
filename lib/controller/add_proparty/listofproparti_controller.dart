// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add_proparty_model/proplist_info.dart';
import 'package:http/http.dart' as http;

class ListOfPropertyController extends GetxController implements GetxService {
  PropListInfo? propListInfo;
  bool isLodding = false;
  List<String> propertyList = [];

  ListOfPropertyController() {
    getPropertiList();
  }
  Future getPropertiList() async {
    print("LIST  OF  UID > < > <> <> <> <> <> <><   ${getData.read("UserLogin")["id"]}");
    try {
      isLodding = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      print(".....///......." + map.toString());
      Uri uri = Uri.parse(Config.path + Config.propartyList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        propertyList = [];
        for (var element in result["proplist"]) {
          propertyList.add(element["title"]);
        }
        propListInfo = PropListInfo.fromJson(result);
      }
      isLodding = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
