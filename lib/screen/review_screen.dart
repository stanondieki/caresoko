// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  HomePageController homePageController = Get.find();

  List reviewList = Get.arguments["list"];
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
          "${homePageController.propetydetailsInfo?.propetydetails!.rate ?? ""}(${homePageController.propetydetailsInfo?.totalReview} ${"reviews".tr})",
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: reviewList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              "${Config.imageUrl}${reviewList[index].userImg ?? ""}",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        "${reviewList[index].userTitle ?? ""}",
                        style: TextStyle(
                          color: notifire.getwhiteblackcolor,
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text(
                        "${reviewList[index].userDesc ?? ""}",
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: TextStyle(
                          color: notifire.getgreycolor,
                          fontFamily: FontFamily.gilroyMedium,
                        ),
                      ),
                      trailing: Container(
                        height: 40,
                        width: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: blueColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${reviewList[index].userRate ?? ""}",
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                color: blueColor,
                              ),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: blueColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: notifire.getgreycolor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
