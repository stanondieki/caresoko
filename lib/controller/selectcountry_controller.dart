// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/country_info.dart';
import 'package:http/http.dart' as http;

class SelectCountryController extends GetxController implements GetxService {
  CountryInfo? countryInfo;
  List<String> countryList = [];

  int? currentIndex;

  bool isLoading = false;

  Future changeCountryIndex(int index) async {
    currentIndex = index;
    save("currentIndex", currentIndex);
    update();
  }

  Future getCountryApi() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin") == null
            ? "0"
            : "${getData.read("UserLogin")["id"]}",
      };
      Uri uri = Uri.parse(Config.path + Config.allCountry);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("<><><><><><><><><><><><><><>< ${response.body}>>");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        countryList = [];
        for (var element in result["CountryData"]) {
          countryList.add(element["title"]);
        }
        countryInfo = CountryInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
