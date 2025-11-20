// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, deprecated_member_use, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/extraimage_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddExtraImageScreen extends StatefulWidget {
  const AddExtraImageScreen({super.key});

  @override
  State<AddExtraImageScreen> createState() => _AddExtraImageScreenState();
}

List<String> propartyStatus = ["Publish", "UnPublish"];
List<String> propartyPanorama = ["Yes", "No"];

class _AddExtraImageScreenState extends State<AddExtraImageScreen> {
  ExtraImageController extraImageController = Get.find();
  ListOfPropertiController listOfPropertiController = Get.find();
  String manageRoute = Get.arguments["add"];

  String? selectProparty;
  String slectStatus = propartyStatus.first;
  String selectPanorama = propartyPanorama.first;

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
    if (manageRoute == "Add") {
      setState(() {
        extraImageController.pType = "";
        selectProparty = null;
        extraImageController.image = "";
        extraImageController.path = null;
      });
    } else if (manageRoute == "edit") {
      setState(() {
        selectProparty = extraImageController.selectProperty;
      });
    }
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
          "Extra Images".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Select Home Or Facility".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 60,
                      width: Get.size.width,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: DropdownButton(
                        value: selectProparty,
                        dropdownColor: notifire.getbgcolor,
                        hint: Text(
                          "Select Home Or Facility".tr,
                          style: TextStyle(color: Colors.grey),
                        ),
                        icon: Image.asset(
                          'assets/images/Arrow - Down.png',
                          height: 20,
                          width: 20,
                          color: notifire.getwhiteblackcolor,
                        ),
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        items: listOfPropertiController.propertyList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                color: notifire.getwhiteblackcolor,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          for (var i = 0;
                              i <
                                  listOfPropertiController
                                      .propListInfo!.proplist!.length;
                              i++) {
                            if (value ==
                                listOfPropertiController
                                    .propListInfo?.proplist![i].name) {
                              extraImageController.pType =
                                  listOfPropertiController
                                          .propListInfo?.proplist![i].id ??
                                      "";
                              print(extraImageController.pType);
                            }
                          }
                          setState(() {
                            selectProparty = value ?? "";
                            // listOfUser.add(selectValue);
                          });
                        },
                      ),
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: notifire.getborderColor),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Upload Image".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DottedBorder(
                      borderType: BorderType.RRect,
                      color: Color(0xff3D5BF6),
                      radius: Radius.circular(15),
                      borderPadding: EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          _openGallery(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: manageRoute == "Add"
                              ? Container(
                                  height: 80,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  width: Get.size.width,
                                  alignment: Alignment.center,
                                  child: extraImageController.path == null
                                      ? Image.asset(
                                          "assets/images/image-upload.png",
                                          height: 40,
                                          width: 42,
                                        )
                                      : Image.file(
                                          File(extraImageController.path
                                              .toString()),
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                )
                              : Container(
                                  height: 80,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  width: Get.size.width,
                                  alignment: Alignment.center,
                                  child: extraImageController.image == ""
                                      ? Image.asset(
                                          "assets/images/image-upload.png",
                                          height: 40,
                                          width: 42,
                                        )
                                      : extraImageController.path == null
                                          ? Image.network(
                                              "${Config.imageUrl}${extraImageController.image}",
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(
                                                extraImageController.path
                                                    .toString(),
                                              ),
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "360 Image".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 60,
                      width: Get.size.width,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: DropdownButton(
                        value: selectPanorama,
                        dropdownColor: notifire.getbgcolor,
                        icon: Image.asset(
                          'assets/images/Arrow - Down.png',
                          height: 20,
                          width: 20,
                          color: notifire.getwhiteblackcolor,
                        ),
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        items: propartyPanorama
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                color: notifire.getwhiteblackcolor,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == "Yes") {
                            extraImageController.isPanorama = "1";
                          } else if (value == "No") {
                            extraImageController.isPanorama = "0";
                          }
                          setState(() {
                            selectPanorama = value ?? "";
                          });
                        },
                      ),
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: notifire.getborderColor),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Gallery Status".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 60,
                      width: Get.size.width,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: DropdownButton(
                        value: slectStatus,
                        dropdownColor: notifire.getbgcolor,
                        icon: Image.asset(
                          'assets/images/Arrow - Down.png',
                          height: 20,
                          width: 20,
                          color: notifire.getwhiteblackcolor,
                        ),
                        isExpanded: true,
                        underline: SizedBox.shrink(),
                        items: propartyStatus
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                color: notifire.getwhiteblackcolor,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == "Publish") {
                            extraImageController.status = "1";
                          } else if (value == "UnPublish") {
                            extraImageController.status = "0";
                          }
                          setState(() {
                            slectStatus = value ?? "";
                          });
                        },
                      ),
                      decoration: BoxDecoration(
                        color: notifire.getblackwhitecolor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: notifire.getborderColor),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    GestButton(
                      Width: Get.size.width,
                      height: 55,
                      buttoncolor: blueColor,
                      margin: EdgeInsets.only(top: 5, left: 35, right: 35),
                      buttontext: "Update".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        color: WhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      onclick: () {
                        if (selectProparty != null) {
                          if (extraImageController.path != null ||
                              extraImageController.image != "") {
                            if (manageRoute == "Add") {
                              extraImageController.addExtraImage();
                            } else if (manageRoute == "edit") {
                              extraImageController.editExtraImage();
                            }
                          } else {
                            showToastMessage("Please Upload Image".tr);
                          }
                        } else {
                          showToastMessage("Please Select Proparty".tr);
                        }
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: notifire.getblackwhitecolor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    print(pickedFile?.path.toString());
    if (pickedFile != null) {
      extraImageController.path = pickedFile.path;
      print(extraImageController.path.toString());
      setState(() {});
      File imageFile = File(extraImageController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      extraImageController.base64Image = base64Encode(imageBytes);
      print(extraImageController.base64Image.toString());
      setState(() {});
    } else {
      print("Null Image");
    }
  }
}
