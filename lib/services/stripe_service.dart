// lib/services/stripe_service.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

/// ---------------- BASE URL SETUP ----------------

String get _devBase {
  if (kIsWeb) {
    // Your local PHP dev host:port/path
    return 'http://localhost:8000/stripe';
  } else if (Platform.isAndroid) {
    // Android emulator -> host machine
    return 'http://10.0.2.2:8000/stripe';
  } else if (Platform.isIOS) {
    // iOS simulator
    return 'http://localhost:8000/stripe';
  } else {
    return 'http://localhost:8000/stripe';
  }
}

/// Production base URL
const _prodBase = 'https://careinafh.caresoko.com/user_api/';

/// Toggle between dev / prod
String get _backendBaseUrl {
  const bool useProd = true; // flip when you want dev
  return useProd ? _prodBase : _devBase;
}

String get _base => _backendBaseUrl;
String baseUrl = "https://careinafh.caresoko.com/user_api/";

/// ---------------- STRIPE SERVICE ----------------
class StripeService {
  Future<bool> payOrder(int orderId, int amount, String currency) async {
    final create = await http.post(
      Uri.parse("$baseUrl/create-payment-intent.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount.toString(),
        "currency": currency,
        "metadata": {"order_id": orderId.toString()}
      }),
    );

    final ci = jsonDecode(create.body);
    final clientSecret = ci["paymentIntentClientSecret"];
    final piId = ci["paymentIntentId"];

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "GoToCareFinder",
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    // verify
    final verify = await http.post(
      Uri.parse("$baseUrl/verify-payment.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "payment_intent_id": piId,
        "order_id": orderId
      }),
    );

    final result = jsonDecode(verify.body);
    return result["ok"] == true;
  }
}