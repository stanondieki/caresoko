// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/add_homecare_controller.dart';
import 'package:gotocarefinder/controller/addproperties_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/enquiry_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  static int gridColumns(BuildContext context) => isDesktop(context)
      ? 2
      : isTablet(context)
          ? 2
          : 1;

  static double maxContentWidth(BuildContext context) => isDesktop(context)
      ? 1000
      : isTablet(context)
          ? 820
          : width(context);
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

class AddHomeCareScreen6 extends StatefulWidget {
  const AddHomeCareScreen6({super.key});

  @override
  State<AddHomeCareScreen6> createState() => _AddHomeCareScreen6State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen6State extends State<AddHomeCareScreen6> {
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
      addHomecareController.readyPricing = addHomecareController.eReadyPricing!;
      addHomecareController.agencyPricingController.text =
          addHomecareController.ePricing!;
      addHomecareController.privatePay = addHomecareController.ePrivatePay!;
      addHomecareController.insurance = addHomecareController.eInsurance!;
      addHomecareController.medicaid = addHomecareController.eMedicaid!;
      addHomecareController.agencyLicenseNoController.text =
          addHomecareController.eAgencyLicenseNo!;
      setState(() {});
    }

    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final hp = Responsive.hPadding(context);
    final vs = Responsive.vSpacing(context);
    final crossAxisCount = Responsive.gridColumns(context);

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
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifire.getwhiteblackcolor,
          ),
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
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            "Just A Few More Things".tr,
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
                                ? "Step 6 of 8".tr
                                : "Step 5 of 7",
                            style: captionStyle,
                          ),
                      ],
                    ),
                    if (Responsive.isMobile(context)) ...[
                      SizedBox(height: vs * 0.5),
                      Text(
                        manegeRoute == "Add" ? "Step 6 of 8".tr : "Step 5 of 7",
                        style: captionStyle,
                      ),
                    ],
                    SizedBox(height: vs * 0.6),
                    Text("Licensing And Pricing".tr, style: sectionTitle),
                    SizedBox(height: 8),
                    Divider(height: 0.5, color: notifire.getgreycolor),
                    SizedBox(height: vs),

                    /// Top grid: Ready pricing + Pricing box (left) and License Number (right)
                    GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio:
                            Responsive.isMobile(context) ? 1 : 1.2,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Do you have ready pricing?".tr,
                                  style: sectionTitle),
                              SizedBox(height: 8),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1,
                                        child: Checkbox(
                                          value: addHomecareController
                                              .readyPricing,
                                          side: const BorderSide(
                                              color: Color(0xffC5CAD4)),
                                          activeColor: blueColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          onChanged: (_) {
                                            addHomecareController.readyPricing =
                                                true;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Text(
                                        "Yes",
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          fontSize: 16,
                                          color: notifire.getwhiteblackcolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(thickness: 1),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Transform.scale(
                                        scale: 1,
                                        child: Checkbox(
                                          value: !addHomecareController
                                              .readyPricing,
                                          side: const BorderSide(
                                              color: Color(0xffC5CAD4)),
                                          activeColor: blueColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          onChanged: (_) {
                                            addHomecareController.readyPricing =
                                                false;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Our pricing is based on care plan assessment",
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            fontSize: 16,
                                            color: notifire.getwhiteblackcolor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              if (addHomecareController.readyPricing) ...[
                                Text("Pricing".tr, style: sectionTitle),
                                SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: notifire.getblackwhitecolor,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                        color: notifire.getborderColor),
                                  ),
                                  child: TextFormField(
                                    controller: addHomecareController
                                        .agencyPricingController,
                                    minLines: 5,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    cursorColor: notifire.getwhiteblackcolor,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: blueColor),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      contentPadding: EdgeInsets.all(12),
                                      border: InputBorder.none,
                                      hintText:
                                          "Pricing breakdown (per hr/day/week/month) with different service packages (e.g., full care, partial care, day-only)."
                                              .tr,
                                      hintStyle: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 16,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                    validator: (value) {
                                      if (addHomecareController.readyPricing &&
                                          (value == null || value.isEmpty)) {
                                        return 'Please Break Down Your Pricing'
                                            .tr;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              textfield(
                                type: "License Number".tr,
                                controller: addHomecareController
                                    .agencyLicenseNoController,
                                labelText: "License Number".tr,
                                textInputType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Your License Number'
                                        .tr;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: vs),

                    /// Payment options: laid out in 1 or 2 columns
                    GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SectionCard(
                          child: _binaryOptionBlock(
                            context: context,
                            title:
                                "Do you accept private payments from clients?"
                                    .tr,
                            value: addHomecareController.privatePay,
                            onYes: () {
                              addHomecareController.privatePay = true;
                              setState(() {});
                            },
                            onNo: () {
                              addHomecareController.privatePay = false;
                              setState(() {});
                            },
                            notifire: notifire,
                          ),
                        ),
                        SectionCard(
                          child: _binaryOptionBlock(
                            context: context,
                            title: "Do you accept insurance for payment?".tr,
                            value: addHomecareController.insurance,
                            onYes: () {
                              addHomecareController.insurance = true;
                              setState(() {});
                            },
                            onNo: () {
                              addHomecareController.insurance = false;
                              setState(() {});
                            },
                            notifire: notifire,
                          ),
                        ),
                        SectionCard(
                          child: _binaryOptionBlock(
                            context: context,
                            title:
                                "Do you support Medicaid as a payment option?"
                                    .tr,
                            value: addHomecareController.medicaid,
                            onYes: () {
                              addHomecareController.medicaid = true;
                              setState(() {});
                            },
                            onNo: () {
                              addHomecareController.medicaid = false;
                              setState(() {});
                            },
                            notifire: notifire,
                          ),
                        ),
                        if (crossAxisCount == 2) SizedBox.shrink(),
                      ],
                    ),

                    SizedBox(height: vs),

                    /// Next button centered with a max width so it doesn’t stretch too wide
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
                                addHomecareController.agencyLicenseNo =
                                    addHomecareController
                                        .agencyLicenseNoController.text;
                                addHomecareController.pricing =
                                    addHomecareController
                                        .agencyPricingController.text;

                                // If you want to enforce validation before continuing, uncomment:
                                // if (!(_formKey.currentState?.validate() ?? false)) return;

                                // COMMENTED OUT: Advert functionality disabled
                                // Get.toNamed(
                                //   Routes.addHomecareScreen7,
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

  /// Re-usable yes/no block with checkboxes styled like radio.
  Widget _binaryOptionBlock({
    required BuildContext context,
    required String title,
    required bool value,
    required VoidCallback onYes,
    required VoidCallback onNo,
    required ColorNotifire notifire,
  }) {
    final labelStyle = TextStyle(
      fontFamily: FontFamily.gilroyBold,
      fontSize: Responsive.isMobile(context) ? 16 : 18,
      color: notifire.getwhiteblackcolor,
    );
    final optionStyle = TextStyle(
      fontFamily: FontFamily.gilroyMedium,
      fontSize: 16,
      color: notifire.getwhiteblackcolor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: labelStyle),
        SizedBox(height: 8),
        Row(
          children: [
            Transform.scale(
              scale: 1,
              child: Checkbox(
                value: value,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) => onYes(),
              ),
            ),
            Text("Yes", style: optionStyle),
          ],
        ),
        Divider(thickness: 1),
        Row(
          children: [
            Transform.scale(
              scale: 1,
              child: Checkbox(
                value: !value,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) => onNo(),
              ),
            ),
            Text("No", style: optionStyle),
          ],
        ),
      ],
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
// import 'package:intl/intl.dart';
//
// class AddHomeCareScreen6 extends StatefulWidget {
//   const AddHomeCareScreen6({super.key});
//
//   @override
//   State<AddHomeCareScreen6> createState() => _AddHomeCareScreen6State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen6State extends State<AddHomeCareScreen6> {
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
//   /*Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: addHomecareController.agencyLicenseExpiry ?? DateTime.now(),
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
//   }*/
//
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     if (manegeRoute == "edit") {
//       addHomecareController.readyPricing = addHomecareController.eReadyPricing!;
//       addHomecareController.agencyPricingController.text =
//           addHomecareController.ePricing!;
//       addHomecareController.privatePay = addHomecareController.ePrivatePay!;
//       addHomecareController.insurance = addHomecareController.eInsurance!;
//       addHomecareController.medicaid = addHomecareController.eMedicaid!;
//       addHomecareController.agencyLicenseNoController.text =
//           addHomecareController.eAgencyLicenseNo!;
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
//                                     value: addHomecareController.readyPricing,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.readyPricing = true;
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
//                                     value: !addHomecareController.readyPricing,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.readyPricing =
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
//                         addHomecareController.readyPricing
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
//                         addHomecareController.readyPricing
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : SizedBox(),
//                         addHomecareController.readyPricing
//                             ? Container(
//                                 margin: EdgeInsets.only(
//                                     top: 5, left: 15, right: 15),
//                                 child: TextFormField(
//                                   controller: addHomecareController
//                                       .agencyPricingController,
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
//                                         "Pricing breakdown (per hr/day/week/month) with different service packages (e.g., full care, partial care, day-only)."
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
//                         addHomecareController.readyPricing
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : SizedBox(),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you accept private payments from clients?".tr,
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
//                                     value: addHomecareController.privatePay,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.privatePay = true;
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
//                                     value: !addHomecareController.privatePay,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.privatePay = false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 70,
//                                   child: Text(
//                                     "No",
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
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you accept insurance for payment?".tr,
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
//                                     value: addHomecareController.insurance,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.insurance = true;
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
//                                     value: !addHomecareController.insurance,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.insurance = false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 70,
//                                   child: Text(
//                                     "No",
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
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you support Medicaid as a payment option?".tr,
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
//                                     value: addHomecareController.medicaid,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.medicaid = true;
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
//                                     value: !addHomecareController.medicaid,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.medicaid = false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 70,
//                                   child: Text(
//                                     "No",
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
//                         textfield(
//                           type: "License Number".tr,
//                           controller:
//                               addHomecareController.agencyLicenseNoController,
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
//                             addHomecareController.agencyLicenseNo =
//                                 addHomecareController
//                                     .agencyLicenseNoController.text;
//
//                             addHomecareController.pricing =
//                                 addHomecareController
//                                     .agencyPricingController.text;
//
//                             Get.toNamed(
//                               Routes.addHomecareScreen7,
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
