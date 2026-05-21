// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:http/http.dart' as http;

/// Recent booking row shown on the provider dashboard.
class RecentBooking {
  final String id;
  final String type; // "homecare" or "property"
  final String title;
  final String customerName;
  final String status;
  final double amount;
  final String bookDate;

  RecentBooking({
    required this.id,
    required this.type,
    required this.title,
    required this.customerName,
    required this.status,
    required this.amount,
    required this.bookDate,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> j) => RecentBooking(
        id: j['id']?.toString() ?? '',
        type: j['type']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        customerName: j['customer_name']?.toString() ?? '',
        status: j['status']?.toString() ?? '',
        amount: double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
        bookDate: j['book_date']?.toString() ?? '',
      );
}

/// Fetches and exposes provider dashboard data.
///
/// Lifecycle: create once with `Get.put(ProviderDashboardController())` from
/// the dashboard screen. Calling `refresh()` re-fetches.
class ProviderDashboardController extends GetxController {
  bool isLoading = true;
  String? errorMessage;

  int bookingsThisWeek = 0;
  int bookingsTotal = 0;
  double earningsMtd = 0;
  String currency = '\$';
  double? avgRating;
  int totalListings = 0;

  List<RecentBooking> recentBookings = [];

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    final user = getData.read("UserLogin");
    if (user == null || user["id"] == null) {
      isLoading = false;
      errorMessage = "Not signed in";
      update();
      return;
    }

    isLoading = true;
    errorMessage = null;
    update();

    try {
      final uri = Uri.parse(Config.path + Config.providerDashboard);
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": user["id"]}),
      );

      if (res.statusCode != 200) {
        errorMessage = "Server returned ${res.statusCode}";
      } else {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body["Result"]?.toString() != "true") {
          errorMessage = body["ResponseMsg"]?.toString() ?? "Failed to load";
        } else {
          final stats = (body["stats"] as Map?) ?? {};
          bookingsThisWeek =
              int.tryParse(stats["bookings_this_week"]?.toString() ?? '') ?? 0;
          bookingsTotal =
              int.tryParse(stats["bookings_total"]?.toString() ?? '') ?? 0;
          earningsMtd =
              double.tryParse(stats["earnings_mtd"]?.toString() ?? '') ?? 0;
          currency = stats["earnings_currency"]?.toString() ?? '\$';
          final rawRating = stats["avg_rating"];
          avgRating =
              rawRating == null ? null : double.tryParse(rawRating.toString());
          totalListings =
              int.tryParse(stats["total_listings"]?.toString() ?? '') ?? 0;

          final list = (body["recent_bookings"] as List?) ?? [];
          recentBookings = list
              .map((e) => RecentBooking.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      print("ProviderDashboardController.fetch error: $e");
    }

    isLoading = false;
    update();
  }
}
