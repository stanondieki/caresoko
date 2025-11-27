// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/gallerycategory_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryCategoryScreen extends StatefulWidget {
  const GalleryCategoryScreen({super.key});

  @override
  State<GalleryCategoryScreen> createState() => _GalleryCategoryScreenState();
}

class _GalleryCategoryScreenState extends State<GalleryCategoryScreen> {
  GalleryCategoryController galleryCategoryController = Get.find();
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
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifire.getblackwhitecolor,
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
          "Gallery Category".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              onTap: () {
                // COMMENTED OUT: Advert functionality disabled
                // Get.toNamed(
                //   Routes.addGalleryCategoryScreen,
                //   arguments: {"add": "Add"},
                // );
              },
              child: Container(
                height: 50,
                width: 50,
                child: Icon(
                  Icons.add,
                  color: WhiteColor,
                ),
                decoration: BoxDecoration(
                  color: Color(0xff3D5BF6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GetBuilder<GalleryCategoryController>(builder: (context) {
                return Container(
                  color: notifire.getblackwhitecolor,
                  child: galleryCategoryController.isLoading
                      ? galleryCategoryController
                              .galleryCatInfo!.galcatlist.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.only(top: 10),
                              itemCount: galleryCategoryController
                                  .galleryCatInfo?.galcatlist.length,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 7),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 70,
                                        width: Get.size.width,
                                        margin: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                "assets/images/Image (2).png",
                                                height: 48,
                                                width: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    galleryCategoryController
                                                            .galleryCatInfo
                                                            ?.galcatlist[index]
                                                            .propertyTitle ??
                                                        "",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: notifire
                                                          .getwhiteblackcolor,
                                                      fontFamily:
                                                          FontFamily.gilroyBold,
                                                      fontSize: 16,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    galleryCategoryController
                                                            .galleryCatInfo
                                                            ?.galcatlist[index]
                                                            .catTitle ??
                                                        "",
                                                    style: TextStyle(
                                                      color: notifire
                                                          .getwhiteblackcolor,
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: notifire.getborderColor),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () {
                                            galleryCategoryController
                                                .getIdAndName(
                                              recId: galleryCategoryController
                                                      .galleryCatInfo
                                                      ?.galcatlist[index]
                                                      .id ??
                                                  "",
                                              categoryName:
                                                  galleryCategoryController
                                                          .galleryCatInfo
                                                          ?.galcatlist[index]
                                                          .catTitle ??
                                                      "",
                                              selectPro:
                                                  galleryCategoryController
                                                          .galleryCatInfo
                                                          ?.galcatlist[index]
                                                          .propertyTitle ??
                                                      "",
                                              pId: galleryCategoryController
                                                      .galleryCatInfo
                                                      ?.galcatlist[index]
                                                      .propertyId ??
                                                  "",
                                            );
                                            // COMMENTED OUT: Advert functionality disabled
                                            // Get.toNamed(
                                            //   Routes.addGalleryCategoryScreen,
                                            //   arguments: {"add": "edit"},
                                            // );
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            padding: EdgeInsets.all(9),
                                            alignment: Alignment.center,
                                            child: Image.asset(
                                                "assets/images/Pen (1).png"),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xff3D5BF6),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
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
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
