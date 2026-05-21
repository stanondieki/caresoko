import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
import 'package:gotocarefinder/model/paystackmodel.dart';
import 'package:http/http.dart' as http;
import '../Api/data_store.dart';

class PaystackController extends GetxController implements GetxService {
  bool loading = true;
  PaystackModel? paystackData;
  String randomKey = "";

  Future paystack(amount) async {
    Map body = {
      "email": getData.read("UserLogin")["email"].toString(),
      "amount": amount
    };

    var response = await http.post(
      Uri.parse(Config.baseurl + Config.paystackpayment),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      var paystackDecode = jsonDecode(response.body);

      if (paystackDecode["status"] == true) {
        loading = false;
        paystackData = paystackModelFromJson(response.body);
        randomKey = paystackData!.data!.reference!;
        update();
      }
    }
  }

  ReviewSummaryController reviewSummaryController =
      Get.put(ReviewSummaryController());

  Future paystackCheck({required String skKey}) async {
    var headers = {
      'accept': 'application/json',
      'authorization': 'Bearer $skKey',
      'cache-control': 'no-cache',
      'Cookie':
          '__cf_bm=nKw4bfwPAY5QJ8dPIH0qS4Dp.Y1TlO.VD1Irv9WAQng-1719051250-1.0.1.1-jBLW_9zjUIrwPtUoTO_RneCcm.aXgbDffT6geT2F9ck0Oru98__c4SekTkQT_zcHtR45Lzil61auKdc1ds_2eA; sails.sid=s%3Aey_lysqt0ZrbDS77szUh-7g1eG_AxjFo.aq4qmVSMZzoCG9un%2FiKh4FVMyxXvAcGIcEpWLPl%2BPdA'
    };

    var request = await http.get(
        Uri.parse('https://api.paystack.co/transaction/verify/$randomKey'),
        headers: headers);

    if (request.statusCode == 200) {
      return jsonDecode(request.body);
    } else {}
  }
}
