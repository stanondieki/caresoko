// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print, prefer_const_constructors_in_immutables, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/coupon_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouponsScreen extends StatefulWidget {
  CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  TextEditingController coupon = TextEditingController();
  CouponController couponController = Get.find();

  String price = Get.arguments["price"];

  bool visibilityUse = false;

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
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              "assets/images/x.png",
              height: 25,
              width: 25,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        title: Text(
          "Coupons".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20),
            child: Text(
              "Available coupons".tr,
              style: TextStyle(
                fontSize: 17,
                fontFamily: FontFamily.gilroyBold,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
          GetBuilder<CouponController>(builder: (context) {
            return Expanded(
              child: couponController.isLodding
                  ? ListView.builder(
                      itemCount:
                          couponController.couponListInfo?.couponlist!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 120,
                          width: Get.size.width,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                padding: EdgeInsets.all(12),
                                child: Image.network(
                                    "${Config.imageUrl}${couponController.couponListInfo?.couponlist![index].cImg ?? ""}"),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xFFf6f7f9),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      couponController
                                              .couponListInfo
                                              ?.couponlist![index]
                                              .couponTitle ??
                                          "",
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: notifire.getwhiteblackcolor,
                                        fontFamily: FontFamily.gilroyBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            couponController
                                                    .couponListInfo
                                                    ?.couponlist![index]
                                                    .cDesc ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            print(
                                                "PRICE  > : > : > :> : > :> : > $price");
                                            if (double.parse(price) >=
                                                int.parse(couponController
                                                        .couponListInfo
                                                        ?.couponlist![index]
                                                        .minAmt ??
                                                    "")) {
                                              couponController
                                                  .checkCouponDataApi(
                                                cid: couponController
                                                    .couponListInfo
                                                    ?.couponlist![index]
                                                    .id,
                                              );
                                              Get.back(result: {
                                                "coupAdded": true,
                                                "copAmt": int.parse(
                                                    couponController
                                                            .couponListInfo
                                                            ?.couponlist![index]
                                                            .cValue ??
                                                        ""),
                                                "fname": "",
                                                "lname": "",
                                                "gender": "",
                                                "email": "",
                                                "mobile": "",
                                                "ccode": "",
                                                "couponCode": couponController
                                                        .couponListInfo
                                                        ?.couponlist![index]
                                                        .couponCode ??
                                                    "",
                                              });
                                            }
                                          },
                                          child: Text(
                                            "Use".tr,
                                            style: TextStyle(
                                              color: double.parse(price) >=
                                                      int.parse(couponController
                                                              .couponListInfo
                                                              ?.couponlist![
                                                                  index]
                                                              .minAmt ??
                                                          "")
                                                  ? blueColor
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Ex ${couponController.couponListInfo?.couponlist![index].cdate.toString().replaceAll(" 00:00:00.000", "") ?? ""}",
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: notifire.getwhiteblackcolor,
                                        fontFamily: FontFamily.gilroyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: notifire.getblackwhitecolor,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
