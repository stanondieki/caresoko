// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/add_homecare_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/enquiry_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddHomeCareScreen3 extends StatefulWidget {
  const AddHomeCareScreen3({super.key});

  @override
  State<AddHomeCareScreen3> createState() => _AddHomeCareScreen3State();
}

const List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen3State extends State<AddHomeCareScreen3> {
  final AddHomecareController addHomecareController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments != null ? Get.arguments["add"] ?? "Add" : "Add";

  String slectStatus = propartyStatus.first;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  @override
  void initState() {
    super.initState();

    if (manegeRoute == "edit") {
      // restore multi-select + toggles from existing values
      addHomecareController.staffAvailability.clear();
      final ea = addHomecareController.eStaffAvailability ?? "";
      if (ea.isNotEmpty) {
        addHomecareController.staffAvailability.addAll(ea.split(","));
      }

      addHomecareController.weekendCoverage =
          addHomecareController.eWeekendCoverage ?? false;
      addHomecareController.holidayCoverage =
          addHomecareController.eHolidayCoverage ?? false;
      setState(() {});
    }

    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isWide = width >= 900; // desktop/tablet breakpoint
    final sidePad = isWide ? 24.0 : 10.0; // nicer gutters on web
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
              : "Edit Homecare Agency".tr,
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
                          _title("Staff Availability".tr),
                          const SizedBox(height: 16),
                          _subtitle(manegeRoute == "Add"
                              ? "Step 3 of 8".tr
                              : "Step 3 of 7".tr),
                          const SizedBox(height: 10),
                          _sectionHeader(
                              "Your Hours, Weekend & Holiday Availability".tr),
                          const SizedBox(height: 10),
                          Divider(height: 0.5, color: notifire.getgreycolor),
                          const SizedBox(height: 20),

                          _sectionHeader(
                              "Staff Availability (Select all that apply)".tr),
                          const SizedBox(height: 8),

                          // Availability options (multi-select)
                          _availabilityCheckbox(
                            label: "24/7",
                            selected: addHomecareController.staffAvailability
                                .contains("24/7"),
                            onChanged: () {
                              final set =
                                  addHomecareController.staffAvailability;
                              set.contains("24/7")
                                  ? set.remove("24/7")
                                  : set.add("24/7");
                              setState(() {});
                            },
                          ),
                          _dividerInset(),
                          _availabilityCheckbox(
                            label: "Part-time",
                            selected: addHomecareController.staffAvailability
                                .contains("Part-time"),
                            onChanged: () {
                              final set =
                                  addHomecareController.staffAvailability;
                              set.contains("Part-time")
                                  ? set.remove("Part-time")
                                  : set.add("Part-time");
                              setState(() {});
                            },
                          ),
                          _dividerInset(),
                          _availabilityCheckbox(
                            label: "Live-in",
                            selected: addHomecareController.staffAvailability
                                .contains("Live-in"),
                            onChanged: () {
                              final set =
                                  addHomecareController.staffAvailability;
                              set.contains("Live-in")
                                  ? set.remove("Live-in")
                                  : set.add("Live-in");
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 16),

                          // Weekend coverage (Yes/No)
                          _question("Do you provide care on weekends?".tr),
                          _yesNo(
                            value: addHomecareController.weekendCoverage,
                            onChanged: (v) => setState(() =>
                                addHomecareController.weekendCoverage = v),
                          ),
                          const SizedBox(height: 14),

                          // Holiday coverage (Yes/No)
                          _question("Do you operate on holidays?".tr),
                          _yesNo(
                            value: addHomecareController.holidayCoverage,
                            onChanged: (v) => setState(() =>
                                addHomecareController.holidayCoverage = v),
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
                                //   Routes.addHomecareScreen4,
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
        padding: const EdgeInsets.only(left: 15),
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

  Widget _availabilityCheckbox({
    required String label,
    required bool selected,
    required VoidCallback onChanged,
  }) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Checkbox(
          value: selected,
          side: const BorderSide(color: Color(0xffC5CAD4)),
          activeColor: blueColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onChanged: (_) => onChanged(),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 17,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ],
    );
  }

  Widget _dividerInset() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(thickness: 1),
      );

  /// Reusable Yes/No control that matches your styling
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
        _dividerInset(),
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
}
// class AddHomeCareScreen3 extends StatefulWidget {
//   const AddHomeCareScreen3({super.key});
//
//   @override
//   State<AddHomeCareScreen3> createState() => _AddHomeCareScreen3State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen3State extends State<AddHomeCareScreen3> {
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
//       addHomecareController.staffAvailability.clear();
//       addHomecareController.staffAvailability.addAll(
//           addHomecareController.eStaffAvailability!.split(","));
//
//       addHomecareController.weekendCoverage =
//           addHomecareController.eWeekendCoverage!;
//       addHomecareController.holidayCoverage =
//           addHomecareController.eHolidayCoverage!;
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
//                             "Staff Availability".tr,
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
//                                 : "Step 3 of 7",
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
//                             "Your Hours, Weekend & Holiday Availability".tr,
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
//                             "Staff Availability (Select all that apply)".tr,
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
//                                         .staffAvailability
//                                         .contains("24/7"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addHomecareController
//                                           .staffAvailability
//                                           .contains("24/7")) {
//                                         addHomecareController.staffAvailability
//                                             .remove("24/7");
//                                       } else {
//                                         addHomecareController.staffAvailability
//                                             .add("24/7");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "24/7",
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
//                                     value: addHomecareController
//                                         .staffAvailability
//                                         .contains("Part-time"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addHomecareController
//                                           .staffAvailability
//                                           .contains("Part-time")) {
//                                         addHomecareController.staffAvailability
//                                             .remove("Part-time");
//                                       } else {
//                                         addHomecareController.staffAvailability
//                                             .add("Part-time");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Part-time",
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
//                                     value: addHomecareController
//                                         .staffAvailability
//                                         .contains("Live-in"),
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       if (addHomecareController
//                                           .staffAvailability
//                                           .contains("Live-in")) {
//                                         addHomecareController.staffAvailability
//                                             .remove("Live-in");
//                                       } else {
//                                         addHomecareController.staffAvailability
//                                             .add("Live-in");
//                                       }
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Live-in",
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
//                             "Do you provide care on weekends?".tr,
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
//                                         addHomecareController.weekendCoverage,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.weekendCoverage =
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
//                                         !addHomecareController.weekendCoverage,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.weekendCoverage =
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
//                             "Do you operate on holidays?".tr,
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
//                                         addHomecareController.holidayCoverage,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.holidayCoverage =
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
//                                         !addHomecareController.holidayCoverage,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.holidayCoverage =
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
//                               Routes.addHomecareScreen4,
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
