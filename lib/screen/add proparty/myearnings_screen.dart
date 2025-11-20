// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/booking_controller.dart';
import 'package:gotocarefinder/controller/myearning_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  MyEarningController myEarningController = Get.find();
  BookingController bookingController = Get.find();
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
    super.initState();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: BackButton(
          color: notifire.getwhiteblackcolor,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "My Earnings...".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
      body: GetBuilder<MyEarningController>(builder: (context) {
        return SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: myEarningController.isLoading
              ? myEarningController.earningInfo!.statuswise!.isNotEmpty
                  ? ListView.builder(
                      itemCount:
                          myEarningController.earningInfo?.statuswise!.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {},
                              child: Container(
                                height: 155,
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          height: 135,
                                          width: 130,
                                          margin: EdgeInsets.all(10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: FadeInImage.assetNetwork(
                                              fadeInCurve: Curves.easeInCirc,
                                              placeholder:
                                                  "assets/images/ezgif.com-crop.gif",
                                              height: 135,
                                              imageErrorBuilder: (context, error, stackTrace) {
                                                return Image.asset("assets/images/ezgif.com-crop.gif",height: 48,width: 48,fit: BoxFit.cover,);
                                              },
                                              image:
                                                  "${Config.imageUrl}${myEarningController.earningInfo?.statuswise![index].propImg ?? ""}",
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
                                                  myEarningController
                                                          .earningInfo
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
                                            myEarningController
                                                    .earningInfo
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
                                                "${currency}${int.parse(myEarningController.earningInfo?.statuswise![index].propPrice ?? "") * int.parse(myEarningController.earningInfo?.statuswise![index].totalDay ?? "")}",
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
                                                "/${myEarningController.earningInfo?.statuswise![index].totalDay ?? ""} ${"days".tr}",
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
                                                bookId: myEarningController
                                                        .earningInfo
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
        );
      }),
    );
  }
}
