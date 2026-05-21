// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double hPadding(BuildContext context) => isDesktop(context)
      ? 32
      : isTablet(context)
          ? 24
          : 12;

  static double vSpacing(BuildContext context) => isDesktop(context)
      ? 24
      : isTablet(context)
          ? 20
          : 16;

  static double maxContentWidth(BuildContext context) => isDesktop(context)
      ? 1000
      : isTablet(context)
          ? 820
          : width(context);

  static int languagesCols(BuildContext context) => isDesktop(context)
      ? 3
      : isTablet(context)
          ? 2
          : 1;
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

/// A simple surface to visually group sections (keeps your colors)
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
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(0.6)),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

class AddHomeCareScreen7 extends StatefulWidget {
  const AddHomeCareScreen7({super.key});

  @override
  State<AddHomeCareScreen7> createState() => _AddHomeCareScreen7State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen7State extends State<AddHomeCareScreen7> {
  AddHomecareController addHomecareController = Get.find();
  DashBoardController dashBoardController = Get.find();
  EnquiryController enquriryController = Get.find();
  SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String manegeRoute = Get.arguments["add"];

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
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();
    print(".....//.......//.....//" + manegeRoute);
    if (manegeRoute == "edit") {
      addHomecareController.selectedLanguages.clear();
      addHomecareController.selectedLanguages.addAll(
        addHomecareController.eLanguages!.split(","),
      );
      addHomecareController.whyTheyStandOutController.text =
          addHomecareController.eWhyTheyStandOut!;
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
    final bodyStyle = TextStyle(
      fontFamily: FontFamily.gilroyBold,
      fontSize: Responsive.isMobile(context) ? 14 : 16,
      color: notifire.getwhiteblackcolor,
    );

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        backgroundColor: notifire.getblackwhitecolor,
        elevation: 0,
        title: Text(
          manegeRoute == "Add"
              ? "Add Homecare Agency".tr
              : "Edit Homecare Agency".tr,
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
                    // Header row with step on the right for wide screens
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            "Why Choose You?".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: Responsive.isMobile(context) ? 18 : 22,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                        ),
                        if (!Responsive.isMobile(context))
                          Text(
                            manegeRoute == "Add"
                                ? "Step 7 of 8".tr
                                : "Step 6 of 7".tr,
                            style: captionStyle,
                          ),
                      ],
                    ),
                    if (Responsive.isMobile(context)) ...[
                      SizedBox(height: vs * 0.5),
                      Text(
                        manegeRoute == "Add"
                            ? "Step 7 of 8".tr
                            : "Step 6 of 7".tr,
                        style: captionStyle,
                      ),
                    ],

                    SizedBox(height: vs * 0.8),
                    Text("Why Your Agency Stands Out From The Rest".tr,
                        style: sectionTitle),
                    SizedBox(height: 8),
                    Divider(height: 0.5, color: notifire.getgreycolor),
                    SizedBox(height: vs),

