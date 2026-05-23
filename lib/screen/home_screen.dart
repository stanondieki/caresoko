// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, sort_child_properties_last, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, unused_local_variable, no_leading_underscores_for_local_identifiers, avoid_print, prefer_interpolation_to_compose_strings, unrelated_type_equality_checks, use_build_context_synchronously
import 'dart:convert';
import 'package:badges/badges.dart' as bg;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/proparty/homepage_controller.dart';
import 'package:gotocarefinder/controller/search_controller.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------- NEW: Responsive helpers ----------------------
class R {
  static const desktop = 1200.0;
  static const tablet = 900.0;
  static const mobile = 600.0;

  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= desktop;
  static bool isTablet(BuildContext c) => MediaQuery.of(c).size.width >= tablet && MediaQuery.of(c).size.width < desktop;
  static bool isLargeMobile(BuildContext c) => MediaQuery.of(c).size.width >= mobile && MediaQuery.of(c).size.width < tablet;
  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < mobile;

  static double maxBodyWidth(BuildContext c) => isDesktop(c) ? 1200 : (isTablet(c) ? 1024 : MediaQuery.of(c).size.width);

  static int gridCount(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1500) return 5;
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    return 2; // mobile
  }

  static EdgeInsets screenPadding(BuildContext c) {
    if (isDesktop(c)) return EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    if (isTablet(c)) return EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    return EdgeInsets.symmetric(horizontal: 10, vertical: 8);
  }
}

