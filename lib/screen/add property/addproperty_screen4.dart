// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';

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
import 'package:gotocarefinder/model/routes_helper.dart';

class AddPropertyScreen4 extends StatefulWidget {
  const AddPropertyScreen4({super.key});

  @override
  State<AddPropertyScreen4> createState() => _AddPropertyScreen4State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreen4State extends State<AddPropertyScreen4> {
  final AddPropertiesController addPropertiesController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments != null ? Get.arguments["add"] ?? "Add" : "Add";

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
      // Defensive split helpers (ignore empties)
      List<String> splitClean(String? s) => (s ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      addPropertiesController.selectedCertifications
        ..clear()
        ..addAll(splitClean(addPropertiesController.eCertifications));

      addPropertiesController.selectedSpecializedCertifications
        ..clear()
        ..addAll(
            splitClean(addPropertiesController.eSpecializedCertifications));

      addPropertiesController.selectedAccreditations
        ..clear()
        ..addAll(splitClean(addPropertiesController.eAccreditations));

      addPropertiesController.selectedMemberships
        ..clear()
        ..addAll(splitClean(addPropertiesController.eMemberships));

      addPropertiesController.backgroundChecks =
          addPropertiesController.eBackgroundChecks ?? false;
      addPropertiesController.drugTesting =
          addPropertiesController.eDrugTesting ?? false;
      addPropertiesController.referenceVerification =
          addPropertiesController.eReferenceVerification ?? false;
      setState(() {});
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) => getdarkmodepreviousstate());
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
            final double width = constraints.maxWidth;

            // Breakpoints
            final bool isPhone = width < 700;
            final bool isTablet = width >= 700 && width < 1100;
            final bool isDesktop = width >= 1100;

