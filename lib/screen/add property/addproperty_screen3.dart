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

class AddPropertyScreen3 extends StatefulWidget {
  const AddPropertyScreen3({super.key});

  @override
  State<AddPropertyScreen3> createState() => _AddPropertyScreen3State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreen3State extends State<AddPropertyScreen3> {
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

  // Available recreational activity choices (editable list)
  final List<String> _recreationOptions = const [
    "Trips",
    "Birthday Parties",
    "Entertainment Performances",
    "Anniversary Parties",
  ];

  @override
  void initState() {
    super.initState();

    if (manegeRoute == "edit") {
      // Prefill toggles
      addPropertiesController.acceptMemoryCareClients =
          addPropertiesController.eAcceptMemoryCareClients ?? false;
      addPropertiesController.acceptMedicaidClients =
          addPropertiesController.eAcceptMedicaidClients ?? false;
      addPropertiesController.acceptHoyerClients =
          addPropertiesController.eAcceptHoyerClients ?? false;
      addPropertiesController.acceptCorrectionalClients =
          addPropertiesController.eAcceptCorrectionalClients ?? false;
      addPropertiesController.provideCuratedMenus =
          addPropertiesController.eProvideCuratedMenus ?? false;
      addPropertiesController.provideMedicationReminders =
          addPropertiesController.eProvideMedicationReminders ?? false;

      // Prefill selected recreation items
      final raw = addPropertiesController.eRecreationalActivities ?? '';
      addPropertiesController.selectedRecreationalFacilities =
          raw.isEmpty ? [] : raw.split(',').map((e) => e.trim()).toList();
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

            final double maxContentWidth =
                isDesktop ? 1100 : (isTablet ? 900 : width);
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 12 : 20,
              vertical: isPhone ? 0 : 8,
            );

            // Two-column info sections if needed; headings full width
            final double halfWidth =
                isPhone ? width - 24 : (maxContentWidth - 20) / 2;

            // Recreation grid columns
            final int recCols = isPhone ? 2 : (isTablet ? 3 : 4);

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
                                  SizedBox(height: 12),
                                  _h1("Tell Us About Your Services"),
                                  SizedBox(height: 20),
                                  _step(
                                      isAdd: manegeRoute == "Add",
                                      stepAdd: "Step 3 of 8",
                                      stepEdit: "Step 3 of 7"),
                                  SizedBox(height: 10),
                                  _h2("Select The Scope Of Your Offerings"),
                                  SizedBox(height: 10),
                                  Divider(
                                      height: 0.5,
                                      color: notifire.getgreycolor),
                                  SizedBox(height: 16),

                                  // ====== YES/NO QUESTIONS (stacked; still responsive with halfWidth if you ever want two side-by-side) ======
                                  _ynSection(
                                    label: "Do you accept memory care clients?",
                                    value: addPropertiesController
                                        .acceptMemoryCareClients,
                                    onChanged: (val) => setState(() =>
                                        addPropertiesController
                                            .acceptMemoryCareClients = val),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label: "Do you accept Medicaid clients?",
                                    value: addPropertiesController
                                        .acceptMedicaidClients,
                                    onChanged: (val) => setState(() =>
                                        addPropertiesController
                                            .acceptMedicaidClients = val),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label: "Do you accept Hoyer clients?",
                                    value: addPropertiesController
                                        .acceptHoyerClients,
                                    onChanged: (val) => setState(() =>
                                        addPropertiesController
                                            .acceptHoyerClients = val),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label:
                                        "Do you accept correctional clients?",
                                    value: addPropertiesController
                                        .acceptCorrectionalClients,
                                    onChanged: (val) => setState(() =>
                                        addPropertiesController
                                            .acceptCorrectionalClients = val),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label: "Do you provide curated menus?",
                                    value: addPropertiesController
                                        .provideCuratedMenus,
                                    onChanged: (val) => setState(() =>
                                        addPropertiesController
                                            .provideCuratedMenus = val),
                                  ),
                                  SizedBox(height: 10),

                                  _ynSection(
                                    label:
                                        "Do you provide medication reminders?",
                                    value: addPropertiesController
                                        .provideMedicationReminders,
                                    onChanged: (val) => setState(() =>
                                        addPropertiesController
                                            .provideMedicationReminders = val),
                                  ),
                                  SizedBox(height: 16),

                                  // ====== RECREATION (responsive grid of chips) ======
                                  _h2("Recreational Activities (Select)"),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child:
                                        LayoutBuilder(builder: (context, box) {
                                      final double gridWidth = box.maxWidth;
                                      final double spacing = 12;
                                      // Simple, flexible tile width
                                      final double tileWidth = (gridWidth -
                                              spacing * (recCols - 1)) /
                                          recCols;

                                      return Wrap(
                                        spacing: spacing,
                                        runSpacing: spacing,
                                        children:
                                            _recreationOptions.map((label) {
                                          final bool selected =
                                              addPropertiesController
                                                  .selectedRecreationalFacilities
                                                  .contains(label);

                                          return SizedBox(
                                            width: tileWidth,
                                            child: _SelectableChipTile(
                                              label: label,
                                              selected: selected,
                                              onTap: () {
                                                final selectedSet =
                                                    addPropertiesController
                                                        .selectedRecreationalFacilities;
                                                if (selected) {
                                                  selectedSet.remove(label);
                                                } else {
                                                  selectedSet.add(label);
                                                }
                                                setState(() {});
                                              },
                                              notifire: notifire,
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    }),
                                  ),

                                  SizedBox(height: 24),
                                  // ====== NEXT BUTTON ======
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
                                        // Persist recreation list to controller string if you need later:
                                        // addPropertiesController.recreationalActivities =
                                        //     addPropertiesController.selectedRecreationalFacilities.join(',');

                                        Get.toNamed(
                                          Routes.addPropertyScreen4,
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

  // ---------- Yes/No section (more compact, reusable, responsive-friendly) ----------
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

  // ---------- Selectable chip-like tile (checkbox + label) ----------
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

// ---------- Reused textfield builder (kept for API parity with other screens) ----------
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
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 48,
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
                label.tr,
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
// class AddPropertyScreen3 extends StatefulWidget {
//   const AddPropertyScreen3({super.key});
//
//   @override
//   State<AddPropertyScreen3> createState() => _AddPropertyScreen3State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen3State extends State<AddPropertyScreen3> {
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
//       addPropertiesController.acceptMemoryCareClients =
//           addPropertiesController.eAcceptMemoryCareClients!;
//       addPropertiesController.acceptMedicaidClients =
//           addPropertiesController.eAcceptMedicaidClients!;
//       addPropertiesController.acceptHoyerClients =
//           addPropertiesController.eAcceptHoyerClients!;
//       addPropertiesController.acceptCorrectionalClients =
//           addPropertiesController.eAcceptCorrectionalClients!;
//       addPropertiesController.provideCuratedMenus =
//           addPropertiesController.eProvideCuratedMenus!;
//       addPropertiesController.provideMedicationReminders =
//           addPropertiesController.eProvideMedicationReminders!;
//
//       addPropertiesController.selectedRecreationalFacilities =
//           addPropertiesController.eRecreationalActivities!.split(',');
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
//                             "Tell Us About Your Services".tr,
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
//                                 ? "Step 3 of 8".tr
//                                 : "Step 3 of 7".tr,
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
//                             "Select The Scope Of Your Offerings".tr,
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
//                             "Do you accept memory care clients?".tr,
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
//                                         .acceptMemoryCareClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptMemoryCareClients = true;
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
//                                         .acceptMemoryCareClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptMemoryCareClients = false;
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
//                             "Do you accept Medicaid clients?".tr,
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
//                                         .acceptMedicaidClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptMedicaidClients = true;
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
//                                         .acceptMedicaidClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptMedicaidClients = false;
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
//                             "Do you accept Hoyer clients?".tr,
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
//                                         .acceptHoyerClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptHoyerClients = true;
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
//                                         .acceptHoyerClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptHoyerClients = false;
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
//                             "Do you accept correctional clients?".tr,
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
//                                         .acceptCorrectionalClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptCorrectionalClients = true;
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
//                                         .acceptCorrectionalClients,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .acceptCorrectionalClients = false;
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
//                             "Do you provide curated menus?".tr,
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
//                                         .provideCuratedMenus,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .provideCuratedMenus = true;
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
//                                         .provideCuratedMenus,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .provideCuratedMenus = false;
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
//                             "Do you provide medication reminders?".tr,
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
//                                         .provideMedicationReminders,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .provideMedicationReminders = true;
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
//                                         .provideMedicationReminders,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .provideMedicationReminders = false;
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
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Recreational Activities (Select)".tr,
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
//                                         .selectedRecreationalFacilities
//                                         .contains("Trips"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addPropertiesController
//                                           .selectedRecreationalFacilities
//                                           .contains("Trips")) {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .remove("Trips");
//                                       } else {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .add("Trips");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Trips",
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
//                                     value: addPropertiesController
//                                         .selectedRecreationalFacilities
//                                         .contains("Birthday Parties"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addPropertiesController
//                                           .selectedRecreationalFacilities
//                                           .contains("Birthday Parties")) {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .remove("Birthday Parties");
//                                       } else {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .add("Birthday Parties");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Birthday Parties",
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
//                                     value: addPropertiesController
//                                         .selectedRecreationalFacilities
//                                         .contains("Entertainment Performances"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addPropertiesController
//                                           .selectedRecreationalFacilities
//                                           .contains(
//                                               "Entertainment Performances")) {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .remove(
//                                                 "Entertainment Performances");
//                                       } else {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .add("Entertainment Performances");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Entertainment Performances",
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
//                                     value: addPropertiesController
//                                         .selectedRecreationalFacilities
//                                         .contains("Anniversary Parties"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addPropertiesController
//                                           .selectedRecreationalFacilities
//                                           .contains("Anniversary Parties")) {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .remove("Anniversary Parties");
//                                       } else {
//                                         addPropertiesController
//                                             .selectedRecreationalFacilities
//                                             .add("Anniversary Parties");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Anniversary Parties",
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
//                               Routes.addPropertyScreen4,
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
