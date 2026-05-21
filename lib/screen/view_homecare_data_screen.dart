// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_key_in_widget_constructors, must_be_immutable, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, unused_field, unused_element, avoid_print, unrelated_type_equality_checks, unnecessary_string_interpolations, avoid_unnecessary_containers, prefer_adjacent_string_concatenation
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
import 'package:latlong2/latlong.dart' as osm;
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

class ViewHomecareDataScreen extends StatefulWidget {
  @override
  State<ViewHomecareDataScreen> createState() => _ViewHomecareDataScreenState();
}

class _ViewHomecareDataScreenState extends State<ViewHomecareDataScreen> {
  late ColorNotifire notifire;
  HomePageController homePageController = Get.find();
  ReviewSummaryController reviewSummaryController = Get.find();
  BookrealEstateController bookrealEstateController = Get.find();
  GalleryController galleryController = Get.find();

  int selectIndex = 0;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  Future<void> _bookNow() async {
    // 1. Check login
    final user = getData.read("UserLogin");
    if (user == null) {
      showToastMessage("Please login to book".tr);
      return;
    }

    final uid = "${user["id"]}";
    final agency = homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails;

    if (agency == null) {
      showToastMessage("Agency details not available".tr);
      return;
    }

    final propId = "${agency.id}";

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

    // 3. Optional short message
    String message = "";
    await showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController msgCtrl = TextEditingController();
        return AlertDialog(
          title: Text("Add Note (Optional)".tr),
          content: TextField(
            controller: msgCtrl,
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
                message = msgCtrl.text.trim();
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
      "book_for": "self",
      "message": message,
    };

    try {
      // 5. Call the API
      final uri = Uri.parse("${Config.path}${Config.homecareBookApi}");

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
          showToastMessage("Booking Confirmed Successfully!!!".tr);
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
    //   var fields;
    //   fields = value.data();
    //
    //   setState(() {
    //     useremail = fields["name"];
    //     fmctoken = fields["token"];
    //   });
    // });
  }

  String latitude = "";
  String longitude = "";

  final List<osm.LatLng> _markers = <osm.LatLng>[];

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
  late Timer _autoScrollTimer;
  int _currentIndex = 0;
  int _totalImages = 0;
  final Duration _scrollDuration = Duration(seconds: 5); // Customize speed

  List<String> accreditations = [];
  List<String> certifications = [];
  List<String> professionalMemberships = [];
  List<String> specializedCertifications = [];
  List<String> languages = [];

  @override
  void initState() {
    super.initState();
    loadData();
    isMeassageAvalable(
        "${homePageController.homecareAgencyDetailsInfo!.homecareAgencyDetails!.userId}");

    _totalImages = homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails?.image?.length ??
        0;

    _pageController = PageController();

    if (_totalImages > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
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
    if (_totalImages > 1) {
      _autoScrollTimer.cancel();
    }
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
    // Guard for lat/lng parsing to avoid exceptions
    final String latStr = homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails!.latitude ??
        "";
    final String lngStr = homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails!.longitude ??
        "";

    try {
      final Uint8List markIcons =
      await getImages("assets/images/MapPin.png", 100);

      final double? lat = double.tryParse(latStr);
      final double? lng = double.tryParse(lngStr);

      if (lat != null && lng != null) {
        _markers.add(osm.LatLng(lat, lng));
      }
    } catch (_) {
      // ignore map marker image load errors
    }

    accreditations = _safeSplit(homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails!.accreditations);

    certifications = _safeSplit(homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails!.certifications);

    professionalMemberships = _safeSplit(homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails!.memberships);

    specializedCertifications = _safeSplit(homePageController
        .homecareAgencyDetailsInfo
        ?.homecareAgencyDetails!
        .specializedCertifications);

    languages = _safeSplit(homePageController
        .homecareAgencyDetailsInfo?.homecareAgencyDetails!.languages);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return GetBuilder<HomePageController>(builder: (context) {
      return Scaffold(
        backgroundColor: notifire.getbgcolor,
        body: homePageController.isProperty
            ? LayoutBuilder(
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

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: heroHeight,
                    floating: false,
                    pinned: true,
                    backgroundColor: notifire.getbgcolor,
                    leading: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(17),
                        child: Image.asset(
                          "assets/images/Arrow - Left.png",
                          color: blueColor,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    actions: [
                      GetBuilder<HomePageController>(builder: (context) {
                        return InkWell(
                          onTap: () {
                            if (getData.read("UserLogin") != null) {
                              homePageController.addFavouriteList(
                                pid: homePageController
                                    .homecareAgencyDetailsInfo!
                                    .homecareAgencyDetails!
                                    .id,
                                propertyType: homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .propertyType,
                              );
                            }
                          },
                          child: homePageController
                              .homecareAgencyDetailsInfo
                              ?.homecareAgencyDetails!
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
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
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final image = homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .image![index]
                                    .image;
                                return FadeInImage.assetNetwork(
                                  fadeInCurve: Curves.easeInCirc,
                                  placeholder:
                                  "assets/images/ezgif.com-crop.gif",
                                  height: heroHeight,
                                  width: Get.size.width,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) {
                                    return Center(
                                      child: Image.asset(
                                        "assets/images/emty.gif",
                                        fit: BoxFit.cover,
                                        height: heroHeight,
                                      ),
                                    );
                                  },
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
                                      isActive: selectIndex == index,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_totalImages > 0 &&
                              (homePageController
                                  .homecareAgencyDetailsInfo
                                  ?.homecareAgencyDetails!
                                  .image![selectIndex]
                                  .isPanorama ==
                                  1))
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.imageViewerSreen,
                                      arguments: {
                                        "img": homePageController
                                            .homecareAgencyDetailsInfo
                                            ?.homecareAgencyDetails!
                                            .image![selectIndex]
                                            .image,
                                      });
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
                                    color: BlackColor.withOpacity(0.5),
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
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
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
                                // ====== TITLE ======
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 3, top: 10),
                                  child: Text(
                                    homePageController
                                        .homecareAgencyDetailsInfo
                                        ?.homecareAgencyDetails!
                                        .name ??
                                        "",
                                    style: TextStyle(
                                      fontSize:
                                      Responsive.isDesktop(constraints)
                                          ? 26
                                          : 22,
                                      fontFamily: FontFamily.gilroyBold,
                                      color:
                                      notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),

                                // ====== BADGES / META ======
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 3),
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                    WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        height: 25,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFeef4ff),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          homePageController
                                              .homecareAgencyDetailsInfo
                                              ?.homecareAgencyDetails!
                                              .propertyTypeTitle ??
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                              "assets/images/verified_user.png",
                                              height: 18,
                                              width: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            "Verified".tr,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              fontFamily: FontFamily
                                                  .gilroyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                              "assets/images/Rating.png",
                                              height: 18,
                                              width: 18),
                                          SizedBox(width: 6),
                                          Text(
                                            "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.rate ?? ""}",
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

                                // ====== LOCATION ======
                                SizedBox(height: 14),
                                Text(
                                  "Location".tr,
                                  style: TextStyle(
                                    fontSize:
                                    Responsive.isDesktop(constraints)
                                        ? 18
                                        : 17,
                                    fontFamily: FontFamily.gilroyBold,
                                    color: notifire.getwhiteblackcolor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "assets/images/Location.png",
                                      height: 22,
                                      width: 22,
                                      color: Color(0xff3D5BF6),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.agencyAddress}",
                                        style: TextStyle(
                                          fontFamily:
                                          FontFamily.gilroyMedium,
                                          color: notifire.getgreycolor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // ====== MAP ======
                                SizedBox(height: 10),
                                Container(
                                  height: mapHeight,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(
                                      top: 6, bottom: 6),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: osm.LatLng(
                                          double.tryParse(
                                                  homePageController
                                                          .homecareAgencyDetailsInfo
                                                          ?.homecareAgencyDetails!
                                                          .latitude ??
                                                      "") ??
                                              0,
                                          double.tryParse(
                                                  homePageController
                                                          .homecareAgencyDetailsInfo
                                                          ?.homecareAgencyDetails!
                                                          .longitude ??
                                                      "") ??
                                              0,
                                        ),
                                        initialZoom: 14,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName:
                                              'com.caresoko.app',
                                        ),
                                        MarkerLayer(
                                          markers: _markers
                                              .map(
                                                (p) => Marker(
                                                  point: p,
                                                  width: 40,
                                                  height: 40,
                                                  child: const Icon(
                                                    Icons.location_on,
                                                    color: Colors.red,
                                                    size: 34,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: notifire.getblackwhitecolor,
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

                                // ====== About This Home ======
                                SizedBox(height: 15),
                                _sectionTitle("About This Home".tr),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                    child: ReadMoreText(
                                      (homePageController
                                          .homecareAgencyDetailsInfo?.homecareAgencyDetails!.about ??
                                          "")
                                          .replaceAll(r'\\n', '\n') // handles double-escaped \\n
                                          .replaceAll(r'\n', '\n')  // handles single-escaped \n
                                          .replaceAll(RegExp(r'\\+'), '') // removes any extra backslashes
                                          .trim(),
                                      trimLines: 4,
                                      colorClickableText: blueColor,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'Read more'.tr,
                                      trimExpandedText: 'Show less'.tr,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: FontFamily.gilroyMedium,
                                        height: 1.5,
                                      ),
                                    )

                                  // child: ReadMoreText(
                                  //   homePageController
                                  //       .homecareAgencyDetailsInfo
                                  //       ?.homecareAgencyDetails!
                                  //       .about ??
                                  //       "",
                                  //   trimLines: 4,
                                  //   colorClickableText: blueColor,
                                  //   trimMode: TrimMode.Line,
                                  //   trimCollapsedText: 'Read more'.tr,
                                  //   trimExpandedText: 'Show less'.tr,
                                  //   style: TextStyle(
                                  //     color: Colors.grey,
                                  //     fontFamily:
                                  //     FontFamily.gilroyMedium,
                                  //   ),
                                  // ),
                                ),

                                // ====== Services ======
                                SizedBox(height: 10),
                                _sectionTitle("Services".tr),
                                SizedBox(height: 15),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .activitiesOfDailyLiving ==
                                    1)
                                  _checkTile(
                                      "Activies of Daily Living (ADL)"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .mealPreparation ==
                                    1)
                                  _checkTile(
                                      "Meal planning & preparation"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .mobilityAssistance ==
                                    1)
                                  _checkTile("Mobility assistance"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .lightHouseKeeping ==
                                    1)
                                  _checkTile("Light housekeeping"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .transportation ==
                                    1)
                                  _checkTile(
                                      "Transportation to appointments & errands"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .laundry ==
                                    1)
                                  _checkTile("Laundry"),

                                // ====== Specialized Services ======
                                SizedBox(height: 15),
                                _sectionTitle("Specialized Services".tr),
                                SizedBox(height: 15),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .memoryCare ==
                                    1)
                                  _checkTile(
                                      "Memory care: caters to individuals with Alzheimer’s or dementia"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .palliativeCare ==
                                    1)
                                  _checkTile(
                                      "Palliative care: offers care focused on comfort for clients with serious illnesses"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .chronicConditionManagement ==
                                    1)
                                  _checkTile(
                                      "Chronic condition management: provides care for clients with ongoing health conditions"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .postHospitalizationCare ==
                                    1)
                                  _checkTile(
                                      "Provides care for clients recovering after hospital stays"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .respiteCare ==
                                    1)
                                  _checkTile(
                                      "Respite care: offers temporary relief for family caregivers"),

                                // ====== Why They Stand Out ======
                                _sectionTitle("Why They Stand Out".tr),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                  child: ReadMoreText(
                                    homePageController
                                        .homecareAgencyDetailsInfo
                                        ?.homecareAgencyDetails!
                                        .whyTheyStandOut ??
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

                                // ====== Accreditations / Certifications / Languages (adaptive) ======
                                _buildAdaptiveListSection(
                                  title: "Accreditations".tr,
                                  items: accreditations,
                                  notifire: notifire,
                                ),
                                _buildAdaptiveListSection(
                                  title: "Caregiver Certifications".tr,
                                  items: certifications,
                                  notifire: notifire,
                                ),
                                _buildAdaptiveListSection(
                                  title:
                                  "Specialized Caregiver Certifications"
                                      .tr,
                                  items: specializedCertifications,
                                  notifire: notifire,
                                ),
                                _buildAdaptiveListSection(
                                  title: "Professional Memberships".tr,
                                  items: professionalMemberships,
                                  notifire: notifire,
                                ),

                                // ====== Screening & Safety ======
                                SizedBox(height: 15),
                                _sectionTitle("Screening & Safety".tr),
                                SizedBox(height: 15),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .backgroundChecks ==
                                    1)
                                  _checkTile(
                                      "Performs background checks on staff to ensure client safety"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .drugTesting ==
                                    1)
                                  _checkTile(
                                      "Conducts drug tests for employees"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .referenceVerification ==
                                    1)
                                  _checkTile(
                                      "Verifies references for caregivers"),

                                // ====== Pricing ======
                                SizedBox(height: 10),
                                _sectionTitle("Pricing".tr),
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 15),
                                  child: ReadMoreText(
                                    (() {
                                      final details = homePageController
                                          .homecareAgencyDetailsInfo
                                          ?.homecareAgencyDetails;
                                      if ((details?.pricingReady ?? 0) ==
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

                                // ====== Payment Options ======
                                SizedBox(height: 15),
                                _sectionTitle("Payment Options".tr),
                                SizedBox(height: 15),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .insurance ==
                                    1)
                                  _checkTile("Accepts insurance"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .privatePay ==
                                    1)
                                  _checkTile(
                                      "Accepts private payments from clients"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .medicaid ==
                                    1)
                                  _checkTile("Accepts Medicaid clients"),

                                // ====== Availability ======
                                SizedBox(height: 15),
                                _sectionTitle("Availability".tr),
                                SizedBox(height: 15),
                                ListTile(
                                  leading: _checkLeading(),
                                  title: Text(
                                    "Staff available: ${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.staffAvailability}",
                                    style: TextStyle(
                                      fontFamily:
                                      FontFamily.gilroyMedium,
                                      fontSize: 16,
                                      color:
                                      notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .weekendCoverage ==
                                    1)
                                  _checkTile("Available on weekends"),
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .holidayCoverage ==
                                    1)
                                  _checkTile("Available on holidays"),

                                _buildAdaptiveListSection(
                                  title: "Languages Spoken".tr,
                                  items: languages,
                                  notifire: notifire,
                                ),

                                // ====== Mission / Vision ======
                                _sectionTitle("Agency Mission".tr),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                  child: ReadMoreText(
                                    homePageController
                                        .homecareAgencyDetailsInfo
                                        ?.homecareAgencyDetails!
                                        .mission ??
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
                                _sectionTitle("Agency Vision".tr),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, top: 10),
                                  child: ReadMoreText(
                                    homePageController
                                        .homecareAgencyDetailsInfo
                                        ?.homecareAgencyDetails!
                                        .vision ??
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
                                SizedBox(height: 10),

                                // ====== Website ======
                                if (homePageController
                                    .homecareAgencyDetailsInfo
                                    ?.homecareAgencyDetails!
                                    .website !=
                                    "None") ...[
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 10),
                                      child: Text(
                                        "Agency Website".tr,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontFamily:
                                          FontFamily.gilroyBold,
                                          color: notifire
                                              .getwhiteblackcolor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 10),
                                      child: ReadMoreText(
                                        homePageController
                                            .homecareAgencyDetailsInfo
                                            ?.homecareAgencyDetails!
                                            .website ??
                                            "",
                                        trimLines: 10,
                                        colorClickableText: blueColor,
                                        trimMode: TrimMode.Line,
                                        trimCollapsedText:
                                        'Read more'.tr,
                                        trimExpandedText:
                                        'Show less'.tr,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontFamily:
                                          FontFamily.gilroyMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // ====== Gallery -> Adaptive GRID ======
                                if (homePageController
                                    .homecareAgencyDetailsInfo!
                                    .gallery!
                                    .isNotEmpty) ...[
                                  gallaryAndSeeAllWidget(
                                      "Gallery".tr, "See All".tr),
                                  SizedBox(height: 8),
                                  LayoutBuilder(
                                    builder: (context, c2) {
                                      final bool wide =
                                          c2.maxWidth >= 600;
                                      final int cross = Responsive
                                          .isDesktop(constraints)
                                          ? 5
                                          : wide
                                          ? 4
                                          : 3;
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                        NeverScrollableScrollPhysics(),
                                        itemCount: homePageController
                                            .homecareAgencyDetailsInfo
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
                                              .homecareAgencyDetailsInfo
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

                                // ====== Reviews ======
                                if (homePageController
                                    .homecareAgencyDetailsInfo!
                                    .reviewlist!
                                    .isNotEmpty) ...[
                                  reviewWidget(
                                    "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.rate ?? ""}(${homePageController.homecareAgencyDetailsInfo?.totalReview} ${"reviews".tr})",
                                    "See All".tr,
                                    Icon(Icons.star, color: yelloColor),
                                  ),
                                  ListView.builder(
                                    itemCount: homePageController
                                        .homecareAgencyDetailsInfo
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
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  "${Config.imageUrl}${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userImg ?? ""}",
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userTitle ?? ""}",
                                            style: TextStyle(
                                              color: notifire
                                                  .getwhiteblackcolor,
                                              fontFamily: FontFamily
                                                  .gilroyBold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userDesc ?? ""}",
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
                                                  "${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userRate ?? ""}",
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
                        // ====== Bottom Booking Bar (FIXED, RESPONSIVE) ======
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: notifire.getblackwhitecolor,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final bool isNarrow = c.maxWidth < 520; // phone portrait etc.

                                    final licenseBlock = Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 8, bottom: 10, right: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                              Expanded(
                                                child: Text(
                                                  "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.licenseNumber ?? ""}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: const Color(0xFF4772ff),
                                                    fontFamily: FontFamily.gilroyBold,
                                                    fontSize: Responsive.isDesktop(c) ? 24 : 22,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );

                                    final bookButton = GetBuilder<BookrealEstateController>(
                                      builder: (context) {
                                        return SizedBox(
                                          // Constrain button so it doesn't overflow in a Row
                                          width: isNarrow ? double.infinity : 260,
                                          height: 56,
                                          child: GestButton(
                                            Width: double.infinity, // <-- let the SizedBox drive width
                                            height: 56,
                                            buttoncolor: const Color(0xFF4772ff),
                                            margin: EdgeInsets.only(
                                              top: 10,
                                              right: isNarrow ? 10 : 10,
                                              left: isNarrow ? 10 : 0,
                                              bottom: 10,
                                            ),
                                            buttontext: "Book Now".tr,
                                            onclick: _bookNow,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              color: WhiteColor,
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    // Row on wide screens, Column on narrow screens
                                    if (isNarrow) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          licenseBlock,
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: bookButton,
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          children: [
                                            Expanded(child: licenseBlock),
                                            const SizedBox(width: 12),
                                            bookButton,
                                          ],
                                        ),
                                      );
                                    }
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
            : Center(child: CircularProgressIndicator()),
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

  Widget _buildAdaptiveListSection({
    required String title,
    required List<String> items,
    required ColorNotifire notifire,
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
                childAspectRatio: 7,
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
                pId: homePageController.homecareAgencyDetailsInfo
                    ?.homecareAgencyDetails!
                    .id);
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
              homePageController.homecareAgencyDetailsInfo?.reviewlist
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


// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_key_in_widget_constructors, must_be_immutable, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, unused_field, unused_element, avoid_print, unrelated_type_equality_checks, unnecessary_string_interpolations, avoid_unnecessary_containers, prefer_adjacent_string_concatenation
// import 'dart:ui' as ui;
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
// import 'package:gotocarefinder/controller/gallery_controller.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:readmore/readmore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
//
// class ViewHomecareDataScreen extends StatefulWidget {
//   @override
//   State<ViewHomecareDataScreen> createState() => _ViewHomecareDataScreenState();
// }
//
// class _ViewHomecareDataScreenState extends State<ViewHomecareDataScreen> {
//   late ColorNotifire notifire;
//   HomePageController homePageController = Get.find();
//   ReviewSummaryController reviewSummaryController = Get.find();
//   BookrealEstateController bookrealEstateController = Get.find();
//   GalleryController galleryController = Get.find();
//
//   //CalendarController calendarController = Get.put(CalendarController());
//
//   int selectIndex = 0;
//
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
//   Future<dynamic> isMeassageAvalable(String uid) async {
//     CollectionReference collectionReference =
//         FirebaseFirestore.instance.collection('users');
//     collectionReference.doc(uid).get().then((value) {
//       var fields;
//       fields = value.data();
//
//       setState(() {
//         useremail = fields["name"];
//         fmctoken = fields["token"];
//       });
//     });
//   }
//
//   String latitude = "";
//   String longitude = "";
//
//   late GoogleMapController mapController;
//   LatLng showLocation = LatLng(27.7089427, 85.3086209);
//
//   final List<Marker> _markers = <Marker>[];
//
//   Future<Uint8List> getImages(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetHeight: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }
//
//   String useremail = '';
//   String fmctoken = '';
//
//   /* SCROLLING FUNCTIONALITY STARTS HERE */
//
//   late PageController _pageController;
//   late Timer _autoScrollTimer;
//   int _currentIndex = 0;
//   int _totalImages = 0;
//   final Duration _scrollDuration = Duration(seconds: 5); // Customize speed
//
//   List<String>? accreditations = [];
//   List<String>? certifications = [];
//   List<String>? professionalMemberships = [];
//   List<String>? specializedCertifications = [];
//   List<String>? languages = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadData();
//     isMeassageAvalable(
//         "${homePageController.homecareAgencyDetailsInfo!.homecareAgencyDetails!.userId}");
//     _totalImages = homePageController
//             .homecareAgencyDetailsInfo?.homecareAgencyDetails?.image?.length ??
//         0;
//     _pageController = PageController();
//     _startAutoScroll();
//   }
//
//   void _startAutoScroll() {
//     _autoScrollTimer = Timer.periodic(_scrollDuration, (timer) {
//       if (_pageController.hasClients) {
//         _currentIndex = (_currentIndex + 1) % _totalImages;
//         _pageController.animateToPage(
//           _currentIndex,
//           duration: Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _autoScrollTimer.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   /*SCROLLING FUNCTIONALITY ENDS HERE */
//
//   loadData() async {
//     final Uint8List markIcons =
//         await getImages("assets/images/MapPin.png", 100);
//
//     _markers.add(
//       Marker(
//         markerId: MarkerId(showLocation.toString()),
//         icon: BitmapDescriptor.fromBytes(markIcons),
//         position: LatLng(
//           double.parse(homePageController
//                   .homecareAgencyDetailsInfo?.homecareAgencyDetails!.latitude ??
//               ""),
//           double.parse(homePageController.homecareAgencyDetailsInfo!
//                   .homecareAgencyDetails!.longitude ??
//               ""),
//         ),
//         infoWindow: InfoWindow(),
//       ),
//     );
//
//     accreditations = homePageController
//         .homecareAgencyDetailsInfo?.homecareAgencyDetails!.accreditations!
//         .split(',');
//
//     certifications = homePageController
//         .homecareAgencyDetailsInfo?.homecareAgencyDetails!.certifications!
//         .split(',');
//
//     professionalMemberships = homePageController
//         .homecareAgencyDetailsInfo?.homecareAgencyDetails!.memberships!
//         .split(',');
//
//     specializedCertifications = homePageController.homecareAgencyDetailsInfo
//         ?.homecareAgencyDetails!.specializedCertifications!
//         .split(',');
//
//     languages = homePageController
//         .homecareAgencyDetailsInfo?.homecareAgencyDetails!.languages!
//         .split(',');
//
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     /*try {} catch (e, stackTrace) {
//       debugPrintStack(label: "Error caught", stackTrace: stackTrace);
//     }*/
//     return GetBuilder<HomePageController>(builder: (context) {
//       return Scaffold(
//         backgroundColor: notifire.getbgcolor,
//         body: homePageController.isProperty
//             ? NestedScrollView(
//                 headerSliverBuilder: (context, innerBoxIsScrolled) {
//                   return [
//                     SliverAppBar(
//                       expandedHeight: 300,
//                       floating: false,
//                       pinned: true,
//                       backgroundColor: notifire.getbgcolor,
//                       leading: InkWell(
//                         onTap: () {
//                           Get.back();
//                         },
//                         child: Container(
//                           height: 50,
//                           width: 50,
//                           alignment: Alignment.center,
//                           padding: EdgeInsets.all(17),
//                           child: Image.asset(
//                             "assets/images/Arrow - Left.png",
//                             color: blueColor,
//                           ),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                       actions: [
//                         GetBuilder<HomePageController>(builder: (context) {
//                           return InkWell(
//                             onTap: () {
//                               if (getData.read("UserLogin") != null) {
//                                 homePageController.addFavouriteList(
//                                   pid: homePageController
//                                       .homecareAgencyDetailsInfo!
//                                       .homecareAgencyDetails!
//                                       .id,
//                                   propertyType: homePageController
//                                       .homecareAgencyDetailsInfo
//                                       ?.homecareAgencyDetails!
//                                       .propertyType,
//                                 );
//                               }
//                             },
//                             child: homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.isFavourite ==
//                                     1
//                                 ? Container(
//                                     height: 50,
//                                     width: 50,
//                                     alignment: Alignment.center,
//                                     padding: EdgeInsets.all(14),
//                                     child: Image.asset(
//                                       "assets/images/Fev-Bold.png",
//                                       color: blueColor,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                     ),
//                                   )
//                                 : Container(
//                                     height: 50,
//                                     width: 50,
//                                     alignment: Alignment.center,
//                                     padding: EdgeInsets.all(14),
//                                     child: Image.asset(
//                                       "assets/images/favorite.png",
//                                       color: blueColor,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                           );
//                         }),
//                         SizedBox(
//                           width: 10,
//                         ),
//                       ],
//                       flexibleSpace: FlexibleSpaceBar(
//                         background: Stack(
//                           children: [
//                             SizedBox(
//                               height: 470,
//                               child: PageView.builder(
//                                 controller: _pageController,
//                                 itemCount: homePageController
//                                     .homecareAgencyDetailsInfo
//                                     ?.homecareAgencyDetails!
//                                     .image!
//                                     .length,
//                                 physics: BouncingScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   return Container(
//                                     child: FadeInImage.assetNetwork(
//                                       fadeInCurve: Curves.easeInCirc,
//                                       placeholder:
//                                           "assets/images/ezgif.com-crop.gif",
//                                       height: 470,
//                                       width: Get.size.width,
//                                       imageErrorBuilder:
//                                           (context, error, stackTrace) {
//                                         return Center(
//                                           child: Image.asset(
//                                             "assets/images/emty.gif",
//                                             fit: BoxFit.cover,
//                                             height: Get.height,
//                                           ),
//                                         );
//                                       },
//                                       image:
//                                           "${Config.imageUrl}${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.image![index].image ?? ""}",
//                                       fit: BoxFit.cover,
//                                     ),
//                                   );
//                                 },
//                                 onPageChanged: (value) {
//                                   setState(() {
//                                     selectIndex = value;
//                                   });
//                                 },
//                               ),
//                             ),
//                             homePageController.homecareAgencyDetailsInfo!
//                                         .homecareAgencyDetails!.image!.length ==
//                                     1
//                                 ? SizedBox()
//                                 : Positioned(
//                                     bottom: 0,
//                                     child: SizedBox(
//                                       height: 25,
//                                       width: Get.size.width,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           ...List.generate(
//                                               homePageController
//                                                   .homecareAgencyDetailsInfo!
//                                                   .homecareAgencyDetails!
//                                                   .image!
//                                                   .length, (index) {
//                                             return IndicatorViewPage(
//                                               isActive: selectIndex == index
//                                                   ? true
//                                                   : false,
//                                             );
//                                           }),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .image![selectIndex]
//                                         .isPanorama ==
//                                     1
//                                 ? Positioned(
//                                     bottom: 10,
//                                     right: 10,
//                                     child: InkWell(
//                                       onTap: () {
//                                         Get.toNamed(Routes.imageViewerSreen,
//                                             arguments: {
//                                               "img": homePageController
//                                                   .homecareAgencyDetailsInfo
//                                                   ?.homecareAgencyDetails!
//                                                   .image![selectIndex]
//                                                   .image,
//                                             });
//                                       },
//                                       child: Container(
//                                         height: 30,
//                                         width: 70,
//                                         padding: EdgeInsets.all(4),
//                                         child: Image.asset(
//                                             "assets/images/360.png"),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           color: BlackColor.withOpacity(0.5),
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ];
//                 },
//                 body: Stack(
//                   children: [
//                     SizedBox(
//                       height: Get.size.height,
//                       width: Get.size.width,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.name ??
//                                     "",
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 15,
//                                 ),
//                                 Container(
//                                   height: 25,
//                                   padding: EdgeInsets.all(5),
//                                   child: Text(
//                                     homePageController
//                                             .homecareAgencyDetailsInfo
//                                             ?.homecareAgencyDetails!
//                                             .propertyTypeTitle ??
//                                         "",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 12,
//                                       color: blueColor,
//                                     ),
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFeef4ff),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Image.asset(
//                                   "assets/images/verified_user.png",
//                                   height: 20,
//                                   width: 20,
//                                 ),
//                                 SizedBox(
//                                   width: 7,
//                                 ),
//                                 Text(
//                                   "Verified".tr,
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 15,
//                                     fontFamily: FontFamily.gilroyMedium,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 10,
//                                 ),
//                                 Image.asset(
//                                   "assets/images/Rating.png",
//                                   height: 20,
//                                   width: 20,
//                                 ),
//                                 SizedBox(
//                                   width: 7,
//                                 ),
//                                 Text(
//                                   "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.rate ?? ""}",
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 15,
//                                     fontFamily: FontFamily.gilroyMedium,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 15,
//                                 ),
//                               ],
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Location".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 15,
//                                 ),
//                                 Image.asset(
//                                   "assets/images/Location.png",
//                                   height: 25,
//                                   width: 25,
//                                   fit: BoxFit.cover,
//                                   color: Color(0xff3D5BF6),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 50,
//                                   child: Text(
//                                     "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.agencyAddress}",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       color: notifire.getgreycolor,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               height: 200,
//                               width: Get.size.width,
//                               margin: EdgeInsets.all(10),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(15),
//                                 child: GoogleMap(
//                                   initialCameraPosition: CameraPosition(
//                                     target: LatLng(
//                                       double.parse(homePageController
//                                               .homecareAgencyDetailsInfo
//                                               ?.homecareAgencyDetails!
//                                               .latitude ??
//                                           ""),
//                                       double.parse(homePageController
//                                               .homecareAgencyDetailsInfo
//                                               ?.homecareAgencyDetails!
//                                               .longitude ??
//                                           ""),
//                                     ),
//                                     zoom: 30.0,
//                                   ),
//                                   markers: Set<Marker>.of(_markers),
//                                   mapType: MapType.normal,
//                                   myLocationEnabled: true,
//                                   compassEnabled: true,
//                                   zoomGesturesEnabled: true,
//                                   tiltGesturesEnabled: true,
//                                   zoomControlsEnabled: true,
//                                   onMapCreated: (controller) {
//                                     setState(() {
//                                       mapController = controller;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               decoration: BoxDecoration(
//                                 color: notifire.getblackwhitecolor,
//                                 borderRadius: BorderRadius.circular(15),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     offset: const Offset(
//                                       0.5,
//                                       0.5,
//                                     ),
//                                     blurRadius: 2,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "About This Home".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: ReadMoreText(
//                                 homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.about ??
//                                     "",
//                                 trimLines: 4,
//                                 colorClickableText: blueColor,
//                                 trimMode: TrimMode.Line,
//                                 trimCollapsedText: 'Read more'.tr,
//                                 trimExpandedText: 'Show less'.tr,
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontFamily: FontFamily.gilroyMedium,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Services".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .activitiesOfDailyLiving ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Activies of Daily Living (ADL)",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .mealPreparation ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Meal planning & preparation",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .mobilityAssistance ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Mobility assistance",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .lightHouseKeeping ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Light housekeeping",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .transportation ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Transportation to appointments & errands",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.laundry ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Laundry",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Specialized Services".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.memoryCare ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Memory care: caters to individuals with Alzheimer’s or dementia",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .palliativeCare ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Palliative care: offers care focused on comfort for clients with serious illnesses",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .chronicConditionManagement ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Chronic condition management: provides care for clients with ongoing health conditions",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .postHospitalizationCare ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Provides care for clients recovering after hospital stays",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.respiteCare ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Respite care: offers temporary relief for family caregivers",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Why They Stand Out".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: ReadMoreText(
//                                 homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .whyTheyStandOut ??
//                                     "",
//                                 trimLines: 4,
//                                 colorClickableText: blueColor,
//                                 trimMode: TrimMode.Line,
//                                 trimCollapsedText: 'Read more'.tr,
//                                 trimExpandedText: 'Show less'.tr,
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontFamily: FontFamily.gilroyMedium,
//                                 ),
//                               ),
//                             ),
//                             accreditations!.isNotEmpty
//                                 ? SizedBox(
//                                     height: 15,
//                                   )
//                                 : SizedBox(),
//                             accreditations!.isNotEmpty
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15, top: 10),
//                                     child: Text(
//                                       "Accreditations".tr,
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             accreditations!.isNotEmpty
//                                 ? ListView.builder(
//                                     physics: NeverScrollableScrollPhysics(),
//                                     padding: EdgeInsets.zero,
//                                     shrinkWrap: true,
//                                     itemCount: accreditations!.length,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         leading: Container(
//                                           height: 40,
//                                           width: 40,
//                                           alignment: Alignment.center,
//                                           child: Image.asset(
//                                             "assets/images/check.png",
//                                             height: 20,
//                                             width: 20,
//                                             color: blueColor,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color(0xFFeef4ff),
//                                           ),
//                                         ),
//                                         title: Text(
//                                           accreditations![index],
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 16,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       );
//                                     })
//                                 : SizedBox(),
//                             certifications!.isNotEmpty
//                                 ? SizedBox(
//                                     height: 15,
//                                   )
//                                 : SizedBox(),
//                             certifications!.isNotEmpty
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15, top: 10),
//                                     child: Text(
//                                       "Caregiver Certifications".tr,
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             certifications!.isNotEmpty
//                                 ? ListView.builder(
//                                     physics: NeverScrollableScrollPhysics(),
//                                     padding: EdgeInsets.zero,
//                                     shrinkWrap: true,
//                                     itemCount: certifications!.length,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         leading: Container(
//                                           height: 40,
//                                           width: 40,
//                                           alignment: Alignment.center,
//                                           child: Image.asset(
//                                             "assets/images/check.png",
//                                             height: 20,
//                                             width: 20,
//                                             color: blueColor,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color(0xFFeef4ff),
//                                           ),
//                                         ),
//                                         title: Text(
//                                           certifications![index],
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 16,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       );
//                                     })
//                                 : SizedBox(),
//                             specializedCertifications!.isNotEmpty
//                                 ? SizedBox(
//                                     height: 15,
//                                   )
//                                 : SizedBox(),
//                             specializedCertifications!.isNotEmpty
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15, top: 10),
//                                     child: Text(
//                                       "Specialized Caregiver Certifications".tr,
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             specializedCertifications!.isNotEmpty
//                                 ? ListView.builder(
//                                     physics: NeverScrollableScrollPhysics(),
//                                     padding: EdgeInsets.zero,
//                                     shrinkWrap: true,
//                                     itemCount:
//                                         specializedCertifications!.length,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         leading: Container(
//                                           height: 40,
//                                           width: 40,
//                                           alignment: Alignment.center,
//                                           child: Image.asset(
//                                             "assets/images/check.png",
//                                             height: 20,
//                                             width: 20,
//                                             color: blueColor,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color(0xFFeef4ff),
//                                           ),
//                                         ),
//                                         title: Text(
//                                           specializedCertifications![index],
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 16,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       );
//                                     })
//                                 : SizedBox(),
//                             professionalMemberships!.isNotEmpty
//                                 ? SizedBox(
//                                     height: 15,
//                                   )
//                                 : SizedBox(),
//                             professionalMemberships!.isNotEmpty
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15, top: 10),
//                                     child: Text(
//                                       "Professional Memberships".tr,
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             professionalMemberships!.isNotEmpty
//                                 ? ListView.builder(
//                                     physics: NeverScrollableScrollPhysics(),
//                                     padding: EdgeInsets.zero,
//                                     shrinkWrap: true,
//                                     itemCount: professionalMemberships!.length,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         leading: Container(
//                                           height: 40,
//                                           width: 40,
//                                           alignment: Alignment.center,
//                                           child: Image.asset(
//                                             "assets/images/check.png",
//                                             height: 20,
//                                             width: 20,
//                                             color: blueColor,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color(0xFFeef4ff),
//                                           ),
//                                         ),
//                                         title: Text(
//                                           professionalMemberships![index],
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 16,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       );
//                                     })
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Screening & Safety".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .backgroundChecks ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Performs background checks on staff to ensure client safety",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.drugTesting ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Conducts drug tests for employees",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .referenceVerification ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Verifies references for caregivers",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Pricing".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15),
//                               child: ReadMoreText(
//                                 (() {
//                                   if (context
//                                           .homecareAgencyDetailsInfo
//                                           ?.homecareAgencyDetails!
//                                           .pricingReady ==
//                                       1) {
//                                     return "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.pricing}";
//                                   } else {
//                                     return "Pricing dependent on care plan assessment";
//                                   }
//                                 }()),
//                                 trimLines: 4,
//                                 colorClickableText: blueColor,
//                                 trimMode: TrimMode.Line,
//                                 trimCollapsedText: 'Read more'.tr,
//                                 trimExpandedText: 'Show less'.tr,
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontFamily: FontFamily.gilroyMedium,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Payment Options".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.insurance ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Accepts insurance",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.privatePay ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Accepts private payments from clients",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.medicaid ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Accepts Medicaid clients",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Availability".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             ListTile(
//                               leading: Container(
//                                 height: 40,
//                                 width: 40,
//                                 alignment: Alignment.center,
//                                 child: Image.asset(
//                                   "assets/images/check.png",
//                                   height: 20,
//                                   width: 20,
//                                   color: blueColor,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: Color(0xFFeef4ff),
//                                 ),
//                               ),
//                               title: Text(
//                                 "Staff available: ${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.staffAvailability}",
//                                 style: TextStyle(
//                                   fontFamily: FontFamily.gilroyMedium,
//                                   fontSize: 16,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .weekendCoverage ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Available on weekends",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!
//                                         .holidayCoverage ==
//                                     1
//                                 ? ListTile(
//                                     leading: Container(
//                                       height: 40,
//                                       width: 40,
//                                       alignment: Alignment.center,
//                                       child: Image.asset(
//                                         "assets/images/check.png",
//                                         height: 20,
//                                         width: 20,
//                                         color: blueColor,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Color(0xFFeef4ff),
//                                       ),
//                                     ),
//                                     title: Text(
//                                       "Available on holidays",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             languages!.isNotEmpty
//                                 ? SizedBox(
//                                     height: 15,
//                                   )
//                                 : SizedBox(),
//                             languages!.isNotEmpty
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15, top: 10),
//                                     child: Text(
//                                       "Languages Spoken".tr,
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             languages!.isNotEmpty
//                                 ? ListView.builder(
//                                     physics: NeverScrollableScrollPhysics(),
//                                     padding: EdgeInsets.zero,
//                                     shrinkWrap: true,
//                                     itemCount: languages!.length,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         leading: Container(
//                                           height: 40,
//                                           width: 40,
//                                           alignment: Alignment.center,
//                                           child: Image.asset(
//                                             "assets/images/check.png",
//                                             height: 20,
//                                             width: 20,
//                                             color: blueColor,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color(0xFFeef4ff),
//                                           ),
//                                         ),
//                                         title: Text(
//                                           languages![index],
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 16,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       );
//                                     })
//                                 : SizedBox(),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Agency Mission".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: ReadMoreText(
//                                 homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.mission ??
//                                     "",
//                                 trimLines: 4,
//                                 colorClickableText: blueColor,
//                                 trimMode: TrimMode.Line,
//                                 trimCollapsedText: 'Read more'.tr,
//                                 trimExpandedText: 'Show less'.tr,
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontFamily: FontFamily.gilroyMedium,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: Text(
//                                 "Agency Vision".tr,
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15, top: 10),
//                               child: ReadMoreText(
//                                 homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.vision ??
//                                     "",
//                                 trimLines: 4,
//                                 colorClickableText: blueColor,
//                                 trimMode: TrimMode.Line,
//                                 trimCollapsedText: 'Read more'.tr,
//                                 trimExpandedText: 'Show less'.tr,
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontFamily: FontFamily.gilroyMedium,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.website !=
//                                     "None"
//                                 ? Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 15, top: 10),
//                                       child: Text(
//                                         "Agency Website".tr,
//                                         style: TextStyle(
//                                           fontSize: 17,
//                                           fontFamily: FontFamily.gilroyBold,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo
//                                         ?.homecareAgencyDetails!.website !=
//                                     "None"
//                                 ? Align(
//                                     alignment: Alignment.centerLeft,
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 15, top: 10),
//                                       child: ReadMoreText(
//                                         homePageController
//                                                 .homecareAgencyDetailsInfo
//                                                 ?.homecareAgencyDetails!
//                                                 .website ??
//                                             "",
//                                         trimLines: 10,
//                                         colorClickableText: blueColor,
//                                         trimMode: TrimMode.Line,
//                                         trimCollapsedText: 'Read more'.tr,
//                                         trimExpandedText: 'Show less'.tr,
//                                         style: TextStyle(
//                                           color: Colors.grey,
//                                           fontFamily: FontFamily.gilroyMedium,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo!
//                                     .gallery!.isNotEmpty
//                                 ? Column(
//                                     children: [
//                                       gallaryAndSeeAllWidget(
//                                           "Gallery".tr, "See All".tr),
//                                       Container(
//                                         height: 110,
//                                         alignment: Alignment.center,
//                                         margin:
//                                             EdgeInsets.only(left: 15, top: 10),
//                                         child: ListView.builder(
//                                           itemCount: homePageController
//                                               .homecareAgencyDetailsInfo
//                                               ?.gallery!
//                                               .length,
//                                           scrollDirection: Axis.horizontal,
//                                           physics:
//                                               NeverScrollableScrollPhysics(),
//                                           itemBuilder: (context, index) {
//                                             return Container(
//                                               height: 110,
//                                               width: 110,
//                                               margin: EdgeInsets.all(5),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 child: FadeInImage.assetNetwork(
//                                                   fadeInCurve:
//                                                       Curves.easeInCirc,
//                                                   placeholder:
//                                                       "assets/images/ezgif.com-crop.gif",
//                                                   height: 110,
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
//                                                       "${Config.imageUrl}${homePageController.homecareAgencyDetailsInfo?.gallery![index]}",
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 color:
//                                                     notifire.getblackwhitecolor,
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo!
//                                     .reviewlist!.isNotEmpty
//                                 ? reviewWidget(
//                                     "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.rate ?? ""}(${homePageController.homecareAgencyDetailsInfo?.totalReview} ${"reviews".tr})",
//                                     "See All".tr,
//                                     Icon(
//                                       Icons.star,
//                                       color: yelloColor,
//                                     ),
//                                   )
//                                 : SizedBox(),
//                             homePageController.homecareAgencyDetailsInfo!
//                                     .reviewlist!.isNotEmpty
//                                 ? ListView.builder(
//                                     itemCount: homePageController
//                                         .homecareAgencyDetailsInfo
//                                         ?.reviewlist!
//                                         .length,
//                                     shrinkWrap: true,
//                                     padding: EdgeInsets.zero,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemBuilder: (context, index) {
//                                       return InkWell(
//                                         onTap: () {},
//                                         child: ListTile(
//                                           leading: Container(
//                                             height: 60,
//                                             width: 60,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               image: DecorationImage(
//                                                 image: NetworkImage(
//                                                   "${Config.imageUrl}${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userImg ?? ""}",
//                                                 ),
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           ),
//                                           title: Text(
//                                             "${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userTitle ?? ""}",
//                                             style: TextStyle(
//                                               color:
//                                                   notifire.getwhiteblackcolor,
//                                               fontFamily: FontFamily.gilroyBold,
//                                               fontSize: 17,
//                                             ),
//                                           ),
//                                           subtitle: Text(
//                                             "${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userDesc ?? ""}",
//                                             textAlign: TextAlign.start,
//                                             maxLines: 2,
//                                             style: TextStyle(
//                                               color: notifire.getgreycolor,
//                                               fontFamily:
//                                                   FontFamily.gilroyMedium,
//                                             ),
//                                           ),
//                                           trailing: Container(
//                                             height: 40,
//                                             width: 70,
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Icon(
//                                                   Icons.star,
//                                                   color: blueColor,
//                                                 ),
//                                                 SizedBox(
//                                                   width: 5,
//                                                 ),
//                                                 Text(
//                                                   "${homePageController.homecareAgencyDetailsInfo?.reviewlist![index].userRate ?? ""}",
//                                                   style: TextStyle(
//                                                     fontFamily:
//                                                         FontFamily.gilroyBold,
//                                                     color: blueColor,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                 color: blueColor,
//                                                 width: 2,
//                                               ),
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   )
//                                 : SizedBox(),
//                             SizedBox(
//                               height: 100,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       child: Container(
//                         height: 80,
//                         width: Get.size.width,
//                         color: notifire.getblackwhitecolor,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               flex: 1,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 10, left: 15),
//                                     child: Text(
//                                       "License No".tr,
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         color: greycolor,
//                                       ),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 10, left: 15),
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           "${homePageController.homecareAgencyDetailsInfo?.homecareAgencyDetails!.licenseNumber ?? ""}",
//                                           style: TextStyle(
//                                             color: Color(0xFF4772ff),
//                                             fontFamily: FontFamily.gilroyBold,
//                                             fontSize: 22,
//                                           ),
//                                         ),
//                                         /*homePageController
//                                                     .homecareAgencyDetailsInfo
//                                                     ?.homecareAgencyDetails!
//                                                     .buyorrent ==
//                                                 "1"
//                                             ? Text(
//                                                 "/night".tr,
//                                                 style: TextStyle(
//                                                   color: Colors.grey,
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                 ),
//                                               )
//                                             : Text(""),*/
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             GetBuilder<BookrealEstateController>(
//                                 builder: (context) {
//                               return StatefulBuilder(
//                                   builder: (context, setState) {
//                                 return Expanded(
//                                     child: /*homePageController.homecareAgencyDetailsInfo
//                                                 ?.homecareAgencyDetails!.buyorrent ==
//                                             "1"
//                                         ? */
//                                         GestButton(
//                                   Width: Get.size.width,
//                                   height: 70,
//                                   buttoncolor: Color(0xFF4772ff),
//                                   margin: EdgeInsets.only(
//                                       top: 10, right: 10, bottom: 10),
//                                   buttontext: "Book Now".tr,
//                                   onclick: _bookNow,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     color: WhiteColor,
//                                     fontSize: 16,
//                                   ),
//                                 )
//                                     /*: homePageController
//                                                     .homecareAgencyDetailsInfo
//                                                     ?.homecareAgencyDetails!
//                                                     .isEnquiry ==
//                                                 1
//                                             ? GestButton(
//                                                 Width: Get.size.width,
//                                                 height: 70,
//                                                 buttoncolor: RedColor,
//                                                 margin: EdgeInsets.only(
//                                                     top: 10,
//                                                     right: 10,
//                                                     bottom: 10),
//                                                 buttontext: "Contacted".tr,
//                                                 onclick: () {
//                                                   Fluttertoast.showToast(
//                                                     msg:
//                                                         "Enquiry Already Send!!"
//                                                             .tr,
//                                                     gravity:
//                                                         ToastGravity.BOTTOM,
//                                                     timeInSecForIosWeb: 1,
//                                                     backgroundColor: RedColor,
//                                                     textColor: Colors.white,
//                                                     fontSize: 14.0,
//                                                   );
//                                                 },
//                                                 style: TextStyle(
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   color: WhiteColor,
//                                                   fontSize: 16,
//                                                 ),
//                                               )
//                                             : GestButton(
//                                                 Width: Get.size.width,
//                                                 height: 70,
//                                                 buttoncolor: Color(0xFF4772ff),
//                                                 margin: EdgeInsets.only(
//                                                     top: 10,
//                                                     right: 10,
//                                                     bottom: 10),
//                                                 buttontext: "Inquiry".tr,
//                                                 onclick: () {
//                                                   if (getData
//                                                           .read("UserLogin") !=
//                                                       null) {
//                                                     homePageController
//                                                         .enquirySetApi(
//                                                       pId: homePageController
//                                                           .homecareAgencyDetailsInfo
//                                                           ?.homecareAgencyDetails!
//                                                           .id,
//                                                     );
//                                                     Get.back();
//                                                   } else {
//                                                     showToastMessage(
//                                                         "Please login and send enquery"
//                                                             .tr);
//                                                   }
//                                                 },
//                                                 style: TextStyle(
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   color: WhiteColor,
//                                                   fontSize: 16,
//                                                 ),
//                                               ),*/
//                                     );
//                               });
//                             })
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : Center(
//                 child: CircularProgressIndicator(),
//               ),
//       );
//     });
//   }
//
//   Widget gallaryAndSeeAllWidget(String name, String buttonName) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 15,
//         ),
//         Text(
//           name,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//         Spacer(),
//         TextButton(
//           onPressed: () {
//             galleryController.getGalleryData(
//                 pId: homePageController
//                     .homecareAgencyDetailsInfo?.homecareAgencyDetails!.id);
//             Get.toNamed(Routes.galleryScreen);
//           },
//           child: Text(
//             buttonName,
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//       ],
//     );
//   }
//
//   Widget reviewWidget(String name, String buttonName, Icon icon) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 15,
//         ),
//         icon,
//         Text(
//           name,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//         Spacer(),
//         TextButton(
//           onPressed: () {
//             Get.toNamed(Routes.reviewScreen, arguments: {
//               "list": homePageController.homecareAgencyDetailsInfo?.reviewlist
//             });
//           },
//           child: Text(
//             buttonName,
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//       ],
//     );
//   }
// }
//
// class IndicatorViewPage extends StatelessWidget {
//   final bool isActive;
//
//   const IndicatorViewPage({required this.isActive});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(3),
//       child: Container(
//         height: isActive ? 6 : 8,
//         width: isActive ? 30 : 8,
//         decoration: BoxDecoration(
//           color: isActive ? Colors.blue : Colors.grey,
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }
