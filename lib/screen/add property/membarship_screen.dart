// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unnecessary_brace_in_string_interps, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/extraimage_controller.dart';
import 'package:gotocarefinder/controller/listofagencies_controller.dart';
import 'package:gotocarefinder/controller/reviewlist_controller.dart';
import 'package:gotocarefinder/firebase/chats_list.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/routes_helper.dart';
import '../../controller/booking_controller.dart';
import '../../controller/enquiry_controller.dart';
import '../../controller/gallerycategory_controller.dart';
import '../../controller/galleryimage_controller.dart';
import '../../controller/listofproperti_controller.dart';
import '../../controller/myearning_controller.dart';
import '../home_screen.dart';
import '../login_screen.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  // Controllers
  final DashBoardController dashBoardController = Get.find();
  final ReviewlistController reviewlistController =
      Get.put(ReviewlistController());
  final MyEarningController myEarningController = Get.find();
  final ListOfPropertiController listOfPropertiController = Get.find();
  final ListOfPropertyController listOfPropertyController =
      Get.put(ListOfPropertyController());
  final ListOfAgenciesController listOfAgenciesController =
      Get.put(ListOfAgenciesController());
  final ExtraImageController extraImageController = Get.find();
  final GalleryCategoryController galleryCategoryController = Get.find();
  final GalleryImageController galleryImageController = Get.find();
  final BookingController bookingController = Get.find();
  final EnquiryController enquiryController = Get.find();

  final List<String> routesList = [
    Routes.listOfPropertyScreen,
    Routes.listOfAgenciesScreen,
    Routes.listOfPropartyScreen,
    Routes.extraImageScreen,
    Routes.galleryCategoryScreen,
    Routes.galleryImageScreen,
    Routes.bookingScreen,
    Routes.myEarningsScreen,
    Routes.enquiryScreen,
    Routes.reviewlistScreen,
    Routes.myPayoutScreen,
  ];

  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    _getDarkModePreviousState();
  }

  Future<void> _getDarkModePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () => Get.to(ChatList()),
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Center(
                child: Image.asset(
                  "assets/images/Chat.png",
                  width: 28,
                  fit: BoxFit.cover,
                  color: blueColor,
                ),
              ),
              decoration: BoxDecoration(
                border: Border.all(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
        leading: getData.read("userType") == "admin"
            ? GestureDetector(
                onTap: () => logoutSheet(),
                child: Image.asset(
                  "assets/images/Logout.png",
                  height: 20,
                  width: 30,
                  scale: 3,
                  color: notifire.getredcolor,
                ),
              )
            : BackButton(
                color: notifire.getwhiteblackcolor,
                onPressed: () => Get.back(),
              ),
        title: Image.asset("assets/images/applogo.png", height: 30, width: 30),
      ),

      // -------------------- BODY (responsive, overflow-safe) --------------------
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
          dashBoardController.getDashBoardData();
        },
        child: GetBuilder<DashBoardController>(builder: (context) {
          if (!dashBoardController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final maxW = w >= 1100 ? 1100.0 : double.infinity;
              final mq = MediaQuery.of(context);

              // Clamp textScaleFactor to avoid layout blow-ups on very large fonts
              final clampedMQ = mq.copyWith(
                textScaler: TextScaler.linear(mq.textScaleFactor.clamp(1.0, 1.2)),
              );

              return MediaQuery(
                data: clampedMQ,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: w < 768 ? 12 : (w < 1024 ? 16 : 20),
                              vertical: 12,
                            ),
                            child: _ResponsiveDashboardGrid(
                              data:
                                  dashBoardController.dashBoardInfo!.reportData,
                              isAdmin: getData.read("userType") == "admin",
                              currency: currency,
                              lCode: getData.read("lCode"),
                              onTap: (index) async {
                                // Original navigation logic
                                if (index == 9) {
                                  final value =
                                      await reviewlistController.reviewlist();
                                  if (value["Result"] == "true") {
                                    Get.toNamed(routesList[index]);
                                  } else {
                                    showToastMessage("No Review");
                                  }
                                } else if (index == 7) {
                                  await myEarningController.getEarningsData();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 0) {
                                  listOfPropertiController.getPropertiList();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 1) {
                                  listOfAgenciesController.getAgencyList();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 2) {
                                  listOfPropertyController.getPropertiList();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 3) {
                                  extraImageController.getExtraImageList();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 4) {
                                  galleryCategoryController
                                      .getGalleryCategoryList();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 5) {
                                  await galleryImageController
                                      .getGalleryImageList();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 6) {
                                  bookingController.getBookingStatusWise();
                                  Get.toNamed(routesList[index]);
                                } else if (index == 8) {
                                  enquiryController.enquiryListApi();
                                  Get.toNamed(routesList[index]);
                                } else {
                                  Get.toNamed(routesList[index]);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Banner
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxW),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: w < 768 ? 12 : (w < 1024 ? 16 : 20),
                              vertical: 12,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio: 16 / 6,
                                child: Image.asset(
                                  "assets/images/addpropartyimg.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  // -------------------- Logout Sheet (responsive) --------------------
  Future logoutSheet() {
    return Get.bottomSheet(
      LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final bool isPhone = w < 768;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: isPhone ? 14 : 24),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: isPhone ? 12 : 16),
                  Text(
                    "Logout".tr,
                    style: TextStyle(
                      fontSize: isPhone ? 18 : 20,
                      fontFamily: FontFamily.gilroyBold,
                      color: RedColor,
                    ),
                  ),
                  SizedBox(height: isPhone ? 12 : 16),
                  Divider(color: notifire.getborderColor),
                  SizedBox(height: isPhone ? 8 : 10),
                  Text(
                    "Are you sure you want to log out?".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: isPhone ? 15 : 16,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                  SizedBox(height: isPhone ? 10 : 12),
                  if (isPhone) ...[
                    _SecondaryActionButton(
                      text: "Cancle".tr,
                      onTap: () => Get.back(),
                      notifire: notifire,
                    ),
                    _PrimaryActionButton(
                      text: "Yes, Logout".tr,
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        save('isLoginBack', true);
                        await prefs.remove('Firstuser');
                        getData.remove("UserLogin");
                        getData.remove("countryId");
                        getData.remove("countryName");
                        getData.remove("currentIndex");
                        tokenemty();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryActionButton(
                            text: "Cancle".tr,
                            onTap: () => Get.back(),
                            notifire: notifire,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _PrimaryActionButton(
                            text: "Yes, Logout".tr,
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              save('isLoginBack', true);
                              await prefs.remove('Firstuser');
                              getData.remove("UserLogin");
                              getData.remove("countryId");
                              getData.remove("countryName");
                              getData.remove("currentIndex");
                              tokenemty();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: isPhone ? 10 : 14),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: notifire.getbgcolor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> tokenemty() async {
    // CollectionReference collectionReference =
    // FirebaseFirestore.instance.collection('users');
    // collectionReference.doc(getData.read("UserLogin")["id"]).update({"token": ""});
  }
}

// ========================= SUPPORTING WIDGETS =========================

class _ResponsiveDashboardGrid extends StatelessWidget {
  final List<dynamic> data;
  final bool isAdmin;
  final String currency;
  final String? lCode;
  final ValueChanged<int> onTap;

  const _ResponsiveDashboardGrid({
    required this.data,
    required this.isAdmin,
    required this.currency,
    required this.lCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorNotifire notifire =
        Provider.of<ColorNotifire>(context, listen: true);

    // Indices to hide from the management page
    // 2  -> My Adverts (Disabled by user request)
    // 7  -> My Earnings
    // 8  -> My Enquiries
    // 10 -> My Payout
    const hiddenIndices = <int>{2, 7, 8, 10};

    // Respect original logic: admin already hides last item (data.length - 1)
    final int baseLength = isAdmin ? data.length - 1 : data.length;

    // Map from grid index -> original index in data/routesList
    final List<int> visibleIndices = [];
    for (int i = 0; i < baseLength; i++) {
      if (!hiddenIndices.contains(i)) {
        visibleIndices.add(i);
      }
    }

    return LayoutBuilder(
      builder: (context, c) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleIndices.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: _maxExtentFor(c.maxWidth),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: _aspectFor(c.maxWidth),
          ),
          itemBuilder: (context, index) {
            // Use the ORIGINAL index for data + navigation
            final int originalIndex = visibleIndices[index];
            final item = data[originalIndex];
            final title = item.title ?? "";
            final url = "${Config.imageUrl}${item.url ?? ""}";

            final bool showCurrency =
                (originalIndex / 5 == 1) || (originalIndex / 8 == 1);
            final displayValue = showCurrency
                ? "$currency${item.reportData ?? ""}"
                : "${item.reportData ?? ""}";

            return _StatCard(
              title: title,
              value: displayValue,
              imageUrl: url,
              rtl: lCode == "ar_IN",
              onTap: () => onTap(originalIndex), // <– still uses original index
              notifire: notifire,
            );
          },
        );
      },
    );
  }

  double _maxExtentFor(double w) {
    if (w >= 1200) return 320;
    if (w >= 1024) return 300;
    if (w >= 768) return 260;
    return 220;
  }

  double _aspectFor(double w) {
    if (w < 360) return 1.05;
    if (w < 420) return 1.15;
    if (w < 768) return 1.25;
    if (w < 1024) return 1.35;
    return 1.45;
  }
}

// class _ResponsiveDashboardGrid extends StatelessWidget {
//   final List<dynamic> data;
//   final bool isAdmin;
//   final String currency;
//   final String? lCode;
//   final ValueChanged<int> onTap;
//
//   const _ResponsiveDashboardGrid({
//     required this.data,
//     required this.isAdmin,
//     required this.currency,
//     required this.lCode,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final ColorNotifire notifire = Provider.of<ColorNotifire>(context, listen: true);
//     final itemCount = isAdmin ? data.length - 1 : data.length;
//
//     return LayoutBuilder(
//       builder: (context, c) {
//         return GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: itemCount,
//           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//             maxCrossAxisExtent: _maxExtentFor(c.maxWidth),
//             crossAxisSpacing: 14,
//             mainAxisSpacing: 14,
//             childAspectRatio: _aspectFor(c.maxWidth), // adaptive height → prevents overflow
//           ),
//           itemBuilder: (context, index) {
//             final item = data[index];
//             final title = item.title ?? "";
//             final url = "${Config.imageUrl}${item.url ?? ""}";
//
//             // Keep your original money formatting logic
//             final bool showCurrency = (index / 5 == 1) || (index / 8 == 1);
//             final displayValue = showCurrency
//                 ? "$currency${item.reportData ?? ""}"
//                 : "${item.reportData ?? ""}";
//
//             return _StatCard(
//               title: title,
//               value: displayValue,
//               imageUrl: url,
//               rtl: lCode == "ar_IN",
//               onTap: () => onTap(index),
//               notifire: notifire,
//             );
//           },
//         );
//       },
//     );
//   }
//
//   // Wider max extent on larger screens → fewer columns, bigger tiles
//   double _maxExtentFor(double w) {
//     if (w >= 1200) return 320;
//     if (w >= 1024) return 300;
//     if (w >= 768) return 260;
//     return 220; // phones
//   }
//
//   // Smaller ratio = taller tile; make tiles taller on small widths
//   double _aspectFor(double w) {
//     if (w < 360) return 1.05;   // very narrow phones
//     if (w < 420) return 1.15;
//     if (w < 768) return 1.25;   // phones
//     if (w < 1024) return 1.35;  // tablets
//     return 1.45;                // desktop
//   }
// }

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String imageUrl;
  final bool rtl;
  final VoidCallback onTap;
  final ColorNotifire notifire;

  const _StatCard({
    required this.title,
    required this.value,
    required this.imageUrl,
    required this.rtl,
    required this.onTap,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Base colors
    final Color border = isDark ? Colors.white10 : Colors.black12;

    // Subtle gradient background
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF1F2230), const Color(0xFF191C27)]
          : [const Color(0xFFEFF3FF), const Color(0xFFEAF0FF)],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          border: Border.all(color: border),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark image
            Positioned(
              right: rtl ? null : 8,
              left: rtl ? 8 : null,
              bottom: 8,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Opacity(
                  opacity: 0.18,
                  child: Image.network(
                    imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),

            // Text content – overflow-safe
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment:
                    rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Value – single line, shrink if needed
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        rtl ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      textDirection:
                          rtl ? TextDirection.rtl : TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: FontFamily.gilroyExtraBold,
                        color: const Color(0xFF3D5BF6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Title – allow up to 2 lines and occupy remaining vertical space
                  Expanded(
                    child: Align(
                      alignment: rtl ? Alignment.topRight : Alignment.topLeft,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection:
                            rtl ? TextDirection.rtl : TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontFamily: FontFamily.gilroyBold,
                          color: const Color(0xFF3D5BF6),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom chevron
                  Align(
                    alignment:
                        rtl ? Alignment.centerLeft : Alignment.centerRight,
                    child: Icon(
                      rtl ? Icons.chevron_left : Icons.chevron_right,
                      size: 20,
                      color: const Color(0xFF3D5BF6),
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

class _PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryActionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(45),
      child: Container(
        height: 52,
        margin: const EdgeInsets.all(12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(45),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: WhiteColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final ColorNotifire notifire;
  const _SecondaryActionButton(
      {required this.text, required this.onTap, required this.notifire});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(45),
      child: Container(
        height: 52,
        margin: const EdgeInsets.all(12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFeef4ff),
          borderRadius: BorderRadius.circular(45),
          border: Border.all(color: notifire.getborderColor),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: blueColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unnecessary_brace_in_string_interps, unnecessary_string_interpolations
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/extraimage_controller.dart';
// import 'package:gotocarefinder/controller/listofagencies_controller.dart';
// import 'package:gotocarefinder/controller/reviewlist_controller.dart';
// import 'package:gotocarefinder/firebase/chats_list.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../controller/booking_controller.dart';
// import '../../controller/enquiry_controller.dart';
// import '../../controller/gallerycategory_controller.dart';
// import '../../controller/galleryimage_controller.dart';
// import '../../controller/listofproperti_controller.dart';
// import '../../controller/myearning_controller.dart';
// import '../login_screen.dart';
//
// class MembershipScreen extends StatefulWidget {
//   const MembershipScreen({super.key});
//
//   @override
//   State<MembershipScreen> createState() => _MembershipScreenState();
// }
//
// class _MembershipScreenState extends State<MembershipScreen> {
//   DashBoardController dashBoardController = Get.find();
//   ReviewlistController reviewlistController = Get.put(ReviewlistController());
//   MyEarningController myEarningController = Get.find();
//   ListOfPropertiController listOfPropertiController = Get.find();
//   ListOfPropertyController listOfPropertyController = Get.put(ListOfPropertyController());
//   ListOfAgenciesController listOfAgenciesController = Get.put(ListOfAgenciesController());
//   ExtraImageController extraImageController = Get.find();
//   GalleryCategoryController galleryCategoryController = Get.find();
//   GalleryImageController galleryImageController = Get.find();
//   BookingController bookingController = Get.find();
//   EnquiryController enquiryController = Get.find();
//
//   List<String> routesList = [
//     Routes.listOfPropertyScreen,
//     Routes.listOfAgenciesScreen,
//     Routes.listOfPropartyScreen,
//     Routes.extraImageScreen,
//     Routes.galleryCategoryScreen,
//     Routes.galleryImageScreen,
//     Routes.bookingScreen,
//     Routes.myEarningsScreen,
//     Routes.enquiryScreen,
//     Routes.reviewlistScreen,
//     Routes.myPayoutScreen,
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     getdarkmodepreviousstate();
//   }
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
//         centerTitle: true,
//         actions: [
//           InkWell(
//             onTap: () {
//               Get.to(ChatList());
//             },
//             child: Container(
//               padding: EdgeInsets.all(5),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//               child: Center(
//                 child: Image.asset(
//                   "assets/images/Chat.png",
//                   // height: 2,
//                   width: 28,
//                   fit: BoxFit.cover,
//                   color: blueColor,
//                 ),
//               ),
//               decoration: BoxDecoration(
//                 border: Border.all(color: notifire.getborderColor),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ],
//         leading: getData.read("userType") == "admin"
//             ? GestureDetector(
//                 onTap: () {
//                   logoutSheet();
//                 },
//                 child: Image.asset(
//                   "assets/images/Logout.png",
//                   height: 20,
//                   width: 30,
//                   scale: 3,
//                   color: notifire.getredcolor,
//                 ),
//               )
//             : BackButton(
//                 color: notifire.getwhiteblackcolor,
//                 onPressed: () {
//                   Get.back();
//                 },
//               ),
//         title: Image.asset(
//           "assets/images/applogo.png",
//           height: 30,
//           width: 30,
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () {
//           return Future.delayed(
//             Duration(seconds: 2),
//             () {
//               dashBoardController.getDashBoardData();
//             },
//           );
//         },
//         child: GetBuilder<DashBoardController>(builder: (context) {
//           return dashBoardController.isLoading
//               ? SizedBox(
//                   height: Get.size.height,
//                   width: Get.size.width,
//                   child: SingleChildScrollView(
//                     physics: BouncingScrollPhysics(),
//                     child: Column(
//                       children: [
//                         /*getData.read("userType") == "admin"
//                             ? SizedBox()
//                             : Column(
//                                 children: [
//                                   Center(
//                                     child: InkWell(
//                                       onTap: () {
//                                         dashBoardController
//                                             .getSubScribeDetails();
//                                         Get.toNamed(Routes.memberShipDetails);
//                                       },
//                                       child: Container(
//                                         height: 50,
//                                         margin: EdgeInsets.symmetric(
//                                             horizontal: 12),
//                                         // width: 295,
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Image.asset(
//                                               "assets/images/verified_user.png",
//                                               height: 25,
//                                               width: 25,
//                                               fit: BoxFit.cover,
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   dashBoardController
//                                                       .membershipData[0],
//                                                   style: TextStyle(
//                                                     fontFamily:
//                                                         FontFamily.gilroyBold,
//                                                     fontSize: 16,
//                                                     color: Color(0xff3D5BF6),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 7,
//                                                 ),
//                                                 Text(
//                                                   "Membership".tr,
//                                                   style: TextStyle(
//                                                     fontFamily:
//                                                         FontFamily.gilroyBold,
//                                                     fontSize: 16,
//                                                     color: notifire
//                                                         .getwhiteblackcolor,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               width: 15,
//                                             ),
//                                             Container(
//                                               height: 25,
//                                               width: 70,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 "ACTIVE".tr,
//                                                 style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: WhiteColor,
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                                 color: Color(0xff3D5BF6),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: notifire.getborderColor),
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   Center(
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           "Valid Till: ".tr,
//                                           style: TextStyle(
//                                             color: notifire.getwhiteblackcolor,
//                                             fontFamily: FontFamily.gilroyMedium,
//                                           ),
//                                         ),
//                                         Text(
//                                           dashBoardController.membershipData[1],
//                                           style: TextStyle(
//                                             color: Color(0xff3D5BF6),
//                                             fontFamily: FontFamily.gilroyMedium,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),*/
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Center(
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 10, right: 10),
//                             child: GridView.builder(
//                               itemCount: getData.read("userType") == "admin"
//                                   ? dashBoardController
//                                           .dashBoardInfo!.reportData.length -
//                                       1
//                                   : dashBoardController
//                                       .dashBoardInfo!.reportData.length,
//                               physics: NeverScrollableScrollPhysics(),
//                               shrinkWrap: true,
//                               padding: EdgeInsets.zero,
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 mainAxisSpacing: 8,
//                                 crossAxisSpacing: 8,
//                                 mainAxisExtent: 115,
//                               ),
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     if (index == 9) {
//                                       reviewlistController.reviewlist().then(
//                                         (value) {
//                                           if (value["Result"] == "true") {
//                                             Get.toNamed(routesList[index]);
//                                           } else {
//                                             showToastMessage("No Review");
//                                           }
//                                         },
//                                       );
//                                     } else if (index == 7) {
//                                       myEarningController
//                                           .getEarningsData()
//                                           .then(
//                                         (value) {
//                                           Get.toNamed(routesList[index]);
//                                         },
//                                       );
//                                     } else if (index == 0) {
//                                       listOfPropertiController
//                                           .getPropertiList();
//                                       Get.toNamed(routesList[index]);
//                                     } else if (index == 1) {
//                                       listOfAgenciesController.getAgencyList();
//                                       Get.toNamed(routesList[index]);
//                                     } else if (index == 2) {
//                                       listOfPropertyController.getPropertiList();
//                                       Get.toNamed(routesList[index]);
//                                     } else if (index == 3) {
//                                       extraImageController.getExtraImageList();
//                                       Get.toNamed(routesList[index]);
//                                     } else if (index == 4) {
//                                       galleryCategoryController
//                                           .getGalleryCategoryList();
//                                       Get.toNamed(routesList[index]);
//                                     } else if (index == 5) {
//                                       galleryImageController
//                                           .getGalleryImageList()
//                                           .then(
//                                         (value) {
//                                           Get.toNamed(routesList[index]);
//                                         },
//                                       );
//                                     } else if (index == 6) {
//                                       bookingController.getBookingStatusWise();
//                                       Get.toNamed(routesList[index]);
//                                     } else if (index == 8) {
//                                       enquiryController.enquiryListApi();
//                                       Get.toNamed(routesList[index]);
//                                     } else {
//                                       Get.toNamed(routesList[index]);
//                                     }
//                                   },
//                                   child: Stack(
//                                     children: [
//                                       Container(
//                                         height: 115,
//                                         width: Get.width / 2,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             SizedBox(
//                                               height: 10,
//                                             ),
//                                             Padding(
//                                               padding: getData.read("lCode") ==
//                                                       "ar_IN"
//                                                   ? EdgeInsets.only(right: 15)
//                                                   : EdgeInsets.only(left: 15),
//                                               child: index / 5 == 1
//                                                   ? Text(
//                                                       "${currency}${dashBoardController.dashBoardInfo?.reportData[index].reportData ?? ""}",
//                                                       style: TextStyle(
//                                                         fontSize: 25,
//                                                         color:
//                                                             Color(0xff3D5BF6),
//                                                         fontFamily: FontFamily
//                                                             .gilroyExtraBold,
//                                                       ),
//                                                     )
//                                                   : index / 8 == 1
//                                                       ? Text(
//                                                           "${currency}${dashBoardController.dashBoardInfo?.reportData[index].reportData ?? ""}",
//                                                           style: TextStyle(
//                                                             fontSize: 25,
//                                                             color: Color(
//                                                                 0xff3D5BF6),
//                                                             fontFamily: FontFamily
//                                                                 .gilroyExtraBold,
//                                                           ),
//                                                         )
//                                                       : Text(
//                                                           "${dashBoardController.dashBoardInfo?.reportData[index].reportData ?? ""}",
//                                                           style: TextStyle(
//                                                             fontSize: 25,
//                                                             color: Color(
//                                                                 0xff3D5BF6),
//                                                             fontFamily: FontFamily
//                                                                 .gilroyExtraBold,
//                                                           ),
//                                                         ),
//                                             ),
//                                             Padding(
//                                               padding: getData.read("lCode") ==
//                                                       "ar_IN"
//                                                   ? EdgeInsets.only(right: 15)
//                                                   : EdgeInsets.only(left: 15),
//                                               child: Text(
//                                                 dashBoardController
//                                                         .dashBoardInfo
//                                                         ?.reportData[index]
//                                                         .title ??
//                                                     "",
//                                                 maxLines: 1,
//                                                 style: TextStyle(
//                                                   color: Color(0xff3D5BF6),
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   fontSize: 15,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: Colors.grey.shade200),
//                                           image: DecorationImage(
//                                             image: getData.read("lCode") ==
//                                                     "ar_IN"
//                                                 ? AssetImage(
//                                                     "assets/images/Frame2.png")
//                                                 : AssetImage(
//                                                     "assets/images/Frame.png"),
//                                             fit: BoxFit.cover,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         bottom: 0.5,
//                                         right: 16.5,
//                                         child: Container(
//                                           height: 60,
//                                           width: 60,
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.only(
//                                               bottomRight: Radius.circular(15),
//                                             ),
//                                             image: DecorationImage(
//                                               image: NetworkImage(
//                                                 "${Config.imageUrl}${dashBoardController.dashBoardInfo?.reportData[index].url ?? ""}",
//                                               ),
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         Container(
//                           margin: EdgeInsets.only(
//                               top: 20, left: 10, right: 10, bottom: 10),
//                           child: Image.asset(
//                             height: 270,
//                             "assets/images/addpropartyimg.png",
//                             fit: BoxFit.fill,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               : Center(
//                   child: CircularProgressIndicator(),
//                 );
//         }),
//       ),
//     );
//   }
//
//   Future logoutSheet() {
//     return Get.bottomSheet(
//       Container(
//         height: 220,
//         width: Get.size.width,
//         child: Column(
//           children: [
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               "Logout".tr,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontFamily: FontFamily.gilroyBold,
//                 color: RedColor,
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//               ),
//               child: Divider(
//                 color: notifire.getborderColor,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               "Are you sure you want to log out?".tr,
//               style: TextStyle(
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 16,
//                 color: notifire.getwhiteblackcolor,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: Container(
//                       height: 60,
//                       margin: EdgeInsets.all(15),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Cancle".tr,
//                         style: TextStyle(
//                           color: blueColor,
//                           fontFamily: FontFamily.gilroyBold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         color: Color(0xFFeef4ff),
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () async {
//                       final prefs = await SharedPreferences.getInstance();
//                       setState(() async {
//                         save('isLoginBack', true);
//                         await prefs.remove('Firstuser');
//                         getData.remove("UserLogin");
//                         getData.remove("countryId");
//                         getData.remove("countryName");
//                         getData.remove("currentIndex");
//                         tokenemty();
//
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LoginScreen()));
//                       });
//                     },
//                     child: Container(
//                       height: 60,
//                       margin: EdgeInsets.all(15),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Yes, Logout".tr,
//                         style: TextStyle(
//                           color: WhiteColor,
//                           fontFamily: FontFamily.gilroyBold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         color: blueColor,
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             )
//           ],
//         ),
//         decoration: BoxDecoration(
//           color: notifire.getbgcolor,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<dynamic> tokenemty() async {
//     CollectionReference collectionReference =
//         FirebaseFirestore.instance.collection('users');
//     collectionReference
//         .doc(getData.read("UserLogin")["id"])
//         .update({"token": ""});
//   }
// }
