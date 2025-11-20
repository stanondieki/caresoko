// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/wallet_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletController walletController = Get.find();
  HomePageController homePageController = Get.find();

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
    walletController.getWalletReportData();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
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
          "Wallet".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<HomePageController>(builder: (context) {
              return GetBuilder<WalletController>(builder: (context) {
                return Container(
                  height: Get.height * 0.28,
                  width: Get.size.width,
                  margin: EdgeInsets.only(left: 15, top: 15, right: 15),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, left: 15),
                        child: Text(
                          "Wallet".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: FontFamily.gilroyBold,
                            color: WhiteColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 15),
                        child: Text(
                          "${currency}${walletController.walletInfo?.wallet}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 45,
                            fontFamily: FontFamily.gilroyBold,
                            color: WhiteColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0, left: 15),
                        child: Text(
                          "Your current Balance".tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: FontFamily.gilroyBold,
                            color: WhiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/walletIMage.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              });
            }),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 25),
              child: Text(
                "History".tr,
                style: TextStyle(
                  fontSize: 17,
                  color: notifire.getwhiteblackcolor,
                  fontFamily: FontFamily.gilroyMedium,
                ),
              ),
            ),
            Expanded(
              child: GetBuilder<WalletController>(builder: (context) {
                return walletController.isLoading
                    ? walletController.walletInfo!.walletitem!.isNotEmpty
                        ? ListView.builder(
                            itemCount:
                                walletController.walletInfo?.walletitem!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.all(10),
                                child: ListTile(
                                  leading: Container(
                                    height: 70,
                                    width: 60,
                                    padding: EdgeInsets.all(12),
                                    child: Image.asset(
                                      "assets/images/Wallet.png",
                                      color: blueColor,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color(0xFFf6f7f9),
                                    ),
                                  ),
                                  title: Text(
                                    walletController.walletInfo
                                            ?.walletitem![index].tdate ??
                                        "",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: notifire.getwhiteblackcolor,
                                      fontFamily: FontFamily.gilroyBold,
                                      // fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  subtitle: Text(
                                    walletController.walletInfo
                                            ?.walletitem![index].status ??
                                        "",
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: notifire.getwhiteblackcolor,
                                      fontFamily: FontFamily.gilroyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  trailing: walletController.walletInfo
                                              ?.walletitem![index].status ==
                                          "Credit"
                                      ? TextButton(
                                          onPressed: () {},
                                          child: Text(
                                              "${walletController.walletInfo?.walletitem![index].amt ?? ""}${currency} +"),
                                        )
                                      : TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            "${walletController.walletInfo?.walletitem![index].amt ?? ""}${currency} -",
                                            style: TextStyle(
                                              color: Colors.orange.shade300,
                                            ),
                                          ),
                                        ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: notifire.getborderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
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
                                  "Go & Add your Amount".tr,
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
                      );
              }),
            ),
            GestButton(
              Width: Get.size.width,
              height: 50,
              buttoncolor: blueColor,
              margin: EdgeInsets.only(top: 15, left: 35, right: 35),
              buttontext: "ADD AMOUNT".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                color: WhiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onclick: () {
                Get.toNamed(Routes.addWalletScreen);
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
