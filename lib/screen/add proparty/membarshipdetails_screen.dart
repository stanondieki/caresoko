// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_brace_in_string_interps, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberShipDetails extends StatefulWidget {
  const MemberShipDetails({super.key});

  @override
  State<MemberShipDetails> createState() => _MemberShipDetailsState();
}

class _MemberShipDetailsState extends State<MemberShipDetails> {
  DashBoardController dashBoardController = Get.find();

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

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
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: BackButton(
          color: blueColor,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Membership Details".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
            fontSize: 17,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: GetBuilder<DashBoardController>(builder: (context) {
            return dashBoardController.isSubLoading
                ? dashBoardController
                        .subDetailsInfo!.subscribedetails!.isNotEmpty
                    ? Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            height: 130,
                            width: 130,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/Illustration.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Stack(
                            children: [
                              Container(
                                height: 92,
                                width: Get.size.width,
                                margin: EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${dashBoardController.subDetailsInfo?.subscribedetails![0].planTitle ?? ""} Plan",
                                          style: TextStyle(
                                            color: Color(0xff3D5BF6),
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          "${dashBoardController.subDetailsInfo?.subscribedetails![0].day} ${"days".tr}",
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            knowMoreSheet(
                                              discription: dashBoardController
                                                      .subDetailsInfo
                                                      ?.subscribedetails![0]
                                                      .planDescription ??
                                                  "",
                                              day: dashBoardController
                                                      .subDetailsInfo
                                                      ?.subscribedetails![0]
                                                      .day ??
                                                  "",
                                              image: dashBoardController
                                                      .subDetailsInfo
                                                      ?.subscribedetails![0]
                                                      .planImage ??
                                                  "",
                                            );
                                          },
                                          child: Text(
                                            "Know More".tr,
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              fontSize: 13,
                                              color: Color(0xFFFACC15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text(
                                          dashBoardController
                                                  .subDetailsInfo
                                                  ?.subscribedetails![0]
                                                  .amount ??
                                              "",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontFamily: FontFamily.gilroyBold,
                                            color: Color(0xff3D5BF6),
                                          ),
                                        ),
                                        Container(
                                          height: 35,
                                          width: 20,
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            "${currency}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: FontFamily.gilroyBold,
                                              color: Color(0xff3D5BF6),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    )
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xff3D5BF6)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 40,
                                child: Container(
                                  height: 25,
                                  width: 70,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "ACTIVE".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 12,
                                      color: WhiteColor,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xff3D5BF6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          detailsRow(
                            detailsName: "Status".tr,
                            value: "Success".tr,
                            color: Color(0xFF398B2B),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          detailsRow(
                            detailsName: "Transaction ID".tr,
                            value: dashBoardController.subDetailsInfo
                                    ?.subscribedetails![0].transId ??
                                "",
                            color: notifire.getwhiteblackcolor,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          detailsRow(
                            detailsName: "Transaction Date".tr,
                            value: dashBoardController
                                .subDetailsInfo?.subscribedetails![0].startDate
                                .toString()
                                .split(" ")
                                .first,
                            color: notifire.getwhiteblackcolor,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          detailsRow(
                            detailsName: "Payment Method".tr,
                            value: dashBoardController.subDetailsInfo
                                    ?.subscribedetails![0].pName ??
                                "",
                            color: notifire.getwhiteblackcolor,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            height: 40,
                            width: Get.size.width,
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Total".tr,
                                  style: TextStyle(
                                    color: Color(0xFF808080),
                                    fontFamily: FontFamily.gilroyBold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  "${currency}${dashBoardController.subDetailsInfo?.subscribedetails![0].amount ?? ""}",
                                  style: TextStyle(
                                    color: notifire.getwhiteblackcolor,
                                    fontFamily: FontFamily.gilroyBold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          child: Column(
                            children: [
                              SizedBox(height: Get.height * 0.10),
                              Image(
                                image: AssetImage(
                                  "assets/images/searchDataEmpty.png",
                                ),
                                height: 110,
                                width: 110,
                              ),
                              Center(
                                child: SizedBox(
                                  width: Get.width * 0.80,
                                  child: Text(
                                    "Sorry, there is no any nearby \n category or data not found"
                                        .tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: notifire.getgreycolor,
                                      fontFamily: FontFamily.gilroyBold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }),
        ),
      ),
    );
  }

  Widget detailsRow({String? detailsName, value, Color? color}) {
    return Row(
      children: [
        SizedBox(
          width: 15,
        ),
        Text(
          detailsName ?? "",
          style: TextStyle(
            color: Color(0xFF808080),
            fontFamily: FontFamily.gilroyMedium,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        Spacer(),
        Text(
          value ?? "",
          style: TextStyle(
            color: color,
            fontFamily: FontFamily.gilroyBold,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        SizedBox(
          width: 15,
        ),
      ],
    );
  }

  Future<void> knowMoreSheet({String? discription, day, image}) {
    return Get.bottomSheet(
      Container(
        width: Get.size.width,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                "${Config.imageUrl}${image}",
                height: 100,
                width: Get.size.width,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                "Package Description:".tr,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 16,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 10,
              ),
              child: HtmlWidget(
                discription ?? "",
                textStyle: TextStyle(
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 16,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  Text(
                    "Validty: ".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 16,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                  Text(
                    "${day} ${"Days".tr}",
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: notifire.getblackwhitecolor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
    );
  }
}
