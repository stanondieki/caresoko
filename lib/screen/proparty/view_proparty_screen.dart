// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, use_key_in_widget_constructors, must_be_immutable, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps, unused_field, unused_element, avoid_print, unrelated_type_equality_checks, unnecessary_string_interpolations, avoid_unnecessary_containers, prefer_adjacent_string_concatenation
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/bookrealestate_controller.dart';
import 'package:gotocarefinder/controller/calendar_controller.dart';
import 'package:gotocarefinder/controller/gallery_controller.dart';
import 'package:gotocarefinder/controller/proparty/homepage_controller.dart';
import 'package:gotocarefinder/controller/reviewsummary_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart' as osm;

class ViewPropartyScreen extends StatefulWidget {
  @override
  State<ViewPropartyScreen> createState() => _ViewPropartyScreenState();
}

class _ViewPropartyScreenState extends State<ViewPropartyScreen> {
  late ColorNotifire notifire;
  PropartyHomePageController homePageController = Get.find();
  ReviewSummaryController reviewSummaryController = Get.find();
  BookrealEstateController bookrealEstateController = Get.find();
  GalleryController galleryController = Get.find();
  CalendarController calendarController = Get.put(CalendarController());


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

  Future<dynamic> isMeassageAvalable(String uid) async {
    // CollectionReference collectionReference =
    //     // FirebaseFirestore.instance.collection('users');
    // collectionReference.doc(uid).get().then((value) {
    //   var fields;
    //   fields = value.data();

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
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  String useremail = '';
  String fmctoken = '';

  @override
  void initState() {
    super.initState();
    loadData();
    isMeassageAvalable(
        "${homePageController.propetydetailsInfo!.propetydetails!.userId}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadData() async {
    try {
      final Uint8List markIcons =
          await getImages("assets/images/MapPin.png", 100);

      final lat = double.tryParse(
          homePageController.propetydetailsInfo?.propetydetails!.latitude ??
              "");
      final lng = double.tryParse(homePageController
              .propetydetailsInfo?.propetydetails!.longtitude ??
          "");

      if (lat != null && lng != null) {
        _markers
          ..clear()
          ..add(osm.LatLng(lat, lng));
      }
    } catch (_) {
      // Keep screen usable even if marker/icon setup fails.
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<PropartyHomePageController>(builder: (context) {
      return Scaffold(
        backgroundColor: notifire.getbgcolor,
        body: homePageController.isProperty
            ? NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 300,
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
                        GetBuilder<PropartyHomePageController>(builder: (context) {
                          return InkWell(
                            onTap: () {
                              if (getData.read("UserLogin") != null) {
                                homePageController.addFavouriteList(
                                  pid: homePageController
                                      .propetydetailsInfo!.propetydetails!.id,
                                  propertyType: homePageController
                                      .propetydetailsInfo
                                      ?.propetydetails
                                      !.propertyType,
                                );
                              }
                            },
                            child: homePageController.propetydetailsInfo
                                        ?.propetydetails!.isFavourite ==
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
                        SizedBox(
                          width: 10,
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            SizedBox(
                              height: 470,
                              child: PageView.builder(
                                itemCount: homePageController.propetydetailsInfo
                                    ?.propetydetails!.image!.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: FadeInImage.assetNetwork(
                                      fadeInCurve: Curves.easeInCirc,
                                      placeholder:
                                          "assets/images/ezgif.com-crop.gif",
                                      height: 470,
                                      width: Get.size.width,
                                      imageErrorBuilder: (context, error, stackTrace) {
                                      return Center(child: Image.asset("assets/images/emty.gif",fit: BoxFit.cover,height: Get.height,),);
                                      },
                                      image:
                                          "${Config.imageUrl}${homePageController.propetydetailsInfo?.propetydetails!.image![index].image ?? ""}",
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                                onPageChanged: (value) {
                                  setState(() {
                                    selectIndex = value;
                                  });
                                },
                              ),
                            ),
                            homePageController
                                .propetydetailsInfo!
                                .propetydetails
                            !.image
                            !.length == 1 ? SizedBox() : Positioned(
                              bottom: 0,
                              child: SizedBox(
                                height: 25,
                                width: Get.size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ...List.generate(
                                        homePageController
                                            .propetydetailsInfo!
                                            .propetydetails
                                            !.image
                                            !.length, (index) {
                                      return IndicatorViewPage(
                                        isActive:
                                            selectIndex == index ? true : false,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            homePageController
                                        .propetydetailsInfo
                                        ?.propetydetails
                                        !.image![selectIndex]
                                        .isPanorama ==
                                    1
                                ? Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: () {
                                        Get.toNamed(Routes.imageViewerSreen,
                                            arguments: {
                                              "img": homePageController
                                                  .propetydetailsInfo
                                                  ?.propetydetails
                                                  !.image![selectIndex]
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
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: Stack(
                  children: [
                    SizedBox(
                      height: Get.size.height,
                      width: Get.size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                homePageController.propetydetailsInfo
                                        ?.propetydetails!.title ??
                                    "",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  height: 25,
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    homePageController.propetydetailsInfo
                                            ?.propetydetails!.propertyTitle ??
                                        "",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 12,
                                      color: blueColor,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFeef4ff),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  "assets/images/Rating.png",
                                  height: 20,
                                  width: 20,
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  "${homePageController.propetydetailsInfo?.propetydetails!.rate ?? ""}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontFamily: FontFamily.gilroyMedium,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        "assets/images/Frame1.png",
                                        height: 20,
                                        width: 20,
                                        color: blueColor,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFeef4ff),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${homePageController.propetydetailsInfo?.propetydetails!.beds ?? ""} ${"Beds".tr}",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        "assets/images/bath.png",
                                        height: 20,
                                        width: 20,
                                        color: blueColor,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFeef4ff),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${homePageController.propetydetailsInfo?.propetydetails!.bathrooms ?? ""} ${"Bath".tr}",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        "assets/images/sqft.png",
                                        height: 20,
                                        width: 20,
                                        color: blueColor,
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFeef4ff),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${homePageController.propetydetailsInfo?.propetydetails!.size ?? ""} ${"sqft".tr}",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                "Posted by".tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              leading: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "${Config.imageUrl}${homePageController.propetydetailsInfo?.propetydetails!.ownerImage}",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                homePageController.propetydetailsInfo
                                        ?.propetydetails!.ownerName ??
                                    "",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                              subtitle: Text(
                                "Verified Partner".tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: FontFamily.gilroyMedium,
                                ),
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Spacer(),
                                    InkWell(
                                      onTap: () async {

                                        final contactPermission = await Permission.phone.request();

                                        if(contactPermission.isGranted){
                                          if (getData.read("UserLogin") != null) {
                                            String? contactToUse = homePageController.propetydetailsInfo
                                                        ?.propetydetails!.contact!.replaceAll(" ", "");
                                            openDialer(contactToUse!);
                                            /*var url = Uri.parse(
                                                "tel:${homePageController.propetydetailsInfo?.propetydetails!.contact ?? ""}");
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }*/
                                          } else {
                                            Get.to(() => LoginScreen());
                                          }
                                        }

                                      },
                                      child: Image.asset(
                                        "assets/images/phone Icon.png",
                                        height: 25,
                                        width: 25,
                                        fit: BoxFit.cover,
                                        color: blueColor,
                                      ),
                                    ),
                                    // homePageController.propetydetailsInfo
                                    //             ?.propetydetails!.userId ==
                                    //         "0"
                                    //     ? SizedBox()
                                       /*SizedBox(
                                            width: 15,
                                          ),*/
                                    // homePageController.propetydetailsInfo
                                    //             ?.propetydetails!.userId ==
                                    //         "0"
                                    //     ? SizedBox()
                                         /*InkWell(
                                            onTap: () {
                                              if (getData.read("UserLogin") !=
                                                  null) {
                                                Get.to(ChatPage(
                                                  proPic: homePageController.propetydetailsInfo!.propetydetails!.ownerImage.toString(),
                                                  resiverUseremail: useremail,
                                                  resiverUserId: homePageController.propetydetailsInfo?.propetydetails!.userId ??
                                                          "0",
                                                ));
                                              } else {
                                                Get.to(() => LoginScreen());
                                              }
                                            },
                                            child: Image.asset(
                                              "assets/images/Chat.png",
                                              height: 28,
                                              width: 28,
                                              fit: BoxFit.cover,
                                              color: blueColor,
                                            ),
                                          ),*/
                                    SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                "About This Property".tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: ReadMoreText(
                                homePageController.propetydetailsInfo
                                        ?.propetydetails!.description ??
                                    "",
                                trimLines: 4,
                                colorClickableText: blueColor,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'Read more'.tr,
                                trimExpandedText: 'Show less'.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: FontFamily.gilroyMedium,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                "Property Facilities".tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              itemCount: homePageController
                                  .propetydetailsInfo?.facility!.length,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                              ),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      alignment: Alignment.center,
                                      child: FadeInImage.assetNetwork(
                                          height: 25,
                                          width: 25,
                                          color: blueColor,
                                          placeholder: "assets/images/loading2.gif",
                                          imageErrorBuilder: (context, error, stackTrace) {
                                          return Center(child: Image.asset("assets/images/emty.gif",fit: BoxFit.cover,height: Get.height,),);
                                          },
                                          image: "${Config.imageUrl}${homePageController.propetydetailsInfo!.facility![index].img}",
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFeef4ff),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      homePageController.propetydetailsInfo
                                              ?.facility![index].title ??
                                          "",
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        overflow: TextOverflow.ellipsis,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                            homePageController
                                    .propetydetailsInfo!.gallery!.isNotEmpty
                                ? Column(
                                    children: [
                                      gallaryAndSeeAllWidget(
                                          "Gallary".tr, "See All".tr),
                                      Container(
                                        height: 110,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(left: 15),
                                        child: ListView.builder(
                                          itemCount: homePageController
                                              .propetydetailsInfo
                                              ?.gallery
                                              !.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              height: 110,
                                              width: 110,
                                              margin: EdgeInsets.all(5),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: FadeInImage.assetNetwork(
                                                  fadeInCurve:
                                                      Curves.easeInCirc,
                                                  placeholder:
                                                      "assets/images/ezgif.com-crop.gif",
                                                  height: 110,
                                                  imageErrorBuilder: (context, error, stackTrace) {
                                                  return Center(child: Image.asset("assets/images/emty.gif",fit: BoxFit.cover,height: Get.height,),);
                                                  },
                                                  image:
                                                      "${Config.imageUrl}${homePageController.propetydetailsInfo?.gallery![index]}",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    notifire.getblackwhitecolor,

                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Text(
                                "Location".tr,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Image.asset(
                                  "assets/images/Location.png",
                                  height: 25,
                                  width: 25,
                                  fit: BoxFit.cover,
                                  color: Color(0xff3D5BF6),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  homePageController.propetydetailsInfo
                                          ?.propetydetails!.address ??
                                      "",
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: notifire.getgreycolor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 200,
                              width: Get.size.width,
                              margin: EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: osm.LatLng(
                                      double.tryParse(homePageController.propetydetailsInfo?.propetydetails!.latitude ?? "") ?? 0,
                                      double.tryParse(homePageController.propetydetailsInfo?.propetydetails!.longtitude ?? "") ?? 0,
                                    ),
                                    initialZoom: 15,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.caresoko.app',
                                    ),
                                    MarkerLayer(
                                      markers: _markers
                                          .map(
                                            (p) => Marker(
                                              point: p,
                                              width: 40,
                                              height: 40,
                                              child: const Icon(Icons.location_on,
                                                  color: Colors.red, size: 34),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: notifire.getblackwhitecolor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: const Offset(
                                      0.5,
                                      0.5,
                                    ),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            homePageController
                                    .propetydetailsInfo!.reviewlist!.isNotEmpty
                                ? reviewWidget(
                                    "${homePageController.propetydetailsInfo?.propetydetails!.rate ?? ""}(${homePageController.propetydetailsInfo?.totalReview} ${"reviews".tr})",
                                    "See All".tr,
                                    Icon(
                                      Icons.star,
                                      color: yelloColor,
                                    ),
                                  )
                                : SizedBox(),
                            homePageController
                                    .propetydetailsInfo!.reviewlist!.isNotEmpty
                                ? ListView.builder(
                                    itemCount: homePageController
                                        .propetydetailsInfo?.reviewlist!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: NeverScrollableScrollPhysics(),
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
                                                  "${Config.imageUrl}${homePageController.propetydetailsInfo?.reviewlist![index].userImg ?? ""}",
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            "${homePageController.propetydetailsInfo?.reviewlist![index].userTitle ?? ""}",
                                            style: TextStyle(
                                              color:
                                                  notifire.getwhiteblackcolor,
                                              fontFamily: FontFamily.gilroyBold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "${homePageController.propetydetailsInfo?.reviewlist![index].userDesc ?? ""}",
                                            textAlign: TextAlign.start,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: notifire.getgreycolor,
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                            ),
                                          ),
                                          trailing: Container(
                                            height: 40,
                                            width: 70,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: blueColor,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${homePageController.propetydetailsInfo?.reviewlist![index].userRate ?? ""}",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    color: blueColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: blueColor,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 80,
                        width: Get.size.width,
                        color: notifire.getblackwhitecolor,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 15),
                                    child: Text(
                                      "Price".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        color: greycolor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 15),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${currency}${homePageController.propetydetailsInfo?.propetydetails!.price ?? ""}",
                                          style: TextStyle(
                                            color: Color(0xFF4772ff),
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        homePageController
                                                    .propetydetailsInfo
                                                    ?.propetydetails
                                                    !.buyorrent ==
                                                "1"
                                            ? Text(
                                                "/night".tr,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                ),
                                              )
                                            : Text(""),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GetBuilder<BookrealEstateController>(
                                builder: (context) {
                              return GetBuilder<CalendarController>(
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder:(context, setState) {
                                      return Expanded(
                                        child: homePageController.propetydetailsInfo
                                                    ?.propetydetails!.buyorrent ==
                                                "1"
                                            ? GestButton(
                                                Width: Get.size.width,
                                                height: 70,
                                                buttoncolor: Color(0xFF4772ff),
                                                margin: EdgeInsets.only(
                                                    top: 10, right: 10, bottom: 10),
                                                buttontext: "Book".tr,
                                                onclick: () {

                                                  if(getData.read("UserLogin") != null){
                                                    bookrealEstateController.cleanDate();
                                                    print(">:>:>:>:>:>:>:>:>:> PROPERTY ID : > ${homePageController.propetydetailsInfo?.propetydetails!.id}");
                                                    calendarController.calendar(homePageController.propetydetailsInfo!.propetydetails!.id).then((value) {
                                                      Get.toNamed(Routes.bookRealEstate);
                                                    },);
                                                    reviewSummaryController.getProductObject(
                                                      pim: homePageController.propetydetailsInfo?.propetydetails!.image![0].image,
                                                      pti: homePageController
                                                          .propetydetailsInfo
                                                          ?.propetydetails
                                                      !.title ??
                                                          "",
                                                      pci: homePageController
                                                          .propetydetailsInfo
                                                          ?.propetydetails
                                                      !.city ??
                                                          "",
                                                      /*price: homePageController
                                                          .propetydetailsInfo
                                                          ?.propetydetails
                                                      !.price,*/
                                                      pId: homePageController
                                                          .propetydetailsInfo
                                                          ?.propetydetails
                                                      !.id ??
                                                          "",
                                                      pLimit: homePageController
                                                          .propetydetailsInfo
                                                          ?.propetydetails
                                                      !.capacity ??
                                                          "1",
                                                    );
                                                  } else {
                                                    showToastMessage(
                                                        "Please login and Book"
                                                            .tr);
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontFamily: FontFamily.gilroyBold,
                                                  color: WhiteColor,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : /*homePageController.propetydetailsInfo
                                                        ?.propetydetails!.isEnquiry ==
                                                    1
                                                ? GestButton(
                                                    Width: Get.size.width,
                                                    height: 70,
                                                    buttoncolor: RedColor,
                                                    margin: EdgeInsets.only(
                                                        top: 10, right: 10, bottom: 10),
                                                    buttontext: "Contacted".tr,
                                                    onclick: () {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Enquiry Already Send!!".tr,
                                                        gravity: ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor: RedColor,
                                                        textColor: Colors.white,
                                                        fontSize: 14.0,
                                                      );
                                                    },
                                                    style: TextStyle(
                                                      fontFamily: FontFamily.gilroyBold,
                                                      color: WhiteColor,
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                : */GestButton(
                                                    Width: Get.size.width,
                                                    height: 70,
                                                    buttoncolor: Color(0xFF4772ff),
                                                    margin: EdgeInsets.only(
                                                        top: 10, right: 10, bottom: 10),
                                                    buttontext: "Inquire".tr,
                                                    onclick: () {
                                                      String? contactToUse = homePageController.propetydetailsInfo
                                                        ?.propetydetails!.contact!.replaceAll(" ", "");
                                                      openDialer(contactToUse!);
                                                      /*if (getData.read("UserLogin") !=
                                                          null) {
                                                        homePageController
                                                            .enquirySetApi(
                                                          pId: homePageController
                                                              .propetydetailsInfo
                                                              ?.propetydetails
                                                              !.id,
                                                        );
                                                        Get.back();
                                                      } else {
                                                        showToastMessage(
                                                            "Please login and send enquery"
                                                                .tr);
                                                      }*/
                                                    },
                                                    style: TextStyle(
                                                      fontFamily: FontFamily.gilroyBold,
                                                      color: WhiteColor,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                      );
                                    }
                                  );
                                }
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      );
    });
  }

  Widget gallaryAndSeeAllWidget(String name, String buttonName) {
    return Row(
      children: [
        SizedBox(
          width: 15,
        ),
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
                pId: homePageController.propetydetailsInfo?.propetydetails!.id);
            Get.toNamed(Routes.galleryScreen);
          },
          child: Text(
            buttonName,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Widget reviewWidget(String name, String buttonName, Icon icon) {
    return Row(
      children: [
        SizedBox(
          width: 15,
        ),
        icon,
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
            Get.toNamed(Routes.reviewScreen, arguments: {
              "list": homePageController.propetydetailsInfo?.reviewlist
            });
          },
          child: Text(
            buttonName,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Future<void> openDialer(String phoneNumber) async {
  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
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
