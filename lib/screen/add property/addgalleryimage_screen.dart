// ignore_for_file: prefer_const_constructors, sort_child_properties_last, deprecated_member_use

import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/galleryimage_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddGalleryImageScreen extends StatefulWidget {
  const AddGalleryImageScreen({super.key});

  @override
  State<AddGalleryImageScreen> createState() => _AddGalleryImageScreenState();
}

List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddGalleryImageScreenState extends State<AddGalleryImageScreen> {
  GalleryImageController galleryImageController = Get.find();
  ListOfPropertiController listOfPropertiController = Get.find();
  String mangeRoute = Get.arguments != null ? Get.arguments["add"] ?? "Add" : "Add";

  bool selectGalleryCat = false;
  String selectStatus = propartyStatus.first;
  String? selectProparty;

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
    print("fcsxvgdxgv ${galleryImageController.selectGalleryCat}");
    super.initState();
    if (mangeRoute == "Add") {
      galleryImageController.emptyDetails();
    } else {
      selectProparty = galleryImageController.selectProprty;
      galleryImageController.propertyWiseGalleryCat(
        proId: galleryImageController.pType,
      );
      setState(() {});
    }
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifire.getbgcolor,
        centerTitle: true,
        title: Container(
          child: Text(
            "Gallery Images".tr,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(
                width: Get.size.width,
                color: notifire.getbgcolor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Select Property".tr,
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
                    Container(
                      height: 60,
                      width: Get.size.width,
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: DropdownButton(
                        dropdownColor: notifire.getbgcolor,
                        hint: Text(
                          "Select Proerty".tr,
                          style: TextStyle(color: Colors.grey),
                        ),
                        value: selectProparty,
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
                              galleryImageController.pType =
                                  listOfPropertiController
                                          .propListInfo?.proplist![i].id ??
                                      "";
                              galleryImageController.propertyWiseGalleryCat(
                                proId: listOfPropertiController
                                        .propListInfo?.proplist![i].id ??
                                    "",
                              );
                            }
                          }
                          setState(() {
                            selectProparty = value ?? "";
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
                        "Select Gallery Category".tr,
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
                    GetBuilder<GalleryImageController>(builder: (context) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.only(left: 15, right: 15),
                          childrenPadding: EdgeInsets.only(left: 15, right: 15),
                          initiallyExpanded: selectGalleryCat,
                          onExpansionChanged: (value) {
                            setState(() {
                              selectGalleryCat = value;
                            });
                          },
                          title: Text("${galleryImageController.slectStatus}",
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                color: notifire.getwhiteblackcolor,
                                fontSize: 14,
                              )),
                          trailing: Image.asset(
                            'assets/images/Arrow - Down.png',
                            height: 20,
                            width: 20,
                            color: notifire.getwhiteblackcolor,
                          ),
                          collapsedBackgroundColor: notifire.getblackwhitecolor,
                          backgroundColor: notifire.getblackwhitecolor,
                          collapsedShape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: notifire.getborderColor)),
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide:
                                  BorderSide(color: notifire.getborderColor)),
                          children: [
                            ListView.builder(
                              itemCount: galleryImageController
                                  .selectGalleryCat.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return galleryImageController.catId ==
                                        galleryImageController.propertyWiseInfo
                                            ?.galcatlist[index].id
                                    ? SizedBox()
                                    : Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                galleryImageController.catId =
                                                    galleryImageController
                                                            .propertyWiseInfo
                                                            ?.galcatlist[index]
                                                            .id ??
                                                        "";
                                                galleryImageController
                                                        .slectStatus =
                                                    galleryImageController
                                                                .selectGalleryCat[
                                                            index] ??
                                                        "";
                                              });
                                            },
                                            child: Text(
                                                galleryImageController
                                                    .selectGalleryCat[index],
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  color: notifire
                                                      .getwhiteblackcolor,
                                                  fontSize: 14,
                                                ))),
                                      );
                              },
                            )
                          ],
                        ),
                      );
                    }),
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
                          child: mangeRoute == "Add"
                              ? Container(
                                  height: 80,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  width: Get.size.width,
                                  alignment: Alignment.center,
                                  child: galleryImageController.path == null ||
                                      galleryImageController.base64Image == null ||
                                      galleryImageController.base64Image!.isEmpty
                                      ? Image.asset(
                                          "assets/images/image-upload.png",
                                          height: 40,
                                          width: 42,
                                        )
                                      : Image.memory(
                                          base64Decode(galleryImageController
                                              .base64Image!),
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
                                  child: galleryImageController.gImage == ""
                                      ? Image.asset(
                                          "assets/images/image-upload.png",
                                          height: 40,
                                          width: 42,
                                        )
                                      : galleryImageController.path == null ||
                                          galleryImageController.base64Image == null ||
                                          galleryImageController.base64Image!.isEmpty
                                          ? Image.network(
                                              "${Config.imageUrl}${galleryImageController.gImage}",
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.memory(
                                              base64Decode(galleryImageController
                                                  .base64Image!),
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
                        value: selectStatus,
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
                            galleryImageController.status = "1";
                          } else if (value == "UnPublish") {
                            galleryImageController.status = "0";
                          }
                          setState(() {
                            selectStatus = value ?? "";
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
                          if (galleryImageController.slectStatus != null) {
                            if (galleryImageController.path != null ||
                                galleryImageController.gImage != "") {
                              if (mangeRoute == "Add") {
                                galleryImageController.addGallery();
                              } else if (mangeRoute == "edit") {
                                galleryImageController.editGalley();
                              }
                            } else {
                              showToastMessage("Please Upload Image".tr);
                            }
                          } else {
                            showToastMessage(
                                "Please Select Gallery Category".tr);
                          }
                        } else {
                          showToastMessage("Please Select Property Type".tr);
                        }
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
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
    if (pickedFile != null) {
      galleryImageController.path = pickedFile.path;
      setState(() {});
      List<int> imageBytes = await pickedFile.readAsBytes();
      galleryImageController.base64Image = base64Encode(imageBytes);
      setState(() {});
    }
  }
}
