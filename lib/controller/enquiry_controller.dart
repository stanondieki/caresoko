// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/model/add%20property%20model/enquiry_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class EnquiryController extends GetxController implements GetxService {
  EnquiryInfo? enquiryInfo;
  ListOfPropertiController listOfPropertiController = Get.find();

  bool isLoading = false;

  makeSellPropertyApi({String? Id}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "prop_id": Id,
      };
      Uri uri = Uri.parse(Config.path + Config.makeSellProperty);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          listOfPropertiController.getPropertiList();
          Get.back();
          showToastMessage(result["ResponseMsg"]);
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  enquiryListApi() async {
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.enquiryListApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      var result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        enquiryInfo = EnquiryInfo.fromJson(result);
        print(
            "ENQUIRY LIST    J JJ J J JJ JJ JJ J ${jsonDecode(response.body)}");
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
