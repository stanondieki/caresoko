// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/enquiry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  EnquiryController enquiryController = Get.find();
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
    enquiryController.enquiryListApi();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: notifire.getwhiteblackcolor,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Enquire".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 17,
          ),
        ),
      ),
      body: GetBuilder<EnquiryController>(builder: (context) {
        return enquiryController.isLoading
            ? enquiryController.enquiryInfo!.enquiryData!.isNotEmpty
                ? ListView.builder(
                    itemCount:
                        enquiryController.enquiryInfo?.enquiryData!.length,
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        height: 125,
                        width: Get.size.width,
                        margin: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 125,
                                  width: 110,
                                  margin: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: FadeInImage.assetNetwork(
                                      fadeInCurve: Curves.easeInCirc,
                                      placeholder:
                                      "assets/images/ezgif.com-crop.gif",
                                      height: 140,
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return Image.asset("assets/images/ezgif.com-crop.gif",height: 48,width: 48,fit: BoxFit.cover,);
                                      },
                                      image:
                                      "${Config.imageUrl}${enquiryController.enquiryInfo?.enquiryData![index].image ?? ""}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                enquiryController.enquiryInfo
                                            ?.enquiryData![index].isSell ==
                                        "0"
                                    ? Positioned(
                                        top: 15,
                                        right: 20,
                                        child: Container(
                                          height: 27,
                                          width: 45,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "BUY".tr,
                                            style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFedeeef),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      )
                                    : Positioned(
                                        top: 15,
                                        right: 20,
                                        child: Container(
                                          height: 27,
                                          width: 45,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "SOLD".tr,
                                            style: TextStyle(
                                              color: Color(0xFFEA1E61),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFedeeef),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                      )
                              ],
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          enquiryController
                                                  .enquiryInfo
                                                  ?.enquiryData![index]
                                                  .title ??
                                              "",
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontFamily: FontFamily.gilroyBold,
                                            color:
                                                notifire.getwhiteblackcolor,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Text(
                                        "Name: ".tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: FontFamily.gilroyMedium,
                                          color: notifire.getwhiteblackcolor,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          enquiryController.enquiryInfo
                                                  ?.enquiryData![index].name ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: notifire.getwhiteblackcolor,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Text(
                                        "Mobile Number: ".tr,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: FontFamily.gilroyMedium,
                                          color: notifire.getwhiteblackcolor,
                                        ),
                                      ),
                                      Text(
                                        enquiryController.enquiryInfo
                                                ?.enquiryData![index].mobile ??
                                            "",
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: FontFamily.gilroyMedium,
                                          color: notifire.getwhiteblackcolor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: notifire.getborderColor),
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
                          "Go & Enquiry your favorite service".tr,
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
    );
  }
}
