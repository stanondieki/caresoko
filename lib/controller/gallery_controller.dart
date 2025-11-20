// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/model/gallery_info.dart';
import 'package:http/http.dart' as http;

class GalleryController extends GetxController implements GetxService {
  GalleryInfo? galleryInfo;
  bool isLoading = false;

  getGalleryData({String? pId}) async {
    try {
      Map map = {
        "prop_id": pId,
      };
      print("============" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.seeAllGalery);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("---------------" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("**************" + result.toString());
        galleryInfo = GalleryInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
