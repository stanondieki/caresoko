// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_interpolation_to_compose_strings, avoid_print, unused_field, sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_final_fields, unnecessary_string_interpolations, unnecessary_brace_in_string_interps

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
import 'package:gotocarefinder/controller/wallet_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:gotocarefinder/model/routes_helper.dart';

class BookRealEstate extends StatefulWidget {
  const BookRealEstate({super.key});

  @override
  State<BookRealEstate> createState() => _BookRealEstateState();
}

/// Simple responsive helper
class _R {
  // Breakpoints
  static const double small = 600;   // phones
  static const double medium = 1024; // tablets / small desktops

  final double width;

  _R(this.width);

  bool get isSmall => width < small;
  bool get isMedium => width >= small && width < medium;
  bool get isLarge => width >= medium;

  double spacing(double base) {
    // Slightly larger spacing for bigger screens
    if (isLarge) return base * 1.4;
    if (isMedium) return base * 1.2;
    return base;
  }

  double text(double mobile, {double? desktop}) {
    if (isLarge) return desktop ?? mobile * 1.15;
    if (isMedium) return mobile * 1.06;
    return mobile;
  }

  EdgeInsetsGeometry edge(EdgeInsets mobile, {EdgeInsets? desktop}) {
    if (isLarge) return desktop ?? mobile.add(EdgeInsets.symmetric(horizontal: 8));
    if (isMedium) return mobile.add(EdgeInsets.symmetric(horizontal: 4));
    return mobile;
  }

  double maxContentWidth() {
    // Constrain very wide screens for better readability
    return isLarge ? 1100 : double.infinity;
  }

  double cardWidthLeftColumn() {
    // Calendar column width on wide screens
    if (isLarge) return 520;
    if (isMedium) return 520;
    return double.infinity;
  }
}

class _BookRealEstateState extends State<BookRealEstate> {
  BookrealEstateController bookrealEstateController = Get.find();
  HomePageController homePageController = Get.find();
  ReviewSummaryController reviewSummaryController = Get.find();
  DateRangePickerController controller = DateRangePickerController();

  WalletController walletController = Get.find();

  late ColorNotifire notifire;
  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  int count = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    bookrealEstateController.cleanDate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final width = MediaQuery.of(context).size.width;
    final r = _R(width);

    final titleStyle = TextStyle(
      fontSize: r.text(17, desktop: 19),
      fontFamily: FontFamily.gilroyBold,
      color: notifire.getwhiteblackcolor,
    );

    final labelStyle = TextStyle(
      fontSize: r.text(18, desktop: 20),
      fontFamily: FontFamily.gilroyBold,
      color: notifire.getwhiteblackcolor,
    );

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        title: Text(
          "Schedule Tour: ${homePageController.propetydetailsInfo?.propetydetails?.name ?? ''}".tr,
          style: titleStyle,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout:
          // - small (phones): single column scroller
          // - medium/large (tablets/web): two columns side-by-side
          final isTwoColumn = r.isMedium || r.isLarge;

          final content = GetBuilder<BookrealEstateController>(
            builder: (c) {
              // LEFT: Calendar card
              final calendarCard = Container(
                width: r.cardWidthLeftColumn(),
                margin: EdgeInsets.all(r.spacing(10)),
                decoration: BoxDecoration(
                  color: Color(0xFFeef4ff),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.only(top: r.spacing(10), left: r.spacing(15)),
                      child: Text("Select Date".tr, style: titleStyle),
                    ),
                    SizedBox(height: r.spacing(10)),
                    Container(
                      margin: EdgeInsets.all(r.spacing(10)),
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SfDateRangePicker(
                        controller: controller,
                        onSelectionChanged: bookrealEstateController.onSelectionChanged,
                        selectionMode: DateRangePickerSelectionMode.single,
                        enablePastDates: false,
                        selectionColor: bookrealEstateController.checkDateResult == "true"
                            ? blueColor
                            : RedColor,
                        headerStyle: DateRangePickerHeaderStyle(
                          textStyle: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            color: notifire.getwhiteblackcolor,
                            fontSize: r.text(16, desktop: 18),
                          ),
                        ),
                        selectionTextStyle: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          fontSize: r.text(14, desktop: 16),
                        ),
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          disabledDatesTextStyle: TextStyle(
                            color: notifire.getgreycolor,
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: r.text(13, desktop: 15),
                          ),
                          textStyle: TextStyle(
                            color: notifire.getwhiteblackcolor,
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: r.text(13, desktop: 15),
                          ),
                          blackoutDateTextStyle: TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                            fontSize: r.text(13, desktop: 15),
                          ),
                        ),
                        monthViewSettings: DateRangePickerMonthViewSettings(
                          viewHeaderStyle: DateRangePickerViewHeaderStyle(
                            textStyle: TextStyle(
                              color: notifire.getwhiteblackcolor,
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: r.text(13, desktop: 15),
                            ),
                          ),
                        ),
                        backgroundColor: notifire.getblackwhitecolor,
                        initialSelectedDate: DateTime.now(),
                      ),
                    ),
                  ],
                ),
              );

              // RIGHT: Time + Message + Booking card
              final rightCard = Container(
                width: isTwoColumn ? (width - r.cardWidthLeftColumn()) : double.infinity,
                margin: EdgeInsets.all(r.spacing(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    Padding(
                      padding: EdgeInsets.only(left: r.spacing(15)),
                      child: Text("Time".tr, style: labelStyle),
                    ),
                    SizedBox(height: r.spacing(10)),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final TimeOfDay? selectedTime = await Get.dialog(
                                Theme(
                                  data: Get.theme.copyWith(
                                    timePickerTheme: TimePickerThemeData(
                                      backgroundColor: notifire.getblackwhitecolor,
                                      hourMinuteTextColor: notifire.getwhiteblackcolor,
                                      dialHandColor: blueColor,
                                      dialBackgroundColor:
                                      notifire.getblackwhitecolor.withOpacity(0.1),
                                      entryModeIconColor: notifire.getwhiteblackcolor,
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: blueColor,
                                      ),
                                    ),
                                  ),
                                  child: TimePickerDialog(
                                    initialTime: TimeOfDay.now(),
                                  ),
                                ),
                              );

                              if (selectedTime != null) {
                                final now = DateTime.now();
                                final dt = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                final formattedTime = DateFormat('hh:mm a').format(dt);
                                bookrealEstateController.updateTime(formattedTime);
                              }
                            },
                            child: Container(
                              height: kIsWeb ? 58 : 55,
                              margin: EdgeInsets.all(r.spacing(8)),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: notifire.getblackwhitecolor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: notifire.getborderColor),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: r.spacing(15)),
                                  Expanded(
                                    child: Text(
                                      bookrealEstateController.selectedTime?.isNotEmpty == true
                                          ? bookrealEstateController.selectedTime!
                                          : "Time".tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: r.text(15, desktop: 16),
                                        color: bookrealEstateController.selectedTime?.isNotEmpty == true
                                            ? notifire.getwhiteblackcolor
                                            : notifire.getgreycolor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: r.spacing(10)),
                                  Padding(
                                    padding: EdgeInsets.only(right: r.spacing(10)),
                                    child: Image.asset(
                                      "assets/images/Calendar.png",
                                      height: r.isSmall ? 22 : 25,
                                      width: r.isSmall ? 22 : 25,
                                      color: bookrealEstateController.selectedTime?.isNotEmpty == true
                                          ? notifire.getwhiteblackcolor
                                          : notifire.getgreycolor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Message
                    SizedBox(height: r.spacing(10)),
                    Padding(
                      padding: EdgeInsets.only(left: r.spacing(15), top: r.spacing(10)),
                      child: Text("Message (optional)".tr, style: titleStyle),
                    ),
                    Container(
                      margin: EdgeInsets.all(r.spacing(15)),
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: notifire.getborderColor),
                      ),
                      child: TextFormField(
                        controller: reviewSummaryController.note,
                        minLines: r.isSmall ? 5 : 6,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: notifire.getwhiteblackcolor,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(r.spacing(12)),
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          hintText: "Message".tr,
                          hintStyle: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            color: notifire.getwhiteblackcolor,
                            fontSize: r.text(15, desktop: 16),
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          fontSize: r.text(16, desktop: 17),
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),

                    // Booking for someone
                    SizedBox(height: r.spacing(6)),
                    Row(
                      children: [
                        SizedBox(width: r.spacing(15)),
                        Text(
                          "Booking for someone".tr,
                          style: TextStyle(
                            fontSize: r.text(17, desktop: 18),
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                        Spacer(),
                        Transform.scale(
                          scale: 1,
                          child: Checkbox(
                            value: bookrealEstateController.chack,
                            side: const BorderSide(color: Color(0xffC5CAD4)),
                            activeColor: blueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: (newbool) {
                              bookrealEstateController.bookingForSomeOne(newbool);
                            },
                          ),
                        ),
                        SizedBox(width: r.spacing(10)),
                      ],
                    ),

                    // Continue button
                    SizedBox(height: r.spacing(10)),
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // Make button a comfortable width on desktop
                          minWidth: r.isSmall ? double.infinity : 320,
                          maxWidth: r.isSmall ? double.infinity : 420,
                        ),
                        child: GestButton(
                          Width: r.isSmall ? Get.size.width : 420,
                          height: kIsWeb ? 54 : 50,
                          buttoncolor: blueColor,
                          margin: EdgeInsets.only(
                            top: r.spacing(15),
                            left: r.isSmall ? 30 : 0,
                            right: r.isSmall ? 30 : 0,
                          ),
                          buttontext: "Continue".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            color: WhiteColor,
                            fontSize: r.text(16, desktop: 17),
                            fontWeight: FontWeight.bold,
                          ),
                          onclick: () {
                            bookrealEstateController.message =
                                reviewSummaryController.note.text;

                            if (bookrealEstateController.chack == true) {
                              Get.toNamed(Routes.bookInformetionScreen);
                            } else {
                              Get.toNamed(Routes.reviewSummaryScreen, arguments: {
                                "copAmt": 0,
                                "fname": "",
                                "lname": "",
                                "gender": "",
                                "email": "",
                                "mobile": "",
                                "ccode": "",
                                "country": "",
                                "couponCode": "",
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );

              // Combine layouts
              if (isTwoColumn) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: r.maxContentWidth()),
                    child: Padding(
                      padding: r.edge(
                        EdgeInsets.symmetric(horizontal: 8),
                        desktop: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: r.spacing(24)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 5,
                                child: calendarCard,
                              ),
                              SizedBox(width: r.spacing(8)),
                              Flexible(
                                flex: 6,
                                child: rightCard,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Mobile one-column
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: r.spacing(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        calendarCard,
                        rightCard,
                      ],
                    ),
                  ),
                );
              }
            },
          );

          return content;
        },
      ),
    );
  }
}



// // ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_interpolation_to_compose_strings, avoid_print, unused_field, sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_final_fields, unnecessary_string_interpolations, unnecessary_brace_in_string_interps
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
// import 'package:gotocarefinder/controller/wallet_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:intl/intl.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
//
// class BookRealEstate extends StatefulWidget {
//   const BookRealEstate({super.key});
//
//   @override
//   State<BookRealEstate> createState() => _BookRealEstateState();
// }
//
// class _BookRealEstateState extends State<BookRealEstate> {
//   BookrealEstateController bookrealEstateController = Get.find();
//   HomePageController homePageController = Get.find();
//   ReviewSummaryController reviewSummaryController = Get.find();
//   DateRangePickerController controller = DateRangePickerController();
//
//   WalletController walletController = Get.find();
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
//   List<Duration> list = [];
//
//   int count = 1;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   List<String> dates = [];
//
//   @override
//   void dispose() {
//     super.dispose();
//     bookrealEstateController.cleanDate();
//   }
//
//   List<PickerDateRange> _generatePickerDateRanges(List<String> dates) {
//     return dates.map((date) {
//       DateTime parsedDate = DateTime.parse(date);
//       return PickerDateRange(parsedDate, parsedDate);
//     }).toList();
//   }
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
//           "Schedule Tour: ${homePageController.propetydetailsInfo?.propetydetails!.name}"
//               .tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: GetBuilder<BookrealEstateController>(builder: (context) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, left: 15),
//                 child: Text(
//                   "Select Date".tr,
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontFamily: FontFamily.gilroyBold,
//                     color: notifire.getwhiteblackcolor,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Container(
//                 margin: EdgeInsets.all(10),
//                 child: SfDateRangePicker(
//                   controller: controller,
//                   onSelectionChanged:
//                       bookrealEstateController.onSelectionChanged,
//                   selectionMode: DateRangePickerSelectionMode
//                       .single, // Changed to single selection
//                   enablePastDates: false,
//                   selectionColor: bookrealEstateController.checkDateResult ==
//                           "true"
//                       ? blueColor
//                       : RedColor, // Changed from range colors to single selection color
//                   headerStyle: DateRangePickerHeaderStyle(
//                     textStyle: TextStyle(
//                       fontFamily: FontFamily.gilroyMedium,
//                       color: notifire.getwhiteblackcolor,
//                     ),
//                   ),
//                   selectionTextStyle: TextStyle(
//                     fontFamily: FontFamily.gilroyMedium,
//                   ),
//                   monthCellStyle: DateRangePickerMonthCellStyle(
//                     disabledDatesTextStyle: TextStyle(
//                         color: notifire.getgreycolor,
//                         fontFamily: FontFamily.gilroyMedium),
//                     textStyle: TextStyle(
//                         color: notifire.getwhiteblackcolor,
//                         fontFamily: FontFamily.gilroyMedium),
//                     blackoutDateTextStyle: TextStyle(
//                         color: Colors.red,
//                         decoration: TextDecoration.lineThrough),
//                   ),
//                   monthViewSettings: DateRangePickerMonthViewSettings(
//                     viewHeaderStyle: DateRangePickerViewHeaderStyle(
//                         textStyle: TextStyle(
//                             color: notifire.getwhiteblackcolor,
//                             fontFamily: FontFamily.gilroyMedium)),
//                   ),
//                   backgroundColor: notifire.getblackwhitecolor,
//                   initialSelectedDate:
//                       DateTime.now(), // Changed from range to single date
//                 ),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFeef4ff),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 15),
//                       child: Text(
//                         "Time".tr,
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontFamily: FontFamily.gilroyBold,
//                           color: notifire.getwhiteblackcolor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () async {
//                         final TimeOfDay? selectedTime = await Get.dialog(
//                           Theme(
//                             data: Get.theme.copyWith(
//                               timePickerTheme: TimePickerThemeData(
//                                 backgroundColor: notifire.getblackwhitecolor,
//                                 hourMinuteTextColor:
//                                     notifire.getwhiteblackcolor,
//                                 dialHandColor: blueColor,
//                                 dialBackgroundColor: notifire.getblackwhitecolor
//                                     .withOpacity(0.1),
//                                 entryModeIconColor: notifire.getwhiteblackcolor,
//                               ),
//                               textButtonTheme: TextButtonThemeData(
//                                 style: TextButton.styleFrom(
//                                   foregroundColor: blueColor,
//                                 ),
//                               ),
//                             ),
//                             child: TimePickerDialog(
//                               initialTime: TimeOfDay.now(),
//                             ),
//                           ),
//                         );
//
//                         if (selectedTime != null) {
//                           final now = DateTime.now();
//                           final dt = DateTime(now.year, now.month, now.day,
//                               selectedTime.hour, selectedTime.minute);
//                           final formattedTime =
//                               DateFormat('hh:mm a').format(dt);
//                           bookrealEstateController.updateTime(formattedTime);
//                         }
//                       },
//                       child: Container(
//                         height: 55,
//                         margin: EdgeInsets.all(8),
//                         child: Row(
//                           children: [
//                             SizedBox(width: 15),
//                             Text(
//                               bookrealEstateController
//                                           .selectedTime?.isNotEmpty ==
//                                       true
//                                   ? bookrealEstateController.selectedTime!
//                                   : "Time".tr,
//                               style: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 color: bookrealEstateController
//                                             .selectedTime?.isNotEmpty ==
//                                         true
//                                     ? notifire.getwhiteblackcolor
//                                     : notifire.getgreycolor,
//                               ),
//                             ),
//                             Spacer(),
//                             Image.asset(
//                               "assets/images/Calendar.png",
//                               height: 25,
//                               width: 25,
//                               color: bookrealEstateController
//                                           .selectedTime?.isNotEmpty ==
//                                       true
//                                   ? notifire.getwhiteblackcolor
//                                   : notifire.getgreycolor,
//                             ),
//                             SizedBox(width: 5),
//                           ],
//                         ),
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: notifire.getblackwhitecolor,
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: notifire.getborderColor),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, left: 15),
//                 child: Text(
//                   "Message (optional)".tr,
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
//                   controller: reviewSummaryController.note,
//                   minLines: 5,
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null,
//                   cursorColor: notifire.getwhiteblackcolor,
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.all(10),
//                     focusedBorder: InputBorder.none,
//                     border: InputBorder.none,
//                     hintText: "Message".tr,
//                     hintStyle: TextStyle(
//                       fontFamily: FontFamily.gilroyMedium,
//                       color: notifire.getwhiteblackcolor,
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
//                   border: Border.all(color: notifire.getborderColor),
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     width: 15,
//                   ),
//                   Text(
//                     "Booking for someone".tr,
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontFamily: FontFamily.gilroyBold,
//                       color: notifire.getwhiteblackcolor,
//                     ),
//                   ),
//                   Spacer(),
//                   Transform.scale(
//                     scale: 1,
//                     child: Checkbox(
//                       value: bookrealEstateController.chack,
//                       side: const BorderSide(color: Color(0xffC5CAD4)),
//                       activeColor: blueColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       onChanged: (newbool) {
//                         bookrealEstateController.bookingForSomeOne(newbool);
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                 ],
//               ),
//               GestButton(
//                 Width: Get.size.width,
//                 height: 50,
//                 buttoncolor: blueColor,
//                 margin: EdgeInsets.only(top: 15, left: 30, right: 30),
//                 buttontext: "Continue".tr,
//                 style: TextStyle(
//                   fontFamily: FontFamily.gilroyBold,
//                   color: WhiteColor,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 onclick: () {
//                   /*bookrealEstateController.checkDateApi(
//                     pid: reviewSummaryController.id,
//                   );*/
//
//                   bookrealEstateController.message =
//                       reviewSummaryController.note.text;
//
//                   if (bookrealEstateController.chack == true) {
//                     Get.toNamed(Routes.bookInformetionScreen);
//                   } else {
//                     Get.toNamed(Routes.reviewSummaryScreen, arguments: {
//                       "copAmt": 0,
//                       "fname": "",
//                       "lname": "",
//                       "gender": "",
//                       "email": "",
//                       "mobile": "",
//                       "ccode": "",
//                       "country": "",
//                       "couponCode": "",
//                     });
//                   }
//                 },
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
