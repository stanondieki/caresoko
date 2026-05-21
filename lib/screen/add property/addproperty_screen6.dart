// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/addproperties_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/enquiry_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPropertyScreen6 extends StatefulWidget {
  const AddPropertyScreen6({super.key});

  @override
  State<AddPropertyScreen6> createState() => _AddPropertyScreen6State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreen6State extends State<AddPropertyScreen6> {
  final AddPropertiesController addPropertiesController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments["add"];

  String selectValue = list.first;
  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();

    if (manegeRoute == "edit") {
      addPropertiesController.pricingReady =
          addPropertiesController.ePricingReady ?? false;
      addPropertiesController.propertyPricingController.text =
          addPropertiesController.ePropertyPricing ?? "";
      addPropertiesController.propertyLicenseNoController.text =
          addPropertiesController.ePropertyLicenseNo ?? "";
      setState(() {});
    }

    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        backgroundColor: notifire.getblackwhitecolor,
        elevation: 0,
        title: Text(
          manegeRoute == "Add"
              ? "Add Home Or Facility".tr
              : "Edit Home Or Facility".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final bool isPhone = w < 700;
            final bool isTablet = w >= 700 && w < 1100;
            final bool isDesktop = w >= 1100;

            final double maxContentWidth =
                isDesktop ? 1000 : (isTablet ? 900 : w);
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 12 : 20,
              vertical: isPhone ? 0 : 8,
            );

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: pagePadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: notifire.getblackwhitecolor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  _h1("Just A Few More Things"),
                                  const SizedBox(height: 25),
                                  _stepText(manegeRoute == "Add"
                                      ? "Step 6 of 8"
                                      : "Step 5 of 7"),
                                  const SizedBox(height: 10),
                                  _h2("Licensing And Pricing"),
                                  const SizedBox(height: 10),
                                  Divider(
                                      height: 0.5,
                                      color: notifire.getgreycolor),
                                  const SizedBox(height: 20),

                                  // Do you have ready pricing?
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      "Do you have ready pricing?".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _ynBlock(
                                    yesChecked:
                                        addPropertiesController.pricingReady,
                                    yesLabel: "Yes",
                                    noChecked:
                                        !addPropertiesController.pricingReady,
                                    noLabel:
                                        "Our pricing is based on care plan assessment",
                                    onYes: () => setState(() =>
                                        addPropertiesController.pricingReady =
                                            true),
                                    onNo: () => setState(() =>
                                        addPropertiesController.pricingReady =
                                            false),
                                  ),
                                  const SizedBox(height: 10),

                                  // Pricing + License responsive row
                                  if (addPropertiesController.pricingReady)
                                    _pricingAndLicenseRow(isPhone),

                                  if (!addPropertiesController.pricingReady)
                                    _licenseOnlyField(),

                                  const SizedBox(height: 20),

                                  // Next button
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isPhone ? 24 : 35),
                                    child: GestButton(
                                      Width: double.infinity,
                                      height: 55,
                                      buttoncolor: blueColor,
                                      margin: EdgeInsets.zero,
                                      buttontext: "Next".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        color: WhiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onclick: () {
                                        addPropertiesController
                                                .propertyLicenseNo =
                                            addPropertiesController
                                                .propertyLicenseNoController
                                                .text;
                                        addPropertiesController
                                                .propertyPricing =
                                            addPropertiesController
                                                .propertyPricingController.text;

                                        // COMMENTED OUT: Advert functionality disabled
                                        // Get.toNamed(
                                        //   Routes.addPropertyScreen7,
                                        //   arguments: {"add": manegeRoute},
                                        // );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- Responsive pieces ----------

  Widget _pricingAndLicenseRow(bool isPhone) {
    final pricingField = _pricingFieldCard();
    final licenseField = _licenseFieldCard();

    if (isPhone) {
      return Column(
        children: [
          pricingField,
          const SizedBox(height: 12),
          licenseField,
        ],
      );
    }

    // Tablet/Desktop: 2 columns
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: pricingField),
          const SizedBox(width: 16),
          Expanded(child: licenseField),
        ],
      ),
    );
  }

  Widget _pricingFieldCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _h2("Pricing"),
        const SizedBox(height: 8),
        Container(
          margin: EdgeInsets.only(top: 5, left: 15, right: 15),
          decoration: BoxDecoration(
            color: notifire.getblackwhitecolor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: notifire.getborderColor),
          ),
          child: TextFormField(
            controller: addPropertiesController.propertyPricingController,
            minLines: 8,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            cursorColor: notifire.getwhiteblackcolor,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: blueColor),
                borderRadius: BorderRadius.circular(15),
              ),
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
              hintText:
                  "Pricing breakdown (per day/week/month) with different service packages (e.g., full care, partial care, day-only)."
                      .tr,
              hintStyle:
                  TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 15),
            ),
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
            validator: (value) {
              if (addPropertiesController.pricingReady) {
                if (value == null || value.isEmpty) {
                  return 'Please Break Down Your Pricing'.tr;
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _licenseFieldCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _h2("License Number"),
        const SizedBox(height: 8),
        _licenseOnlyField(),
      ],
    );
  }

  Widget _licenseOnlyField() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15),
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: TextFormField(
        controller: addPropertiesController.propertyLicenseNoController,
        keyboardType: TextInputType.text,
        cursorColor: notifire.getwhiteblackcolor,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: blueColor),
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(12),
          border: InputBorder.none,
          hintText: "License Number".tr,
          hintStyle:
              TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 15),
        ),
        style: TextStyle(
          fontFamily: FontFamily.gilroyMedium,
          fontSize: 16,
          color: notifire.getwhiteblackcolor,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Enter Your License Number'.tr;
          }
          return null;
        },
      ),
    );
  }

  // ---------- Shared small helpers from earlier screens ----------

  Widget _h1(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text.tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  Widget _h2(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text.tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  Widget _stepText(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text.tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: notifire.getgreycolor,
          ),
        ),
      );

  Widget _ynBlock({
    required bool yesChecked,
    required String yesLabel,
    required bool noChecked,
    required String noLabel,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            Transform.scale(
              scale: 1,
              child: Checkbox(
                value: yesChecked,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) => onYes(),
              ),
            ),
            Text(
              yesLabel.tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 17,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(thickness: 1),
        ),
        Row(
          children: [
            SizedBox(width: 10),
            Transform.scale(
              scale: 1,
              child: Checkbox(
                value: noChecked,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) => onNo(),
              ),
            ),
            Expanded(
              child: Text(
                noLabel.tr,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 17,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  // Kept for parity with your codebase (not used here but preserved)
  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addPropertiesController.path = pickedFile.path;
      setState(() {});
      File imageFile = File(addPropertiesController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addPropertiesController.base64Image = base64Encode(imageBytes);
      // print debug if you need
    }
  }

  // Original textfield helper (not used but retained if other parts rely on it)
  Widget textfield({
    String? type,
    labelText,
    prefixtext,
    suffix,
    Color? labelcolor,
    prefixcolor,
    floatingLabelColor,
    focusedBorderColor,
    TextDecoration? decoration,
    bool? readOnly,
    double? Width,
    int? max,
    TextEditingController? controller,
    TextInputType? textInputType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    Height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
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
        SizedBox(height: 6),
        Container(
          height: Height,
          width: Width,
          margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: notifire.getwhiteblackcolor,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: max,
            readOnly: readOnly ?? false,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
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

// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/controller/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/enquiry_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
//
// class AddPropertyScreen6 extends StatefulWidget {
//   const AddPropertyScreen6({super.key});
//
//   @override
//   State<AddPropertyScreen6> createState() => _AddPropertyScreen6State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen6State extends State<AddPropertyScreen6> {
//   AddPropertiesController addPropertiesController = Get.find();
//   DashBoardController dashBoardController = Get.find();
//   EnquiryController enquriryController = Get.find();
//   SelectCountryController selectCountryController = Get.find();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String manegeRoute = Get.arguments["add"];
//
//   String selectValue = list.first;
//   String? selectProperty;
//   String? selectCountry;
//   String slectStatus = propartyStatus.first;
//
//   bool carCheck = false;
//   bool sportCheck = false;
//   bool laundaryCheck = false;
//
//   late ColorNotifire notifire;
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     if (previusstate == null) {
//       notifire.setIsDark = false;
//     } else {
//       notifire.setIsDark = previusstate;
//     }
//   }
//
//   Future<Position> locateUser() async {
//     return Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }
//
//   /*Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate:
//           addPropertiesController.propertyLicenseExpiry ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.black, // Header background
//               onPrimary: Colors.white, // Header text
//               onSurface: Colors.black, // Calendar text
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null &&
//         picked != addPropertiesController.propertyLicenseExpiry) {
//       setState(() {
//         addPropertiesController.propertyLicenseExpiry = picked;
//         addPropertiesController.propertyLicenseExpiryController.text =
//             DateFormat('dd/MM/yyyy').format(picked);
//       });
//     }
//   }*/
//
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     if (manegeRoute == "edit") {
//       addPropertiesController.pricingReady =
//           addPropertiesController.ePricingReady!;
//       addPropertiesController.propertyPricingController.text =
//           addPropertiesController.ePropertyPricing!;
//       addPropertiesController.propertyLicenseNoController.text =
//           addPropertiesController.ePropertyLicenseNo!;
//
//       setState(() {});
//     }
//
//     getdarkmodepreviousstate();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getfevAndSearch,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(
//             Icons.arrow_back,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//         backgroundColor: notifire.getblackwhitecolor,
//         elevation: 0,
//         title: Text(
//           manegeRoute == "Add"
//               ? "Add Home Or Facility".tr
//               : "Edit Home Or Facility".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: BouncingScrollPhysics(),
//                   child: Container(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Just A Few More Things".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 18,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 25,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             manegeRoute == "Add"
//                                 ? "Step 6 of 8".tr
//                                 : "Step 5 of 7",
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 14,
//                               color: notifire.getgreycolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Licensing And Pricing".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: notifire.getgreycolor,
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you have ready pricing?".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Column(
//                           children: [
//                             Row(
//                               children: [
//                                 SizedBox(width: 10),
//                                 Transform.scale(
//                                   scale: 1,
//                                   child: Checkbox(
//                                     value: addPropertiesController.pricingReady,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.pricingReady =
//                                           true;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Yes",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 20),
//                               child: Divider(thickness: 1),
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(width: 10),
//                                 Transform.scale(
//                                   scale: 1,
//                                   child: Checkbox(
//                                     value:
//                                         !addPropertiesController.pricingReady,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.pricingReady =
//                                           false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 70,
//                                   child: Text(
//                                     "Our pricing is based on care plan assessment",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 17,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         addPropertiesController.pricingReady
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Pricing".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : SizedBox(),
//                         addPropertiesController.pricingReady
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : SizedBox(),
//                         addPropertiesController.pricingReady
//                             ? Container(
//                                 margin: EdgeInsets.only(
//                                     top: 5, left: 15, right: 15),
//                                 child: TextFormField(
//                                   controller: addPropertiesController
//                                       .propertyPricingController,
//                                   minLines: 5,
//                                   keyboardType: TextInputType.multiline,
//                                   maxLines: null,
//                                   cursorColor: notifire.getwhiteblackcolor,
//                                   autovalidateMode:
//                                       AutovalidateMode.onUserInteraction,
//                                   decoration: InputDecoration(
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(color: blueColor),
//                                       borderRadius: BorderRadius.circular(15),
//                                     ),
//                                     contentPadding: EdgeInsets.all(10),
//                                     border: InputBorder.none,
//                                     hintText:
//                                         "Pricing breakdown (per day/week/month) with different service packages (e.g., full care, partial care, day-only)."
//                                             .tr,
//                                     hintStyle: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Please Break Down Your Pricing'
//                                           .tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: notifire.getblackwhitecolor,
//                                   borderRadius: BorderRadius.circular(15),
//                                   border: Border.all(
//                                       color: notifire.getborderColor),
//                                 ),
//                               )
//                             : SizedBox(),
//                         addPropertiesController.pricingReady
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : SizedBox(),
//                         textfield(
//                           type: "License Number".tr,
//                           controller: addPropertiesController
//                               .propertyLicenseNoController,
//                           labelText: "License Number".tr,
//                           textInputType: TextInputType.text,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Your License Number'.tr;
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         GestButton(
//                           Width: Get.size.width,
//                           height: 55,
//                           buttoncolor: blueColor,
//                           margin: EdgeInsets.only(top: 5, left: 35, right: 35),
//                           buttontext: "Next".tr,
//                           style: TextStyle(
//                             fontFamily: FontFamily.gilroyBold,
//                             color: WhiteColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           onclick: () {
//                             addPropertiesController.propertyLicenseNo =
//                                 addPropertiesController
//                                     .propertyLicenseNoController.text;
//
//                             addPropertiesController.propertyPricing =
//                                 addPropertiesController
//                                     .propertyPricingController.text;
//
//                             Get.toNamed(
//                               Routes.addPropertyScreen7,
//                               arguments: {"add": manegeRoute},
//                             );
//                             /*if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     if (selectCountry != null) {
//                                       if (selectProperty != null) {
//                                         if (addPropertiesController
//                                             .selectedIndexes.isNotEmpty) {
//                                           if (addPropertiesController.lat !=
//                                                   null &&
//                                               addPropertiesController.long !=
//                                                   null) {
//                                             if (addPropertiesController.path !=
//                                                     null ||
//                                                 addPropertiesController
//                                                         .pImage !=
//                                                     "") {
//                                               if (manegeRoute == "Add") {
//                                                 addPropertiesController
//                                                     .addPropertyApi();
//                                               } else if (manegeRoute ==
//                                                   "edit") {
//                                                 addPropertiesController
//                                                     .editPropertyApi();
//                                               }
//                                             } else {
//                                               showToastMessage(
//                                                   "Please Upload Image".tr);
//                                             }
//                                           } else {
//                                             showToastMessage(
//                                                 "Please Add Your Property Location"
//                                                     .tr);
//                                           }
//                                         } else {
//                                           showToastMessage(
//                                               "Please Select Property Facility"
//                                                   .tr);
//                                         }
//                                       } else {
//                                         showToastMessage(
//                                             "Please Select Property Type".tr);
//                                       }
//                                     } else {
//                                       showToastMessage(
//                                           "Please Select Country".tr);
//                                     }
//                                   }*/
//                           },
//                         ),
//                         SizedBox(
//                           height: 25,
//                         ),
//                       ],
//                     ),
//                     decoration: BoxDecoration(
//                       color: notifire.getblackwhitecolor,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _openGallery(BuildContext context) async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       addPropertiesController.path = pickedFile.path;
//       setState(() {});
//       File imageFile = File(addPropertiesController.path.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       addPropertiesController.base64Image = base64Encode(imageBytes);
//       print("!!!!!!!!!++++++++++++${addPropertiesController.base64Image}");
//       setState(() {});
//     }
//   }
//
//   textfield(
//       {String? type,
//       labelText,
//       prefixtext,
//       suffix,
//       Color? labelcolor,
//       prefixcolor,
//       floatingLabelColor,
//       focusedBorderColor,
//       TextDecoration? decoration,
//       bool? readOnly,
//       double? Width,
//       int? max,
//       TextEditingController? controller,
//       TextInputType? textInputType,
//       Function(String)? onChanged,
//       String? Function(String?)? validator,
//       Height}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 10,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 15),
//           child: Text(
//             type ?? "",
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//               fontSize: 16,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 6,
//         ),
//         Container(
//           height: Height,
//           width: Width,
//           margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: notifire.getblackwhitecolor),
//           child: TextFormField(
//             controller: controller,
//             onChanged: onChanged,
//             cursorColor: notifire.getwhiteblackcolor,
//             keyboardType: textInputType,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             maxLength: max,
//             readOnly: readOnly ?? false,
//             style: TextStyle(
//                 color: notifire.getwhiteblackcolor,
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 18),
//             decoration: InputDecoration(
//               hintText: labelText,
//               hintStyle: TextStyle(
//                   color: Colors.grey,
//                   fontFamily: "Gilroy Medium",
//                   fontSize: 16),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: blueColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: notifire.getborderColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }
//
//   /*dateTextField(
//       {String? type,
//       String? labelText,
//       String? prefixtext,
//       Widget? suffix,
//       Color? labelcolor,
//       Color? prefixcolor,
//       Color? floatingLabelColor,
//       Color? focusedBorderColor,
//       TextDecoration? decoration,
//       bool? readOnly,
//       double? Width,
//       int? max,
//       TextEditingController? controller,
//       TextInputType? textInputType,
//       Function(String)? onChanged,
//       String? Function(String?)? validator,
//       bool? isDatePicker,
//       Function(DateTime?)? onDateSelected,
//       double? Height}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 10,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 15),
//           child: Text(
//             type ?? "",
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//               fontSize: 16,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 6,
//         ),
//         Container(
//           height: Height,
//           width: Width,
//           margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: notifire.getblackwhitecolor),
//           child: TextFormField(
//             controller: controller,
//             onChanged: onChanged,
//             cursorColor: notifire.getwhiteblackcolor,
//             keyboardType: textInputType,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             maxLength: max,
//             readOnly: isDatePicker == true ? true : readOnly ?? false,
//             onTap: isDatePicker == true ? () => _selectDate(context) : null,
//             style: TextStyle(
//                 color: notifire.getwhiteblackcolor,
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 18),
//             decoration: InputDecoration(
//               hintText: labelText,
//               hintStyle: TextStyle(
//                   color: Colors.grey,
//                   fontFamily: "Gilroy Medium",
//                   fontSize: 16),
//               suffixIcon: isDatePicker == true
//                   ? Icon(
//                       Icons.calendar_today,
//                       color: notifire.getwhiteblackcolor,
//                     )
//                   : suffix,
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: blueColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: notifire.getborderColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }*/
// }
