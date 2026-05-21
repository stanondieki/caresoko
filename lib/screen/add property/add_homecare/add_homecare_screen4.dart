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

class AddHomeCareScreen4 extends StatefulWidget {
  const AddHomeCareScreen4({super.key});

  @override
  State<AddHomeCareScreen4> createState() => _AddHomeCareScreen4State();
}

const List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen4State extends State<AddHomeCareScreen4> {
  final AddHomecareController addHomecareController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments["add"];

  String slectStatus = propartyStatus.first;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  Future<Position> locateUser() async =>
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  @override
  void initState() {
    super.initState();

    if (manegeRoute == "edit") {
      // restore selectable lists
      addHomecareController.selectedCertifications
        ..clear()
        ..addAll((addHomecareController.eCertifications ?? "")
            .split(",")
            .where((e) => e.trim().isNotEmpty));

      addHomecareController.selectedSpecializedCertifications
        ..clear()
        ..addAll((addHomecareController.eSpecializedCertifications ?? "")
            .split(",")
            .where((e) => e.trim().isNotEmpty));

      addHomecareController.selectedAccreditations
        ..clear()
        ..addAll((addHomecareController.eAccreditations ?? "")
            .split(",")
            .where((e) => e.trim().isNotEmpty));

      addHomecareController.selectedMemberships
        ..clear()
        ..addAll((addHomecareController.eMemberships ?? "")
            .split(",")
            .where((e) => e.trim().isNotEmpty));

      // toggles
      addHomecareController.backgroundChecks =
          addHomecareController.eBackgroundChecks ?? false;
      addHomecareController.drugTesting =
          addHomecareController.eDrugTesting ?? false;
      addHomecareController.referenceVerification =
          addHomecareController.eReferenceVerification ?? false;
    }

    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 900; // desktop/tablet breakpoint
    final sidePad = isWide ? 24.0 : 10.0; // nicer gutters on wide screens
    const contentMaxWidth = 1100.0;

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        backgroundColor: notifire.getblackwhitecolor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          manegeRoute == "Add"
              ? "Add Homecare Agency".tr
              : "Edit Homecare Agency",
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: contentMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: Scrollbar(
                  thumbVisibility: isWide,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      color: notifire.getblackwhitecolor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _title(
                              "Accreditations, Certifications, and Memberships"
                                  .tr),
                          const SizedBox(height: 16),
                          _subtitle(manegeRoute == "Add"
                              ? "Step 4 of 8".tr
                              : "Step 4 of 7"),
                          const SizedBox(height: 10),
                          _sectionHeader(
                              "Give Clients Confidence In Your Quality Of Care"
                                  .tr),
                          const SizedBox(height: 10),
                          Divider(height: 0.5, color: notifire.getgreycolor),
                          const SizedBox(height: 20),

                          // Certifications
                          _sectionHeader(
                              "Select Caregiver Certifications Your Staff Hold"
                                  .tr),
                          const SizedBox(height: 8),
                          _checkboxList(
                            items: addHomecareController.allCertifications,
                            isSelected: (s) => addHomecareController
                                .selectedCertifications
                                .contains(s),
                            toggle: (s) {
                              final sel =
                                  addHomecareController.selectedCertifications;
                              sel.contains(s) ? sel.remove(s) : sel.add(s);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 10),

                          // Specialized Certifications
                          _sectionHeader(
                              "Select Specialized Certifications Your Staff Hold"
                                  .tr),
                          const SizedBox(height: 8),
                          _checkboxList(
                            items:
                                addHomecareController.specializedCertifications,
                            isSelected: (s) => addHomecareController
                                .selectedSpecializedCertifications
                                .contains(s),
                            toggle: (s) {
                              final sel = addHomecareController
                                  .selectedSpecializedCertifications;
                              sel.contains(s) ? sel.remove(s) : sel.add(s);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 10),

                          // Accreditations
                          _sectionHeader(
                              "Select The Accreditations Your Agency Holds To Demonstrate Adherence To High Standards Of Care"
                                  .tr),
                          const SizedBox(height: 8),
                          _checkboxList(
                            items: addHomecareController.allAccreditations,
                            isSelected: (s) => addHomecareController
                                .selectedAccreditations
                                .contains(s),
                            toggle: (s) {
                              final sel =
                                  addHomecareController.selectedAccreditations;
                              sel.contains(s) ? sel.remove(s) : sel.add(s);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 10),

                          // Memberships
                          _sectionHeader(
                              "Select Memberships With Recognized Professional Organizations"
                                  .tr),
                          const SizedBox(height: 8),
                          _checkboxList(
                            items:
                                addHomecareController.professionalMemberships,
                            isSelected: (s) => addHomecareController
                                .selectedMemberships
                                .contains(s),
                            toggle: (s) {
                              final sel =
                                  addHomecareController.selectedMemberships;
                              sel.contains(s) ? sel.remove(s) : sel.add(s);
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 20),
                          _sectionHeader("Screening & Safety".tr),
                          const SizedBox(height: 15),

                          // Background checks
                          _question(
                              "Do you perform background checks on staff to ensure client safety?"
                                  .tr),
                          _yesNo(
                            value: addHomecareController.backgroundChecks,
                            onChanged: (v) => setState(() =>
                                addHomecareController.backgroundChecks = v),
                          ),
                          const SizedBox(height: 10),

                          // Drug testing
                          _question(
                              "Do you conduct drug tests for employees?".tr),
                          _yesNo(
                            value: addHomecareController.drugTesting,
                            onChanged: (v) => setState(
                                () => addHomecareController.drugTesting = v),
                          ),
                          const SizedBox(height: 10),

                          // Reference verification
                          _question(
                              "Do you verify references for your caregivers?"
                                  .tr),
                          _yesNo(
                            value: addHomecareController.referenceVerification,
                            onChanged: (v) => setState(() =>
                                addHomecareController.referenceVerification =
                                    v),
                          ),

                          const SizedBox(height: 22),

                          // NEXT
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 160 : 35),
                            child: GestButton(
                              Width: double.infinity,
                              height: 55,
                              buttoncolor: blueColor,
                              margin: const EdgeInsets.only(top: 5),
                              buttontext: "Next".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                color: WhiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              onclick: () {
                                // COMMENTED OUT: Advert functionality disabled
                                // Get.toNamed(
                                //   manegeRoute == "Add" ? Routes.addHomecareScreen5 : Routes.addHomecareScreen6,
                                //   arguments: {"add": manegeRoute},
                                // );
                              },
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers (responsive-friendly) ----------

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 20,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  Widget _subtitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: notifire.getgreycolor,
          ),
        ),
      );

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  Widget _question(String text) => Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  /// Compact, non-scrolling checkbox list (since parent scrolls)
  Widget _checkboxList({
    required List<String> items,
    required bool Function(String) isSelected,
    required void Function(String) toggle,
  }) {
    return ListView.separated(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(thickness: 1),
      ),
      itemBuilder: (context, index) {
        final label = items[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: isSelected(label),
              side: const BorderSide(color: Color(0xffC5CAD4)),
              activeColor: blueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => toggle(label),
            ),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 17,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        );
      },
    );
  }

  /// Reusable Yes/No control
  Widget _yesNo({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: value,
              side: const BorderSide(color: Color(0xffC5CAD4)),
              activeColor: blueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => onChanged(true),
            ),
            Text(
              "Yes",
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 17,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(thickness: 1),
        ),
        Row(
          children: [
            const SizedBox(width: 10),
            Checkbox(
              value: !value,
              side: const BorderSide(color: Color(0xffC5CAD4)),
              activeColor: blueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => onChanged(false),
            ),
            Text(
              "No",
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 17,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // (Optional) kept from your file for parity — not used here
  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addHomecareController.path = pickedFile.path;
      setState(() {});
      final imageFile = File(addHomecareController.path.toString());
      final imageBytes = imageFile.readAsBytesSync();
      addHomecareController.base64Image = base64Encode(imageBytes);
    }
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
// class AddHomeCareScreen4 extends StatefulWidget {
//   const AddHomeCareScreen4({super.key});
//
//   @override
//   State<AddHomeCareScreen4> createState() => _AddHomeCareScreen4State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen4State extends State<AddHomeCareScreen4> {
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
//       addHomecareController.selectedCertifications.clear();
//       addHomecareController.selectedCertifications.addAll(
//           addHomecareController.eCertifications!.split(","));
//
//       addHomecareController.selectedSpecializedCertifications.clear();
//       addHomecareController.selectedSpecializedCertifications.addAll(
//           addHomecareController.eSpecializedCertifications!.split(","));
//
//       addHomecareController.selectedAccreditations.clear();
//       addHomecareController.selectedAccreditations.addAll(
//           addHomecareController.eAccreditations!.split(","));
//
//       addHomecareController.selectedMemberships.clear();
//       addHomecareController.selectedMemberships.addAll(
//           addHomecareController.eMemberships!.split(","));
//
//       addHomecareController.backgroundChecks =
//           addHomecareController.eBackgroundChecks!;
//       addHomecareController.drugTesting =
//           addHomecareController.eDrugTesting!;
//       addHomecareController.referenceVerification =
//           addHomecareController.eReferenceVerification!;
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
//                             "Accreditations, Certifications, and Memberships"
//                                 .tr,
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
//                                 ? "Step 4 of 8".tr
//                                 : "Step 4 of 7",
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
//                             "Give Clients Confidence In Your Quality Of Care"
//                                 .tr,
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
//                             "Select Caregiver Certifications Your Staff Hold"
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
//                               addHomecareController.allCertifications.length,
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
//                                             .selectedCertifications
//                                             .contains(addHomecareController
//                                                 .allCertifications[index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addHomecareController
//                                               .selectedCertifications
//                                               .contains(addHomecareController
//                                                   .allCertifications[index])) {
//                                             addHomecareController
//                                                 .selectedCertifications
//                                                 .remove(addHomecareController
//                                                     .allCertifications[index]);
//                                           } else {
//                                             addHomecareController
//                                                 .selectedCertifications
//                                                 .add(addHomecareController
//                                                     .allCertifications[index]);
//                                           }
//
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: Get.width - 60,
//                                       child: Text(
//                                         addHomecareController
//                                             .allCertifications[index],
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Select Specialized Certifications Your Staff Hold"
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
//                           itemCount: addHomecareController
//                               .specializedCertifications.length,
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
//                                             .selectedSpecializedCertifications
//                                             .contains(addHomecareController
//                                                     .specializedCertifications[
//                                                 index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addHomecareController
//                                               .selectedSpecializedCertifications
//                                               .contains(addHomecareController
//                                                       .specializedCertifications[
//                                                   index])) {
//                                             addHomecareController
//                                                 .selectedSpecializedCertifications
//                                                 .remove(addHomecareController
//                                                         .specializedCertifications[
//                                                     index]);
//                                           } else {
//                                             addHomecareController
//                                                 .selectedSpecializedCertifications
//                                                 .add(addHomecareController
//                                                         .specializedCertifications[
//                                                     index]);
//                                           }
//
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: Get.width - 60,
//                                       child: Text(
//                                         addHomecareController
//                                             .specializedCertifications[index],
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Select The Accreditations Your Agency Holds To Demonstrate Adherence To High Standards Of Care"
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
//                               addHomecareController.allAccreditations.length,
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
//                                             .selectedAccreditations
//                                             .contains(addHomecareController
//                                                 .allAccreditations[index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addHomecareController
//                                               .selectedAccreditations
//                                               .contains(addHomecareController
//                                                   .allAccreditations[index])) {
//                                             addHomecareController
//                                                 .selectedAccreditations
//                                                 .remove(addHomecareController
//                                                     .allAccreditations[index]);
//                                           } else {
//                                             addHomecareController
//                                                 .selectedAccreditations
//                                                 .add(addHomecareController
//                                                     .allAccreditations[index]);
//                                           }
//
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: Get.width - 60,
//                                       child: Text(
//                                         addHomecareController
//                                             .allAccreditations[index],
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Select Memberships With Recognized Professional Organizations"
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
//                           itemCount: addHomecareController
//                               .professionalMemberships.length,
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
//                                             .selectedMemberships
//                                             .contains(addHomecareController
//                                                     .professionalMemberships[
//                                                 index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addHomecareController
//                                               .selectedMemberships
//                                               .contains(addHomecareController
//                                                       .professionalMemberships[
//                                                   index])) {
//                                             addHomecareController
//                                                 .selectedMemberships
//                                                 .remove(addHomecareController
//                                                         .professionalMemberships[
//                                                     index]);
//                                           } else {
//                                             addHomecareController
//                                                 .selectedMemberships
//                                                 .add(addHomecareController
//                                                         .professionalMemberships[
//                                                     index]);
//                                           }
//
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: Get.width - 60,
//                                       child: Text(
//                                         addHomecareController
//                                             .professionalMemberships[index],
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
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
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Screening & Safety".tr,
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
//                             "Do you perform background checks on staff to ensure client safety?"
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
//                         Column(
//                           children: [
//                             Row(
//                               children: [
//                                 SizedBox(width: 10),
//                                 Transform.scale(
//                                   scale: 1,
//                                   child: Checkbox(
//                                     value:
//                                         addHomecareController.backgroundChecks,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.backgroundChecks =
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
//                                         !addHomecareController.backgroundChecks,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.backgroundChecks =
//                                           false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "No",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you conduct drug tests for employees?".tr,
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
//                                     value: addHomecareController.drugTesting,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.drugTesting = true;
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
//                                     value: !addHomecareController.drugTesting,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.drugTesting = false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "No",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you verify references for your caregivers?".tr,
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
//                                     value: addHomecareController
//                                         .referenceVerification,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController
//                                           .referenceVerification = true;
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
//                                     value: !addHomecareController
//                                         .referenceVerification,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController
//                                           .referenceVerification = false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "No",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
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
//                             Get.toNamed(
//                               manegeRoute == "Add"
//                                   ? Routes.addHomecareScreen5
//                                   : Routes.addHomecareScreen6,
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
