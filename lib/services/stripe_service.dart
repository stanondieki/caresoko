// lib/services/stripe_service.dart
import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

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