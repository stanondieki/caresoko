// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageViewerSreen extends StatefulWidget {
  const ImageViewerSreen({super.key});

  @override
  State<ImageViewerSreen> createState() => _ImageViewerSreenState();
}

class _ImageViewerSreenState extends State<ImageViewerSreen> {
  String image = Get.arguments["img"];

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
    getdarkmodepreviousstate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        title: Text(
          "360 Preview",
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Get.back();
          },
          color: notifire.getwhiteblackcolor,
        ),
      ),
      body: PanoramaViewer(
        child: Image.network(Config.imageUrl + image),
        zoom: 0,
      ),
    );
  }
}
