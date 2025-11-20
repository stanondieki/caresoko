import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/Custom_widget.dart';

class Senangpay extends StatefulWidget {
  final String totalAmount;
  final String name;
  final String email;
  final String phone;

  const Senangpay({
    super.key,
    required this.totalAmount,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<Senangpay> createState() => _SenangpayState();
}

class _SenangpayState extends State<Senangpay> {
  late final WebViewController _controller;
  var progress = 0;
  String? accessToken;
  String? payerID;
  final notificationId = UniqueKey().hashCode;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            this.progress = progress;
          });
        },
        onPageFinished: (url) {
          readJS();
        },
        onNavigationRequest: (request) async {
          final uri = Uri.parse(request.url);
          if (uri.queryParameters["msg"] == null) {
            accessToken = uri.queryParameters["token"];
          } else {
            if (uri.queryParameters["msg"] == "Payment_was_successful") {
              payerID = uri.queryParameters["transaction_id"];
              Get.back(result: payerID);
            } else {
              Get.back();
              showToastMessage("${uri.queryParameters["msg"]}");
            }
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(
        "${Config.paymentBaseUrl}result.php?detail=Movers&amount=${widget.totalAmount}"
        "&order_id=$notificationId&name=${widget.name}&email=${widget.email}&phone=${widget.phone}",
      ));
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
          var val1 = jsonStringToMap(json);
          if ((val1['ResponseCode'] == "200") && (val1['Result'] == "true")) {
            Get.back(result: val1["Transaction_id"]);
            showToastMessage(val1["ResponseMsg"]);
          } else {
            showToastMessage(val1["ResponseMsg"]);
            Get.back();
          }
        } else {
          var val2 = jsonStringToMap(fixed);
          if ((val2['ResponseCode'] == "200") && (val2['Result'] == "true")) {
            Get.back(result: val2["Transaction_id"]);
            showToastMessage(val2["ResponseMsg"]);
          } else {
            showToastMessage(val2["ResponseMsg"]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}
