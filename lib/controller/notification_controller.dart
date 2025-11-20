// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/notification_info.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController implements GetxService {
  NotificationInfo? notificationInfo;
  bool isLoading = false;

  NotificationController() {
    getNotificationData();
  }

  getNotificationData() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      print(map.toString());
      Uri uri = Uri.parse(Config.path + Config.notification);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("{{{{{{{{{{{{{{${response.body}");
      print(response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("0000000000000000" + result.toString());
        notificationInfo = NotificationInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
