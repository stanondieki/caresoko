// ignore_for_file: deprecated_member_use, file_names, prefer_typing_uninitialized_variables, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/screen/payment/PaymentCard.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripePaymentWeb extends StatefulWidget {
  final PaymentCardCreated paymentCard;
  const StripePaymentWeb({super.key, required this.paymentCard});

  @override
  State<StripePaymentWeb> createState() => _StripePaymentWebState();
}

class _StripePaymentWebState extends State<StripePaymentWeb> {
  late final WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PaymentCardCreated? payCard;
  var progress = 0;

  @override
  void initState() {
    super.initState();
    payCard = widget.paymentCard;
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.grey.shade200)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            this.progress = progress;
          });
        },
        onPageFinished: (url) {
          readJS();
        },
      ))
      ..loadRequest(Uri.parse(initialUrl));
  }

  String get initialUrl =>
      Config.paymentBaseUrl +
      'stripe/index.php?name=${payCard!.name}&email=${payCard!.email}'
          '&cardno=${payCard!.number}&cvc=${payCard!.cvv}&amt=${payCard!.amount}'
          '&mm=${payCard!.month}&yyyy=${payCard!.year}';

  @override
  Widget build(BuildContext context) {
    if (_scaffoldKey.currentState == null) {
      return WillPopScope(
        onWillPop: (() async => true),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Get.height * 0.02),
                      SizedBox(
                        width: Get.width * 0.80,
                        child: const Text(
                          'Please don`t press back until the transaction is complete',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.01),
                Stack(
                  children: [
                    Container(
                      color: Colors.grey.shade200,
                      height: 25,
                      child: WebViewWidget(
                        controller: _controller,
                      ),
                    ),
                    Container(
                      height: 25,
                      color: Colors.white,
                      width: Get.width,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Future<void> readJS() async {
    try {
      final String? content = await _controller.runJavaScriptReturningResult(
        "document.documentElement.innerText",
      ) as String?;

      if (content != null && content.contains("Transaction_id")) {
        String fixed = content.replaceAll(r"\'", "");
        if (GetPlatform.isAndroid) {
          String json = jsonDecode(fixed);
          var val = jsonStringToMap(json);
          if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
            Get.back(result: val["Transaction_id"]);
            showToastMessage(val["ResponseMsg"]);
          } else {
            showToastMessage(val["ResponseMsg"]);
            Get.back();
          }
        } else {
          var val = jsonStringToMap(fixed);
          if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
            Get.back(result: val["Transaction_id"]);
            showToastMessage(val["ResponseMsg"]);
          } else {
            showToastMessage(val["ResponseMsg"]);
            Get.back();
          }
        }
      }
    } catch (e) {
      debugPrint('Error reading JavaScript: $e');
    }
  }

  Map<String, dynamic> jsonStringToMap(String data) {
    List<String> str = data
        .replaceAll("{", "")
        .replaceAll("}", "")
        .replaceAll("\"", "")
        .replaceAll("'", "")
        .split(",");
    Map<String, dynamic> result = {};
    for (int i = 0; i < str.length; i++) {
      List<String> s = str[i].split(":");
      result.putIfAbsent(s[0].trim(), () => s[1].trim());
    }
    return result;
  }
}
