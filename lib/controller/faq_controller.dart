// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/faq_info.dart';
import 'package:http/http.dart' as http;

class FaqController extends GetxController implements GetxService {
  FaqListInfo? faqListInfo;
  bool isLoading = false;
  String faqType = "Resident";

  getFaqDataApi() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "type": faqType
      };
      Uri uri = Uri.parse(Config.path + Config.faqApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        faqListInfo = FaqListInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
