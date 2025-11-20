import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/paystack_controller.dart';
import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../../controller/wallet_controller.dart';

int verifyPaystack = -1;

class Paystackweb extends StatefulWidget {
  final String? url;
  final String skID;

  const Paystackweb({this.url, required this.skID});

  @override
  State<Paystackweb> createState() => _PaystackwebState();
}

class _PaystackwebState extends State<Paystackweb> {
  late final WebViewController _controller;
  bool isLoading = true;
  int progress = 0;

  final WalletController walletController = Get.put(WalletController());
  final ReviewSummaryController reviewSummaryController =
      Get.put(ReviewSummaryController());
  final PaystackController paystackController = Get.put(PaystackController());

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
        onPageFinished: (finish) {
          paystackController.paystackCheck(skKey: widget.skID).then(
            (value) {
              if (value["status"] == true) {
                verifyPaystack = 1;
                Get.back();
              } else {
                verifyPaystack = 0;
              }
            },
          );
        },
        onNavigationRequest: (request) async {
          final uri = Uri.parse(request.url);
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url ?? ''));
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
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }

  Future<void> _verifyTransaction(String reference) async {
    final url = 'https://api.paystack.co/transaction/verify/$reference';
    final headers = {
      'Authorization': 'Bearer YOUR_SECRET_KEY',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody['data']['status'] == 'success') {
          Navigator.pop(
              context, {'status': 'successful', 'transaction_id': reference});
        } else {
          Navigator.pop(context, {'status': 'failed'});
        }
      } else {
        Navigator.pop(context, {'status': 'error'});
      }
    } catch (e) {
      Navigator.pop(context, {'status': 'error'});
    }
  }
}
