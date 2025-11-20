import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidTrans extends StatefulWidget {
  final String email;
  final String totalAmount;
  final String phonNumber;

  const MidTrans({
    required this.email,
    required this.totalAmount,
    required this.phonNumber,
  });

  @override
  State<MidTrans> createState() => _MidTransState();
}

class _MidTransState extends State<MidTrans> {
  late final WebViewController _controller;
  bool isLoading = true;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            this.progress = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            isLoading = false;
          });
        },
        onNavigationRequest: (request) async {
          final uri = Uri.parse(request.url);
          if (uri.queryParameters["transaction_status"] == null) {
            String? accessToken = uri.queryParameters["token"];
            return NavigationDecision.navigate;
          } else {
            if (uri.queryParameters["status_code"] == "200") {
              String? payerId = uri.queryParameters["order_id"];
              Get.back(result: payerId);
            } else {
              Get.back();
              showToastMessage("${uri.queryParameters["transaction_status"]}");
            }
            return NavigationDecision.navigate;
          }
        },
      ))
      ..loadRequest(Uri.parse(
          "${Config.baseurl}Midtrans/index.php?name=test&email=${widget.email}&phone=${widget.phonNumber}&amt=${widget.totalAmount}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            WebViewWidget(
              controller: _controller,
            ),
            if (isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: Get.height * 0.02),
                    SizedBox(
                      width: Get.width * 0.80,
                      child: Text(
                        'Please don`t press back until the transaction is complete'
                            .tr,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
          ],
        ),
      ),
    );
  }
}
