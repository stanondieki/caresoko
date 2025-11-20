// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_if_null_operators

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/homesearchmodel.dart';
import 'package:gotocarefinder/model/search_info.dart';
import 'package:http/http.dart' as http;

class SearchPropertyController extends GetxController implements GetxService {
  TextEditingController search = TextEditingController();

  List<SearchInfo> searchData = [];
  bool isLoading = false;

  String searchText = "";

  changeValueUpdate(String value) {
    searchText = value;
    update();
  }

  HomesearchModel? homesearchData;
  Future getSearchData({String? countryId}) async {
    try {
      Map map = {
        "keyword": search.text,
        "uid": getData.read("UserLogin")["id"].toString(),
        "country_id": countryId,
      };
      Uri uri = Uri.parse(Config.path + Config.searchApi);
      print("uri {$uri}");

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("response::::::::::::::::: {${response.body}}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result);
        homesearchData = homesearchModelFromJson(response.body);
        for (var element in result["search_propety"]) {
          searchData.add(SearchInfo.fromJson(element));
        }
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
