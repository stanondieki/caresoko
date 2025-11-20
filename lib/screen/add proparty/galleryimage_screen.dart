// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/galleryimage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GallertImageScreen extends StatefulWidget {
  const GallertImageScreen({super.key});

  @override
  State<GallertImageScreen> createState() => _GallertImageScreenState();
}

class _GallertImageScreenState extends State<GallertImageScreen> {
  GalleryImageController galleryImageController = Get.find();
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
          "Gallery Images".tr,
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
                Get.toNamed(Routes.addGalleryImageScreen, arguments: {
                  "add": "Add",
                });
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
              child: GetBuilder<GalleryImageController>(builder: (context) {
                return Container(
                  color: notifire.getblackwhitecolor,
                  child: galleryImageController.isLoading
                      ? galleryImageController
                              .addGalleryInfo!.gallerylist.isNotEmpty
                          ? ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                              itemCount: galleryImageController
                                  .addGalleryInfo?.gallerylist.length,
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
                                                  BorderRadius.circular(8),
                                              child: FadeInImage.assetNetwork(
                                                fadeInCurve: Curves.easeInCirc,
                                                placeholder:
                                                "assets/images/ezgif.com-crop.gif",
                                                height: 48,
                                                width: 48,
                                                imageErrorBuilder: (context, error, stackTrace) {
                                                 return Image.asset("assets/images/ezgif.com-crop.gif",height: 48,width: 48,fit: BoxFit.cover,);
                                                },
                                                image:
                                                "${Config.imageUrl}${galleryImageController.addGalleryInfo?.gallerylist[index].image ?? ""}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    galleryImageController
                                                            .addGalleryInfo
                                                            ?.gallerylist[index]
                                                            .propertyTitle ??
                                                        "",
                                                    style: TextStyle(
                                                      color: notifire
                                                          .getwhiteblackcolor,
                                                      fontFamily:
                                                          FontFamily.gilroyBold,
                                                      fontSize: 16,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    galleryImageController
                                                            .addGalleryInfo
                                                            ?.gallerylist[index]
                                                            .categoryTitle ??
                                                        "",
                                                    style: TextStyle(
                                                      color: notifire
                                                          .getwhiteblackcolor,
                                                      fontFamily:
                                                          FontFamily.gilroyMedium,
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
                                            galleryImageController
                                                .getGalleryImageAndId(
                                              recId: galleryImageController
                                                      .addGalleryInfo
                                                      ?.gallerylist[index]
                                                      .id ??
                                                  "",
                                              gImg: galleryImageController
                                                      .addGalleryInfo
                                                      ?.gallerylist[index]
                                                      .image ??
                                                  "",
                                              selectPro: galleryImageController
                                                      .addGalleryInfo
                                                      ?.gallerylist[index]
                                                      .propertyTitle ??
                                                  "",
                                              pId: galleryImageController
                                                      .addGalleryInfo
                                                      ?.gallerylist[index]
                                                      .propertyId ??
                                                  "",
                                            );
                                            galleryImageController.catId =
                                                galleryImageController
                                                        .addGalleryInfo
                                                        ?.gallerylist[index]
                                                        .categoryId ??
                                                    "";
                                            galleryImageController.slectStatus =
                                                galleryImageController
                                                        .addGalleryInfo
                                                        ?.gallerylist[index]
                                                        .categoryTitle ??
                                                    "";
                                            galleryImageController.propertyWiseGalleryCat(proId: galleryImageController.addGalleryInfo?.gallerylist[index].id).then((value) {
                                              Get.toNamed(
                                                  Routes.addGalleryImageScreen,
                                                  arguments: {
                                                    "add": "edit",
                                                  });
                                            },);
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
            )
          ],
        ),
      ),
    );
  }
}
