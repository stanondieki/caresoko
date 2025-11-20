// ignore_for_file: unused_element, unused_field, unnecessary_string_interpolations, unused_local_variable, prefer_interpolation_to_compose_strings, avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/wallet_controller.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookrealEstateController extends GetxController implements GetxService {
  WalletController walletController = Get.put(WalletController());

  int count = 1;

  DateTime selectedDate = DateTime.now();

  String dateOfTour = "";

  String message = "";

  String checkDateResult = "true";
  String checkDateMsg = "";

  bool visible = false;
  bool chack = false;
  List days = [];

  String? selectedTime;

  void updateTime(String time) {
    selectedTime = time;
    update();
  }

  int currentValue = 0;

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is DateTime) {
      days = [];
      checkDateResult = "true";
      selectedDate = args.value as DateTime;
      dateOfTour = DateFormat('dd/MM/yyyy').format(selectedDate);

      visible = true;
      update();
    }
  }

  cleanDate() {
    selectedDate = DateTime.now();
    dateOfTour = "";
    visible = false;
    chack = false;
    count = 1;
    update();
  }

  bookingForSomeOne(bool? newbool) {
    chack = newbool ?? false;
    update();
  }

  changeValue(int value) {
    currentValue = value;
    update();
  }

  /*checkDateApi({String? pid}) async {
    try {
      Map map = {
        "pro_id": pid,
        "date": dateOfTour,
        "time": selectedTime,
      };
      Uri uri = Uri.parse(Config.path + Config.checDateApi);

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      print(" + + + + + + + + + + ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        checkDateResult = result["Result"];
        checkDateMsg = result["ResponseMsg"];

        if (visible == true) {
          if (checkDateResult == "true") {
            if (chack == true) {
              Get.toNamed(Routes.bookInformetionScreen);
            } else {
              Get.toNamed(Routes.reviewSummaryScreen, arguments: {
                "copAmt": 0,
                "fname": "",
                "lname": "",
                "gender": "",
                "email": "",
                "mobile": "",
                "ccode": "",
                "country": "",
                "couponCode": "",
              });
            }
          } else {
            Fluttertoast.showToast(
              msg: checkDateMsg,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: RedColor,
              textColor: Colors.white,
              fontSize: 14.0,
            );
          }
        } else {
          showToastMessage("Please select date".tr);
        }
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }*/

  bookApiData({
    String? pid,
    String? bookFor,
    String? fname,
    String? lname,
    String? email,
    String? mobile,
    String? ccode,
    String? country,
    String? noGuest,
  }) async {
    try {
      Map map = {
        "prop_id": pid,
        "uid": getData.read("UserLogin")["id"].toString(),
        "date": dateOfTour,
        "time": selectedTime,
        "message": message,
        "book_for": bookFor,
        "fname": fname,
        "lname": lname,
        "email": email,
        "mobile": mobile,
        "ccode": ccode,
        "country": country,
      };

      print("---------+++++++++++${map.toString()}");
      Uri uri = Uri.parse(Config.path + Config.bookApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("---------===========" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("---------===========" + result.toString());
        String bookresult = result["ResponseMsg"];

        showToastMessage(bookresult);
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