            // Page sizing
            final double maxContentWidth =
                isDesktop ? 1100 : (isTablet ? 900 : width);
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 12 : 20,
              vertical: isPhone ? 0 : 8,
            );

            // Chip grid columns
            final int chipCols = isPhone ? 2 : (isTablet ? 3 : 4);
            final double spacing = 12;

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
                                  SizedBox(height: 10),
                                  _h1("Accreditations, Certifications, and Memberships"),
                                  SizedBox(height: 20),
                                  _step(
                                      isAdd: manegeRoute == "Add",
                                      stepAdd: "Step 4 of 8",
                                      stepEdit: "Step 4 of 7"),
                                  SizedBox(height: 10),
                                  _h2("Give Clients Confidence In Your Quality Of Care"),
                                  SizedBox(height: 10),
                                  Divider(
                                      height: 0.5,
                                      color: notifire.getgreycolor),
                                  SizedBox(height: 18),

                                  // ===== CERTIFICATIONS =====
                                  _h2("Select Caregiver Certifications Your Staff Hold"),
                                  SizedBox(height: 10),
                                  _ChipGrid(
                                    options: addPropertiesController
                                        .allCertifications,
                                    selected: addPropertiesController
                                        .selectedCertifications,
                                    onToggle: (label) {
                                      setState(() {
                                        final sel = addPropertiesController
                                            .selectedCertifications;
                                        sel.contains(label)
                                            ? sel.remove(label)
                                            : sel.add(label);
                                      });
                                    },
                                    cols: chipCols,
                                    spacing: spacing,
                                    notifire: notifire,
                                  ),

                                  SizedBox(height: 16),
                                  _h2("Select Specialized Certifications Your Staff Hold"),
                                  SizedBox(height: 10),
                                  _ChipGrid(
                                    options: addPropertiesController
                                        .specializedCertifications,
                                    selected: addPropertiesController
                                        .selectedSpecializedCertifications,
                                    onToggle: (label) {
                                      setState(() {
                                        final sel = addPropertiesController
                                            .selectedSpecializedCertifications;
                                        sel.contains(label)
                                            ? sel.remove(label)
                                            : sel.add(label);
                                      });
                                    },
                                    cols: chipCols,
                                    spacing: spacing,
                                    notifire: notifire,
                                  ),

                                  SizedBox(height: 16),
                                  _h2("Select The Accreditations Your Home Holds To Demonstrate Adherence To High Standards Of Care"),
                                  SizedBox(height: 10),
                                  _ChipGrid(
                                    options: addPropertiesController
                                        .allAccreditations,
                                    selected: addPropertiesController
                                        .selectedAccreditations,
                                    onToggle: (label) {
                                      setState(() {
                                        final sel = addPropertiesController
                                            .selectedAccreditations;
                                        sel.contains(label)
                                            ? sel.remove(label)
                                            : sel.add(label);
                                      });
                                    },
                                    cols: chipCols,
                                    spacing: spacing,
                                    notifire: notifire,
                                  ),

                                  SizedBox(height: 16),
                                  _h2("Select Memberships With Recognized Professional Organizations"),
                                  SizedBox(height: 10),
                                  _ChipGrid(
                                    options: addPropertiesController
                                        .professionalMemberships,
                                    selected: addPropertiesController
                                        .selectedMemberships,
                                    onToggle: (label) {
                                      setState(() {
                                        final sel = addPropertiesController
                                            .selectedMemberships;
                                        sel.contains(label)
                                            ? sel.remove(label)
                                            : sel.add(label);
                                      });
                                    },
                                    cols: chipCols,
                                    spacing: spacing,
                                    notifire: notifire,
                                  ),

                                  SizedBox(height: 22),
                                  _h2("Screening & Safety"),
                                  SizedBox(height: 14),

                                  _ynSection(
                                    label:
                                        "Do you perform background checks on staff to ensure client safety?",
                                    value: addPropertiesController
                                        .backgroundChecks,
                                    onChanged: (v) => setState(() =>
                                        addPropertiesController
                                            .backgroundChecks = v),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label:
                                        "Do you conduct drug tests for employees?",
                                    value: addPropertiesController.drugTesting,
                                    onChanged: (v) => setState(() =>
                                        addPropertiesController.drugTesting =
                                            v),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label:
                                        "Do you verify references for your caregivers?",
                                    value: addPropertiesController
                                        .referenceVerification,
                                    onChanged: (v) => setState(() =>
                                        addPropertiesController
                                            .referenceVerification = v),
                                  ),

                                  SizedBox(height: 24),
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
                                        Get.toNamed(
                                          manegeRoute == "Add"
                                              ? Routes.addPropertyScreen5
                                              : Routes.addPropertyScreen6,
                                          arguments: {"add": manegeRoute},
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 28),
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

  // ---------- Headings ----------
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

  Widget _step(
          {required bool isAdd,
          required String stepAdd,
          required String stepEdit}) =>
      Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          (isAdd ? stepAdd : stepEdit).tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: notifire.getgreycolor,
          ),
        ),
      );

  // ---------- Yes/No reusable section ----------
  Widget _ynSection({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _h2(label),
          SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: notifire.getborderColor),
              color: notifire.getblackwhitecolor,
            ),
            child: Column(
              children: [
                _ynRow(
                    title: "Yes", checked: value, onTap: () => onChanged(true)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(thickness: 1),
                ),
                _ynRow(
                    title: "No",
                    checked: !value,
                    onTap: () => onChanged(false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ynRow(
      {required String title,
      required bool checked,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          SizedBox(width: 10),
          Transform.scale(
            scale: 1,
            child: Checkbox(
              value: checked,
              side: const BorderSide(color: Color(0xffC5CAD4)),
              activeColor: blueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => onTap(),
            ),
          ),
          Text(
            title.tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 17,
              color: notifire.getwhiteblackcolor,
            ),
          ),
          Spacer(),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  // ---------- Responsive Chip Grid ----------
  // Renders a grid of checkbox-chips that toggle membership in `selected`.
  // Keeps your controller lists unchanged.
  Widget _ChipGrid({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<String> onToggle,
    required int cols,
    required double spacing,
    required ColorNotifire notifire,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: LayoutBuilder(
        builder: (context, box) {
          final double gridWidth = box.maxWidth;
          final double tileWidth = (gridWidth - spacing * (cols - 1)) / cols;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: options.map((label) {
              final bool isSelected = selected.contains(label);
              return SizedBox(
                width: tileWidth,
                child: _SelectableChipTile(
                  label: label,
                  selected: isSelected,
                  onTap: () => onToggle(label),
                  notifire: notifire,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ---------- Single selectable chip-like tile ----------
  // (Checkbox + label, highlighted when selected)

  // ---------- Image picker (unchanged) ----------
  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addPropertiesController.path = pickedFile.path;
      setState(() {});
      List<int> imageBytes = await pickedFile.readAsBytes();
      addPropertiesController.base64Image = base64Encode(imageBytes);
      print("!!!!!!!!!++++++++++++${addPropertiesController.base64Image}");
      setState(() {});
    }
  }

  // ---------- Legacy textfield helper (kept for parity / future reuse) ----------
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
        if (type != null) ...[
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              type.tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
          SizedBox(height: 6),
        ],
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
              counterText: "",
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

class _SelectableChipTile extends StatelessWidget {
  const _SelectableChipTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.notifire,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: selected ? blueColor : notifire.getborderColor),
          color:
              selected ? const Color(0xFFeef4ff) : notifire.getblackwhitecolor,
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              side: const BorderSide(color: Color(0xffC5CAD4)),
              activeColor: blueColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 15,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
            ),
          ],
        ),
      ),
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
// class AddPropertyScreen4 extends StatefulWidget {
//   const AddPropertyScreen4({super.key});
//
//   @override
//   State<AddPropertyScreen4> createState() => _AddPropertyScreen4State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen4State extends State<AddPropertyScreen4> {
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
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     if (manegeRoute == "edit") {
//       addPropertiesController.selectedCertifications.clear();
//       addPropertiesController.selectedCertifications.addAll(
//           addPropertiesController.eCertifications!.split(","));
//
//       addPropertiesController.selectedSpecializedCertifications.clear();
//       addPropertiesController.selectedSpecializedCertifications.addAll(
//           addPropertiesController.eSpecializedCertifications!.split(","));
//
//       addPropertiesController.selectedAccreditations.clear();
//       addPropertiesController.selectedAccreditations.addAll(
//           addPropertiesController.eAccreditations!.split(","));
//
//       addPropertiesController.selectedMemberships.clear();
//       addPropertiesController.selectedMemberships.addAll(
//           addPropertiesController.eMemberships!.split(","));
//
//       addPropertiesController.backgroundChecks =
//           addPropertiesController.eBackgroundChecks!;
//       addPropertiesController.drugTesting =
//           addPropertiesController.eDrugTesting!;
//       addPropertiesController.referenceVerification =
//           addPropertiesController.eReferenceVerification!;
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
//               : "Edit Home Or Facility",
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
//                               addPropertiesController.allCertifications.length,
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
//                                         value: addPropertiesController
//                                             .selectedCertifications
//                                             .contains(addPropertiesController
//                                                 .allCertifications[index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addPropertiesController
//                                               .selectedCertifications
//                                               .contains(addPropertiesController
//                                                   .allCertifications[index])) {
//                                             addPropertiesController
//                                                 .selectedCertifications
//                                                 .remove(addPropertiesController
//                                                     .allCertifications[index]);
//                                           } else {
//                                             addPropertiesController
//                                                 .selectedCertifications
//                                                 .add(addPropertiesController
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
//                                         addPropertiesController
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
//                           itemCount: addPropertiesController
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
//                                         value: addPropertiesController
//                                             .selectedSpecializedCertifications
//                                             .contains(addPropertiesController
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
//                                           if (addPropertiesController
//                                               .selectedSpecializedCertifications
//                                               .contains(addPropertiesController
//                                                       .specializedCertifications[
//                                                   index])) {
//                                             addPropertiesController
//                                                 .selectedSpecializedCertifications
//                                                 .remove(addPropertiesController
//                                                         .specializedCertifications[
//                                                     index]);
//                                           } else {
//                                             addPropertiesController
//                                                 .selectedSpecializedCertifications
//                                                 .add(addPropertiesController
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
//                                         addPropertiesController
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
//                             "Select The Accreditations Your Home Holds To Demonstrate Adherence To High Standards Of Care"
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
//                               addPropertiesController.allAccreditations.length,
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
//                                         value: addPropertiesController
//                                             .selectedAccreditations
//                                             .contains(addPropertiesController
//                                                 .allAccreditations[index]),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           if (addPropertiesController
//                                               .selectedAccreditations
//                                               .contains(addPropertiesController
//                                                   .allAccreditations[index])) {
//                                             addPropertiesController
//                                                 .selectedAccreditations
//                                                 .remove(addPropertiesController
//                                                     .allAccreditations[index]);
//                                           } else {
//                                             addPropertiesController
//                                                 .selectedAccreditations
//                                                 .add(addPropertiesController
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
//                                         addPropertiesController
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
//                           itemCount: addPropertiesController
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
//                                         value: addPropertiesController
//                                             .selectedMemberships
//                                             .contains(addPropertiesController
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
//                                           if (addPropertiesController
//                                               .selectedMemberships
//                                               .contains(addPropertiesController
//                                                       .professionalMemberships[
//                                                   index])) {
//                                             addPropertiesController
//                                                 .selectedMemberships
//                                                 .remove(addPropertiesController
//                                                         .professionalMemberships[
//                                                     index]);
//                                           } else {
//                                             addPropertiesController
//                                                 .selectedMemberships
//                                                 .add(addPropertiesController
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
//                                         addPropertiesController
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
//                                         addPropertiesController.backgroundChecks,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.backgroundChecks =
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
//                                         !addPropertiesController.backgroundChecks,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.backgroundChecks =
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
//                                     value: addPropertiesController.drugTesting,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.drugTesting = true;
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
//                                     value: !addPropertiesController.drugTesting,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.drugTesting = false;
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
//                                     value: addPropertiesController
//                                         .referenceVerification,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
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
//                                     value: !addPropertiesController
//                                         .referenceVerification,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
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
//                            Get.toNamed(
//                               manegeRoute == "Add"
//                                   ? Routes.addPropertyScreen5
//                                   : Routes.addPropertyScreen6,
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
// }
