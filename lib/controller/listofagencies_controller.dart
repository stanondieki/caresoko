// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add%20property%20model/agencylist_info.dart';
import 'package:gotocarefinder/model/add%20property%20model/proplist_info.dart';
import 'package:http/http.dart' as http;

class ListOfAgenciesController extends GetxController implements GetxService {
  AgencyListInfo? agencyListInfo;
  bool isLodding = false;
  List<String> agencyList = [];

  ListOfAgenciesController() {
    getAgencyList();
  }
  Future getAgencyList() async {
    print(
        "LIST  OF  UID >))))))))))))))))) < > <> <> <> <> <> <><   ${getData.read("UserLogin")["id"]}");
    try {
      isLodding = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      print(".....///......." + map.toString());
      Uri uri = Uri.parse(Config.path + Config.agencyList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      print("SERVER RESPONSE -> " + response.body);

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        agencyList = [];
        for (var element in result["agencylist"]) {
          agencyList.add(element["name"]);
        }
        agencyListInfo = AgencyListInfo.fromJson(result);
      }
      isLodding = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
