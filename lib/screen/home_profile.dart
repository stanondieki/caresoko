// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unused_local_variable, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously, unused_field, non_constant_identifier_names, unused_element, deprecated_member_use, prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/login_controller.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:readmore/readmore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProfileScreen extends StatefulWidget {
  const HomeProfileScreen({super.key});

  @override
  State<HomeProfileScreen> createState() => _HomeProfileScreenState();
}

class _HomeProfileScreenState extends State<HomeProfileScreen> {
  late ColorNotifire notifire;
  HomePageController homePageController = Get.find();

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

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
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: notifire.getbgcolor,
        appBar: AppBar(
          backgroundColor: notifire.getbgcolor,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 15, left: 14, bottom: 15),
            child: Image.asset(
              "assets/images/applogo.png",
              height: 10,
              width: 10,
            ),
          ),
          title: Text(
            "Home Profile".tr,
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
          child: GetBuilder<SignUpController>(builder: (context) {
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  GetBuilder<LoginController>(builder: (context) {
                    return Stack(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: SizedBox(
                            height: 120,
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Image.network(
                                "${Config.imageUrl}${homePageController.propetydetailsInfo?.propetydetails!.logo}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${homePageController.propetydetailsInfo?.propetydetails!.name}",
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 20,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(
                      color: notifire.getborderColor,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: Text(
                        "About Us".tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: FontFamily.gilroyBold,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: ReadMoreText(
                        homePageController
                                .propetydetailsInfo?.propetydetails!.about ??
                            "",
                        trimLines: 10,
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
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: Text(
                        "Our Mission".tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: FontFamily.gilroyBold,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: ReadMoreText(
                        homePageController
                                .propetydetailsInfo?.propetydetails!.mission ??
                            "",
                        trimLines: 10,
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
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: Text(
                        "Our Vision".tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: FontFamily.gilroyBold,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10),
                      child: ReadMoreText(
                        homePageController
                                .propetydetailsInfo?.propetydetails!.vision ??
                            "",
                        trimLines: 10,
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
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  homePageController
                              .propetydetailsInfo?.propetydetails!.website !=
                          "None"
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 10),
                            child: Text(
                              "Our Website".tr,
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: FontFamily.gilroyBold,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  homePageController
                              .propetydetailsInfo?.propetydetails!.website !=
                          "None"
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, top: 10),
                            child: ReadMoreText(
                              homePageController.propetydetailsInfo
                                      ?.propetydetails!.website ??
                                  "",
                              trimLines: 10,
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
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
