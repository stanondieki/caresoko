// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/wallet_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferFriendScreen extends StatefulWidget {
  const ReferFriendScreen({super.key});

  @override
  State<ReferFriendScreen> createState() => _ReferFriendScreenState();
}

class _ReferFriendScreenState extends State<ReferFriendScreen> {
  WalletController walletController = Get.find();
  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
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
    getPackage();
  }

  void getPackage() async {
    //! App details get
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    packageName = packageInfo!.packageName;
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
          "Refer a Friend".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: GetBuilder<WalletController>(builder: (context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: SizedBox(
            height: Get.size.height,
            width: Get.size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/images/refer.png",
                  height: 220,
                  width: Get.size.width,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Earn ${currency + walletController.refercredit} for Each\n Friend you refer",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/lovef.png",
                            height: 28,
                            width: 28,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Share the referral link with your friends".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 16,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/lovef.png",
                            height: 28,
                            width: 28,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Friend get ${currency + walletController.refercredit} on their first complete\ntransaction",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 16,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/lovef.png",
                            height: 28,
                            width: 28,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "You get ${currency + walletController.signupcredit} on your wallet ",
                            textAlign: TextAlign.start,
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
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  height: 50,
                  width: Get.size.width,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 15, left: 35, right: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            walletController.rCode,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            new ClipboardData(text: walletController.rCode),
                          );
                          showToastMessage("Copy");
                        },
                        child: Image.asset(
                          "assets/images/copy.png",
                          height: 20,
                          width: 20,
                          color: blueColor,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFe1e9f5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                GestButton(
                  Width: Get.size.width,
                  height: 50,
                  buttoncolor: blueColor,
                  margin: EdgeInsets.only(top: 15, left: 35, right: 35),
                  buttontext: "Refer a friend".tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: WhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: () async {
                    await Share.share(
                        'https://play.google.com/store/apps/details?id=$packageName',
                        subject:
                            'Hey! Finding care for mum or dad has never been easier! View Adult Family Homes and other Care Facilities in any zipcode or city, with numerous features and high quality photos and videos. And easily schedule tours at your convenience');
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> share() async {
    print("!!!!!!!!!!" + appName.toString());
    print("!!!!!!!!!!" + packageName.toString());
    await Share.share(
        'https://play.google.com/store/apps/details?id=$packageName',
        subject:
            'Hey! Finding care for mum or dad has never been easier! View Adult Family Homes and other Care Facilities in any zipcode or city, with numerous features and high quality photos and videos. And easily schedule tours at your convenience');
  }
}
