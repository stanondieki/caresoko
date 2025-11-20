// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add%20property%20model/extralist_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class ExtraImageController extends GetxController implements GetxService {
  ExtraListInfo? extraListInfo;
  bool isLoading = false;

  String? path;
  String? base64Image;

  String pType = "";
  String status = "";
  String isPanorama = "";

  String image = "";
  String recordID = "";

  String selectProperty = "";

  ExtraImageController() {
    getExtraImageList();
  }

  getEditExtraImage({String? img, recordId, selectPro, pId}) {
    image = img ?? "";
    recordID = recordId;
    selectProperty = selectPro;
    pType = pId;
    update();
  }

  getExtraImageList() async {
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.extraImageList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        extraListInfo = ExtraListInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  addExtraImage() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "prop_id": pType,
        "img": base64Image,
        "status": status == "" ? "1" : status,
        "is_panorama": isPanorama != "" ? isPanorama : "1",
      };
      Uri uri = Uri.parse(Config.path + Config.addExtraImage);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          getExtraImageList();
          showToastMessage(result["ResponseMsg"]);
          Get.back();
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  editExtraImage() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "prop_id": pType,
        "img": base64Image,
        "status": status == "" ? "1" : status,
        "record_id": recordID,
        "is_panorama": isPanorama != "" ? isPanorama : "1",
      };
      Uri uri = Uri.parse(Config.path + Config.editExtraImage);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          getExtraImageList();
          showToastMessage(result["ResponseMsg"]);
          Get.back();
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
