// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/add%20property%20model/addgallery_info.dart';
import 'package:gotocarefinder/model/add%20property%20model/propertywise_info.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;

class GalleryImageController extends GetxController implements GetxService {
  AddGalleryInfo? addGalleryInfo;
  PropertyWiseInfo? propertyWiseInfo;

  List<String> selectGalleryCat = [];

  bool isLoading = false;

  String recodeId = "";
  String gImage = "";

  String? path;
  String? base64Image;
  String? slectStatus;

  String pType = "";
  String status = "";

  String catId = "";
  String selectProprty = "";

  GalleryImageController() {
    getGalleryImageList();
  }
  Future getGalleryImageList() async {
    try {
      isLoading = false;
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.path + Config.galleryList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        addGalleryInfo = AddGalleryInfo.fromJson(result);
        print(result.toString());
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getGalleryImageAndId({String? recId, gImg, selectPro, selectCat, pId, cId}) {
    recodeId = recId ?? "";
    gImage = gImg ?? "";
    selectProprty = selectPro;
    pType = pId;
    update();
  }

  emptyDetails() {
    pType = "";
    status = "";
    catId = "";
    path = null;
    slectStatus = null;
    selectGalleryCat = [];
  }

  Future propertyWiseGalleryCat({String? proId}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "prop_id": proId,
      };
      print(">>>>>>>>>>>>>>>>>>>$proId");
      Uri uri = Uri.parse(Config.path + Config.proWiseGalleryCat);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        selectGalleryCat = [];
        for (var element in result["galcatlist"]) {
          selectGalleryCat.add(element["cat_title"]);
        }
        print("GALLERY CAT LIST >>>>>>>>>>>>>>>>>>>>>>>> $selectGalleryCat");
        propertyWiseInfo = PropertyWiseInfo.fromJson(result);
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  addGallery() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "prop_id": pType,
        "cat_id": catId,
        "status": status == "" ? "1" : status,
        "img": base64Image,
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.addGallery);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getGalleryImageList();
          emptyDetails();
          showToastMessage(result["ResponseMsg"]);
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

  editGalley() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "prop_id": pType,
        "cat_id": catId,
        "status": status == "" ? "1" : status,
        "img": path != null ? base64Image : "0",
        "record_id": recodeId,
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.editGallery);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          getGalleryImageList();
          emptyDetails();
          showToastMessage(result["ResponseMsg"]);
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
