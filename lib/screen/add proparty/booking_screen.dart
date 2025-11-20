// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unused_field, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/booking_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  BookingController bookingController = Get.find();
  TabController? _tabController;

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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController?.index == 0;
    print("|||||||||||${_tabController?.index}");
    if (_tabController?.index == 0) {
      bookingController.statusWiseBook = "active";
      bookingController.getBookingStatusWise();
    }
    getdarkmodepreviousstate();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
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
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        title: Text(
          "Booking".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
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
                onTap: (value) {
                  if (value == 0) {
                    bookingController.statusWiseBook = "active";
                    bookingController.getBookingStatusWise();
                  } else {
                    bookingController.statusWiseBook = "completed";
                    bookingController.getBookingStatusWise();
                  }
                },
                tabs: [
                  Tab(
                    text: "Current Booking".tr,
                  ),
                  Tab(
                    text: "Completed".tr,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  activeWidget(),
                  completedWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activeWidget() {
    return GetBuilder<BookingController>(builder: (context) {
      return RefreshIndicator(
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 2),
            () {
              bookingController.getBookingStatusWise();
            },
          );
        },
        child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: bookingController.isLoading
              ? bookingController.proStatusWiseInfo!.statuswise!.isNotEmpty
                  ? ListView.builder(
                      itemCount: bookingController
                          .proStatusWiseInfo?.statuswise!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await bookingController.getBookingDetails(
                                  bookId: bookingController.proStatusWiseInfo
                                          ?.statuswise![index].bookId ??
                                      "",
                                );
                                Get.toNamed(
                                  Routes.eReceiptProScreen,
                                );
                              },
                              child: Container(
                                height: 150,
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 130,
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/images/ezgif.com-crop.gif",
                                              height: 140,
                                              imageErrorBuilder: (context, error, stackTrace) {
                                                return Image.asset("assets/images/ezgif.com-crop.gif",height: 48,width: 48,fit: BoxFit.cover,);
                                              },
                                              image:
                                                  "${Config.imageUrl}${bookingController.proStatusWiseInfo?.statuswise![index].propImg ?? ""}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        Positioned(
                                          top: 15,
                                          right: 20,
                                          child: Container(
                                            height: 30,
                                            width: 45,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 3, 0),
                                                  child: Image.asset(
                                                    "assets/images/Rating.png",
                                                    height: 12,
                                                    width: 12,
                                                  ),
                                                ),
                                                Text(
                                                  bookingController
                                                          .proStatusWiseInfo
                                                          ?.statuswise![index]
                                                          .rate ??
                                                      "",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyMedium,
                                                    color: blueColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFedeeef),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            bookingController
                                                    .proStatusWiseInfo
                                                    ?.statuswise![index]
                                                    .propTitle ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontFamily:
                                                  FontFamily.gilroyBold,
                                              color:
                                                  notifire.getwhiteblackcolor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${currency}${int.parse(bookingController.proStatusWiseInfo?.statuswise![index].propPrice ?? "") * int.parse(bookingController.proStatusWiseInfo?.statuswise![index].totalDay ?? "")}",
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 20,
                                                  color: blueColor,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "/${bookingController.proStatusWiseInfo?.statuswise![index].totalDay ?? ""} ${"days"}",
                                                style: TextStyle(
                                                  color: notifire.getgreycolor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          bookingController
                                                      .proStatusWiseInfo
                                                      ?.statuswise![index]
                                                      .pMethodId !=
                                                  "2"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      height: 30,
                                                      width: 60,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "Paid".tr,
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontFamily: FontFamily
                                                              .gilroyMedium,
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: blueColor),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      height: 30,
                                                      width: 85,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "UnPaid".tr,
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontFamily: FontFamily
                                                              .gilroyMedium,
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.red),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 15,
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: notifire.getblackwhitecolor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Image.asset(
                              "assets/images/bookingEmpty.png",
                              height: 110,
                              width: 100,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Go & Book your favorite service".tr,
                            style: TextStyle(
                              color: notifire.getgreycolor,
                              fontFamily: FontFamily.gilroyBold,
                            ),
                          )
                        ],
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      );
    });
  }

  Widget completedWidget() {
    return GetBuilder<BookingController>(builder: (context) {
      return RefreshIndicator(
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 2),
            () {
              bookingController.getBookingStatusWise();
            },
          );
        },
        child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: bookingController.isLoading
              ? bookingController.proStatusWiseInfo!.statuswise!.isNotEmpty
                  ? ListView.builder(
                      itemCount: bookingController
                          .proStatusWiseInfo?.statuswise!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {

                              },
                              child: Container(
                                height: 155,
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 140,
                                          width: 130,
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/images/ezgif.com-crop.gif",
                                              height: 140,
                                              imageErrorBuilder: (context, error, stackTrace) {
                                                return Image.asset("assets/images/ezgif.com-crop.gif",height: 48,width: 48,fit: BoxFit.cover,);
                                              },
                                              image:
                                                  "${Config.imageUrl}${bookingController.proStatusWiseInfo?.statuswise![index].propImg ?? ""}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        Positioned(
                                          top: 15,
                                          right: 20,
                                          child: Container(
                                            height: 30,
                                            width: 45,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 0, 3, 0),
                                                  child: Image.asset(
                                                    "assets/images/Rating.png",
                                                    height: 12,
                                                    width: 12,
                                                  ),
                                                ),
                                                Text(
                                                  bookingController
                                                          .proStatusWiseInfo
                                                          ?.statuswise![index]
                                                          .rate ??
                                                      "",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyMedium,
                                                    color: blueColor,
                                                  ),
                                                )
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFedeeef),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            bookingController
                                                    .proStatusWiseInfo
                                                    ?.statuswise![index]
                                                    .propTitle ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontFamily:
                                                  FontFamily.gilroyBold,
                                              color:
                                                  notifire.getwhiteblackcolor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "${currency}${int.parse(bookingController.proStatusWiseInfo?.statuswise![index].propPrice ?? "") * int.parse(bookingController.proStatusWiseInfo?.statuswise![index].totalDay ?? "")}",
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 20,
                                                  color: blueColor,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "/${bookingController.proStatusWiseInfo?.statuswise![index].totalDay ?? ""} days",
                                                style: TextStyle(
                                                  color: notifire.getgreycolor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              await bookingController
                                                  .getBookingDetails(
                                                bookId: bookingController
                                                        .proStatusWiseInfo
                                                        ?.statuswise![index]
                                                        .bookId ??
                                                    "",
                                              );
                                              Get.toNamed(
                                                Routes.eReceiptProScreen,
                                              );
                                            },
                                            child: Container(
                                              height: 35,
                                              width: 120,
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                "E-Receipt".tr,
                                                style: TextStyle(
                                                  color: blueColor,
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: blueColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: notifire.getblackwhitecolor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Image.asset(
                              "assets/images/bookingEmpty.png",
                              height: 110,
                              width: 100,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Go & Book your favorite service".tr,
                            style: TextStyle(
                              color: notifire.getgreycolor,
                              fontFamily: FontFamily.gilroyBold,
                            ),
                          ),
                        ],
                      ),
                    )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      );
    });
  }
}