var lat;
var long;
var first;
var currency;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomePageController homePageController = Get.find();
  PropartyHomePageController propartyHomePageController = Get.put(PropartyHomePageController());
  SignUpController signUpController = Get.find();
  bool isLoding = false;
  Position? currentLocation;
  String fevId = "";

  String userName = "";
  String? base64Image;

  String? networkimage;

  List facilities = [
    "assets/images/beds.svg",
    //"assets/images/bath.svg",
    "assets/images/sqft.svg",
  ];

  @override
  void initState() {
    // Ensure countryId is set before making API calls
    String countryId = getData.read("countryId") ?? "4";
    if (countryId.isEmpty) {
      countryId = "4";
      save("countryId", "4");
    }
    
    // Call both getHomeDataApi and getCatWiseData to ensure isLoading flags are set
    homePageController.getHomeDataApi(countryId: countryId);
    homePageController.getCatWiseData(countryId: countryId, cId: "0");
    propartyHomePageController.getHomeDataApi(countryId: countryId);
    propartyHomePageController.getCatWiseData(countryId: countryId, cId: "0");

    getdarkmodepreviousstate();
    if (getData.read("UserLogin") != null) {
      // isUserOnlie(getData.read("UserLogin")["id"], false);
    }

    lat == null || long == null ? getUserLocation() : getUserLocation1();
    super.initState();
    if (getData.read("UserLogin") != null) {
      setState(() {
        userName = getData.read("UserLogin")["name"] ?? "";
        networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
        if (getData.read("UserLogin")["pro_pic"] != "null") {
          networkimageconvert();
        }
      });
    }
  }

  networkimageconvert() {
    (() async {
      http.Response response = await http.get(Uri.parse(Config.imageUrl + networkimage.toString()));
      if (mounted) {
        setState(() {
          base64Image = const Base64Encoder().convert(response.bodyBytes);
        });
      }
    })();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future getUserLocation() async {
    setState(() {});
    var currentLocation = await locateUser();
    debugPrint('location: ${currentLocation.latitude}');
    lat = currentLocation.latitude;
    long = currentLocation.longitude;

    List<Placemark> addresses = await placemarkFromCoordinates(currentLocation.latitude, currentLocation.longitude);
    setState(() {
      if (getData.read("homeCall") == true) {
        homePageController.getHomeDataApi(countryId: getData.read("countryId"));
        propartyHomePageController.getHomeDataApi(countryId: getData.read("countryId"));
        save("homeCall", false);
      }
      first = addresses.first.name;
    });
  }

  Future getUserLocation1() async {
    isLoding = true;
    setState(() {});
    var currentLocation = await locateUser();
    debugPrint('location: ${currentLocation.latitude}');
  }

  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final padding = R.screenPadding(context);

    return PopScope(
      canPop: !kIsWeb, // NEW: allow browser back on web
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          if (!kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.android ||
               defaultTargetPlatform == TargetPlatform.iOS)) {
            // Exit app only on mobile
            print("Exiting app");
          }
        }
      },
      child: Scaffold(
        backgroundColor: notifire.getbgcolor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kIsWeb ? 80 : 70),
          child: _appBar(context),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            homePageController.getHomeDataApi(countryId: getData.read("countryId"));
            homePageController.getCatWiseData(cId: "0", countryId: getData.read("countryId"));
            propartyHomePageController.getHomeDataApi(countryId: getData.read("countryId"));
            propartyHomePageController.getCatWiseData(cId: "0", countryId: getData.read("countryId"));
          },
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
              child: Padding(
                padding: padding,
                child: GetBuilder<HomePageController>(builder: (_) {
                  if (!homePageController.isLoading || !propartyHomePageController.isLoading) {
                    return SizedBox(
                      height: Get.height,
                      width: Get.width,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Scrollbar(
                    thumbVisibility: kIsWeb,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          _searchWidget(),
                          SizedBox(height: 20),
                          _sectionHeader("Featured".tr, "See All".tr, onTap: () => Get.toNamed(Routes.featuredScreen)),
                          _listFeatured(context),
                          _sectionHeader("Recommended For You".tr, "See All".tr, onTap: () async {
                            await homePageController.getCatWiseData(cId: "0", countryId: getData.read("countryId"));
                            Get.toNamed(Routes.ourRecommendationScreen);
                          }),
                          _categoriesChips(
                            items: homePageController.homeDatatInfo?.homeData?.catlist ?? [],
                            currentIndex: homePageController.catCurrentIndex,
                            onSelected: (i, id) {
                              homePageController.changeCategoryIndex(i);
                              homePageController.getCatWiseData(cId: id, countryId: getData.read("countryId"));
                            },
                          ),
                          _catWiseGrid(context),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- UI Pieces (refactored & responsive) ----------------------
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: kIsWeb ? 80 : 100,
      automaticallyImplyLeading: false,
      backgroundColor: notifire.getbgcolor,
      elevation: 0,
      titleSpacing: R.isDesktop(context) ? 0 : null,
      title: Row(
        children: [
          (getData.read("UserLogin") != null && (networkimage ?? "").isNotEmpty)
              ? InkWell(
            onTap: () {},
            child: _avatar(NetworkImage("${Config.imageUrl}${networkimage ?? ""}")),
          )
              : InkWell(onTap: () {}, child: _avatar(AssetImage("assets/images/profile-default.png"))),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome 👋".tr, style: TextStyle(color: Color(0xFF757575), fontFamily: FontFamily.gilroyMedium, fontSize: 14)),
              Text(userName.isNotEmpty ? userName : "User".tr,
                  style: TextStyle(color: notifire.getwhiteblackcolor, fontFamily: FontFamily.gilroyBold, fontSize: 18)),
            ],
          )
        ],
      ),
      actions: [
        Tooltip(
          message: "Notifications",
          child: InkWell(
            onTap: () {
              if (getData.read("UserLogin") != null) {
                Get.toNamed(Routes.notificationScreen);
              } else {
                Get.toNamed(Routes.login);
              }
            },
            child: Center(
              child: bg.Badge(
                badgeStyle: bg.BadgeStyle(badgeColor: Colors.red, shape: bg.BadgeShape.circle),
                badgeContent: Text(''),
                badgeAnimation: bg.BadgeAnimation.slide(),
                position: bg.BadgePosition.topEnd(end: 14, top: 3),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: notifire.getblackwhitecolor,
                  child: Image.asset("assets/images/Notification.png", height: 25, width: 25, color: notifire.getwhiteblackcolor),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _avatar(ImageProvider provider) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: provider, fit: BoxFit.cover)),
    );
  }

  Widget _searchWidget() {
    SearchPropertyController searchController = Get.put(SearchPropertyController());
    return InkWell(
      onTap: () {
        searchController.search.text = "";
        Get.toNamed(Routes.homeSearchScreen);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: R.isMobile(context) ? 0 : 4),
        decoration: BoxDecoration(
          color: notifire.getInputFillColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notifire.getInputBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: notifire.getCardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            margin: EdgeInsets.only(left: 12),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: blueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.search_rounded, color: blueColor, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Search care facilities, homecare...".tr,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                color: notifire.getHintTextColor,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune_rounded, color: WhiteColor, size: 20),
          ),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String name, String buttonName, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
            letterSpacing: -0.3,
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                buttonName,
                style: TextStyle(
                  color: blueColor,
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: blueColor),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _categoriesChips({required List items, required int currentIndex, required void Function(int i, String? id) onSelected}) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = currentIndex == index;
          final item = items[index];
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => onSelected(index, item.id),
            label: Row(children: [
              FadeInImage.assetNetwork(
                height: 22,
                width: 22,
                image: "${Config.imageUrl}${item.img ?? ""}",
                placeholder: "assets/images/ezgif.com-crop.gif",
                imageErrorBuilder: (c, e, s) => SizedBox(height: 22, width: 22),
              ),
              SizedBox(width: 8),
              Text(
                item.title ?? "",
                style: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  color: selected ? WhiteColor : notifire.getwhiteblackcolor,
                  fontSize: 13,
                ),
              ),
            ]),
            labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            selectedColor: blueColor,
            backgroundColor: notifire.getSurfaceColor,
            side: BorderSide(
              color: selected ? blueColor : notifire.getborderColor,
              width: selected ? 0 : 1,
            ),
            elevation: selected ? 2 : 0,
            pressElevation: 4,
            shadowColor: blueColor.withOpacity(0.3),
          );
        },
      ),
    );
  }

  Widget _catWiseGrid(BuildContext context) {
    if (!homePageController.isCatWise) {
      return Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
    final list = homePageController.catWiseInfo?.propertyCat ?? [];
    if (list.isEmpty) return _emptyState();
    final cross = R.gridCount(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 260,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _PropertyCard(
          title: item.name ?? "",
          image: "${Config.imageUrl}${item.image ?? ""}",
          zipcode: item.zipcode,
          city: item.city,
          badgeText: item.rate?.toString() ?? "",
          typeTitle: item.propertyTypeTitle ?? "",
          onTap: () async {
            setState(() => homePageController.rate = item.rate ?? "");
            homePageController.chnageObjectIndex(index);
            await homePageController.getPropertyDetailsApi(id: item.id, ptype: item.propertyType);
            if ((item.propertyType ?? "") == "3") {
              Get.toNamed(Routes.viewHomecareDataScreen);
            } else {
              Get.toNamed(Routes.viewDataScreen);
            }
          },
          notifire: notifire,
        );
      },
    );
  }

  Widget _listFeatured(BuildContext context) {
    final featured = homePageController.homeDatatInfo?.homeData?.featuredProperty ?? [];
    if (featured.isEmpty) return _emptyState();

    final cardWidth = R.isDesktop(context)
        ? 360.0
        : (R.isTablet(context)
        ? 300.0
        : 260.0);
    final cardHeight = cardWidth * 1.25;

    return SizedBox(
      height: cardHeight + 20,
      width: double.infinity,
      child: ListView.builder(
        itemCount: featured.length,
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, idx) {
          final f = featured[idx];
          currency = homePageController.homeDatatInfo?.homeData?.currency ?? "";
          
          // Null-safe data extraction
          final name = f.name ?? "Property ${idx + 1}";
          final zipcode = f.zipcode ?? "";
          final city = f.city ?? "";
          final beds = f.beds ?? "0";
          final capacity = f.capacity ?? "N/A";
          final rate = f.rate ?? "";
          final propertyTypeTitle = f.propertyTypeTitle ?? "";
          final imageUrl = "${Config.imageUrl}${f.image ?? ""}";
          
          return Padding(
            padding: EdgeInsets.only(right: 12),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  setState(() => homePageController.rate = f.rate ?? "");
                  homePageController.chnageObjectIndex(idx);
                  await homePageController.getPropertyDetailsApi(
                    id: f.id,
                    ptype: f.propertyType,
                  );
                  final ptype = f.propertyType;
                  if ((ptype ?? "") == "3") {
                    Get.toNamed(Routes.viewHomecareDataScreen);
                  } else {
                    Get.toNamed(Routes.viewDataScreen);
                  }
                },
                child: SizedBox(
                  height: cardHeight,
                  width: cardWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(children: [
                      // Background Image with better error handling
                      Positioned.fill(
                        child: FadeInImage.assetNetwork(
                          fadeInCurve: Curves.easeInCirc,
                          placeholder: "assets/images/ezgif.com-crop.gif",
                          image: imageUrl,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stack) => Container(
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Icon(Icons.home, size: 48, color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.6, 0.8, 1.0],
                              colors: [Colors.transparent, Colors.black54, Colors.black87],
                            ),
                          ),
                        ),
                      ),
                      // Rating badge (only if rate exists)
                      if (rate.isNotEmpty)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _ratingPill(text: rate),
                        ),
                      // Content at bottom
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Property name
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: FontFamily.gilroyBold,
                                color: WhiteColor,
                              ),
                            ),
                            SizedBox(height: 6),
                            // Location (only if data exists)
                            if (zipcode.isNotEmpty || city.isNotEmpty)
                              Row(children: [
                                Icon(Icons.location_on, size: 16, color: WhiteColor.withOpacity(0.9)),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "$zipcode${zipcode.isNotEmpty && city.isNotEmpty ? ', ' : ''}$city",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      color: WhiteColor.withOpacity(0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ]),
                            SizedBox(height: 8),
                            // Beds and Capacity
                            Row(children: [
                              Icon(Icons.bed, size: 14, color: WhiteColor.withOpacity(0.9)),
                              SizedBox(width: 6),
                              Text(
                                "$beds Beds",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  color: WhiteColor.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(Icons.groups, size: 14, color: WhiteColor.withOpacity(0.9)),
                              SizedBox(width: 6),
                              Text(
                                capacity,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  color: WhiteColor.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ]),
                            if (propertyTypeTitle.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                propertyTypeTitle,
                                style: TextStyle(
                                  color: WhiteColor,
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ratingPill({required String text}) {
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Color(0xFFedeeef), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [
        Image.asset("assets/images/Rating.png", height: 15, width: 15),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: blueColor)),
      ]),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(children: [
        SizedBox(height: 40),
        Image(image: AssetImage("assets/images/searchDataEmpty.png"), height: 110, width: 110),
        SizedBox(height: 12),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480),
          child: Text(
            "Sorry, there is no any nearby \n category or data not found".tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: notifire.getgreycolor, fontFamily: FontFamily.gilroyBold),
          ),
        ),
      ]),
    );
  }
}

// ---------------------- Reusable Card ----------------------
class _PropertyCard extends StatefulWidget {
  final String title;
  final String image;
  final String? zipcode;
  final String? city;
  final String badgeText;
  final String typeTitle;
  final VoidCallback onTap;
  final ColorNotifire notifire;

