// ignore_for_file: prefer_const_constructors, unused_field, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print, unnecessary_brace_in_string_interps, unrelated_type_equality_checks, prefer_typing_uninitialized_variables
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/bookingdetails_controller.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/mybooking_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // for R helpers if you want
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  final MyBookingController myBookingController = Get.find();
  final HomePageController homePageController = Get.find();
  final BookingDetailsController bookingDetailsController = Get.find();

  var selectedRadioTile;
  final note = TextEditingController();
  String? rejectmsg = '';

  late ColorNotifire notifire;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = (prefs.getBool("setIsDark")) ?? false;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging) {
        if (_tabController!.index == 0) {
          myBookingController.statusWiseBook = "active";
        } else {
          myBookingController.statusWiseBook = "completed";
        }
        myBookingController.statusWiseBooking();
      }
    });

    // initial fetch
    myBookingController.statusWiseBook = "active";
    myBookingController.statusWiseBooking();

    _loadTheme();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return WillPopScope(
      onWillPop: () {
        if (getData.read("backHome") == true) {
          Get.toNamed(Routes.bottoBarScreen);
          save("backHome", false);
        } else {
          Get.back();
        }
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: notifire.getbgcolor,
        appBar: AppBar(
          backgroundColor: notifire.getbgcolor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (getData.read("backHome") == true) {
                Get.toNamed(Routes.bottoBarScreen);
                save("backHome", false);
              } else {
                Get.back();
              }
            },
            icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
          ),
          title: Text(
            "My Booking".tr,
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
            constraints: BoxConstraints(
              // nice centered column on wide web screens
              maxWidth: R.maxBodyWidth(context),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: TabBar(
                    controller: _tabController,
                    unselectedLabelColor: notifire.getgreycolor,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 16,
                    ),
                    labelColor: blueColor,
                    tabs: [
                      Tab(text: "Active".tr),
                      Tab(text: "Completed".tr),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _BookingsTab(
                        type: "active",
                        notifire: notifire,
                        myBookingController: myBookingController,
                        homePageController: homePageController,
                        bookingDetailsController: bookingDetailsController,
                        onCancel: ticketCancell,
                      ),
                      _BookingsTab(
                        type: "completed",
                        notifire: notifire,
                        myBookingController: myBookingController,
                        homePageController: homePageController,
                        bookingDetailsController: bookingDetailsController,
                        onCancel: null, // no cancel in completed
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void ticketCancell(String? ticketid) {
    if (ticketid == null || ticketid.isEmpty) {
      Get.snackbar("Error", "Invalid booking id");
      return;
    }
    showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: notifire.getbgcolor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setS) {
          return Scrollbar(
            thumbVisibility: kIsWeb,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Container(height: 6, width: 80, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(25))),
                    SizedBox(height: 16),
                    Text("Select Reason".tr, style: TextStyle(fontSize: 20, fontFamily: 'Gilroy Bold', color: notifire.getwhiteblackcolor)),
                    SizedBox(height: 8),
                    Text("Please select the reason for cancellation:".tr,
                        style: TextStyle(fontSize: 16, fontFamily: 'Gilroy Medium', color: notifire.getwhiteblackcolor)),
                    ListView.builder(
                      itemCount: cancelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return RadioListTile(
                          fillColor: WidgetStateColor.resolveWith((states) => i == selectedRadioTile ? blueColor : notifire.getborderColor),
                          dense: true,
                          value: i,
                          activeColor: blueColor,
                          groupValue: selectedRadioTile,
                          title: Text(cancelList[i]["title"], style: TextStyle(fontSize: 16, fontFamily: 'Gilroy Medium', color: notifire.getwhiteblackcolor)),
                          onChanged: (val) {
                            setS(() {
                              selectedRadioTile = val;
                              rejectmsg = cancelList[i]["title"];
                            });
                          },
                        );
                      },
                    ),
                    if (rejectmsg == "Others".tr)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: note,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Enter reason'.tr,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: blueColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: blueColor, width: 1),
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _pillBtn("Cancel".tr, onTap: () => Get.back()),
                        _pillBtn("Confirm".tr, onTap: () {
                          myBookingController.bookingCancle(
                            bookId: ticketid,
                            reason: rejectmsg == "Others".tr ? note.text : rejectmsg,
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _pillBtn(String title, {required VoidCallback onTap}) {
    return SizedBox(
      width: Get.width * 0.35,
      height: Get.height * 0.05,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: blueColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: blueColor)),
          child: Text(title, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5, fontFamily: 'Gilroy Medium')),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> cancelList = [
    {"id": 1, "title": "Scheduling conflict".tr},
    {"id": 2, "title": "Found another facility".tr},
    {"id": 3, "title": "Change in care requirements".tr},
    {"id": 4, "title": "Transportation issues".tr},
    {"id": 5, "title": "Health-related concerns".tr},
    {"id": 6, "title": "Facility no longer available".tr},
    {"id": 7, "title": "Family decision".tr},
    {"id": 8, "title": "Personal reasons".tr},
    {"id": 9, "title": "Others".tr},
  ];
}

/// One widget reused for both tabs. It handles:
/// - loading state
/// - empty state
/// - responsive grid (1 / 2 / 3 columns)
class _BookingsTab extends StatelessWidget {
  final String type; // "active" | "completed"
  final ColorNotifire notifire;
  final MyBookingController myBookingController;
  final HomePageController homePageController;
  final BookingDetailsController bookingDetailsController;
  final void Function(String? bookId)? onCancel;

  const _BookingsTab({
    required this.type,
    required this.notifire,
    required this.myBookingController,
    required this.homePageController,
    required this.bookingDetailsController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyBookingController>(builder: (_) {
      // Treat isLoading=false as "loading...", true as "loaded".
      if (!myBookingController.isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      final list = myBookingController.statusWiseBookInfo?.statuswise ?? [];
      if (list.isEmpty) {
        return _emptyState(context);
      }

      final width = MediaQuery.of(context).size.width;
      final cross = width >= 1200 ? 3 : (width >= 800 ? 2 : 1);
      final isGrid = cross > 1;

      final scrollChild = isGrid
          ? GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 190,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) => _BookingCard(
          item: list[index],
          notifire: notifire,
          showCancel: type == "active" && (list[index].bookStatus ?? "") == "Booked",
          onTapCard: () async {
            await homePageController.getPropertyDetailsApi(
              id: list[index].propId ?? "",
              ptype: list[index].propType,
            );
            Get.toNamed(Routes.viewDataScreen);
          },
          onTapDetails: () {
            bookingDetailsController.getbookingDetails(bookId: list[index].bookId ?? "");
            Get.toNamed(Routes.eReceiptScreen, arguments: {"Completed": type == "active" ? "Active" : "Completed"});
          },
          onTapCancel: onCancel == null ? null : () => onCancel!(list[index].bookId),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: _BookingCard(
            item: list[index],
            notifire: notifire,
            showCancel: type == "active" && (list[index].bookStatus ?? "") == "Booked",
            onTapCard: () async {
              await homePageController.getPropertyDetailsApi(
                id: list[index].propId ?? "",
                ptype: list[index].propType,
              );
              Get.toNamed(Routes.viewDataScreen);
            },
            onTapDetails: () {
              bookingDetailsController.getbookingDetails(bookId: list[index].bookId ?? "");
              Get.toNamed(Routes.eReceiptScreen, arguments: {"Completed": type == "active" ? "Active" : "Completed"});
            },
            onTapCancel: onCancel == null ? null : () => onCancel!(list[index].bookId),
          ),
        ),
      );

      return Scrollbar(thumbVisibility: kIsWeb, child: scrollChild);
    });
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Image.asset("assets/images/bookingEmpty.png", height: 110, width: 100),
          ),
          SizedBox(height: 20),
          Text("Go & Book your favorite service".tr, style: TextStyle(color: notifire.getgreycolor, fontFamily: FontFamily.gilroyBold)),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic item;
  final ColorNotifire notifire;
  final bool showCancel;
  final VoidCallback onTapCard;
  final VoidCallback onTapDetails;
  final VoidCallback? onTapCancel;

  const _BookingCard({
    required this.item,
    required this.notifire,
    required this.showCancel,
    required this.onTapCard,
    required this.onTapDetails,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    final title = item?.propTitle ?? "";
    final addr = item?.address ?? "";
    final rate = item?.totalRate?.toString() ?? "";
    final type = item?.propType ?? "";
    final img = "${Config.imageUrl}${item?.propImg ?? ""}";

    return InkWell(
      onTap: onTapCard,
      child: Container(
        decoration: BoxDecoration(color: notifire.getblackwhitecolor, borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          children: [
            // image + rating
            Stack(
              children: [
                Container(
                  height: 140,
                  width: 130,
                  margin: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeInCirc,
                      placeholder: "assets/images/ezgif.com-crop.gif",
                      height: 140,
                      imageErrorBuilder: (c, e, s) => Image.asset("assets/images/emty.gif", fit: BoxFit.cover),
                      image: img,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 20,
                  child: Container(
                    height: 30,
                    width: 45,
                    decoration: BoxDecoration(color: Color(0xFFedeeef), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/Rating.png", height: 12, width: 12),
                        SizedBox(width: 3),
                        Text(rate, style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: blueColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 17, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor)),
                    SizedBox(height: 5),
                    Text(addr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: notifire.getgreycolor, fontFamily: FontFamily.gilroyMedium)),
                    SizedBox(height: 5),
                    Text(type, style: TextStyle(fontSize: 15, fontFamily: FontFamily.gilroyBold, color: blueColor)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        if (showCancel && onTapCancel != null)
                          Expanded(
                            child: InkWell(
                              onTap: onTapCancel,
                              child: Container(
                                height: 40,
                                margin: EdgeInsets.only(right: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: blueColor, borderRadius: BorderRadius.circular(20)),
                                child: Text("Cancel".tr,
                                    style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: WhiteColor, fontSize: 15)),
                              ),
                            ),
                          ),
                        Expanded(
                          child: InkWell(
                            onTap: onTapDetails,
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: blueColor)),
                              child: Text("Details".tr,
                                  style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: blueColor, fontSize: 15)),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// // ignore_for_file: prefer_const_constructors, unused_field, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print, unnecessary_brace_in_string_interps, unrelated_type_equality_checks, prefer_typing_uninitialized_variables
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/bookingdetails_controller.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/mybooking_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyBookingScreen extends StatefulWidget {
//   const MyBookingScreen({super.key});
//
//   @override
//   State<MyBookingScreen> createState() => _MyBookingScreenState();
// }
//
// class _MyBookingScreenState extends State<MyBookingScreen>
//     with TickerProviderStateMixin {
//   TabController? _tabController;
//
//   MyBookingController myBookingController = Get.find();
//   HomePageController homePageController = Get.find();
//   BookingDetailsController bookingDetailsController = Get.find();
//
//   var selectedRadioTile;
//   final note = TextEditingController();
//   String? rejectmsg = '';
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
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController?.index == 0;
//     if (_tabController?.index == 0) {
//       myBookingController.statusWiseBook = "active";
//       myBookingController.statusWiseBooking();
//     }
//     getdarkmodepreviousstate();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _tabController?.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return WillPopScope(
//       onWillPop: () {
//         if (getData.read("backHome") == true) {
//           Get.toNamed(Routes.bottoBarScreen);
//           save("backHome", false);
//         } else {
//           Get.back();
//         }
//         return Future.value(false);
//       },
//       child: Scaffold(
//         backgroundColor: notifire.getbgcolor,
//         appBar: AppBar(
//           backgroundColor: notifire.getbgcolor,
//           elevation: 0,
//           leading: IconButton(
//             onPressed: () {
//               if (getData.read("backHome") == true) {
//                 Get.toNamed(Routes.bottoBarScreen);
//                 save("backHome", false);
//               } else {
//                 Get.back();
//               }
//             },
//             icon: Icon(
//               Icons.arrow_back,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//           title: Text(
//             "My Booking".tr,
//             style: TextStyle(
//               fontSize: 17,
//               fontFamily: FontFamily.gilroyBold,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         body: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 50,
//                 child: TabBar(
//                   controller: _tabController,
//                   unselectedLabelColor: notifire.getgreycolor,
//                   labelStyle: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontFamily: FontFamily.gilroyBold,
//                     fontSize: 16,
//                   ),
//                   labelColor: blueColor,
//                   onTap: (value) {
//                     if (value == 0) {
//                       myBookingController.statusWiseBook = "active";
//                       myBookingController.statusWiseBooking();
//                     } else {
//                       myBookingController.statusWiseBook = "completed";
//                       myBookingController.statusWiseBooking();
//                     }
//                   },
//                   tabs: [
//                     Tab(
//                       text: "Active".tr,
//                     ),
//                     Tab(
//                       text: "Completed".tr,
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 flex: 1,
//                 child: TabBarView(
//                   controller: _tabController,
//                   physics: NeverScrollableScrollPhysics(),
//                   children: [
//                     activeWidget(),
//                     completedWidget(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget activeWidget() {
//     return GetBuilder<MyBookingController>(builder: (context) {
//       return RefreshIndicator(
//         onRefresh: () {
//           return Future.delayed(
//             Duration(seconds: 2),
//             () {
//               myBookingController.statusWiseBooking();
//             },
//           );
//         },
//         child: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: myBookingController.isLoading
//               ? myBookingController.statusWiseBookInfo!.statuswise!.isNotEmpty
//                   ? ListView.builder(
//                       itemCount: myBookingController
//                           .statusWiseBookInfo?.statuswise!.length,
//                       itemBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             InkWell(
//                               onTap: () async {
//                                 await homePageController.getPropertyDetailsApi(
//                                     id: myBookingController.statusWiseBookInfo
//                                             ?.statuswise![index].propId ??
//                                         "",
//                                     ptype: myBookingController
//                                         .statusWiseBookInfo
//                                         ?.statuswise![index]
//                                         .propType);
//                                 Get.toNamed(Routes.viewDataScreen);
//                               },
//                               child: Container(
//                                 margin: EdgeInsets.all(10),
//                                 child: Column(
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Stack(
//                                           children: [
//                                             Container(
//                                               height: 140,
//                                               width: 130,
//                                               margin: EdgeInsets.all(10),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                                 child: FadeInImage.assetNetwork(
//                                                   fadeInCurve:
//                                                       Curves.easeInCirc,
//                                                   placeholder:
//                                                       "assets/images/ezgif.com-crop.gif",
//                                                   height: 140,
//                                                   imageErrorBuilder: (context,
//                                                       error, stackTrace) {
//                                                     return Center(
//                                                       child: Image.asset(
//                                                         "assets/images/emty.gif",
//                                                         fit: BoxFit.cover,
//                                                         height: Get.height,
//                                                       ),
//                                                     );
//                                                   },
//                                                   image:
//                                                       "${Config.imageUrl}${myBookingController.statusWiseBookInfo?.statuswise![index].propImg ?? ""}",
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                               ),
//                                             ),
//                                             Positioned(
//                                               top: 15,
//                                               right: 20,
//                                               child: Container(
//                                                 height: 30,
//                                                 width: 45,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Container(
//                                                       margin: const EdgeInsets
//                                                           .fromLTRB(0, 0, 3, 0),
//                                                       child: Image.asset(
//                                                         "assets/images/Rating.png",
//                                                         height: 12,
//                                                         width: 12,
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       myBookingController
//                                                               .statusWiseBookInfo
//                                                               ?.statuswise![
//                                                                   index]
//                                                               .totalRate ??
//                                                           "",
//                                                       style: TextStyle(
//                                                         fontFamily: FontFamily
//                                                             .gilroyMedium,
//                                                         color: blueColor,
//                                                       ),
//                                                     )
//                                                   ],
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   color: Color(0xFFedeeef),
//                                                   borderRadius:
//                                                       BorderRadius.circular(15),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           width: 8,
//                                         ),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Text(
//                                                 myBookingController
//                                                         .statusWiseBookInfo
//                                                         ?.statuswise![index]
//                                                         .propTitle ??
//                                                     "",
//                                                 maxLines: 2,
//                                                 style: TextStyle(
//                                                   fontSize: 17,
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   color: notifire
//                                                       .getwhiteblackcolor,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 5),
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: Text(
//                                                       myBookingController
//                                                               .statusWiseBookInfo
//                                                               ?.statuswise![
//                                                                   index]
//                                                               .address ??
//                                                           "",
//                                                       maxLines: 1,
//                                                       style: TextStyle(
//                                                         color: notifire
//                                                             .getgreycolor,
//                                                         fontFamily: FontFamily
//                                                             .gilroyMedium,
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     width: 10,
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(height: 5),
//                                               Row(
//                                                 children: [
//                                                   Text(
//                                                     "${myBookingController.statusWiseBookInfo?.statuswise![index].propType ?? ""}",
//                                                     style: TextStyle(
//                                                       fontSize: 15,
//                                                       fontFamily:
//                                                           FontFamily.gilroyBold,
//                                                       color: blueColor,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               SizedBox(
//                                                 height: 15,
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 children: [
//                                                   SizedBox(
//                                                     height: 10,
//                                                   ),
//                                                   Container(
//                                                     height: 30,
//                                                     width: 80,
//                                                     alignment: Alignment.center,
//                                                     child: Text(
//                                                       "Confirmed".tr,
//                                                       style: TextStyle(
//                                                         color: blueColor,
//                                                         fontFamily: FontFamily
//                                                             .gilroyMedium,
//                                                       ),
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       border: Border.all(
//                                                           color: blueColor),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               5),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     width: 15,
//                                                   ),
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       children: [
//                                         myBookingController
//                                                     .statusWiseBookInfo
//                                                     ?.statuswise![index]
//                                                     .bookStatus ==
//                                                 "Booked"
//                                             ? Expanded(
//                                                 child: InkWell(
//                                                   onTap: () {
//                                                     ticketCancell(
//                                                       myBookingController
//                                                           .statusWiseBookInfo
//                                                           ?.statuswise![index]
//                                                           .bookId,
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     height: 40,
//                                                     alignment: Alignment.center,
//                                                     margin: EdgeInsets.all(10),
//                                                     child: Text(
//                                                       "Cancel".tr,
//                                                       style: TextStyle(
//                                                         fontFamily: FontFamily
//                                                             .gilroyMedium,
//                                                         color: WhiteColor,
//                                                         fontSize: 15,
//                                                       ),
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               20),
//                                                       color: blueColor,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               )
//                                             : Container(),
//                                         Expanded(
//                                           child: InkWell(
//                                             onTap: () {
//                                               bookingDetailsController
//                                                   .getbookingDetails(
//                                                 bookId: myBookingController
//                                                         .statusWiseBookInfo
//                                                         ?.statuswise![index]
//                                                         .bookId ??
//                                                     "",
//                                               );
//                                               Get.toNamed(
//                                                 Routes.eReceiptScreen,
//                                                 arguments: {
//                                                   "Completed": "Active",
//                                                 },
//                                               );
//                                             },
//                                             child: Container(
//                                               height: 40,
//                                               alignment: Alignment.center,
//                                               margin: EdgeInsets.all(10),
//                                               child: Text(
//                                                 "Details".tr,
//                                                 style: TextStyle(
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                   color: blueColor,
//                                                   fontSize: 15,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(20),
//                                                 border: Border.all(
//                                                     color: blueColor),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: notifire.getblackwhitecolor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 30),
//                             child: Image.asset(
//                               "assets/images/bookingEmpty.png",
//                               height: 110,
//                               width: 100,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           Text(
//                             "Go & Book your favorite service".tr,
//                             style: TextStyle(
//                               color: notifire.getgreycolor,
//                               fontFamily: FontFamily.gilroyBold,
//                             ),
//                           )
//                         ],
//                       ),
//                     )
//               : Center(
//                   child: CircularProgressIndicator(),
//                 ),
//         ),
//       );
//     });
//   }
//
//   Widget completedWidget() {
//     return GetBuilder<MyBookingController>(builder: (context) {
//       return RefreshIndicator(
//         onRefresh: () {
//           return Future.delayed(
//             Duration(seconds: 2),
//             () {
//               myBookingController.statusWiseBooking();
//             },
//           );
//         },
//         child: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: myBookingController.isLoading
//               ? myBookingController.statusWiseBookInfo!.statuswise!.isNotEmpty
//                   ? ListView.builder(
//                       itemCount: myBookingController
//                           .statusWiseBookInfo?.statuswise!.length,
//                       itemBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             InkWell(
//                               onTap: () async {
//                                 await homePageController.getPropertyDetailsApi(
//                                     id: myBookingController.statusWiseBookInfo
//                                             ?.statuswise![index].propId ??
//                                         "",
//                                     ptype: myBookingController
//                                         .statusWiseBookInfo
//                                         ?.statuswise![index]
//                                         .propType);
//                                 Get.toNamed(Routes.viewDataScreen);
//                               },
//                               child: Container(
//                                 height: 155,
//                                 margin: EdgeInsets.all(10),
//                                 child: Row(
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         Container(
//                                           height: 140,
//                                           width: 130,
//                                           margin: EdgeInsets.all(10),
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                             child: FadeInImage.assetNetwork(
//                                               fadeInCurve: Curves.easeInCirc,
//                                               placeholder:
//                                                   "assets/images/ezgif.com-crop.gif",
//                                               height: 140,
//                                               imageErrorBuilder:
//                                                   (context, error, stackTrace) {
//                                                 return Center(
//                                                   child: Image.asset(
//                                                     "assets/images/emty.gif",
//                                                     fit: BoxFit.cover,
//                                                     height: Get.height,
//                                                   ),
//                                                 );
//                                               },
//                                               image:
//                                                   "${Config.imageUrl}${myBookingController.statusWiseBookInfo?.statuswise![index].propImg ?? ""}",
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                           ),
//                                         ),
//                                         Positioned(
//                                           top: 15,
//                                           right: 20,
//                                           child: Container(
//                                             height: 30,
//                                             width: 45,
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                   margin:
//                                                       const EdgeInsets.fromLTRB(
//                                                           0, 0, 3, 0),
//                                                   child: Image.asset(
//                                                     "assets/images/Rating.png",
//                                                     height: 12,
//                                                     width: 12,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   myBookingController
//                                                           .statusWiseBookInfo
//                                                           ?.statuswise![index]
//                                                           .totalRate ??
//                                                       "",
//                                                   style: TextStyle(
//                                                     fontFamily:
//                                                         FontFamily.gilroyMedium,
//                                                     color: blueColor,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: Color(0xFFedeeef),
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       width: 8,
//                                     ),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             myBookingController
//                                                     .statusWiseBookInfo
//                                                     ?.statuswise![index]
//                                                     .propTitle ??
//                                                 "",
//                                             maxLines: 2,
//                                             style: TextStyle(
//                                               fontSize: 17,
//                                               fontFamily: FontFamily.gilroyBold,
//                                               color:
//                                                   notifire.getwhiteblackcolor,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           SizedBox(height: 5),
//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: Text(
//                                                   myBookingController
//                                                           .statusWiseBookInfo
//                                                           ?.statuswise![index]
//                                                           .address ??
//                                                       "",
//                                                   maxLines: 1,
//                                                   style: TextStyle(
//                                                     color:
//                                                         notifire.getgreycolor,
//                                                     fontFamily:
//                                                         FontFamily.gilroyMedium,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 10,
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: 5),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 "${myBookingController.statusWiseBookInfo?.statuswise![index].propType ?? ""}",
//                                                 style: TextStyle(
//                                                   fontSize: 15,
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   color: blueColor,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: 15),
//                                           InkWell(
//                                             onTap: () {
//                                               bookingDetailsController
//                                                   .getbookingDetails(
//                                                 bookId: myBookingController
//                                                         .statusWiseBookInfo
//                                                         ?.statuswise![index]
//                                                         .bookId ??
//                                                     "",
//                                               );
//                                               Get.toNamed(
//                                                 Routes.eReceiptScreen,
//                                                 arguments: {
//                                                   "Completed": "Completed"
//                                                 },
//                                               );
//                                             },
//                                             child: Container(
//                                               height: 35,
//                                               width: 120,
//                                               alignment: Alignment.center,
//                                               padding: EdgeInsets.all(8),
//                                               child: Text(
//                                                 "Details".tr,
//                                                 style: TextStyle(
//                                                   color: blueColor,
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color: blueColor),
//                                                 borderRadius:
//                                                     BorderRadius.circular(5),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: notifire.getblackwhitecolor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 30),
//                             child: Image.asset(
//                               "assets/images/bookingEmpty.png",
//                               height: 110,
//                               width: 100,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           Text(
//                             "Go & Book your favorite service".tr,
//                             style: TextStyle(
//                               color: notifire.getgreycolor,
//                               fontFamily: FontFamily.gilroyBold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//               : Center(
//                   child: CircularProgressIndicator(),
//                 ),
//         ),
//       );
//     });
//   }
//
//   ticketCancell(ticketid) {
//     showModalBottomSheet(
//         isDismissible: false,
//         isScrollControlled: true,
//         backgroundColor: notifire.getbgcolor,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(height: Get.height * 0.02),
//                     Container(
//                         height: 6,
//                         width: 80,
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(25))),
//                     SizedBox(height: Get.height * 0.02),
//                     Text(
//                       "Select Reason".tr,
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontFamily: 'Gilroy Bold',
//                           color: notifire.getwhiteblackcolor),
//                     ),
//                     SizedBox(height: Get.height * 0.02),
//                     Text(
//                       "Please select the reason for cancellation:".tr,
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontFamily: 'Gilroy Medium',
//                           color: notifire.getwhiteblackcolor),
//                     ),
//                     SizedBox(height: Get.height * 0.02),
//                     ListView.builder(
//                       itemCount: cancelList.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (ctx, i) {
//                         return RadioListTile(
//                           fillColor: WidgetStateColor.resolveWith((states) =>
//                               i == selectedRadioTile
//                                   ? blueColor
//                                   : notifire.getborderColor),
//                           dense: true,
//                           value: i,
//                           activeColor: Color(0xFF246BFD),
//                           tileColor: notifire.getdarkscolor,
//                           selected: true,
//                           groupValue: selectedRadioTile,
//                           title: Text(
//                             cancelList[i]["title"],
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontFamily: 'Gilroy Medium',
//                                 color: notifire.getwhiteblackcolor),
//                           ),
//                           onChanged: (val) {
//                             setState(() {});
//                             selectedRadioTile = val;
//                             rejectmsg = cancelList[i]["title"];
//                           },
//                         );
//                       },
//                     ),
//                     rejectmsg == "Others".tr
//                         ? SizedBox(
//                             height: 50,
//                             width: Get.width * 0.85,
//                             child: TextField(
//                               controller: note,
//                               decoration: InputDecoration(
//                                   isDense: true,
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(10)),
//                                     borderSide:
//                                         BorderSide(color: blueColor, width: 1),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(10)),
//                                     borderSide:
//                                         BorderSide(color: blueColor, width: 1),
//                                   ),
//                                   hintText: 'Enter reason'.tr,
//                                   hintStyle: TextStyle(
//                                       fontFamily: 'Gilroy Medium',
//                                       fontSize: Get.size.height / 55,
//                                       color: Colors.grey)),
//                             ),
//                           )
//                         : const SizedBox(),
//                     SizedBox(height: Get.height * 0.02),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         SizedBox(
//                           width: Get.width * 0.35,
//                           height: Get.height * 0.05,
//                           child: ticketbutton(
//                             title: "Cancel".tr,
//                             bgColor: blueColor,
//                             titleColor: Colors.white,
//                             ontap: () {
//                               Get.back();
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           width: Get.width * 0.35,
//                           height: Get.height * 0.05,
//                           child: ticketbutton(
//                             title: "Confirm".tr,
//                             bgColor: blueColor,
//                             titleColor: Colors.white,
//                             ontap: () {
//                               myBookingController.bookingCancle(
//                                 bookId: ticketid,
//                                 reason: rejectmsg == "Others".tr
//                                     ? note.text
//                                     : rejectmsg,
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: Get.height * 0.04),
//                   ],
//                 ),
//               ),
//             );
//           });
//         });
//   }
//
//   List cancelList = [
//     {"id": 1, "title": "Scheduling conflict".tr},
//     {"id": 2, "title": "Found another facility".tr},
//     {"id": 3, "title": "Change in care requirements".tr},
//     {"id": 4, "title": "Transportation issues".tr},
//     {"id": 5, "title": "Health-related concerns".tr},
//     {"id": 6, "title": "Facility no longer available".tr},
//     {"id": 7, "title": "Family decision".tr},
//     {"id": 8, "title": "Personal reasons".tr},
//     {"id": 9, "title": "Others".tr},
//   ];
//
//   ticketbutton({Function()? ontap, String? title, Color? bgColor, titleColor}) {
//     return InkWell(
//       onTap: ontap,
//       child: Container(
//         height: Get.height * 0.04,
//         width: Get.width * 0.40,
//         decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: (BorderRadius.circular(18)),
//             border: Border.all(color: bgColor!, width: 1)),
//         child: Center(
//           child: Text(title!,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                   color: titleColor,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.5,
//                   fontFamily: 'Gilroy Medium')),
//         ),
//       ),
//     );
//   }
// }
