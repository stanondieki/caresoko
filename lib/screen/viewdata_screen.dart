// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_key_in_widget_constructors, must_be_immutable, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, unused_field, unused_element, avoid_print, unrelated_type_equality_checks, unnecessary_string_interpolations, avoid_unnecessary_containers, prefer_adjacent_string_concatenation
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
import 'package:gotocarefinder/controller/gallery_controller.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


/// ---------- RESPONSIVE HELPERS ----------
const double kTabletBreakpoint = 768;
const double kDesktopBreakpoint = 1024;

class Responsive {
  static bool isMobile(BoxConstraints c) => c.maxWidth < kTabletBreakpoint;
  static bool isTablet(BoxConstraints c) =>
      c.maxWidth >= kTabletBreakpoint && c.maxWidth < kDesktopBreakpoint;
  static bool isDesktop(BoxConstraints c) => c.maxWidth >= kDesktopBreakpoint;
}

class ViewDataScreen extends StatefulWidget {
  @override
  State<ViewDataScreen> createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  late ColorNotifire notifire;
  final HomePageController homePageController = Get.find();
  final ReviewSummaryController reviewSummaryController = Get.find();
  final BookrealEstateController bookrealEstateController = Get.find();
  final GalleryController galleryController = Get.find();

  int selectIndex = 0;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }
  Future<void> _bookNow() async {
    // 1. Check login
    final user = getData.read("UserLogin");
    if (user == null) {
      showToastMessage("Please login to book".tr);
      return;
    }

    final uid = "${user["id"]}";
    final prop = homePageController.propetydetailsInfo?.propetydetails;

    if (prop == null) {
      showToastMessage("Property details not available".tr);
      return;
    }

    final propId = "${prop.id}";

    // 2. Ask user for date & time (simple pickers)
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // 3. Optional short message (you can skip this dialog if you want)
    String message = "";
    await showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController _msgCtrl = TextEditingController();
        return AlertDialog(
          title: Text("Add Note (Optional)".tr),
          content: TextField(
            controller: _msgCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Describe any special request…".tr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text("Skip".tr),
            ),
            TextButton(
              onPressed: () {
                message = _msgCtrl.text.trim();
                Navigator.of(ctx).pop();
              },
              child: Text("OK".tr),
            ),
          ],
        );
      },
    );

    // Format date & time for API (Y-m-d, H:i)
    final String dateStr =
        "${pickedDate.year.toString().padLeft(4, '0')}-"
        "${pickedDate.month.toString().padLeft(2, '0')}-"
        "${pickedDate.day.toString().padLeft(2, '0')}";

    final String timeStr =
        "${pickedTime.hour.toString().padLeft(2, '0')}:"
        "${pickedTime.minute.toString().padLeft(2, '0')}";

    // 4. Build payload (book_for = 'self' basic case)
    final Map<String, dynamic> body = {
      "prop_id": propId,
      "uid": uid,
      "date": dateStr,
      "time": timeStr,
      "book_for": "self",   // or "other" if you want to send extra fields
      "message": message,
    };

    try {
      // 5. Call the API
      final uri = Uri.parse("${Config.path}${Config.bookApi}");
      // == https://careinafh.caresoko.com/user_api/u_book.php

      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);

        if (data["Result"] == "true") {
          final bookId = data["book_id"];
          showToastMessage("Booking Confirmed Successfully!!!".tr);
          // If you want, navigate to booking details:
          // Get.toNamed(Routes.bookingDetailsScreen, arguments: {"book_id": bookId});
        } else {
          showToastMessage("${data["ResponseMsg"] ?? "Booking failed"}");
        }
      } else {
        showToastMessage("Server error (${res.statusCode})".tr);
      }
    } catch (e) {
      print("BOOK ERROR: $e");
      showToastMessage("Something went wrong while booking".tr);
    }
  }
  Future<dynamic> isMeassageAvalable(String uid) async {
    // CollectionReference collectionReference =
    // FirebaseFirestore.instance.collection('users');
    // collectionReference.doc(uid).get().then((value) {
    //   var fields = value.data() as Map<String, dynamic>?;
    //   if (fields != null) {
    //     setState(() {
    //       useremail = fields["name"] ?? '';
    //       fmctoken = fields["token"] ?? '';
    //     });
    //   }
    // });
  }

  String latitude = "";
  String longitude = "";

  late GoogleMapController mapController;
  LatLng showLocation = LatLng(27.7089427, 85.3086209);

  final List<Marker> _markers = <Marker>[];

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  String useremail = '';
  String fmctoken = '';

  /* SCROLLING FUNCTIONALITY STARTS HERE */
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentIndex = 0;
  int _totalImages = 0;
  final Duration _scrollDuration = Duration(seconds: 5); // Customize speed

  List<String> recreationalItems = [];
  List<String> accreditations = [];
  List<String> certifications = [];
  List<String> professionalMemberships = [];
  List<String> specializedCertifications = [];

  @override
  void initState() {
    super.initState();
    
    // SAFE: Only access data if it exists (API might return error)
    final details = homePageController.propetydetailsInfo?.propetydetails;
    if (details != null) {
      loadData();
      isMeassageAvalable("${details.userId ?? ''}");
      _totalImages = details.image?.length ?? 0;
    } else {
      _totalImages = 0;
      
      // If no data and not loading, redirect to home after a brief delay
      // This handles direct URL navigation to /viewDataScreen
      if (!homePageController.isProperty) {
        Future.delayed(Duration(milliseconds: 1500), () {
          if (mounted && homePageController.propetydetailsInfo?.propetydetails == null) {
            Get.offAllNamed(Routes.bottomBar);
          }
        });
      }
    }

    _pageController = PageController();

    if (_totalImages > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_scrollDuration, (timer) {
      if (_pageController.hasClients && _totalImages > 1) {
        _currentIndex = (_currentIndex + 1) % _totalImages;
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /*SCROLLING FUNCTIONALITY ENDS HERE */

  List<String> _safeSplit(String? csv) => (csv ?? '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  loadData() async {
    // Marker icon + safe lat/lng parsing
    try {
      final Uint8List markIcons =
      await getImages("assets/images/MapPin.png", 100);

      final String latStr =
          homePageController.propetydetailsInfo?.propetydetails!.latitude ??
              "";
      final String lngStr =
          homePageController.propetydetailsInfo?.propetydetails!.longtitude ??
              "";

      final double? lat = double.tryParse(latStr);
      final double? lng = double.tryParse(lngStr);

      if (lat != null && lng != null) {
        _markers.add(
          Marker(
            markerId: MarkerId(LatLng(lat, lng).toString()),
            icon: BitmapDescriptor.fromBytes(markIcons),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(),
          ),
        );
      }
    } catch (_) {
      // ignore marker/icon errors
    }

    recreationalItems = _safeSplit(homePageController
        .propetydetailsInfo?.propetydetails!.recreationalActivities);

    accreditations = _safeSplit(homePageController
        .propetydetailsInfo?.propetydetails!.accreditations);

    certifications = _safeSplit(homePageController
        .propetydetailsInfo?.propetydetails!.certifications);

    professionalMemberships = _safeSplit(homePageController
        .propetydetailsInfo?.propetydetails!.memberships);

    specializedCertifications = _safeSplit(homePageController
        .propetydetailsInfo?.propetydetails!.specializedCertifications);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<HomePageController>(builder: (context) {
      // Check if data is actually available (not just loading complete)
      final hasData = homePageController.propetydetailsInfo?.propetydetails != null;
      
      return Scaffold(
        backgroundColor: notifire.getbgcolor,
        body: !homePageController.isProperty
            // Still loading
            ? Center(child: CircularProgressIndicator(color: blueColor))
            : !hasData
                // Error state - API returned error or null data
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Could not load property details".tr,
                          style: TextStyle(
                            fontSize: 18,
                            color: notifire.getwhiteblackcolor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Please try again later".tr,
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(backgroundColor: blueColor),
                          child: Text("Go Back".tr, style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = Responsive.isDesktop(constraints);
            final bool isTablet = Responsive.isTablet(constraints);

            const double maxContentWidth = 1200;
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 12,
            );

            final double heroHeight = isDesktop
                ? 420
                : isTablet
                ? 360
                : 300;

            final double mapHeight = isDesktop
                ? 320
                : isTablet
                ? 260
                : 200;

            // Adaptive feature grid columns
            int featureCols;
            if (isDesktop) {
              featureCols = 6;
            } else if (isTablet) {
              featureCols = 4;
            } else {
              featureCols = 3;
            }

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: heroHeight,
                    floating: false,
                    pinned: true,
                    backgroundColor: notifire.getbgcolor,
                    leading: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(17),
                        child: Image.asset(
                          "assets/images/Arrow - Left.png",
                          color: blueColor,
                        ),
                        decoration:
                        BoxDecoration(shape: BoxShape.circle),
                      ),
                    ),
                    actions: [
                      GetBuilder<HomePageController>(builder: (context) {
                        return InkWell(
                          onTap: () {
                            if (getData.read("UserLogin") != null) {
                              homePageController.addFavouriteList(
                                pid: homePageController
                                    .propetydetailsInfo!
                                    .propetydetails!
                                    .id,
                                propertyType: homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .propertyType,
                              );
                            }
                          },
                          child: homePageController
                              .propetydetailsInfo
                              ?.propetydetails!
                              .isFavourite ==
                              1
                              ? Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(14),
                            child: Image.asset(
                              "assets/images/Fev-Bold.png",
                              color: blueColor,
                            ),
                          )
                              : Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(14),
                            child: Image.asset(
                              "assets/images/favorite.png",
                              color: blueColor,
                            ),
                          ),
                        );
                      }),
                      SizedBox(width: 10),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          SizedBox(
                            height: heroHeight,
                            child: _totalImages == 0
                                ? Container(
                              color: Colors.black12,
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/images/emty.gif",
                                height: heroHeight,
                                fit: BoxFit.cover,
                              ),
                            )
                                : PageView.builder(
                              controller: _pageController,
                              itemCount: _totalImages,
                              physics:
                              BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final image = homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .image![index]
                                    .image;
                                return FadeInImage.assetNetwork(
                                  fadeInCurve:
                                  Curves.easeInCirc,
                                  placeholder:
                                  "assets/images/ezgif.com-crop.gif",
                                  height: heroHeight,
                                  width: Get.size.width,
                                  imageErrorBuilder: (c, e, s) =>
                                      Center(
                                        child: Image.asset(
                                          "assets/images/emty.gif",
                                          fit: BoxFit.cover,
                                          height: heroHeight,
                                        ),
                                      ),
                                  image:
                                  "${Config.imageUrl}${image ?? ""}",
                                  fit: BoxFit.cover,
                                );
                              },
                              onPageChanged: (value) {
                                setState(() {
                                  selectIndex = value;
                                });
                              },
                            ),
                          ),
                          if (_totalImages > 1)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 25,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: List.generate(
                                    _totalImages,
                                        (index) => IndicatorViewPage(
                                      isActive:
                                      selectIndex == index,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_totalImages > 0 &&
                              (homePageController
                                  .propetydetailsInfo
                                  ?.propetydetails!
                                  .image![selectIndex]
                                  .isPanorama ==
                                  1))
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.imageViewerSreen,
                                    arguments: {
                                      "img": homePageController
                                          .propetydetailsInfo
                                          ?.propetydetails!
                                          .image![selectIndex]
                                          .image,
                                    },
                                  );
                                },
                                child: Container(
                                  height: 30,
                                  width: 70,
                                  padding: EdgeInsets.all(4),
                                  child: Image.asset(
                                      "assets/images/360.png"),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    color:
                                    BlackColor.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Center(
                child: ConstrainedBox(
                  constraints:
                  BoxConstraints(maxWidth: maxContentWidth),
                  child: Padding(
                    padding: pagePadding,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: Get.size.height,
                          width: Get.size.width,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // -------- TITLE --------
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                  child: Text(
                                    homePageController
                                        .propetydetailsInfo
                                        ?.propetydetails!
                                        .name ??
                                        "",
                                    style: TextStyle(
                                      fontSize: isDesktop ? 26 : 22,
                                      fontFamily:
                                      FontFamily.gilroyBold,
                                      color: notifire
                                          .getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),

                                // -------- BADGES / META (Wrap for responsiveness) --------
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12, right: 12),
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                    WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        height: 25,
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFeef4ff),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          homePageController
                                              .propetydetailsInfo
                                              ?.propetydetails!
                                              .propertyTitle ??
                                              "",
                                          style: TextStyle(
                                            fontFamily:
                                            FontFamily.gilroyMedium,
                                            fontSize: 12,
                                            color: blueColor,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            "assets/images/Rating.png",
                                            height: 18,
                                            width: 18,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "${homePageController.propetydetailsInfo?.propetydetails!.rate ?? ""}",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              fontFamily: FontFamily
                                                  .gilroyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // -------- STATS WRAP (Beds / Rooms) --------
                                SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: Wrap(
                                    alignment:
                                    WrapAlignment.spaceEvenly,
                                    runSpacing: 8,
                                    children: [
                                      _iconStat(
                                        icon: "assets/images/Frame1.png",
                                        label:
                                        "${homePageController.propetydetailsInfo?.propetydetails!.beds} Beds",
                                      ),
                                      if (homePageController
                                          .propetydetailsInfo
                                          ?.propetydetails!
                                          .privateRooms ==
                                          1)
                                        _iconStat(
                                          icon:
                                          "assets/images/sqft.png",
                                          label: (() {
                                            final hasOwnBath =
                                                (homePageController
                                                    .propetydetailsInfo
                                                    ?.propetydetails!
                                                    .ownBathrooms ??
                                                    0) ==
                                                    1;
                                            final pr =
                                                homePageController
                                                    .propetydetailsInfo
                                                    ?.propetydetails!
                                                    .privateRooms ??
                                                    0;
                                            return hasOwnBath
                                                ? "$pr Private Room(s) (Own Bath)"
                                                : "$pr Private Room(s)";
                                          }()),
                                        ),
                                      if (homePageController
                                          .propetydetailsInfo
                                          ?.propetydetails!
                                          .sharedRooms ==
                                          1)
                                        _iconStat(
                                          icon:
                                          "assets/images/sun.png",
                                          label:
                                          "${homePageController.propetydetailsInfo?.propetydetails!.sharedRooms} Shared Room(s) (Shared Bath)",
                                        ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Divider(),
                                ),

                                // -------- POSTED BY --------
                                _sectionTitle("Posted By".tr),
                                SizedBox(height: 8),
                                ListTile(
                                  leading: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          "${Config.imageUrl}${homePageController.propetydetailsInfo?.propetydetails!.logo}",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    homePageController
                                        .propetydetailsInfo
                                        ?.propetydetails!
                                        .name ??
                                        "",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily:
                                      FontFamily.gilroyBold,
                                      color: notifire
                                          .getwhiteblackcolor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Verified".tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily:
                                      FontFamily.gilroyMedium,
                                    ),
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                        Routes.homeProfileScreen,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4),
                                      child: Text(
                                        "More Info",
                                        style: TextStyle(
                                          color: blueColor,
                                          fontFamily:
                                          FontFamily.gilroyBold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // -------- ABOUT --------
                                _sectionTitle("About This Home".tr),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                  child: ReadMoreText(
                                    homePageController
                                        .propetydetailsInfo
                                        ?.propetydetails!
                                        .description ??
                                        "",
                                    trimLines: 4,
                                    colorClickableText: blueColor,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'Read more'.tr,
                                    trimExpandedText: 'Show less'.tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily:
                                      FontFamily.gilroyMedium,
                                    ),
                                  ),
                                ),

                                // -------- HOME FEATURES (Adaptive Grid) --------
                                SizedBox(height: 10),
                                _sectionTitle("Home Features".tr),
                                SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  NeverScrollableScrollPhysics(),
                                  itemCount: homePageController
                                      .propetydetailsInfo
                                      ?.facility!
                                      .length,
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8),
                                  gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: featureCols,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final facility = homePageController
                                        .propetydetailsInfo!
                                        .facility![index];
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 60,
                                          width: 60,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFeef4ff),
                                          ),
                                          child: FadeInImage.assetNetwork(
                                            height: 25,
                                            width: 25,
                                            color: blueColor,
                                            placeholder:
                                            "assets/images/loading2.gif",
                                            imageErrorBuilder:
                                                (context, error,
                                                stackTrace) {
                                              return Center(
                                                child: Image.asset(
                                                  "assets/images/emty.gif",
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                            image:
                                            "${Config.imageUrl}${facility.img}",
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          facility.title ?? "",
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: FontFamily
                                                .gilroyMedium,
                                            color: notifire
                                                .getwhiteblackcolor,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                // -------- GALLERY (Adaptive Grid) --------
                                if (homePageController
                                    .propetydetailsInfo!
                                    .gallery!
                                    .isNotEmpty) ...[
                                  gallaryAndSeeAllWidget(
                                      "Gallery".tr, "See All".tr),
                                  SizedBox(height: 8),
                                  LayoutBuilder(
                                    builder: (context, c2) {
                                      final bool wide =
                                          c2.maxWidth >= 600;
                                      final int cross = isDesktop
                                          ? 5
                                          : wide
                                          ? 4
                                          : 3;
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                        NeverScrollableScrollPhysics(),
                                        itemCount: homePageController
                                            .propetydetailsInfo
                                            ?.gallery!
                                            .length ??
                                            0,
                                        gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: cross,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                          childAspectRatio: 1,
                                        ),
                                        itemBuilder:
                                            (context, index) {
                                          final img = homePageController
                                              .propetydetailsInfo
                                              ?.gallery![index];
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                              color: notifire
                                                  .getblackwhitecolor,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                              child: FadeInImage
                                                  .assetNetwork(
                                                fadeInCurve:
                                                Curves.easeInCirc,
                                                placeholder:
                                                "assets/images/ezgif.com-crop.gif",
                                                imageErrorBuilder: (c, e,
                                                    s) =>
                                                    Center(
                                                      child: Image.asset(
                                                        "assets/images/emty.gif",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                image:
                                                "${Config.imageUrl}$img",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],

                                // -------- LOCATION --------
                                _sectionTitle("Location".tr),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        "assets/images/Location.png",
                                        height: 22,
                                        width: 22,
                                        fit: BoxFit.cover,
                                        color: Color(0xff3D5BF6),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          homePageController
                                              .propetydetailsInfo
                                              ?.propetydetails!
                                              .city ??
                                              "",
                                          style: TextStyle(
                                            fontFamily: FontFamily
                                                .gilroyMedium,
                                            color:
                                            notifire.getgreycolor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: mapHeight,
                                  width: double.infinity,
                                  margin: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    child: GoogleMap(
                                      initialCameraPosition:
                                      CameraPosition(
                                        target: LatLng(
                                          double.tryParse(
                                              homePageController
                                                  .propetydetailsInfo
                                                  ?.propetydetails!
                                                  .latitude ??
                                                  "") ??
                                              0,
                                          double.tryParse(
                                              homePageController
                                                  .propetydetailsInfo
                                                  ?.propetydetails!
                                                  .longtitude ??
                                                  "") ??
                                              0,
                                        ),
                                        zoom: 14.0,
                                      ),
                                      markers: Set<Marker>.of(
                                          _markers),
                                      mapType: MapType.normal,
                                      myLocationEnabled:
                                      false, // friendlier default on web
                                      compassEnabled: true,
                                      zoomGesturesEnabled: true,
                                      tiltGesturesEnabled: true,
                                      zoomControlsEnabled: true,
                                      onMapCreated: (controller) {
                                        setState(() {
                                          mapController = controller;
                                        });
                                      },
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: notifire
                                        .getblackwhitecolor,
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0.5, 0.5),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),

                                // -------- SERVICES --------
                                _sectionTitle("Services".tr),
                                SizedBox(height: 12),
                                if (homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .memoryCareClients ==
                                    1)
                                  _checkTile(
                                      "Accepts memory care clients"),
                                if (homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .medicaidClients ==
                                    1)
                                  _checkTile(
                                      "Accepts Medicaid clients"),
                                if (homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .hoyerClients ==
                                    1)
                                  _checkTile("Accepts Hoyer clients"),
                                if (homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .curatedMenus ==
                                    1)
                                  _checkTile(
                                      "Provides curated meal plans"),
                                if (homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .medicationReminders ==
                                    1)
                                  _checkTile(
                                      "Assists with medication"),
                                if (homePageController
                                    .propetydetailsInfo
                                    ?.propetydetails!
                                    .correctionalClients ==
                                    1)
                                  _checkTile(
                                      "Accepts correctional clients"),

                                // -------- TYPICAL DAY --------
                                _sectionTitle(
                                    "Typical Day For A Resident Here"
                                        .tr),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                  child: ReadMoreText(
                                    homePageController
                                        .propetydetailsInfo
                                        ?.propetydetails!
                                        .typicalDay ??
                                        "",
                                    trimLines: 4,
                                    colorClickableText: blueColor,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'Read more'.tr,
                                    trimExpandedText: 'Show less'.tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily:
                                      FontFamily.gilroyMedium,
                                    ),
                                  ),
                                ),

                                // -------- LISTS (Adaptive two-column) --------
                                _adaptiveListSection(
                                  title: "Accreditations".tr,
                                  items: accreditations,
                                ),
                                _adaptiveListSection(
                                  title: "Caregiver Certifications".tr,
                                  items: certifications,
                                ),
                                _adaptiveListSection(
                                  title:
                                  "Specialized Caregiver Certifications"
                                      .tr,
                                  items: specializedCertifications,
                                ),
                                _adaptiveListSection(
                                  title: "Professional Memberships".tr,
                                  items: professionalMemberships,
                                ),

                                // -------- RECREATIONAL ACTIVITIES --------
                                if (recreationalItems.isNotEmpty) ...[
                                  _sectionTitle(
                                      "Recreational Activities".tr),
                                  SizedBox(height: 12),
                                  _presenceTile(
                                      "Trips", recreationalItems),
                                  _presenceTile("Birthday Parties",
                                      recreationalItems),
                                  _presenceTile(
                                      "Entertainment Performances",
                                      recreationalItems),
                                  _presenceTile("Anniversary Parties",
                                      recreationalItems),
                                ],

                                // -------- PRICING --------
                                _sectionTitle("Pricing".tr),
                                SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: ReadMoreText(
                                    (() {
                                      final details = homePageController
                                          .propetydetailsInfo
                                          ?.propetydetails;
                                      if ((details?.pricingReady ??
                                          0) ==
                                          1) {
                                        return details?.pricing ?? "";
                                      } else {
                                        return "Pricing dependent on care plan assessment";
                                      }
                                    }()),
                                    trimLines: 4,
                                    colorClickableText: blueColor,
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'Read more'.tr,
                                    trimExpandedText: 'Show less'.tr,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily:
                                      FontFamily.gilroyMedium,
                                    ),
                                  ),
                                ),

                                // -------- REVIEWS --------
                                if (homePageController
                                    .propetydetailsInfo!
                                    .reviewlist!
                                    .isNotEmpty) ...[
                                  reviewWidget(
                                    "${homePageController.propetydetailsInfo?.propetydetails!.rate ?? ""}(${homePageController.propetydetailsInfo?.totalReview} ${"reviews".tr})",
                                    "See All".tr,
                                    Icon(Icons.star,
                                        color: yelloColor),
                                  ),
                                  ListView.builder(
                                    itemCount: homePageController
                                        .propetydetailsInfo
                                        ?.reviewlist!
                                        .length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                    NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {},
                                        child: ListTile(
                                          leading: Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              shape:
                                              BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  "${Config.imageUrl}${homePageController.propetydetailsInfo?.reviewlist![index].userImg ?? ""}",
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "${homePageController.propetydetailsInfo?.reviewlist![index].userTitle ?? ""}",
                                            style: TextStyle(
                                              color: notifire
                                                  .getwhiteblackcolor,
                                              fontFamily: FontFamily
                                                  .gilroyBold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "${homePageController.propetydetailsInfo?.reviewlist![index].userDesc ?? ""}",
                                            textAlign:
                                            TextAlign.start,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: notifire
                                                  .getgreycolor,
                                              fontFamily: FontFamily
                                                  .gilroyMedium,
                                            ),
                                          ),
                                          trailing: Container(
                                            height: 40,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: blueColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(20),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: [
                                                Icon(Icons.star,
                                                    color: blueColor),
                                                SizedBox(width: 5),
                                                Text(
                                                  "${homePageController.propetydetailsInfo?.reviewlist![index].userRate ?? ""}",
                                                  style: TextStyle(
                                                    fontFamily:
                                                    FontFamily
                                                        .gilroyBold,
                                                    color: blueColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],

                                SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),

                        // -------- BOTTOM BOOKING BAR --------
                        // -------- BOTTOM BOOKING BAR (overflow-proof) --------
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Material( // keeps elevation/ink on web
                            color: notifire.getblackwhitecolor,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final isNarrow = c.maxWidth < 520; // stack on very small screens
                                    final button = Flexible(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          // clamp button width so it never overflows the row
                                          maxWidth: c.maxWidth < 700 ? 220 : 280,
                                          minWidth: 140,
                                          minHeight: 48,
                                        ),
                                        child: GetBuilder<BookrealEstateController>(builder: (_) {
                                          return GestButton(
                                            Width: double.infinity,
                                            height: 56,
                                            buttoncolor: const Color(0xFF4772ff),
                                            margin: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                            buttontext: "Book Now".tr,
                                            onclick: _bookNow,  // <-- call our API method
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              color: WhiteColor,
                                              fontSize: 16,
                                            ),
                                          );
                                          // return GestButton(
                                          //   Width: double.infinity, // fill the constrained box only
                                          //   height: 56,
                                          //   buttoncolor: const Color(0xFF4772ff),
                                          //   margin: const EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                          //   buttontext: "Schedule Tour".tr,
                                          //   onclick: () {
                                          //     if (getData.read("UserLogin") != null) {
                                          //       bookrealEstateController.cleanDate();
                                          //       Get.toNamed(Routes.bookRealEstate);
                                          //       reviewSummaryController.getProductObject(
                                          //         pim: homePageController.propetydetailsInfo?.propetydetails!.image![0].image,
                                          //         pti: homePageController.propetydetailsInfo?.propetydetails!.name ?? "",
                                          //         pci: homePageController.propetydetailsInfo?.propetydetails!.city ?? "",
                                          //         pPty: homePageController.propetydetailsInfo?.propetydetails!.propertyTitle,
                                          //         pId: homePageController.propetydetailsInfo?.propetydetails!.id ?? "",
                                          //         pLimit: homePageController.propetydetailsInfo?.propetydetails!.capacity ?? "1",
                                          //       );
                                          //     } else {
                                          //       showToastMessage("Please login and Book".tr);
                                          //     }
                                          //   },
                                          //   style: TextStyle(
                                          //     fontFamily: FontFamily.gilroyBold,
                                          //     color: WhiteColor,
                                          //     fontSize: 16,
                                          //   ),
                                          // );
                                        }),
                                      ),
                                    );

                                    final license = Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10, left: 15, bottom: 10, right: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "License No".tr,
                                              style: TextStyle(
                                                fontFamily: FontFamily.gilroyMedium,
                                                color: greycolor,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    "${homePageController.propetydetailsInfo?.propetydetails!.licenseNo ?? ""}",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: const Color(0xFF4772ff),
                                                      fontFamily: FontFamily.gilroyBold,
                                                      fontSize: c.maxWidth >= 900 ? 24 : 20,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );

                                    if (isNarrow) {
                                      // On narrow widths, stack vertically to avoid any chance of overflow
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(children: [license]),
                                          Row(children: [Expanded(child: Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: button,
                                          ))]),
                                        ],
                                      );
                                    }

                                    // Wider screens: keep it in a single row; button is width‑clamped
                                    return Row(
                                      children: [
                                        license,
                                        button,
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        )
      );
    });
  }

  /// ---------- SMALL WIDGET HELPERS ----------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontFamily: FontFamily.gilroyBold,
          color: notifire.getwhiteblackcolor,
        ),
      ),
    );
  }

  Widget _iconStat({required String icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFeef4ff),
            ),
            child: Image.asset(icon, height: 20, width: 20, color: blueColor),
          ),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkLeading() {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFeef4ff),
      ),
      child: Image.asset(
        "assets/images/check.png",
        height: 20,
        width: 20,
        color: blueColor,
      ),
    );
  }

  Widget _checkTile(String title) {
    return ListTile(
      leading: _checkLeading(),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: FontFamily.gilroyMedium,
          fontSize: 16,
          color: notifire.getwhiteblackcolor,
        ),
      ),
    );
  }

  Widget _presenceTile(String label, List<String> items) {
    if (!items.contains(label)) return SizedBox.shrink();
    return _checkTile(label);
  }

  Widget _adaptiveListSection({
    required String title,
    required List<String> items,
  }) {
    if (items.isEmpty) return SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool wide = constraints.maxWidth >= 700;
        final int columns = wide ? 2 : 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontFamily: FontFamily.gilroyBold,
                color: notifire.getwhiteblackcolor,
              ),
            ),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 7, // row-like chips
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    height: 34,
                    width: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFeef4ff),
                    ),
                    child: Image.asset(
                      "assets/images/check.png",
                      height: 18,
                      width: 18,
                      color: blueColor,
                    ),
                  ),
                  title: Text(
                    items[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 15,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget gallaryAndSeeAllWidget(String name, String buttonName) {
    return Row(
      children: [
        SizedBox(width: 15),
        Text(
          name,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: () {
            galleryController.getGalleryData(
                pId: homePageController
                    .propetydetailsInfo?.propetydetails!.id);
            Get.toNamed(Routes.galleryScreen);
          },
          child: Text(
            buttonName,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget reviewWidget(String name, String buttonName, Icon icon) {
    return Row(
      children: [
        SizedBox(width: 15),
        icon,
        SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontFamily: FontFamily.gilroyBold,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.toNamed(Routes.reviewScreen, arguments: {
              "list":
              homePageController.propetydetailsInfo?.reviewlist
            });
          },
          child: Text(
            buttonName,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}

class IndicatorViewPage extends StatelessWidget {
  final bool isActive;
  const IndicatorViewPage({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
        height: isActive ? 6 : 8,
        width: isActive ? 30 : 8,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}