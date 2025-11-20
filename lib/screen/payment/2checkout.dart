// ignore_for_file: prefer_final_fields, unused_field, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, avoid_print, prefer_const_constructors, avoid_unnecessary_containers, file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Api/config.dart';

class CheckOutPayment extends StatefulWidget {
  final String? email;
  final String? totalAmount;

  const CheckOutPayment({this.email, this.totalAmount});

  @override
  State<CheckOutPayment> createState() => _CheckOutPaymentState();
}

class _CheckOutPaymentState extends State<CheckOutPayment> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final WebViewController _controller;

  var progress = 0;
  String? accessToken;
  String? payerID;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            print(" + + + + + + + + + + + + + ${uri.queryParameters}");

            if (uri.queryParameters["status"] == null) {
              accessToken = uri.queryParameters["preference_id"];
            } else {
              if (uri.queryParameters["status"] == "successful") {
                payerID = uri.queryParameters["merchant_account_id"];
                Get.back(result: payerID);
              } else {
                Get.back();
                showToastMessage("${uri.queryParameters["status"]}");
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            "${Config.paymentBaseUrl}2checkout/index.php?amt=${widget.totalAmount}"),
      );
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: Get.height * 0.02),
                    SizedBox(
                      width: Get.width * 0.80,
                      child: Text(
                        'Please don`t press back until the transaction is complete'
                            .tr,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
