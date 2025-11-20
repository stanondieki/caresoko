// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add%20property%20model/gallerycat_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class GalleryCategoryController extends GetxController implements GetxService {
  TextEditingController name = TextEditingController();

  GalleryCatInfo? galleryCatInfo;
  bool isLoading = false;

  String pType = "";
  String status = "";

  String recordID = "";
  String catName = "";

  String selectProperty = "";

  GalleryCategoryController() {
    getGalleryCategoryList();
  }

  getIdAndName({String? recId, categoryName, selectPro, pId}) {
    recordID = recId ?? "";
    catName = categoryName ?? "";
    selectProperty = selectPro;
    pType = pId;
  }

  getGalleryCategoryList() async {
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.galleryCatList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        galleryCatInfo = GalleryCatInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  emptyDetails() {
    name.text = "";
    status = "";
  }

  addGalleyCat() async {
    try {
      Map map = {
        "status": status == "" ? "1" : status,
        "prop_id": pType,
        "uid": getData.read("UserLogin")["id"],
        "title": name.text,
      };
      Uri uri = Uri.parse(Config.path + Config.addGalleryCat);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getGalleryCategoryList();
          showToastMessage(result["ResponseMsg"]);
          emptyDetails();
          Get.back();
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  editGalleryCat() async {
    try {
      Map map = {
        "status": status == "" ? "1" : status,
        "prop_id": pType,
        "uid": getData.read("UserLogin")["id"],
        "title": name.text,
        "record_id": recordID,
      };
      print("--------------------" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.upDateGalleryCat);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getGalleryCategoryList();
          showToastMessage(result["ResponseMsg"]);
          emptyDetails();
          Get.back();
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
