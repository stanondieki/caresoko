import 'dart:convert';

import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:http/http.dart' as http;
import '../Api/data_store.dart';

class CalendarController extends GetxController implements GetxService {
  var selectedDate = [];
  Future calendar(propertyid) async {
    Map body = {
      "uid": getData.read("UserLogin")["id"],
      "property_id": propertyid
    };

    var response = await http.post(
      Uri.parse(Config.path + Config.calendar),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var calendarData = jsonDecode(response.body);
      selectedDate = calendarData["datelist"];
      update();
      return calendarData;
    }
  }
}
