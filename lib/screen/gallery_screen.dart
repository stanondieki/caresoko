// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable, use_key_in_widget_constructors, unnecessary_string_interpolations, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/gallery_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  GalleryController galleryController = Get.find();
  PageController pageController = PageController();

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
          "Gallary".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: GetBuilder<GalleryController>(builder: (context) {
        return Column(
          children: [
            galleryController.isLoading
                ? Expanded(
                    child: ListView.builder(
                      itemCount:
                          galleryController.galleryInfo?.gallerydata!.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index1) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: SizedBox(
                                height: 25,
                                child: galleryController.galleryInfo!
                                        .gallerydata![index1].imglist!.isEmpty
                                    ? SizedBox()
                                    : Text(
                                        galleryController.galleryInfo
                                                ?.gallerydata![index1].title ??
                                            "",
                                        style: TextStyle(
                                          color: notifire.getwhiteblackcolor,
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 17,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 115,
                              child: ListView.builder(
                                itemCount: galleryController.galleryInfo
                                    ?.gallerydata![index1].imglist!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.to(FullScreenImage(
                                        index1: index1,
                                      ));
                                    },
                                    child: Container(
                                      height: 115,
                                      width: 110,
                                      margin: EdgeInsets.all(8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FadeInImage.assetNetwork(
                                          fadeInCurve: Curves.easeInCirc,
                                          placeholder:
                                              "assets/images/ezgif.com-crop.gif",
                                          height: 110,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Image.asset(
                                                "assets/images/emty.gif",
                                                fit: BoxFit.cover,
                                                height: Get.height,
                                              ),
                                            );
                                          },
                                          image:
                                              "${Config.imageUrl}${galleryController.galleryInfo?.gallerydata![index1].imglist![index]}",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: notifire.getblackwhitecolor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        );
      }),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final int index1;
  String? imageUrl;
  String? tag;
  FullScreenImage({this.imageUrl, this.tag, required this.index1});
  GalleryController galleryController = Get.find();
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: tag ?? "",
            child: PhotoViewGallery.builder(
              itemCount: galleryController
                  .galleryInfo?.gallerydata![index1].imglist!.length,
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(
                      "${Config.imageUrl}${galleryController.galleryInfo?.gallerydata![index1].imglist![index]}"),
                );
              },
              pageController: pageController,
              onPageChanged: (index) {},
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
