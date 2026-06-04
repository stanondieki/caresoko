// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/add_homecare_controller.dart';
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

/// =======================
/// Responsive Utilities
/// =======================
class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double hPadding(BuildContext context) =>
      isDesktop(context) ? 32 : isTablet(context) ? 24 : 12;

  static double vSpacing(BuildContext context) =>
      isDesktop(context) ? 24 : isTablet(context) ? 20 : 16;

  static double maxContentWidth(BuildContext context) =>
      isDesktop(context) ? 1000 : isTablet(context) ? 820 : width(context);
}

/// Centers and constrains page content for web/desktop while allowing full-bleed on mobile.
class ContentContainer extends StatelessWidget {
  final Widget child;
  const ContentContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxW = Responsive.maxContentWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }
}

/// A simple surface to visually group sections (keeps your theme)
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.6)),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

class AddHomeCareScreen8 extends StatefulWidget {
  const AddHomeCareScreen8({super.key});

  @override
  State<AddHomeCareScreen8> createState() => _AddHomeCareScreen8State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen8State extends State<AddHomeCareScreen8> {
  AddHomecareController addHomecareController = Get.find();
  DashBoardController dashBoardController = Get.find();
  EnquiryController enquriryController = Get.find();
  SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String manegeRoute = Get.arguments != null ? Get.arguments["add"] ?? "Add" : "Add";

  String selectValue = list.first;
  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  bool carCheck = false;
  bool sportCheck = false;
  bool laundaryCheck = false;

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

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();
    print(".....//.......//.....//" + manegeRoute);
    if (manegeRoute == "edit") {
      addHomecareController.agencyAboutController.text = addHomecareController.eAgencyAbout!;
      addHomecareController.agencyMissionController.text = addHomecareController.eAgencyMission!;
      addHomecareController.agencyVisionController.text = addHomecareController.eAgencyVision!;
      addHomecareController.agencyWebsiteController.text = addHomecareController.eAgencyWebsite!;
      setState(() {});
    }
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final hp = Responsive.hPadding(context);
    final vs = Responsive.vSpacing(context);

    final titleStyle = TextStyle(
      fontFamily: FontFamily.gilroyBold,
      fontSize: Responsive.isMobile(context) ? 16 : 18,
      color: notifire.getwhiteblackcolor,
    );
    final captionStyle = TextStyle(
      fontFamily: FontFamily.gilroyBold,
      fontSize: Responsive.isMobile(context) ? 13 : 14,
      color: notifire.getgreycolor,
    );
    final sectionTitle = TextStyle(
      fontFamily: FontFamily.gilroyBold,
      fontSize: Responsive.isMobile(context) ? 16 : 18,
      color: notifire.getwhiteblackcolor,
    );

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
          manegeRoute == "Add" ? "Add Homecare Agency".tr : "Edit Homecare Agency",
          style: titleStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ContentContainer(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hp, vertical: vs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: title + step (right on wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            "Finally".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: Responsive.isMobile(context) ? 18 : 22,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                        ),
                        if (!Responsive.isMobile(context))
                          Text(
                            manegeRoute == "Add" ? "Step 8 of 8".tr : "Step 7 of 7",
                            style: captionStyle,
                          ),
                      ],
                    ),
                    if (Responsive.isMobile(context)) ...[
                      SizedBox(height: vs * 0.5),
                      Text(
                        manegeRoute == "Add" ? "Step 8 of 8".tr : "Step 7 of 7",
                        style: captionStyle,
                      ),
                    ],

                    SizedBox(height: vs * 0.8),
                    Text("Agency Philosophy".tr, style: sectionTitle),
                    SizedBox(height: 8),
                    Divider(height: 0.5, color: notifire.getgreycolor),
                    SizedBox(height: vs),

                    /// ABOUT (full width card)
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("About You".tr, style: sectionTitle),
                          SizedBox(height: 8),
                          _multilineField(
                            controller: addHomecareController.agencyAboutController,
                            hint:
                            "Describe your agency, your experience and approach to care. Highlight your expertise, commitment to quality, and what sets you apart."
                                .tr,
                            validatorText:
                            'Share a brief introduction about your agency and your experience in homecare'.tr,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: vs),

