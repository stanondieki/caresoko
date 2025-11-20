// ignore_for_file: prefer_const_constructors, sort_child_properties_last, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/gallerycategory_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddGalleryCategoryScreen extends StatefulWidget {
  const AddGalleryCategoryScreen({super.key});

  @override
  State<AddGalleryCategoryScreen> createState() =>
      _AddGalleryCategoryScreenState();
}

List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddGalleryCategoryScreenState extends State<AddGalleryCategoryScreen> {
  GalleryCategoryController galleryCategoryController = Get.find();
  DashBoardController dashBoardController = Get.find();
  ListOfPropertiController listOfPropertiController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectProparty;
  String slectStatus = propartyStatus.first;

  String manageRoutes = Get.arguments["add"];

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
    if (manageRoutes == "edit") {
      galleryCategoryController.emptyDetails();
      galleryCategoryController.name.text = galleryCategoryController.catName;
      selectProparty = galleryCategoryController.selectProperty;
      setState(() {});
    } else {
      selectProparty = null;
      galleryCategoryController.pType = "";
      galleryCategoryController.emptyDetails();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
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
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
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
                                galleryCategoryController.pType =
                                    listOfPropertiController
                                            .propListInfo?.proplist![i].id ??
                                        "";
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
                      textfield(
                        type: "Gallery Category Name".tr,
                        controller: galleryCategoryController.name,
                        labelText: "Category Name".tr,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Category Name'.tr;
                          }
                          return null;
                        },
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
                        height: 10,
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
                              galleryCategoryController.status = "1";
                            } else if (value == "UnPublish") {
                              galleryCategoryController.status = "0";
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
                          if (_formKey.currentState?.validate() ?? false) {
                            if (selectProparty != null) {
                              if (manageRoutes == "Add") {
                                galleryCategoryController.addGalleyCat();
                              } else if (manageRoutes == "edit") {
                                galleryCategoryController.editGalleryCat();
                              }
                            } else {
                              showToastMessage(
                                  "Please Select Property Type".tr);
                            }
                          }
                        },
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: notifire.getbgcolor,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  textfield(
      {String? type,
      labelText,
      prefixtext,
      suffix,
      Color? labelcolor,
      prefixcolor,
      floatingLabelColor,
      focusedBorderColor,
      TextDecoration? decoration,
      double? Width,
      TextEditingController? controller,
      TextInputType? textInputType,
      Function(String)? onChanged,
      String? Function(String?)? validator,
      Height}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            type ?? "",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          height: Height,
          width: Width,
          margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: notifire.getblackwhitecolor),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: notifire.getwhiteblackcolor,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(
                color: notifire.getwhiteblackcolor,
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 18),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: TextStyle(
                  color: Colors.grey,
                  fontFamily: "Gilroy Medium",
                  fontSize: 16),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: blueColor),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifire.getborderColor),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