                    /// Why Choose You (card)
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Explain what makes your agency unique and why clients should choose you. Use this to share memorable, differentiating qualities, such as awards, personalized programs, or innovative approaches to care"
                                .tr,
                            style: bodyStyle,
                          ),
                          SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: notifire.getblackwhitecolor,
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(color: notifire.getborderColor),
                            ),
                            child: TextFormField(
                              controller: addHomecareController
                                  .whyTheyStandOutController
                                ..text = addHomecareController
                                    .whyTheyStandOutController.text
                                    // Replace both \\ and \ followed by n with real line breaks
                                    .replaceAll(RegExp(r'\\+n'), '\n')
                                    // Also replace leftover single backslashes with spaces (optional cleanup)
                                    .replaceAll('\\', ''),
                              minLines: 6,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              cursorColor: notifire.getwhiteblackcolor,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: blueColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                contentPadding: EdgeInsets.all(12),
                                border: InputBorder.none,
                                hintText: "Why Choose You".tr,
                                hintStyle: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 15,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                fontSize: 16,
                                color: notifire.getwhiteblackcolor,
                                height: 1.5,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Tell Us Why You Stand Out'.tr;
                                }
                                return null;
                              },
                            ),

                            // child: TextFormField(
                            //   controller: addHomecareController.whyTheyStandOutController,
                            //   minLines: 6,
                            //   keyboardType: TextInputType.multiline,
                            //   maxLines: null,
                            //   cursorColor: notifire.getwhiteblackcolor,
                            //   autovalidateMode: AutovalidateMode.onUserInteraction,
                            //   decoration: InputDecoration(
                            //     focusedBorder: OutlineInputBorder(
                            //       borderSide: BorderSide(color: blueColor),
                            //       borderRadius: BorderRadius.circular(15),
                            //     ),
                            //     contentPadding: EdgeInsets.all(12),
                            //     border: InputBorder.none,
                            //     hintText: "Why Choose You".tr,
                            //     hintStyle: TextStyle(
                            //       fontFamily: FontFamily.gilroyMedium,
                            //       fontSize: 15,
                            //     ),
                            //   ),
                            //   style: TextStyle(
                            //     fontFamily: FontFamily.gilroyMedium,
                            //     fontSize: 16,
                            //     color: notifire.getwhiteblackcolor,
                            //   ),
                            //   validator: (value) {
                            //     if (value == null || value.isEmpty) {
                            //       return 'Please Tell Us Why You Stand Out'.tr;
                            //     }
                            //     return null;
                            //   },
                            // ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: vs),

                    /// Languages (card) with responsive grid
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Languages".tr, style: sectionTitle),
                          SizedBox(height: 8),
                          Text(
                            "Select all languages your staff speaks fluently to accommodate diverse client needs"
                                .tr,
                            style: bodyStyle,
                          ),
                          SizedBox(height: 12),

                          // Responsive grid of language checkboxes
                          GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                addHomecareController.languagesSpoken.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: Responsive.languagesCols(context),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 8,
                              // taller tiles for readability
                              childAspectRatio:
                                  Responsive.isMobile(context) ? 6 : 5.5,
                            ),
                            itemBuilder: (context, index) {
                              final lang =
                                  addHomecareController.languagesSpoken[index];
                              final selected = addHomecareController
                                  .selectedLanguages
                                  .contains(lang);
                              return _languageTile(
                                context: context,
                                label: lang,
                                selected: selected,
                                onChanged: () {
                                  if (selected) {
                                    addHomecareController.selectedLanguages
                                        .remove(lang);
                                  } else {
                                    addHomecareController.selectedLanguages
                                        .add(lang);
                                  }
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: vs),

                    /// Next button centered with max width
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
                                addHomecareController.whyTheyStandOut =
                                    addHomecareController
                                        .whyTheyStandOutController.text;

                                // If you want to enforce validation before continuing, uncomment:
                                // if (!(_formKey.currentState?.validate() ?? false)) return;

                                // COMMENTED OUT: Advert functionality disabled
                                // Get.toNamed(
                                //   Routes.addHomecareScreen8,
                                //   arguments: {"add": manegeRoute},
                                // );
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

  /// Single language checkbox tile
  Widget _languageTile({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onChanged,
  }) {
    return InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Transform.scale(
            scale: 1,
            child: Checkbox(
              value: selected,
              side: const BorderSide(color: Color(0xffC5CAD4)),
              activeColor: blueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => onChanged(),
            ),
          ),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addHomecareController.path = pickedFile.path;
      setState(() {});
      File imageFile = File(addHomecareController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addHomecareController.base64Image = base64Encode(imageBytes);
      print("!!!!!!!!!++++++++++++${addHomecareController.base64Image}");
      setState(() {});
    }
  }

  /// Kept from your original file; reused inside the responsive layout
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
              hintStyle: TextStyle(
                color: Colors.grey,
                fontFamily: "Gilroy Medium",
                fontSize: 16,
              ),
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
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/controller/add_homecare_controller.dart';
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
//
// class AddHomeCareScreen7 extends StatefulWidget {
//   const AddHomeCareScreen7({super.key});
//
//   @override
//   State<AddHomeCareScreen7> createState() => _AddHomeCareScreen7State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen7State extends State<AddHomeCareScreen7> {
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
//       addHomecareController.selectedLanguages.clear();
//       addHomecareController.selectedLanguages.addAll(
//           addHomecareController.eLanguages!.split(","));
//
//       addHomecareController.whyTheyStandOutController.text = addHomecareController.eWhyTheyStandOut!;
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
//               ? "Add Homecare Agency".tr
//               : "Edit Homecare Agency".tr,
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
//                             "Why Choose You?".tr,
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
//                                 ? "Step 7 of 8".tr
//                                 : "Step 6 of 7".tr,
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
//                             "Why Your Agency Stands Out From The Rest".tr,
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
//                             "Explain what makes your agency unique and why clients should choose you. Use this to share memorable, differentiating qualities, such as awards, personalized programs, or innovative approaches to care"
//                                 .tr,
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
//                                 addHomecareController.whyTheyStandOutController,
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
//                               hintText: "Why Choose You".tr,
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
//                                 return 'Please Tell Us Why You Stand Out'.tr;
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
//                           height: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Languages".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Select all languages your staff speaks fluently to accommodate diverse client needs"
//                                 .tr,
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
//                         ListView.separated(
//                           itemCount:
//                               addHomecareController.languagesSpoken.length,
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           separatorBuilder: (context, index) {
//                             return Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 20),
//                               child: Divider(thickness: 1),
//                             );
//                           },
//                           itemBuilder: (context, index) {
//                             return Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     SizedBox(width: 10),
//                                     Transform.scale(
//                                       scale: 1,
//                                       child: Checkbox(
//                                         value: addHomecareController
//                                             .selectedLanguages
//                                             .contains(addHomecareController
//                                                 .languagesSpoken[index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addHomecareController
//                                               .selectedLanguages
//                                               .contains(addHomecareController
//                                                   .languagesSpoken[index])) {
//                                             addHomecareController
//                                                 .selectedLanguages
//                                                 .remove(addHomecareController
//                                                     .languagesSpoken[index]);
//                                           } else {
//                                             addHomecareController
//                                                 .selectedLanguages
//                                                 .add(addHomecareController
//                                                     .languagesSpoken[index]);
//                                           }
//
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ),
//                                     Text(
//                                       addHomecareController
//                                           .languagesSpoken[index],
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 17,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             );
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
//                             addHomecareController.whyTheyStandOut =
//                                 addHomecareController
//                                     .whyTheyStandOutController.text;
//
//                             Get.toNamed(
//                               Routes.addHomecareScreen8,
//                               arguments: {"add": manegeRoute},
//                             );
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
//       addHomecareController.path = pickedFile.path;
//       setState(() {});
//       File imageFile = File(addHomecareController.path.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       addHomecareController.base64Image = base64Encode(imageBytes);
//       print("!!!!!!!!!++++++++++++${addHomecareController.base64Image}");
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