                    /// MISSION & VISION (2 columns on wide)
                    GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 1 : 1.05,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Mission".tr, style: sectionTitle),
                              SizedBox(height: 8),
                              _multilineField(
                                controller: addHomecareController.agencyMissionController,
                                hint: "State the purpose and values that drive your care agency".tr,
                                validatorText: 'Please Enter Your Mission'.tr,
                              ),
                            ],
                          ),
                        ),
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Vision".tr, style: sectionTitle),
                              SizedBox(height: 8),
                              _multilineField(
                                controller: addHomecareController.agencyVisionController,
                                hint:
                                "Describe your long-term goals and how you envision improving senior care"
                                    .tr,
                                validatorText: 'Please Enter Your Vision'.tr,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: vs),

                    /// WEBSITE & LOGO (2 columns on wide)
                    GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.isMobile(context) ? 1 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: Responsive.isMobile(context) ? 1.05 : 1.0,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Website".tr, style: sectionTitle),
                              SizedBox(height: 8),
                              _textField(
                                labelText: "Your Website (Optional)".tr,
                                controller: addHomecareController.agencyWebsiteController,
                                validator: (value) {
                                  // Keep your original behavior; you can loosen validation if it's truly optional
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Your Website Link'.tr;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Upload Your Logo".tr, style: sectionTitle),
                              SizedBox(height: 10),
                              _logoPicker(context),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: vs),

                    /// Submit button centered with max width
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 480),
                            margin: EdgeInsets.symmetric(horizontal: hp),
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
                                // If you'd like to enforce validation:
                                // if (!(_formKey.currentState?.validate() ?? false)) return;

                                if (manegeRoute == "Add") {
                                  addHomecareController.addHomecareApi();
                                } else if (manegeRoute == "edit") {
                                  addHomecareController.editHomecareApi();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: vs),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// --- Small UI helpers reused above ---

  Widget _multilineField({
    required TextEditingController controller,
    required String hint,
    required String validatorText,
  }) {
    // 🧹 Clean the controller text before showing (handles \, \\n, etc.)
    controller.text = controller.text
        .replaceAll(RegExp(r'\\+n'), '\n') // convert \n, \\n, etc. to real newlines
        .replaceAll('\\', ''); // remove leftover single slashes

    return TextFormField(
      controller: controller,
      minLines: 6,
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
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: FontFamily.gilroyMedium,
          fontSize: 15,
        ),
      ),
      style: TextStyle(
        fontFamily: FontFamily.gilroyMedium,
        fontSize: 16,
        color: notifire.getwhiteblackcolor,
        height: 1.5, // improves readability for multi-line text
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }

  // Widget _multilineField({
  //   required TextEditingController controller,
  //   required String hint,
  //   String? validatorText,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: notifire.getblackwhitecolor,
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(color: notifire.getborderColor),
  //     ),
  //     child: TextFormField(
  //       controller: controller,
  //       minLines: 6,
  //       keyboardType: TextInputType.multiline,
  //       maxLines: null,
  //       cursorColor: notifire.getwhiteblackcolor,
  //       autovalidateMode: AutovalidateMode.onUserInteraction,
  //       decoration: InputDecoration(
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: blueColor),
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         contentPadding: EdgeInsets.all(12),
  //         border: InputBorder.none,
  //         hintText: hint,
  //         hintStyle: TextStyle(
  //           fontFamily: FontFamily.gilroyMedium,
  //           fontSize: 15,
  //         ),
  //       ),
  //       style: TextStyle(
  //         fontFamily: FontFamily.gilroyMedium,
  //         fontSize: 16,
  //         color: notifire.getwhiteblackcolor,
  //       ),
  //       validator: (value) {
  //         if (validatorText != null && (value == null || value.isEmpty)) {
  //           return validatorText;
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }

  Widget _textField({
    String? labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType? textInputType,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: notifire.getblackwhitecolor,
        border: Border.all(color: notifire.getborderColor),
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: notifire.getwhiteblackcolor,
        keyboardType: textInputType ?? TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: TextStyle(
          color: notifire.getwhiteblackcolor,
          fontFamily: FontFamily.gilroyMedium,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: TextStyle(color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: validator,
      ),
    );
  }

  Widget _logoPicker(BuildContext context) {
    final Widget imageWidget;
    if (manegeRoute == "Add") {
      if (addHomecareController.logoPath == null ||
          addHomecareController.logoBase64Image == null ||
          addHomecareController.logoBase64Image!.isEmpty) {
        imageWidget = Image.asset("assets/images/image-upload.png", height: 40, width: 42);
      } else {
        imageWidget = Image.memory(
          base64Decode(addHomecareController.logoBase64Image!),
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        );
      }
    } else {
      if (addHomecareController.eLogo == "") {
        imageWidget = Image.asset("assets/images/image-upload.png", height: 40, width: 42);
      } else if (addHomecareController.logoPath == null ||
          addHomecareController.logoBase64Image == null ||
          addHomecareController.logoBase64Image!.isEmpty) {
        imageWidget = Image.network(
          "${Config.imageUrl}${addHomecareController.eLogo}",
          height: 50, width: 50, fit: BoxFit.cover,
        );
      } else {
        imageWidget = Image.memory(
          base64Decode(addHomecareController.logoBase64Image!),
          height: 50, width: 50, fit: BoxFit.cover,
        );
      }
    }

    return DottedBorder(
      borderType: BorderType.RRect,
      color: Color(0xff3D5BF6),
      radius: Radius.circular(15),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _openGallery(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            child: imageWidget,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  /// --- Original helpers retained where relevant ---

  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addHomecareController.logoPath = pickedFile.path;
      addHomecareController.eLogoUpdated = true;
      setState(() {});
      List<int> imageBytes = await pickedFile.readAsBytes();
      addHomecareController.logoBase64Image = base64Encode(imageBytes);
      print("!!!!!!!!!++++++++++++${addHomecareController.logoBase64Image}");
      setState(() {});
    }
  }

  // Keeping your original field builder if you still use it elsewhere
  textfield({
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
              hintStyle: TextStyle(color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
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
//
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/add_homecare_controller.dart';
// import 'package:gotocarefinder/controller/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/enquiry_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AddHomeCareScreen8 extends StatefulWidget {
//   const AddHomeCareScreen8({super.key});
//
//   @override
//   State<AddHomeCareScreen8> createState() => _AddHomeCareScreen8State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen8State extends State<AddHomeCareScreen8> {
//   AddHomecareController addHomecareController = Get.find();
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
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     if (manegeRoute == "edit") {
//       addHomecareController.agencyAboutController.text =
//           addHomecareController.eAgencyAbout!;
//       addHomecareController.agencyMissionController.text =
//           addHomecareController.eAgencyMission!;
//       addHomecareController.agencyVisionController.text =
//           addHomecareController.eAgencyVision!;
//       addHomecareController.agencyWebsiteController.text =
//           addHomecareController.eAgencyWebsite!;
//
//       setState(() {});
//     }
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
//               ? "Add Homecare Agency".tr
//               : "Edit Homecare Agency",
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
//                             "Finally".tr,
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
//                                 ? "Step 8 of 8".tr
//                                 : "Step 7 of 7",
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
//                             "Agency Philosophy".tr,
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
//                             "About You".tr,
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
//                         Container(
//                           margin: EdgeInsets.only(top: 5, left: 15, right: 15),
//                           child: TextFormField(
//                             controller:
//                                 addHomecareController.agencyAboutController,
//                             minLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             cursorColor: notifire.getwhiteblackcolor,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             decoration: InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: blueColor),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               contentPadding: EdgeInsets.all(10),
//                               border: InputBorder.none,
//                               hintText: "Describe your agency, your experience and approach to care. Highlight your expertise, commitment to quality, and what sets you apart.".tr,
//                               hintStyle: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Share a brief introduction about your agency and your experience in homecare'
//                                     .tr;
//                               }
//                               return null;
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Your Mission".tr,
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
//                         Container(
//                           margin: EdgeInsets.only(top: 5, left: 15, right: 15),
//                           child: TextFormField(
//                             controller:
//                                 addHomecareController.agencyMissionController,
//                             minLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             cursorColor: notifire.getwhiteblackcolor,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             decoration: InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: blueColor),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               contentPadding: EdgeInsets.all(10),
//                               border: InputBorder.none,
//                               hintText:
//                                   "State the purpose and values that drive your care agency"
//                                       .tr,
//                               hintStyle: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Your Mission'.tr;
//                               }
//                               return null;
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Your Vision".tr,
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
//                         Container(
//                           margin: EdgeInsets.only(top: 5, left: 15, right: 15),
//                           child: TextFormField(
//                             controller:
//                                 addHomecareController.agencyVisionController,
//                             minLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             cursorColor: notifire.getwhiteblackcolor,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             decoration: InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: blueColor),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               contentPadding: EdgeInsets.all(10),
//                               border: InputBorder.none,
//                               hintText:
//                                   "Describe your long-term goals and how you envision improving senior care"
//                                       .tr,
//                               hintStyle: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Your Vision'.tr;
//                               }
//                               return null;
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         textfield(
//                           type: "Your Website".tr,
//                           controller:
//                               addHomecareController.agencyWebsiteController,
//                           labelText: "Your Website (Optional)".tr,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Your Website Link'.tr;
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Upload Your Logo".tr,
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
//                         DottedBorder(
//                           borderType: BorderType.RRect,
//                           color: Color(0xff3D5BF6),
//                           radius: Radius.circular(15),
//                           borderPadding: EdgeInsets.symmetric(horizontal: 20),
//                           child: InkWell(
//                             onTap: () {
//                               _openGallery(context);
//                             },
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: manegeRoute == "Add"
//                                   ? Container(
//                                       height: 80,
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 20),
//                                       width: Get.size.width,
//                                       alignment: Alignment.center,
//                                       child: addHomecareController.logoPath ==
//                                               null
//                                           ? Image.asset(
//                                               "assets/images/image-upload.png",
//                                               height: 40,
//                                               width: 42,
//                                             )
//                                           : Image.file(
//                                               File(
//                                                 addHomecareController.logoPath
//                                                     .toString(),
//                                               ),
//                                               height: 50,
//                                               width: 50,
//                                               fit: BoxFit.cover,
//                                             ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     )
//                                   : Container(
//                                       height: 80,
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 20),
//                                       width: Get.size.width,
//                                       alignment: Alignment.center,
//                                       child: addHomecareController.eLogo == ""
//                                           ? Image.asset(
//                                               "assets/images/image-upload.png",
//                                               height: 40,
//                                               width: 42,
//                                             )
//                                           : addHomecareController.logoPath ==
//                                                   null
//                                               ? Image.network(
//                                                   "${Config.imageUrl}${addHomecareController.eLogo}",
//                                                   height: 50,
//                                                   width: 50,
//                                                   fit: BoxFit.cover,
//                                                 )
//                                               : Image.file(
//                                                   File(
//                                                     addHomecareController
//                                                         .logoPath
//                                                         .toString(),
//                                                   ),
//                                                   height: 50,
//                                                   width: 50,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     ),
//                             ),
//                           ),
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
//                             if (manegeRoute == "Add") {
//                               addHomecareController.addHomecareApi();
//                             } else if (manegeRoute == "edit") {
//                               addHomecareController.editHomecareApi();
//                             }
//                             /*if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     if (selectCountry != null) {
//                                       if (selectProperty != null) {
//                                         if (addHomecareController
//                                             .selectedIndexes.isNotEmpty) {
//                                           if (addHomecareController.lat !=
//                                                   null &&
//                                               addHomecareController.long !=
//                                                   null) {
//                                             if (addHomecareController.path !=
//                                                     null ||
//                                                 addHomecareController
//                                                         .pImage !=
//                                                     "") {
//                                               if (manegeRoute == "Add") {
//                                                 addHomecareController
//                                                     .addPropertyApi();
//                                               } else if (manegeRoute ==
//                                                   "edit") {
//                                                 addHomecareController
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
//       addHomecareController.logoPath = pickedFile.path;
//       addHomecareController.eLogoUpdated = true;
//       setState(() {});
//       File imageFile = File(addHomecareController.logoPath.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       addHomecareController.logoBase64Image = base64Encode(imageBytes);
//       print("!!!!!!!!!++++++++++++${addHomecareController.logoBase64Image}");
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
// }