  const _PropertyCard({
    required this.title,
    required this.image,
    this.zipcode,
    this.city,
    required this.badgeText,
    required this.typeTitle,
    required this.onTap,
    required this.notifire,
  });

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1.0,
        duration: Duration(milliseconds: 120),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: widget.notifire.getbgcolor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.notifire.getborderColor),
              boxShadow: _hover
                  ? [BoxShadow(blurRadius: 12, spreadRadius: 0, offset: Offset(0, 6), color: Colors.black.withOpacity(0.08))]
                  : [],
            ),
            child: Column(children: [
              Stack(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FadeInImage.assetNetwork(
                    placeholder: "assets/images/ezgif.com-crop.gif",
                    image: widget.image,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (c, e, s) => Container(height: 140, color: Colors.grey.shade200),
                  ),
                ),
                Positioned(top: 10, right: 12, child: _ratingPill(text: widget.badgeText)),
              ]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontFamily: FontFamily.gilroyBold, color: widget.notifire.getwhiteblackcolor)),
                    SizedBox(height: 6),
                    Row(children: [
                      SvgPicture.asset("assets/images/location.svg", height: 16, colorFilter: ColorFilter.mode(widget.notifire.getwhiteblackcolor, BlendMode.srcIn)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text("${widget.zipcode ?? ''}, ${widget.city ?? ''}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: widget.notifire.getgreycolor, fontFamily: FontFamily.gilroyMedium)),
                      ),
                    ]),
                    SizedBox(height: 6),
                    Row(children: [
                      Text(widget.typeTitle, style: TextStyle(color: blueColor, fontFamily: FontFamily.gilroyBold, fontSize: 15)),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _ratingPill({required String text}) {
    return Container(
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Color(0xFFedeeef), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Image.asset("assets/images/Rating.png", height: 14, width: 14),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: blueColor)),
      ]),
    );
  }
}

// ---------------------- Notifications (Firebase removed) ----------------------
// Firebase Messaging has been removed. If you need push notifications,
// consider using OneSignal or another alternative service.




// // ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, sort_child_properties_last, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, unused_local_variable, no_leading_underscores_for_local_identifiers, avoid_print, prefer_interpolation_to_compose_strings, unrelated_type_equality_checks, use_build_context_synchronously
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:badges/badges.dart' as bg;
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/proparty/homepage_controller.dart';
// import 'package:gotocarefinder/controller/search_controller.dart';
// import 'package:gotocarefinder/controller/signup_controller.dart';
// import 'package:gotocarefinder/firebase/chat_screen.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../firebase_accesstoken.dart';
//
// var lat;
// var long;
// var first;
// var currency;
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   HomePageController homePageController = Get.find();
//   PropartyHomePageController propartyHomePageController =
//       Get.put(PropartyHomePageController());
//   SignUpController signUpController = Get.find();
//   bool isLoding = false;
//   Position? currentLocation;
//   String fevId = "";
//
//   String userName = "";
//   String? base64Image;
//
//   String? networkimage;
//
//   List facilities = [
//     "assets/images/beds.svg",
//     //"assets/images/bath.svg",
//     "assets/images/sqft.svg",
//   ];
//
//   @override
//   void initState() {
//     propartyHomePageController.getCatWiseData(
//         countryId: getData.read("countryId"), cId: "0");
//
//     homePageController.getCatWiseData(
//         countryId: getData.read("countryId"), cId: "0");
//
//     FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
//       Get.to(ChatPage(
//         proPic: remoteMessage.data["propic"],
//         resiverUserId: remoteMessage.data["id"],
//         resiverUseremail: remoteMessage.data["name"],
//       ));
//     });
//     getdarkmodepreviousstate();
//     if (getData.read("UserLogin") != null) {
//       isUserOnlie(getData.read("UserLogin")["id"], false);
//     }
//
//     lat == null || long == null ? getUserLocation() : getUserLocation1();
//     super.initState();
//     getData.read("UserLogin") != null
//         ? setState(() {
//             userName = getData.read("UserLogin")["name"] ?? "";
//             networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
//             getData.read("UserLogin")["pro_pic"] != "null"
//                 ? setState(() {
//                     networkimageconvert();
//                   })
//                 : const SizedBox();
//           })
//         : null;
//
//     FirebaseAccesstoken accesstoken = new FirebaseAccesstoken();
//     accesstoken.getAccessToken();
//   }
//
//   networkimageconvert() {
//     (() async {
//       http.Response response =
//           await http.get(Uri.parse(Config.imageUrl + networkimage.toString()));
//
//       if (mounted) {
//         print(response.bodyBytes);
//         setState(() {
//           base64Image = const Base64Encoder().convert(response.bodyBytes);
//         });
//       }
//     })();
//   }
//
//   Future<Position> locateUser() async {
//     return Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }
//
//   Future getUserLocation() async {
//     setState(() {});
//     var currentLocation = await locateUser();
//     debugPrint('location: ${currentLocation.latitude}');
//     lat = currentLocation.latitude;
//     long = currentLocation.longitude;
//
//     List<Placemark> addresses = await placemarkFromCoordinates(
//         currentLocation.latitude, currentLocation.longitude);
//     setState(() {
//       if (getData.read("homeCall") == true) {
//         setState(() {
//           homePageController.getHomeDataApi(
//             countryId: getData.read("countryId"),
//           );
//           propartyHomePageController.getHomeDataApi(
//             countryId: getData.read("countryId"),
//           );
//         });
//         save("homeCall", false);
//       }
//       first = addresses.first.name;
//     });
//   }
//
//   Future getUserLocation1() async {
//     isLoding = true;
//     setState(() {});
//     var currentLocation = await locateUser();
//     debugPrint('location: ${currentLocation.latitude}');
//   }
//
//   late ColorNotifire notifire;
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
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) {
//           exit(0);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: notifire.getbgcolor,
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(70),
//           child: AppBar(
//             toolbarHeight: 100,
//             automaticallyImplyLeading: false,
//             backgroundColor: notifire.getbgcolor,
//             elevation: 0,
//             title: Row(
//               children: [
//                 getData.read("UserLogin") != null && networkimage != ""
//                     ? InkWell(
//                         onTap: () {},
//                         child: Container(
//                           height: 50,
//                           width: 50,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                   "${Config.imageUrl}${networkimage ?? ""}"),
//                               fit: BoxFit.fill,
//                             ),
//                           ),
//                         ),
//                       )
//                     : InkWell(
//                         onTap: () {},
//                         child: Container(
//                           height: 50,
//                           width: 50,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             image: DecorationImage(
//                               image: AssetImage(
//                                   "assets/images/profile-default.png"),
//                               fit: BoxFit.fill,
//                             ),
//                           ),
//                         ),
//                       ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Welcome 👋".tr,
//                       style: TextStyle(
//                         color: Color(0xFF757575),
//                         fontFamily: FontFamily.gilroyMedium,
//                         fontSize: 14,
//                       ),
//                     ),
//                     userName != ""
//                         ? Text(
//                             userName,
//                             style: TextStyle(
//                               color: notifire.getwhiteblackcolor,
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 18,
//                             ),
//                           )
//                         : Text(
//                             "User".tr,
//                             style: TextStyle(
//                               color: notifire.getwhiteblackcolor,
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 18,
//                             ),
//                           ),
//                   ],
//                 )
//               ],
//             ),
//             actions: [
//               InkWell(
//                 onTap: () {
//                   if (getData.read("UserLogin") != null) {
//                     Get.toNamed(Routes.notificationScreen);
//                   } else {
//                     Get.toNamed(Routes.login);
//                   }
//                 },
//                 child: Center(
//                   child: bg.Badge(
//                     badgeStyle: bg.BadgeStyle(
//                       badgeColor: Colors.red,
//                       shape: bg.BadgeShape.circle,
//                     ),
//                     badgeContent: Text(''),
//                     badgeAnimation: bg.BadgeAnimation.slide(),
//                     position: bg.BadgePosition.topEnd(end: 14, top: 3),
//                     child: CircleAvatar(
//                       radius: 24,
//                       child: Container(
//                         height: 50,
//                         width: 50,
//                         alignment: Alignment.center,
//                         child: Image.asset(
//                           "assets/images/Notification.png",
//                           height: 25,
//                           width: 25,
//                           color: notifire.getwhiteblackcolor,
//                         ),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       backgroundColor: notifire.getblackwhitecolor,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//             ],
//           ),
//         ),
//         body: RefreshIndicator(
//           onRefresh: () {
//             return Future.delayed(
//               Duration(seconds: 2),
//               () {
//                 homePageController.getHomeDataApi(
//                   countryId: getData.read("countryId"),
//                 );
//                 homePageController.getCatWiseData(
//                   cId: "0",
//                   countryId: getData.read("countryId"),
//                 );
//
//                 propartyHomePageController.getHomeDataApi(
//                   countryId: getData.read("countryId"),
//                 );
//                 propartyHomePageController.getCatWiseData(
//                   cId: "0",
//                   countryId: getData.read("countryId"),
//                 );
//               },
//             );
//           },
//           child: GetBuilder<HomePageController>(builder: (context) {
//             return SingleChildScrollView(
//               physics: BouncingScrollPhysics(),
//               child: homePageController.isLoading ||
//                       propartyHomePageController.isLoading
//                   ? Column(
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         searchWidget(),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         categoryAndSeeAllWidget("Featured".tr, "See All".tr),
//                         listFeatured(),
//                         categoryAndSeeAllWidget(
//                             "Recommended For You".tr, "See All".tr),
//                         SizedBox(
//                           height: 55,
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 10),
//                             child: ListView.builder(
//                               itemCount: homePageController
//                                   .homeDatatInfo?.homeData!.catlist!.length,
//                               scrollDirection: Axis.horizontal,
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     homePageController
//                                         .changeCategoryIndex(index);
//
//                                     homePageController.getCatWiseData(
//                                       cId: homePageController.homeDatatInfo
//                                           ?.homeData!.catlist![index].id,
//                                       countryId: getData.read("countryId"),
//                                     );
//                                   },
//                                   child: Container(
//                                     height: 50,
//                                     padding: EdgeInsets.all(8),
//                                     margin: EdgeInsets.only(
//                                         left: 5, right: 5, top: 7, bottom: 7),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         FadeInImage.assetNetwork(
//                                           height: 25,
//                                           width: 25,
//                                           fit: homePageController
//                                                       .homeDatatInfo
//                                                       ?.homeData!
//                                                       .catlist![index] ==
//                                                   0
//                                               ? BoxFit.contain
//                                               : BoxFit.cover,
//                                           imageErrorBuilder:
//                                               (context, error, stackTrace) {
//                                             return Center(
//                                               child: Image.asset(
//                                                 "assets/images/emty.gif",
//                                                 fit: BoxFit.cover,
//                                                 height: Get.height,
//                                               ),
//                                             );
//                                           },
//                                           image:
//                                               "${Config.imageUrl}${homePageController.homeDatatInfo?.homeData!.catlist![index].img ?? ""}",
//                                           color: homePageController
//                                                       .catCurrentIndex ==
//                                                   index
//                                               ? WhiteColor
//                                               : blueColor,
//                                           placeholder:
//                                               "assets/images/ezgif.com-crop.gif",
//                                         ),
//                                         SizedBox(
//                                           width: 5,
//                                         ),
//                                         Text(
//                                           homePageController
//                                                   .homeDatatInfo
//                                                   ?.homeData!
//                                                   .catlist![index]
//                                                   .title ??
//                                               "",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyBold,
//                                             color: homePageController
//                                                         .catCurrentIndex ==
//                                                     index
//                                                 ? WhiteColor
//                                                 : blueColor,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     decoration: BoxDecoration(
//                                       border: Border.all(
//                                           color: blueColor, width: 2),
//                                       borderRadius: BorderRadius.circular(25),
//                                       color:
//                                           homePageController.catCurrentIndex ==
//                                                   index
//                                               ? blueColor
//                                               : notifire.getbgcolor,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         homePageController.isCatWise
//                             ? homePageController
//                                     .catWiseInfo!.propertyCat!.isNotEmpty
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 10, right: 10, bottom: 10),
//                                     child: GridView.builder(
//                                       itemCount: homePageController
//                                           .catWiseInfo?.propertyCat!.length,
//                                       shrinkWrap: true,
//                                       physics: NeverScrollableScrollPhysics(),
//                                       gridDelegate:
//                                           SliverGridDelegateWithFixedCrossAxisCount(
//                                         crossAxisCount: 2,
//                                         mainAxisExtent: 250,
//                                       ),
//                                       itemBuilder: (context, index) {
//                                         return InkWell(
//                                           onTap: () async {
//                                             setState(() {
//                                               homePageController.rate =
//                                                   homePageController
//                                                           .catWiseInfo
//                                                           ?.propertyCat![index]
//                                                           .rate ??
//                                                       "";
//                                             });
//                                             homePageController
//                                                 .chnageObjectIndex(index);
//                                             await homePageController
//                                                 .getPropertyDetailsApi(
//                                                     id: homePageController
//                                                         .catWiseInfo
//                                                         ?.propertyCat![index]
//                                                         .id,
//                                                     ptype: homePageController
//                                                         .catWiseInfo
//                                                         ?.propertyCat![index]
//                                                         .propertyType);
//                                             homePageController
//                                                         .catWiseInfo
//                                                         ?.propertyCat![index]
//                                                         .propertyType ==
//                                                     "3"
//                                                 ? Get.toNamed(
//                                                     Routes
//                                                         .viewHomecareDataScreen,
//                                                   )
//                                                 : Get.toNamed(
//                                                     Routes.viewDataScreen,
//                                                   );
//                                           },
//                                           child: Container(
//                                             height: 250,
//                                             margin: EdgeInsets.all(8),
//                                             child: Column(
//                                               children: [
//                                                 Stack(
//                                                   children: [
//                                                     Container(
//                                                       height: 140,
//                                                       width: Get.size.width,
//                                                       margin: EdgeInsets.only(
//                                                         right: 8,
//                                                         left: 8,
//                                                         top: 8,
//                                                       ),
//                                                       child: ClipRRect(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(15),
//                                                         child: FadeInImage
//                                                             .assetNetwork(
//                                                           fadeInCurve:
//                                                               Curves.easeInCirc,
//                                                           placeholder:
//                                                               "assets/images/ezgif.com-crop.gif",
//                                                           height: 130,
//                                                           width: Get.size.width,
//                                                           imageErrorBuilder:
//                                                               (context, error,
//                                                                   stackTrace) {
//                                                             return Center(
//                                                               child:
//                                                                   Image.asset(
//                                                                 "assets/images/emty.gif",
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                                 height:
//                                                                     Get.height,
//                                                               ),
//                                                             );
//                                                           },
//                                                           image:
//                                                               "${Config.imageUrl}${homePageController.catWiseInfo?.propertyCat![index].image ?? ""}",
//                                                           fit: BoxFit.cover,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     /*homePageController
//                                                                 .catWiseInfo
//                                                                 ?.propertyCat![
//                                                                     index]
//                                                                 .buyorrent ==
//                                                             "1"
//                                                         ? */
//                                                     Positioned(
//                                                       top: 15,
//                                                       right: 20,
//                                                       child: Container(
//                                                         height: 30,
//                                                         width: 45,
//                                                         child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .fromLTRB(
//                                                                       0,
//                                                                       0,
//                                                                       3,
//                                                                       0),
//                                                               child:
//                                                                   Image.asset(
//                                                                 "assets/images/Rating.png",
//                                                                 height: 15,
//                                                                 width: 15,
//                                                               ),
//                                                             ),
//                                                             Text(
//                                                               "${homePageController.catWiseInfo?.propertyCat![index].rate ?? ""}",
//                                                               style: TextStyle(
//                                                                 fontFamily:
//                                                                     FontFamily
//                                                                         .gilroyMedium,
//                                                                 color:
//                                                                     blueColor,
//                                                               ),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xFFedeeef),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(15),
//                                                         ),
//                                                       ),
//                                                     )
//                                                     /*: Positioned(
//                                                             top: 15,
//                                                             right: 20,
//                                                             child: Container(
//                                                               height: 30,
//                                                               width: 60,
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               child: Text(
//                                                                 "BUY".tr,
//                                                                 style: TextStyle(
//                                                                     color:
//                                                                         blueColor,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w600),
//                                                               ),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: Color(
//                                                                     0xFFedeeef),
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             15),
//                                                               ),
//                                                             ),
//                                                           ),*/
//                                                   ],
//                                                 ),
//                                                 Expanded(
//                                                   child: Container(
//                                                     height: 128,
//                                                     width: Get.size.width,
//                                                     margin: EdgeInsets.all(5),
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   left: 10),
//                                                           child: Text(
//                                                             homePageController
//                                                                     .catWiseInfo
//                                                                     ?.propertyCat![
//                                                                         index]
//                                                                     .name ??
//                                                                 "",
//                                                             maxLines: 1,
//                                                             style: TextStyle(
//                                                               fontSize: 17,
//                                                               fontFamily:
//                                                                   FontFamily
//                                                                       .gilroyBold,
//                                                               color: notifire
//                                                                   .getwhiteblackcolor,
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   left: 10,
//                                                                   top: 6),
//                                                           child: Row(
//                                                             children: [
//                                                               SvgPicture.asset(
//                                                                 "assets/images/location.svg",
//                                                                 height: 16,
//                                                                 colorFilter: ColorFilter.mode(
//                                                                     notifire
//                                                                         .getwhiteblackcolor,
//                                                                     BlendMode
//                                                                         .srcIn),
//                                                               ),
//                                                               SizedBox(
//                                                                 width: 2,
//                                                               ),
//                                                               Flexible(
//                                                                 child: Text(
//                                                                   "${homePageController.catWiseInfo?.propertyCat![index].zipcode}, ${homePageController.catWiseInfo?.propertyCat![index].city}",
//                                                                   maxLines: 1,
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: notifire
//                                                                         .getgreycolor,
//                                                                     fontFamily:
//                                                                         FontFamily
//                                                                             .gilroyMedium,
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .only(
//                                                                   left: 10),
//                                                           child: Row(
//                                                             children: [
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .only(
//                                                                         top: 4),
//                                                                 child: Text(
//                                                                   "${homePageController.catWiseInfo?.propertyCat![index].propertyTypeTitle ?? ""}",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color:
//                                                                         blueColor,
//                                                                     fontFamily:
//                                                                         FontFamily
//                                                                             .gilroyBold,
//                                                                     fontSize:
//                                                                         15,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               /*homePageController
//                                                                           .catWiseInfo
//                                                                           ?.propertyCat![
//                                                                               index]
//                                                                           .buyorrent ==
//                                                                       "1"
//                                                                   ? Padding(
//                                                                       padding: const EdgeInsets
//                                                                           .only(
//                                                                           left:
//                                                                               3,
//                                                                           top:
//                                                                               7),
//                                                                       child:
//                                                                           Text(
//                                                                         "/night"
//                                                                             .tr,
//                                                                         style:
//                                                                             TextStyle(
//                                                                           color:
//                                                                               notifire.getgreycolor,
//                                                                           fontFamily:
//                                                                               FontFamily.gilroyMedium,
//                                                                         ),
//                                                                       ),
//                                                                     )
//                                                                   : Text(""),*/
//                                                             ],
//                                                           ),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   color:
//                                                       notifire.getborderColor),
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               color: notifire.getbgcolor,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   )
//                                 : Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 14, vertical: 5),
//                                     child: Column(
//                                       children: [
//                                         SizedBox(height: Get.height * 0.10),
//                                         Image(
//                                           image: AssetImage(
//                                             "assets/images/searchDataEmpty.png",
//                                           ),
//                                           height: 110,
//                                           width: 110,
//                                         ),
//                                         Center(
//                                           child: SizedBox(
//                                             width: Get.width * 0.80,
//                                             child: Text(
//                                               "Sorry, there is no any nearby \n category or data not found"
//                                                   .tr,
//                                               textAlign: TextAlign.center,
//                                               style: TextStyle(
//                                                 color: notifire.getgreycolor,
//                                                 fontFamily:
//                                                     FontFamily.gilroyBold,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                             : Center(
//                                 child: CircularProgressIndicator(),
//                               ),
//                         /*****
//                          *
//                          *
//                          *
//                          *
//                          *
//                          *
//                          *
//                          *
//                          */
//                                       SizedBox(
//                                         height: 20,
//                                       ),
//                                       /*categoryAndSeeAllWidget(
//                                           "Featured".tr, "See All".tr),
//                                       listFeatured(),*/
//                                       categoryAndSeeAllWidget(
//                                           "For Providers: Buy & Rent".tr,
//                                           "See All".tr),
//                                       SizedBox(
//                                         height: 55,
//                                         child: Padding(
//                                           padding:
//                                               const EdgeInsets.only(left: 10),
//                                           child: ListView.builder(
//                                             itemCount:
//                                                 propartyHomePageController
//                                                     .homeDatatInfo
//                                                     ?.homeData!
//                                                     .catlist!
//                                                     .length,
//                                             scrollDirection: Axis.horizontal,
//                                             itemBuilder: (context, index) {
//                                               return InkWell(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     propartyHomePageController
//                                                       .changeCategoryIndex(
//                                                           index);
//
//                                                   propartyHomePageController
//                                                       .getCatWiseData(
//                                                     cId:
//                                                         propartyHomePageController
//                                                             .homeDatatInfo
//                                                             ?.homeData!
//                                                             .catlist![index]
//                                                             .id,
//                                                     countryId: getData
//                                                         .read("countryId"),
//                                                   );
//                                                   setState(() {
//
//                                                   });
//                                                   });
//                                                 },
//                                                 child: Container(
//                                                   height: 50,
//                                                   padding: EdgeInsets.all(8),
//                                                   margin: EdgeInsets.only(
//                                                       left: 5,
//                                                       right: 5,
//                                                       top: 7,
//                                                       bottom: 7),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       FadeInImage.assetNetwork(
//                                                         height: 25,
//                                                         width: 25,
//                                                         fit: BoxFit.cover,
//                                                         imageErrorBuilder:
//                                                             (context, error,
//                                                                 stackTrace) {
//                                                           return Center(
//                                                             child: Image.asset(
//                                                               "assets/images/emty.gif",
//                                                               fit: BoxFit.cover,
//                                                               height:
//                                                                   Get.height,
//                                                             ),
//                                                           );
//                                                         },
//                                                         image:
//                                                             "${Config.imageUrl}${propartyHomePageController.homeDatatInfo?.homeData!.catlist![index].img ?? ""}",
//                                                         color: propartyHomePageController
//                                                                     .catCurrentIndex ==
//                                                                 index
//                                                             ? WhiteColor
//                                                             : blueColor,
//                                                         placeholder:
//                                                             "assets/images/ezgif.com-crop.gif",
//                                                       ),
//                                                       SizedBox(
//                                                         width: 5,
//                                                       ),
//                                                       Text(
//                                                         propartyHomePageController
//                                                                 .homeDatatInfo
//                                                                 ?.homeData!
//                                                                 .catlist![index]
//                                                                 .title ??
//                                                             "",
//                                                         style: TextStyle(
//                                                           fontFamily: FontFamily
//                                                               .gilroyBold,
//                                                           color: propartyHomePageController
//                                                                       .catCurrentIndex ==
//                                                                   index
//                                                               ? WhiteColor
//                                                               : blueColor,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         color: blueColor,
//                                                         width: 2),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             25),
//                                                     color: propartyHomePageController
//                                                                 .catCurrentIndex ==
//                                                             index
//                                                         ? blueColor
//                                                         : notifire.getbgcolor,
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       propartyHomePageController.isCatWise
//                                           ? propartyHomePageController
//                                                   .catWiseInfo!
//                                                   .propertyCat!
//                                                   .isNotEmpty
//                                               ? Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                           left: 10,
//                                                           right: 10,
//                                                           bottom: 10),
//                                                   child: GridView.builder(
//                                                     itemCount:
//                                                         propartyHomePageController
//                                                             .catWiseInfo
//                                                             ?.propertyCat!
//                                                             .length,
//                                                     shrinkWrap: true,
//                                                     physics:
//                                                         NeverScrollableScrollPhysics(),
//                                                     gridDelegate:
//                                                         SliverGridDelegateWithFixedCrossAxisCount(
//                                                       crossAxisCount: 2,
//                                                       mainAxisExtent: 250,
//                                                     ),
//                                                     itemBuilder:
//                                                         (context, index) {
//                                                       return InkWell(
//                                                         onTap: () async {
//                                                           setState(() {
//                                                             propartyHomePageController
//                                                                 .rate = propartyHomePageController
//                                                                     .catWiseInfo
//                                                                     ?.propertyCat![
//                                                                         index]
//                                                                     .rate ??
//                                                                 "";
//                                                           });
//                                                           propartyHomePageController
//                                                               .chnageObjectIndex(
//                                                                   index);
//                                                           await propartyHomePageController
//                                                               .getPropertyDetailsApi(
//                                                             id: propartyHomePageController
//                                                                 .catWiseInfo
//                                                                 ?.propertyCat![
//                                                                     index]
//                                                                 .id,
//                                                           );
//                                                           Get.toNamed(Routes
//                                                               .viewPropartyScreen);
//                                                         },
//                                                         child: Container(
//                                                           height: 250,
//                                                           margin:
//                                                               EdgeInsets.all(8),
//                                                           child: Column(
//                                                             children: [
//                                                               Stack(
//                                                                 children: [
//                                                                   Container(
//                                                                     height: 140,
//                                                                     width: Get
//                                                                         .size
//                                                                         .width,
//                                                                     margin:
//                                                                         EdgeInsets
//                                                                             .only(
//                                                                       right: 8,
//                                                                       left: 8,
//                                                                       top: 8,
//                                                                     ),
//                                                                     child:
//                                                                         ClipRRect(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               15),
//                                                                       child: FadeInImage
//                                                                           .assetNetwork(
//                                                                         fadeInCurve:
//                                                                             Curves.easeInCirc,
//                                                                         placeholder:
//                                                                             "assets/images/ezgif.com-crop.gif",
//                                                                         height:
//                                                                             130,
//                                                                         width: Get
//                                                                             .size
//                                                                             .width,
//                                                                         imageErrorBuilder: (context,
//                                                                             error,
//                                                                             stackTrace) {
//                                                                           return Center(
//                                                                             child:
//                                                                                 Image.asset(
//                                                                               "assets/images/emty.gif",
//                                                                               fit: BoxFit.cover,
//                                                                               height: Get.height,
//                                                                             ),
//                                                                           );
//                                                                         },
//                                                                         image:
//                                                                             "${Config.imageUrl}${propartyHomePageController.catWiseInfo?.propertyCat![index].image ?? ""}",
//                                                                         fit: BoxFit
//                                                                             .cover,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   propartyHomePageController
//                                                                               .catWiseInfo
//                                                                               ?.propertyCat![index]
//                                                                               .buyorrent ==
//                                                                           "1"
//                                                                       ? Positioned(
//                                                                           top:
//                                                                               15,
//                                                                           right:
//                                                                               20,
//                                                                           child:
//                                                                               Container(
//                                                                             height:
//                                                                                 30,
//                                                                             width:
//                                                                                 45,
//                                                                             child:
//                                                                                 Row(
//                                                                               mainAxisAlignment: MainAxisAlignment.center,
//                                                                               children: [
//                                                                                 Container(
//                                                                                   margin: const EdgeInsets.fromLTRB(0, 0, 3, 0),
//                                                                                   child: Image.asset(
//                                                                                     "assets/images/Rating.png",
//                                                                                     height: 15,
//                                                                                     width: 15,
//                                                                                   ),
//                                                                                 ),
//                                                                                 Text(
//                                                                                   "${propartyHomePageController.catWiseInfo?.propertyCat![index].rate ?? ""}",
//                                                                                   style: TextStyle(
//                                                                                     fontFamily: FontFamily.gilroyMedium,
//                                                                                     color: blueColor,
//                                                                                   ),
//                                                                                 )
//                                                                               ],
//                                                                             ),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               color: Color(0xFFedeeef),
//                                                                               borderRadius: BorderRadius.circular(15),
//                                                                             ),
//                                                                           ),
//                                                                         )
//                                                                       : Positioned(
//                                                                           top:
//                                                                               15,
//                                                                           right:
//                                                                               20,
//                                                                           child:
//                                                                               Container(
//                                                                             height:
//                                                                                 30,
//                                                                             width:
//                                                                                 75,
//                                                                             alignment:
//                                                                                 Alignment.center,
//                                                                             child:
//                                                                                 Text(
//                                                                               "FOR SALE".tr,
//                                                                               style: TextStyle(color: blueColor, fontWeight: FontWeight.w600),
//                                                                             ),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               color: Color(0xFFedeeef),
//                                                                               borderRadius: BorderRadius.circular(15),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                 ],
//                                                               ),
//                                                               Expanded(
//                                                                 child:
//                                                                     Container(
//                                                                   height: 128,
//                                                                   width: Get
//                                                                       .size
//                                                                       .width,
//                                                                   margin:
//                                                                       EdgeInsets
//                                                                           .all(
//                                                                               5),
//                                                                   child: Column(
//                                                                     crossAxisAlignment:
//                                                                         CrossAxisAlignment
//                                                                             .start,
//                                                                     children: [
//                                                                       Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .only(
//                                                                             left:
//                                                                                 10),
//                                                                         child:
//                                                                             Text(
//                                                                           propartyHomePageController.catWiseInfo?.propertyCat![index].title ??
//                                                                               "",
//                                                                           maxLines:
//                                                                               1,
//                                                                           style:
//                                                                               TextStyle(
//                                                                             fontSize:
//                                                                                 17,
//                                                                             fontFamily:
//                                                                                 FontFamily.gilroyBold,
//                                                                             color:
//                                                                                 notifire.getwhiteblackcolor,
//                                                                             overflow:
//                                                                                 TextOverflow.ellipsis,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .only(
//                                                                             left:
//                                                                                 10,
//                                                                             top:
//                                                                                 6),
//                                                                         child:
//                                                                             Row(
//                                                                           children: [
//                                                                             SvgPicture.asset(
//                                                                               "assets/images/location.svg",
//                                                                               height: 16,
//                                                                               colorFilter: ColorFilter.mode(notifire.getwhiteblackcolor, BlendMode.srcIn),
//                                                                             ),
//                                                                             SizedBox(
//                                                                               width: 2,
//                                                                             ),
//                                                                             Flexible(
//                                                                               child: Text(
//                                                                                 "${propartyHomePageController.catWiseInfo?.propertyCat![index].zipcode}, ${propartyHomePageController.catWiseInfo?.propertyCat![index].city}",
//                                                                                 maxLines: 1,
//                                                                                 style: TextStyle(
//                                                                                   color: notifire.getgreycolor,
//                                                                                   fontFamily: FontFamily.gilroyMedium,
//                                                                                   overflow: TextOverflow.ellipsis,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                       Padding(
//                                                                         padding: const EdgeInsets
//                                                                             .only(
//                                                                             left:
//                                                                                 10),
//                                                                         child:
//                                                                             Row(
//                                                                           children: [
//                                                                             Padding(
//                                                                               padding: const EdgeInsets.only(top: 7),
//                                                                               child: Text(
//                                                                                 "${currency}${propartyHomePageController.catWiseInfo?.propertyCat![index].price ?? ""}",
//                                                                                 style: TextStyle(
//                                                                                   color: blueColor,
//                                                                                   fontFamily: FontFamily.gilroyBold,
//                                                                                   fontSize: 17,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                             propartyHomePageController.catWiseInfo?.propertyCat![index].buyorrent == "1"
//                                                                                 ? Padding(
//                                                                                     padding: const EdgeInsets.only(left: 3, top: 7),
//                                                                                     child: Text(
//                                                                                       "/night".tr,
//                                                                                       style: TextStyle(
//                                                                                         color: notifire.getgreycolor,
//                                                                                         fontFamily: FontFamily.gilroyMedium,
//                                                                                       ),
//                                                                                     ),
//                                                                                   )
//                                                                                 : Text(""),
//                                                                           ],
//                                                                         ),
//                                                                       )
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             border: Border.all(
//                                                                 color: notifire
//                                                                     .getborderColor),
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         15),
//                                                             color: notifire
//                                                                 .getbgcolor,
//                                                           ),
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 )
//                                               : Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 14,
//                                                       vertical: 5),
//                                                   child: Column(
//                                                     children: [
//                                                       SizedBox(
//                                                           height: Get.height *
//                                                               0.10),
//                                                       Image(
//                                                         image: AssetImage(
//                                                           "assets/images/searchDataEmpty.png",
//                                                         ),
//                                                         height: 110,
//                                                         width: 110,
//                                                       ),
//                                                       Center(
//                                                         child: SizedBox(
//                                                           width:
//                                                               Get.width * 0.80,
//                                                           child: Text(
//                                                             "Sorry, there is no any nearby \n category or data not found"
//                                                                 .tr,
//                                                             textAlign: TextAlign
//                                                                 .center,
//                                                             style: TextStyle(
//                                                               color: notifire
//                                                                   .getgreycolor,
//                                                               fontFamily:
//                                                                   FontFamily
//                                                                       .gilroyBold,
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 )
//                                           : Center(
//                                               child:
//                                                   CircularProgressIndicator(),
//                                             )
//                       ],
//                     )
//                   : SizedBox(
//                       height: Get.height,
//                       width: Get.width,
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
//
//   Widget searchWidget() {
//     SearchPropertyController searchController =
//         Get.put(SearchPropertyController());
//     return InkWell(
//       onTap: () {
//         searchController.search.text = "";
//         Get.toNamed(Routes.homeSearchScreen);
//       },
//       child: Container(
//         height: 50,
//         width: Get.size.width,
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Image.asset(
//                 "assets/images/SearchHomescreen.png",
//                 height: 22,
//                 width: 22,
//                 fit: BoxFit.cover,
//                 color: notifire.getlightblack,
//               ),
//             ),
//             Text(
//               "Search".tr,
//               style: TextStyle(
//                 fontFamily: FontFamily.gilroyMedium,
//                 color: notifire.getlightblack,
//               ),
//             ),
//           ],
//         ),
//         decoration: BoxDecoration(
//           color: notifire.getlightblackwhite,
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
//
//   Widget categoryAndSeeAllWidget(String name, String buttonName) {
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
//             if (name == "Featured".tr) {
//               Get.toNamed(Routes.featuredScreen);
//             }
//             if (name == "Recommended For You".tr) {
//               homePageController
//                   .getCatWiseData(
//                       cId: "0", countryId: getData.read("countryId"))
//                   .then(
//                 (value) {
//                   Get.toNamed(Routes.ourRecommendationScreen);
//                   setState(() {});
//                 },
//               );
//             }
//             if (name == "For Providers: Buy & Rent".tr) {
//               //See all adverts
//             }
//           },
//           child: Text(
//             buttonName,
//             style: TextStyle(
//               color: Color(0xff3D5BF6),
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
//   Widget listFeatured() {
//     return GetBuilder<HomePageController>(builder: (context) {
//       return SizedBox(
//         height: 320,
//         width: Get.size.width,
//         child: homePageController
//                 .homeDatatInfo!.homeData!.featuredProperty!.isNotEmpty
//             ? ListView.builder(
//                 itemCount: homePageController
//                     .homeDatatInfo?.homeData!.featuredProperty!.length,
//                 scrollDirection: Axis.horizontal,
//                 physics: BouncingScrollPhysics(),
//                 itemBuilder: (context, index1) {
//                   currency =
//                       homePageController.homeDatatInfo?.homeData!.currency ??
//                           "";
//                   return InkWell(
//                     onTap: () async {
//                       setState(() {
//                         homePageController.rate = homePageController
//                                 .homeDatatInfo
//                                 ?.homeData!
//                                 .featuredProperty![index1]
//                                 .rate ??
//                             "";
//                       });
//                       print(
//                           "IDDD ? >> >>> >>> >>> > ${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].id}");
//                       homePageController.chnageObjectIndex(index1);
//                       await homePageController.getPropertyDetailsApi(
//                           id: homePageController.homeDatatInfo?.homeData!
//                               .featuredProperty![index1].id,
//                           ptype: homePageController
//                               .catWiseInfo?.propertyCat![index1].propertyType);
//                       homePageController.catWiseInfo?.propertyCat![index1]
//                                   .propertyType ==
//                               "3"
//                           ? Get.toNamed(
//                               Routes.viewHomecareDataScreen,
//                             )
//                           : Get.toNamed(
//                               Routes.viewDataScreen,
//                             );
//                     },
//                     child: Container(
//                       height: 320,
//                       width: 240,
//                       margin: EdgeInsets.all(10),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(30),
//                         child: Stack(
//                           children: [
//                             SizedBox(
//                               height: 320,
//                               width: 240,
//                               child: FadeInImage.assetNetwork(
//                                 fadeInCurve: Curves.easeInCirc,
//                                 placeholder: "assets/images/ezgif.com-crop.gif",
//                                 height: 320,
//                                 width: 240,
//                                 placeholderCacheHeight: 320,
//                                 placeholderCacheWidth: 240,
//                                 placeholderFit: BoxFit.fill,
//                                 imageErrorBuilder:
//                                     (context, error, stackTrace) {
//                                   return Center(
//                                     child: Image.asset(
//                                       "assets/images/emty.gif",
//                                       fit: BoxFit.cover,
//                                       height: Get.height,
//                                     ),
//                                   );
//                                 },
//                                 image:
//                                     "${Config.imageUrl}${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].image ?? ""}",
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   stops: [0.6, 0.8, 1.5],
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.5),
//                                     Colors.black.withOpacity(0.5),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             /*homePageController.homeDatatInfo?.homeData!
//                                         .featuredProperty![index1].buyorrent ==
//                                     "1"
//                                 ? */
//                             Positioned(
//                               top: 15,
//                               right: 20,
//                               child: Container(
//                                 height: 30,
//                                 width: 45,
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Container(
//                                       margin:
//                                           const EdgeInsets.fromLTRB(0, 0, 3, 0),
//                                       child: Image.asset(
//                                         "assets/images/Rating.png",
//                                         height: 15,
//                                         width: 15,
//                                       ),
//                                     ),
//                                     Text(
//                                       "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].rate ?? ""}",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         color: blueColor,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFedeeef),
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                             ),
//                             /* :
//                             Positioned(
//                               top: 15,
//                               right: 20,
//                               child: Container(
//                                 height: 30,
//                                 width: 60,
//                                 alignment: Alignment.center,
//                                 child: Text(
//                                   "BUY".tr,
//                                   style: TextStyle(
//                                       color: blueColor,
//                                       fontWeight: FontWeight.w600),
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFedeeef),
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                             ),*/
//                             Positioned(
//                               bottom: 10,
//                               child: SizedBox(
//                                 height: 130,
//                                 width: 240,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 12, top: 10),
//                                       child: Text(
//                                         homePageController
//                                                 .homeDatatInfo
//                                                 ?.homeData!
//                                                 .featuredProperty![index1]
//                                                 .name ??
//                                             "",
//                                         maxLines: 1,
//                                         style: TextStyle(
//                                           fontSize: 17,
//                                           fontFamily: FontFamily.gilroyBold,
//                                           color: WhiteColor,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 9, top: 8),
//                                       child: Row(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           SvgPicture.asset(
//                                             "assets/images/location.svg",
//                                             height: 15,
//                                             colorFilter: ColorFilter.mode(
//                                                 WhiteColor, BlendMode.srcIn),
//                                           ),
//                                           SizedBox(width: 2),
//                                           SizedBox(
//                                             width: 200,
//                                             child: Text(
//                                               "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].zipcode}, ${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].city}",
//                                               maxLines: 1,
//                                               style: TextStyle(
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 color: WhiteColor,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding:
//                                           EdgeInsets.only(left: 12, top: 11),
//                                       child: SizedBox(
//                                         height: 13,
//                                         child: ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount: facilities.length,
//                                           itemBuilder: (context, index) {
//                                             return Row(
//                                               children: [
//                                                 SvgPicture.asset(
//                                                   facilities[index],
//                                                   height: 12,
//                                                 ),
//                                                 SizedBox(
//                                                   width: 5,
//                                                 ),
//                                                 index == 0
//                                                     ? Text(
//                                                         "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].beds} Beds",
//                                                         style: TextStyle(
//                                                             fontFamily: FontFamily
//                                                                 .gilroyMedium,
//                                                             color: WhiteColor,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             fontSize: 12),
//                                                       )
//                                                     : index == 1
//                                                         ? Text(
//                                                             (() {
//                                                               if (homePageController
//                                                                           .homeDatatInfo
//                                                                           ?.homeData!
//                                                                           .featuredProperty![
//                                                                               index1]
//                                                                           .privateRooms ==
//                                                                       1 &&
//                                                                   homePageController
//                                                                           .homeDatatInfo
//                                                                           ?.homeData!
//                                                                           .featuredProperty![
//                                                                               index1]
//                                                                           .sharedRooms ==
//                                                                       1) {
//                                                                 return "Private & Shared";
//                                                               } else if (homePageController
//                                                                           .homeDatatInfo
//                                                                           ?.homeData!
//                                                                           .featuredProperty![
//                                                                               index1]
//                                                                           .privateRooms ==
//                                                                       1 &&
//                                                                   homePageController
//                                                                           .homeDatatInfo
//                                                                           ?.homeData!
//                                                                           .featuredProperty![
//                                                                               index1]
//                                                                           .sharedRooms ==
//                                                                       0) {
//                                                                 return "Private";
//                                                               } else if (homePageController
//                                                                           .homeDatatInfo
//                                                                           ?.homeData!
//                                                                           .featuredProperty![
//                                                                               index1]
//                                                                           .privateRooms ==
//                                                                       0 &&
//                                                                   homePageController
//                                                                           .homeDatatInfo
//                                                                           ?.homeData!
//                                                                           .featuredProperty![
//                                                                               index1]
//                                                                           .sharedRooms ==
//                                                                       1) {
//                                                                 return "Shared";
//                                                               } else {
//                                                                 return "Unspecified";
//                                                               }
//                                                             }()),
//                                                             style: TextStyle(
//                                                                 fontFamily:
//                                                                     FontFamily
//                                                                         .gilroyMedium,
//                                                                 color:
//                                                                     WhiteColor,
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 fontSize: 12),
//                                                           )
//                                                         : Text(
//                                                             "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].capacity}",
//                                                             style: TextStyle(
//                                                                 fontFamily:
//                                                                     FontFamily
//                                                                         .gilroyMedium,
//                                                                 color:
//                                                                     WhiteColor,
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .ellipsis,
//                                                                 fontSize: 12),
//                                                           ),
//                                                 SizedBox(
//                                                   width: 8,
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ),
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 12, top: 10),
//                                           child: Text(
//                                             "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].propertyTypeTitle}",
//                                             style: TextStyle(
//                                               color: WhiteColor,
//                                               fontFamily: FontFamily.gilroyBold,
//                                               fontSize: 17,
//                                             ),
//                                           ),
//                                         ),
//                                         /*homePageController
//                                                     .homeDatatInfo
//                                                     ?.homeData!
//                                                     .featuredProperty![index1]
//                                                     .buyorrent ==
//                                                 "1"
//                                             ? Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     left: 5, top: 10),
//                                                 child: Text(
//                                                   "/night".tr,
//                                                   style: TextStyle(
//                                                     color: WhiteColor,
//                                                     fontFamily:
//                                                         FontFamily.gilroyMedium,
//                                                   ),
//                                                 ),
//                                               )
//                                             : Text(""),*/
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   );
//                 },
//               )
//             : Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//                 child: Column(
//                   children: [
//                     SizedBox(height: Get.height * 0.10),
//                     Image(
//                       image: AssetImage(
//                         "assets/images/searchDataEmpty.png",
//                       ),
//                       height: 110,
//                       width: 110,
//                     ),
//                     Center(
//                       child: SizedBox(
//                         width: Get.width * 0.80,
//                         child: Text(
//                           "Sorry, there is no any nearby \n category or data not found"
//                               .tr,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: notifire.getgreycolor,
//                             fontFamily: FontFamily.gilroyBold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       );
//     });
//   }
// }
//
// late AndroidNotificationChannel channel;
// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
// void listenFCM() async {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     if (notification != null && android != null && !kIsWeb) {
//       flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               icon: '@mipmap/ic_launcher',
//             ),
//             /*iOS: const IOSNotificationDetails(
//               presentAlert: true,
//               presentSound: true,
//               presentBadge: true,
//             ),*/
//           ),
//           payload: jsonEncode({
//             "name": message.data["name"],
//             "id": message.data["id"],
//             "propic": message.data["propic"]
//           }));
//     }
//   });
// }
//
// Future<void> initializeNotifications() async {
//   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);
//
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     /*onSelectNotification: (String? payload) async {
//       if (payload != null) {
//         Map data = jsonDecode(payload);
//         Get.to(ChatPage(
//           proPic: data["propic"],
//           resiverUserId: data["id"],
//           resiverUseremail: data["name"],
//         ));
//       }
//     },*/
//   );
// }
//
// void loadFCM() async {
//   if (!kIsWeb) {
//     channel = const AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.high,
//       enableVibration: true,
//     );
//
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
// }
