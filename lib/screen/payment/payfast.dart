import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../Api/config.dart';

class PayFast extends StatefulWidget {
  final String? email;
  final String? totalAmount;

  const PayFast({this.email, this.totalAmount});

  @override
  State<PayFast> createState() => _PayFastState();
}

class _PayFastState extends State<PayFast> {
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

          if (uri.queryParameters["status"] == null) {
            String? accessToken = uri.queryParameters["payment_id"];
            return NavigationDecision.navigate;
          } else {
            if (uri.queryParameters["status"] == "success") {
              String? payerId = uri.queryParameters["payment_id"];
              Get.back(result: payerId);
            } else {
              Get.back();
              showToastMessage("${uri.queryParameters["status"]}");
            }
            return NavigationDecision.navigate;
          }
        },
      ))
      ..loadRequest(Uri.parse(
          "${Config.paymentBaseUrl}Payfast/index.php?amt=${widget.totalAmount}"));
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
