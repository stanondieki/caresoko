// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/notification_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController notificationController = Get.find();

  late ColorNotifire notifire;

  Future<void> _restoreTheme() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = (prefs.getBool("setIsDark")) ?? false;
  }

  // --------- Simple responsive helpers (no external deps) ---------
  bool _isDesktop(double w) => w >= 1200;
  bool _isTablet(double w) => w >= 900 && w < 1200;
  EdgeInsets _screenPadding(double w) {
    if (_isDesktop(w)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    if (_isTablet(w)) return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  double _maxBodyWidth(double w) {
    if (_isDesktop(w)) return 980;
    if (_isTablet(w)) return 820;
    return double.infinity;
  }

  @override
  void initState() {
    super.initState();
    _restoreTheme();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final w = MediaQuery.of(context).size.width;
    final isWide = _isTablet(w) || _isDesktop(w);

    final leadingRadius = isWide ? 28.0 : 24.0;
    final iconSize = isWide ? 26.0 : 22.0;
    final titleSize = isWide ? 18.0 : 16.0;
    final tileVPad = isWide ? 14.0 : 8.0;

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: !isWide,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Notification".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxBodyWidth(w)),
          child: Padding(
            padding: _screenPadding(w),
            child: GetBuilder<NotificationController>(builder: (_) {
              if (!notificationController.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              final items =
                  notificationController.notificationInfo?.notificationData ?? [];

              if (items.isEmpty) {
                return _emptyState(isWide);
              }

              return Scrollbar(
                thumbVisibility: kIsWeb,
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final n = items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: notifire.getborderColor),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: tileVPad,
                        ),
                        leading: CircleAvatar(
                          radius: leadingRadius,
                          backgroundColor: const Color(0xFFeef4ff),
                          child: Image.asset(
                            "assets/images/Notification1.png",
                            color: blueColor,
                            height: iconSize,
                            width: iconSize,
                          ),
                        ),
                        title: Text(
                          n.title ?? "",
                          style: TextStyle(
                            fontSize: titleSize,
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                        subtitle: Text(
                          "${n.datetime ?? ""}",
                          style: TextStyle(
                            color: notifire.getgreycolor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(bool isWide) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(left: isWide ? 0 : 30),
              child: Image.asset(
                "assets/images/bookingEmpty.png",
                height: isWide ? 140 : 120,
                width: isWide ? 140 : 120,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "We'll let you know when we\nget news for you".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notifire.getgreycolor,
                fontFamily: FontFamily.gilroyBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/controller/notification_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   NotificationController notificationController = Get.find();
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
//           "Notification".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: GetBuilder<NotificationController>(builder: (context) {
//         return Column(
//           children: [
//             Expanded(
//               child: notificationController.isLoading
//                   ? notificationController
//                           .notificationInfo!.notificationData!.isNotEmpty
//                       ? ListView.builder(
//                           itemCount: notificationController
//                               .notificationInfo?.notificationData!.length,
//                           itemBuilder: (context, index) {
//                             return Container(
//                               margin: EdgeInsets.all(10),
//                               child: ListTile(
//                                 leading: Container(
//                                   height: 60,
//                                   width: 60,
//                                   padding: EdgeInsets.all(15),
//                                   child: Image.asset(
//                                     "assets/images/Notification1.png",
//                                     color: blueColor,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Color(0xFFeef4ff),
//                                   ),
//                                 ),
//                                 title: Text(
//                                   notificationController.notificationInfo
//                                           ?.notificationData![index].title ??
//                                       "",
//                                   style: TextStyle(
//                                     fontSize: 17,
//                                     fontFamily: FontFamily.gilroyBold,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                                 subtitle: Text(
//                                   "${notificationController.notificationInfo?.notificationData![index].datetime ?? ""}",
//                                   style: TextStyle(
//                                     color: notifire.getgreycolor,
//                                     fontFamily: FontFamily.gilroyMedium,
//                                   ),
//                                 ),
//                               ),
//                               decoration: BoxDecoration(
//                                 color: notifire.getblackwhitecolor,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                             );
//                           },
//                         )
//                       : Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 30),
//                                 child: Image.asset(
//                                   "assets/images/bookingEmpty.png",
//                                   height: 120,
//                                   width: 120,
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               Text(
//                                 "We'll let you know when we\nget news for you"
//                                     .tr,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: notifire.getgreycolor,
//                                   fontFamily: FontFamily.gilroyBold,
//                                 ),
//                               )
//                             ],
//                           ),
//                         )
//                   : Center(
//                       child: CircularProgressIndicator(),
//                     ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
