// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/booking_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/model/add%20property%20model/porstatuswise_info.dart';

/// Orchestrates the provider dashboard by delegating to the architecture's
/// existing controllers:
///   - [DashBoardController] → `u_dashboard.php` (KPIs, subscription, earnings)
///   - [BookingController]   → `u_my_book.php`   (owner-side bookings)
///   - [ListOfPropertiController] → `u_property_list.php` (listing count)
///
/// This avoids a custom endpoint and reuses what the production backend
/// already provides.
class ProviderDashboardController extends GetxController {
  bool isLoading = true;
  String? errorMessage;

  // KPIs derived from DashBoardController.dashBoardInfo
  String totalBookings = "0";
  String totalEarnings = "0";
  String currency = '\$';
  int totalListings = 0;
  bool isSubscribed = false;
  String withdrawLimit = "0";

  // Recent bookings from BookingController (owner side)
  List<Statuswise> recentBookings = [];

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
      // 1. Fetch dashboard KPIs via existing DashBoardController
      final dashCtrl = Get.find<DashBoardController>();
      await dashCtrl.getDashBoardData();

      if (dashCtrl.dashBoardInfo != null) {
        isSubscribed = dashCtrl.dashBoardInfo!.isSubscribe == 1;
        withdrawLimit = dashCtrl.dashBoardInfo!.withdrawLimit;

        // Extract KPIs from report_data
        for (final report in dashCtrl.dashBoardInfo!.reportData) {
          if (report.title == "Total Booking" || report.title == "Total Book") {
            totalBookings = report.reportData;
          }
          if (report.title == "My Earning") {
            totalEarnings = report.reportData;
          }
        }

        // Currency from home data
        currency = getData.read("currency") ?? '\$';
      }

      // 2. Fetch owner-side bookings via existing BookingController
      final bookCtrl = Get.find<BookingController>();
      bookCtrl.statusWiseBook = "active";
      await bookCtrl.getBookingStatusWise();

      if (bookCtrl.proStatusWiseInfo?.statuswise != null) {
        // Show up to 5 most recent bookings
        recentBookings = bookCtrl.proStatusWiseInfo!.statuswise!.take(5).toList();
      }

      // 3. Get listing count via existing ListOfPropertiController
      final listCtrl = Get.find<ListOfPropertiController>();
      await listCtrl.getPropertiList();
      totalListings = listCtrl.propListInfo?.proplist?.length ?? 0;

    } catch (e) {
      errorMessage = e.toString();
      print("ProviderDashboardController.fetch error: $e");
    }

    isLoading = false;
    update();
  }
}
