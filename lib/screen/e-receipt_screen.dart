// ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print, unnecessary_brace_in_string_interps, unused_local_variable, unnecessary_new

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/bookingdetails_controller.dart';
import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
import 'package:gotocarefinder/controller/mybooking_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers (padding + max body width)
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EReceiptScreen extends StatefulWidget {
  const EReceiptScreen({super.key});

  @override
  State<EReceiptScreen> createState() => _EReceiptScreenState();
}

class _EReceiptScreenState extends State<EReceiptScreen> {
  final BookrealEstateController bookrealEstateController = Get.find();
  final BookingDetailsController bookingDetailsController = Get.find();
  final MyBookingController myBookingController = Get.find();

  // "Completed" / "Active" passed via arguments; guard for null
  String statusArg = (Get.arguments?["Completed"] ?? "").toString();

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final padding = R.screenPadding(context); // consistent inner padding
    final cardRadius = BorderRadius.circular(15);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Booking Details".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        centerTitle: !R.isDesktop(context),
      ),
      body: GetBuilder<BookingDetailsController>(builder: (_) {
        if (!bookingDetailsController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final details = bookingDetailsController.bookDetailsInfo?.bookdetails;

        // Basic safe getters
        String safe(String? v, {String fallback = "—"}) =>
            (v == null || v.isEmpty) ? fallback : v;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
            child: Scrollbar(
              thumbVisibility: kIsWeb,
              child: SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Property Card
                    Container(
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: cardRadius,
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            safe(details?.propTitle, fallback: ""),
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 18,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            safe(details?.propType, fallback: ""),
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 15,
                              color: blueColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            safe(details?.address, fallback: ""),
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 15,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Date/Time Card
                    Container(
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: cardRadius,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: "Date".tr,
                            value: safe(details?.date?.toString(), fallback: "—"),
                            notifire: notifire,
                          ),
                          SizedBox(height: 12),
                          _InfoRow(
                            label: "Time".tr,
                            value: safe(details?.time?.toString(), fallback: "—"),
                            notifire: notifire,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Contact / Status Card
                    Container(
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: cardRadius,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: "Name".tr,
                            value: (() {
                              // If API fname is empty, show from local user profile
                              final apiName = details?.fname ?? "";
                              if (apiName.isEmpty) {
                                return (getData.read("UserLogin")?["name"] ?? "").toString();
                              }
                              return apiName;
                            })(),
                            notifire: notifire,
                          ),
                          SizedBox(height: 12),
                          _InfoRow(
                            label: "Phone Number".tr,
                            value: (() {
                              final m = details?.mobile ?? "";
                              if (m.isEmpty) {
                                final ccode = (getData.read("UserLogin")?["ccode"] ?? "").toString();
                                final mobile = (getData.read("UserLogin")?["mobile"] ?? "").toString();
                                return "$ccode $mobile".trim();
                              }
                              final ccode = safe(details?.ccode, fallback: "");
                              return "$ccode ${details?.mobile}".trim();
                            })(),
                            notifire: notifire,
                          ),
                          SizedBox(height: 12),
                          _InfoRow(
                            label: "Booking Status".tr,
                            value: safe(details?.bookStatus, fallback: "—"),
                            notifire: notifire,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Note (if any)
                    if (safe(details?.message, fallback: "").isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: notifire.getblackwhitecolor,
                          borderRadius: cardRadius,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Note:",
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 18,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              safe(details?.message, fallback: "—"),
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                fontSize: 15,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Review button (only when completed & not rated)
                    if ((details?.bookStatus == "Completed") &&
                        (details?.isRate == "0"))
                      GestButton(
                        Width: double.infinity,
                        height: 50,
                        buttoncolor: blueColor,
                        margin: EdgeInsets.only(top: 20),
                        buttontext: "Review".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          color: WhiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        onclick: () => reviewSheet(),
                      ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future reviewSheet() {
    return Get.bottomSheet(
      isScrollControlled: true,
      Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: GetBuilder<BookingDetailsController>(builder: (context) {
            return Material(
              color: notifire.getblackwhitecolor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context as BuildContext).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Leave a Review",
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(color: notifire.getgreycolor),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "How was your experience",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RatingBar(
                          initialRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          ratingWidget: RatingWidget(
                            full: Image.asset('assets/images/starBold.png', color: blueColor),
                            half: Image.asset('assets/images/star-half.png', color: blueColor),
                            empty: Image.asset('assets/images/Star.png', color: blueColor),
                          ),
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          onRatingUpdate: (r) => bookingDetailsController.totalRateUpdate(r),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(color: notifire.getgreycolor),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 16, right: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Write Your Review",
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: FontFamily.gilroyBold,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notifire.getblackwhitecolor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: notifire.getborderColor),
                          ),
                          child: TextFormField(
                            controller: bookingDetailsController.ratingText,
                            minLines: 4,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            cursorColor: notifire.getwhiteblackcolor,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: InputBorder.none,
                              hintText: "Your review here...",
                              hintStyle: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                fontSize: 15,
                                color: notifire.getgreycolor,
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 16,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Divider(color: notifire.getgreycolor),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Get.back(),
                                child: Container(
                                  height: 50,
                                  margin: const EdgeInsets.all(15),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFeef4ff),
                                    borderRadius: BorderRadius.circular(45),
                                  ),
                                  child: Text(
                                    "Maybe Later",
                                    style: TextStyle(
                                      color: blueColor,
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  bookingDetailsController.reviewUpdateApi(
                                    bookId: bookingDetailsController.bookDetailsInfo?.bookdetails?.bookId,
                                  );
                                },
                                child: Container(
                                  height: 50,
                                  margin: const EdgeInsets.all(15),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: blueColor,
                                    borderRadius: BorderRadius.circular(45),
                                  ),
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: WhiteColor,
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Label–value row that gracefully ellipsizes the value to avoid overflows.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorNotifire notifire;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 15,
              color: notifire.getwhiteblackcolor,
            ),
          ),
          Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 15,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}





// // ignore_for_file: file_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print, unnecessary_brace_in_string_interps, unused_local_variable, unnecessary_new
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/bookingdetails_controller.dart';
// import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
// import 'package:gotocarefinder/controller/mybooking_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class EReceiptScreen extends StatefulWidget {
//   const EReceiptScreen({super.key});
//
//   @override
//   State<EReceiptScreen> createState() => _EReceiptScreenState();
// }
//
// class _EReceiptScreenState extends State<EReceiptScreen> {
//   BookrealEstateController bookrealEstateController = Get.find();
//   BookingDetailsController bookingDetailsController = Get.find();
//   MyBookingController myBookingController = Get.find();
//
//   String staus = Get.arguments["Completed"];
//
//   late ColorNotifire notifire;
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     if (previusstate == null) {
//       notifire.setIsDark = false;
//     } else {
//       notifire.setIsDark = previusstate;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getdarkmodepreviousstate();
//   }
//
//   int total = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getbgcolor,
//       appBar: AppBar(
//         backgroundColor: notifire.getbgcolor,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(
//             Icons.arrow_back,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//         title: Text(
//           "Booking Details".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: GetBuilder<BookingDetailsController>(builder: (context) {
//         return bookingDetailsController.isLoading
//             ? SizedBox(
//                 height: Get.size.height,
//                 width: Get.size.width,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         margin: EdgeInsets.symmetric(horizontal: 10),
//                         decoration: BoxDecoration(
//                           color: notifire.getblackwhitecolor,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 bookingDetailsController.bookDetailsInfo
//                                         ?.bookdetails!.propTitle ??
//                                     "",
//                                 style: TextStyle(
//                                   fontFamily: FontFamily.gilroyBold,
//                                   fontSize: 18,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                               SizedBox(height: 3),
//                               Text(
//                                 bookingDetailsController.bookDetailsInfo
//                                         ?.bookdetails!.propType ??
//                                     "",
//                                 style: TextStyle(
//                                   fontFamily: FontFamily.gilroyBold,
//                                   fontSize: 15,
//                                   color: blueColor,
//                                 ),
//                               ),
//                               SizedBox(height: 3),
//                               Text(
//                                 bookingDetailsController.bookDetailsInfo
//                                         ?.bookdetails!.address ??
//                                     "",
//                                 style: TextStyle(
//                                   fontFamily: FontFamily.gilroyMedium,
//                                   fontSize: 15,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 10),
//                         width: Get.size.width,
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 20.0, bottom: 20),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                   Text(
//                                     "Date".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Text(
//                                     bookingDetailsController
//                                             .bookDetailsInfo?.bookdetails!.date
//                                             .toString() ??
//                                         "Null",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                   Text(
//                                     "Time".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Text(
//                                     bookingDetailsController
//                                             .bookDetailsInfo?.bookdetails!.time
//                                             .toString() ??
//                                         "Null",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: notifire.getblackwhitecolor,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       Container(
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [],
//                             ),
//                           ],
//                         ),
//                         decoration: BoxDecoration(
//                           color: notifire.getblackwhitecolor,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 10),
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 Text(
//                                   'Name'.tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 15,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                                 Spacer(),
//                                 bookingDetailsController.bookDetailsInfo
//                                             ?.bookdetails!.fname ==
//                                         ""
//                                     ? Text(
//                                         getData
//                                             .read("UserLogin")["name"]
//                                             .toString(),
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 15,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       )
//                                     : Text(
//                                         bookingDetailsController.bookDetailsInfo
//                                                 ?.bookdetails!.fname ??
//                                             "",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 15,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 Text(
//                                   'Phone Number'.tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 15,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                                 Spacer(),
//                                 bookingDetailsController.bookDetailsInfo
//                                             ?.bookdetails!.mobile ==
//                                         ""
//                                     ? Text(
//                                         "${getData.read("UserLogin")["ccode"]} ${getData.read("UserLogin")["mobile"]}",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 15,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       )
//                                     : Text(
//                                         "${bookingDetailsController.bookDetailsInfo?.bookdetails!.ccode ?? ""} ${bookingDetailsController.bookDetailsInfo?.bookdetails!.mobile ?? ""}",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 15,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 20,
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 Text(
//                                   'Booking Status'.tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 15,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                                 Spacer(),
//                                 Text(
//                                   bookingDetailsController.bookDetailsInfo
//                                           ?.bookdetails!.bookStatus ??
//                                       "",
//                                   maxLines: 1,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 15,
//                                     color: notifire.getwhiteblackcolor,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                               ],
//                             ),
//                             SizedBox(
//                               height: 20,
//                             ),
//                           ],
//                         ),
//                         decoration: BoxDecoration(
//                           color: notifire.getblackwhitecolor,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       bookingDetailsController
//                                   .bookDetailsInfo?.bookdetails!.message ==
//                               ""
//                           ? SizedBox()
//                           : Container(
//                               width: double.infinity,
//                               margin: EdgeInsets.symmetric(horizontal: 10),
//                               decoration: BoxDecoration(
//                                 color: notifire.getblackwhitecolor,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Note:",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyBold,
//                                         fontSize: 18,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                     SizedBox(height: 3),
//                                     Text(
//                                       bookingDetailsController.bookDetailsInfo
//                                               ?.bookdetails!.message ??
//                                           "Null",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 15,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       bookingDetailsController
//                                   .bookDetailsInfo?.bookdetails!.bookStatus ==
//                               "Completed"
//                           ? bookingDetailsController
//                                       .bookDetailsInfo?.bookdetails!.isRate ==
//                                   "0"
//                               ? GestButton(
//                                   Width: Get.size.width,
//                                   height: 50,
//                                   buttoncolor: blueColor,
//                                   margin: EdgeInsets.only(
//                                       top: 15, left: 30, right: 30),
//                                   buttontext: "Review".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     color: WhiteColor,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   onclick: () {
//                                     reviewSheet();
//                                   },
//                                 )
//                               : SizedBox.shrink()
//                           : SizedBox(),
//                       SizedBox(
//                         height: 40,
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             : Center(
//                 child: CircularProgressIndicator(),
//               );
//       }),
//     );
//   }
//
//   Future reviewSheet() {
//     return Get.bottomSheet(
//       isScrollControlled: true,
//       GetBuilder<BookingDetailsController>(builder: (context) {
//         return Container(
//           height: 520,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "Leave a Review",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontFamily: FontFamily.gilroyBold,
//                   color: notifire.getwhiteblackcolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                 ),
//                 child: Divider(
//                   color: notifire.getgreycolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "How was your experience",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontFamily: FontFamily.gilroyBold,
//                   color: notifire.getwhiteblackcolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               RatingBar(
//                 initialRating: 1,
//                 direction: Axis.horizontal,
//                 allowHalfRating: true,
//                 itemCount: 5,
//                 ratingWidget: RatingWidget(
//                   full: Image.asset(
//                     'assets/images/starBold.png',
//                     color: blueColor,
//                   ),
//                   half: Image.asset(
//                     'assets/images/star-half.png',
//                     color: blueColor,
//                   ),
//                   empty: Image.asset(
//                     'assets/images/Star.png',
//                     color: blueColor,
//                   ),
//                 ),
//                 itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                 onRatingUpdate: (rating) {
//                   bookingDetailsController.totalRateUpdate(rating);
//                 },
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                 ),
//                 child: Divider(
//                   color: notifire.getgreycolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, left: 15),
//                 child: Text(
//                   "Write Your Review",
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontFamily: FontFamily.gilroyBold,
//                     color: notifire.getwhiteblackcolor,
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.all(15),
//                 child: TextFormField(
//                   controller: bookingDetailsController.ratingText,
//                   minLines: 4,
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null,
//                   cursorColor: notifire.getwhiteblackcolor,
//                   decoration: InputDecoration(
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                         color: notifire.getborderColor,
//                       ),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     contentPadding: EdgeInsets.all(10),
//                     focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(
//                           color: notifire.getborderColor,
//                         )),
//                     border: InputBorder.none,
//                     hintText: "Your review here...",
//                     hintStyle: TextStyle(
//                       fontFamily: FontFamily.gilroyMedium,
//                       fontSize: 15,
//                     ),
//                   ),
//                   style: TextStyle(
//                     fontFamily: FontFamily.gilroyMedium,
//                     fontSize: 16,
//                     color: notifire.getwhiteblackcolor,
//                   ),
//                 ),
//                 decoration: BoxDecoration(
//                   color: notifire.getblackwhitecolor,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                 ),
//                 child: Divider(
//                   color: notifire.getgreycolor,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: Container(
//                         height: 50,
//                         margin: EdgeInsets.all(15),
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Maybe Later",
//                           style: TextStyle(
//                             color: blueColor,
//                             fontFamily: FontFamily.gilroyBold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFeef4ff),
//                           borderRadius: BorderRadius.circular(45),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         bookingDetailsController.reviewUpdateApi(
//                           bookId: bookingDetailsController
//                               .bookDetailsInfo?.bookdetails!.bookId,
//                         );
//                       },
//                       child: Container(
//                         height: 50,
//                         margin: EdgeInsets.all(15),
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Submit",
//                           style: TextStyle(
//                             color: WhiteColor,
//                             fontFamily: FontFamily.gilroyBold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: blueColor,
//                           borderRadius: BorderRadius.circular(45),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               )
//             ],
//           ),
//           decoration: BoxDecoration(
//             color: notifire.getblackwhitecolor,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
