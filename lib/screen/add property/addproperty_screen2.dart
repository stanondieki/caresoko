// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
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

class AddPropertyScreen2 extends StatefulWidget {
  const AddPropertyScreen2({super.key});

  @override
  State<AddPropertyScreen2> createState() => _AddPropertyScreen2State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreen2State extends State<AddPropertyScreen2> {
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

  bool carCheck = false;
  bool sportCheck = false;
  bool laundaryCheck = false;

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
      try {
        setState(() {
          addPropertiesController.propertyCapacityController.text =
              (addPropertiesController.ePropertyCapacity ?? 0).toString();
          addPropertiesController.propertyBedsController.text =
              (addPropertiesController.ePropertyBeds ?? 0).toString();

          addPropertiesController.privateRoomsAvailable =
              addPropertiesController.ePrivateRoomsAvailable ?? false;
          addPropertiesController.noOfPrivateRoomsController.text =
              (addPropertiesController.eNoOfPrivateRooms ?? 0).toString();
          addPropertiesController.privateRoomsHaveOwnBathroom =
              addPropertiesController.ePrivateRoomsHaveOwnBathroom ?? false;

          addPropertiesController.sharedRoomsAvailable =
              addPropertiesController.eSharedRoomsAvailable ?? false;
          addPropertiesController.noOfSharedRoomsController.text =
              (addPropertiesController.eNoOfSharedRooms ?? 0).toString();

          // Preselect features from fList (comma-separated titles)
          final titles = (addPropertiesController.fList)
              .split(",")
              .map((e) => e.trim())
              .toSet();
          final facilities =
              dashBoardController.facilityInfo?.facilitylist ?? [];
          addPropertiesController.selectedFeaturesIndexes.clear();
          for (final f in facilities) {
            if (titles.contains(f.title)) {
              final id = f.id;
              if (id != null) {
                addPropertiesController.selectedFeaturesIndexes.add(id);
              }
            }
          }
        });
      } catch (e, stackTrace) {
        print("Edit prefill error: $e\n$stackTrace");
      }
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

            // Form field width (two columns on larger screens)
            final double fieldMaxWidth =
                isPhone ? width - 24 : (maxContentWidth - 20) / 2;

            // Features grid columns
            final facilities =
                dashBoardController.facilityInfo?.facilitylist ?? [];
            final int featureCols = isPhone ? 2 : (isTablet ? 3 : 4);

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
                                  _h1("Home Features"),
                                  SizedBox(height: 20),
                                  _step(
                                      isAdd: manegeRoute == "Add",
                                      stepAdd: "Step 2 of 8",
                                      stepEdit: "Step 2 of 7"),
                                  SizedBox(height: 10),
                                  _h2("Help Prospects Understand Your Home"),
                                  SizedBox(height: 10),
                                  Divider(
                                      height: 0.5,
                                      color: notifire.getgreycolor),
                                  SizedBox(height: 16),

                                  // ====== FORM GRID (Wrap) ======
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 12,
                                    children: [
                                      _boxed(
                                        width: fieldMaxWidth,
                                        label:
                                            "How many residents can your home house?",
                                        child: textfield(
                                          labelText: "Home Capacity".tr,
                                          controller: addPropertiesController
                                              .propertyCapacityController,
                                          textInputType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Home Capacity'
                                                  .tr;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      _boxed(
                                        width: fieldMaxWidth,
                                        label:
                                            "How many beds do you have available?",
                                        child: textfield(
                                          labelText: "Beds Available".tr,
                                          controller: addPropertiesController
                                              .propertyBedsController,
                                          textInputType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Beds Available'
                                                  .tr;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 10),
                                  _h2("Do you have private rooms available?"),
                                  SizedBox(height: 8),
                                  _binaryChoice(
                                    value: addPropertiesController
                                        .privateRoomsAvailable,
                                    onYes: () {
                                      setState(() => addPropertiesController
                                          .privateRoomsAvailable = true);
                                    },
                                    onNo: () {
                                      setState(() => addPropertiesController
                                          .privateRoomsAvailable = false);
                                    },
                                  ),

                                  if (addPropertiesController
                                      .privateRoomsAvailable) ...[
                                    _boxed(
                                      width: isPhone
                                          ? fieldMaxWidth
                                          : (maxContentWidth - 20) / 2,
                                      label:
                                          "How many private rooms do you have available?",
                                      child: textfield(
                                        labelText: "Private Rooms Available".tr,
                                        controller: addPropertiesController
                                            .noOfPrivateRoomsController,
                                        textInputType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter No Of Private Rooms'
                                                .tr;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    _h2("Do the private rooms have their own bathrooms & toilets?"),
                                    SizedBox(height: 8),
                                    _binaryChoice(
                                      value: addPropertiesController
                                          .privateRoomsHaveOwnBathroom,
                                      onYes: () {
                                        setState(() => addPropertiesController
                                                .privateRoomsHaveOwnBathroom =
                                            true);
                                      },
                                      onNo: () {
                                        setState(() => addPropertiesController
                                                .privateRoomsHaveOwnBathroom =
                                            false);
                                      },
                                    ),
                                  ],

                                  SizedBox(height: 10),
                                  _h2("Do you have shared rooms available?"),
                                  SizedBox(height: 8),
                                  _binaryChoice(
                                    value: addPropertiesController
                                        .sharedRoomsAvailable,
                                    onYes: () {
                                      setState(() => addPropertiesController
                                          .sharedRoomsAvailable = true);
                                    },
                                    onNo: () {
                                      setState(() => addPropertiesController
                                          .sharedRoomsAvailable = false);
                                    },
                                  ),

                                  if (addPropertiesController
                                      .sharedRoomsAvailable)
                                    _boxed(
                                      width: isPhone
                                          ? fieldMaxWidth
                                          : (maxContentWidth - 20) / 2,
                                      label:
                                          "How many shared rooms do you have available?",
                                      child: textfield(
                                        labelText: "Shared Rooms Available".tr,
                                        controller: addPropertiesController
                                            .noOfSharedRoomsController,
                                        textInputType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter No Of Shared Rooms'
                                                .tr;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                  SizedBox(height: 16),
                                  _h2("Select Home Features"),
                                  SizedBox(height: 10),

                                  // ====== FEATURES GRID (responsive) ======
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: facilities.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: featureCols,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 3.6, // wide chip
                                      ),
                                      itemBuilder: (context, index) {
                                        final f = facilities[index];
                                        final selected = addPropertiesController
                                            .selectedFeaturesIndexes
                                            .contains(f.id);
                                        return InkWell(
                                          onTap: () {
                                            final id = f.id;
                                            if (id == null) return;
                                            if (selected) {
                                              addPropertiesController
                                                  .selectedFeaturesIndexes
                                                  .remove(id);
                                            } else {
                                              addPropertiesController
                                                  .selectedFeaturesIndexes
                                                  .add(id);
                                            }
                                            setState(() {});
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: selected
                                                    ? blueColor
                                                    : notifire.getborderColor,
                                              ),
                                              color: selected
                                                  ? const Color(0xFFeef4ff)
                                                  : notifire.getblackwhitecolor,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: selected,
                                                  onChanged: (_) {
                                                    final id = f.id;
                                                    if (id == null) return;
                                                    if (selected) {
                                                      addPropertiesController
                                                          .selectedFeaturesIndexes
                                                          .remove(id);
                                                    } else {
                                                      addPropertiesController
                                                          .selectedFeaturesIndexes
                                                          .add(id);
                                                    }
                                                    setState(() {});
                                                  },
                                                  side: const BorderSide(
                                                      color: Color(0xffC5CAD4)),
                                                  activeColor: blueColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    f.title ?? "",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      fontSize: 15,
                                                      color: notifire
                                                          .getwhiteblackcolor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor:
                                                      const Color(0xFFeef4ff),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Image.network(
                                                      "${Config.imageUrl}${f.img ?? ""}",
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              SizedBox.shrink(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
                                        // Safe parsing
                                        addPropertiesController
                                            .propertyCapacity = int.tryParse(
                                                addPropertiesController
                                                    .propertyCapacityController
                                                    .text) ??
                                            0;

                                        addPropertiesController.propertyBeds =
                                            int.tryParse(addPropertiesController
                                                    .propertyBedsController
                                                    .text) ??
                                                0;

                                        addPropertiesController
                                            .noOfPrivateRooms = int.tryParse(
                                                addPropertiesController
                                                    .noOfPrivateRoomsController
                                                    .text) ??
                                            0;
                                        addPropertiesController
                                            .noOfSharedRooms = int.tryParse(
                                                addPropertiesController
                                                    .noOfSharedRoomsController
                                                    .text) ??
                                            0;

                                        // COMMENTED OUT: Advert functionality disabled
                                        // Get.toNamed(
                                        //   Routes.addPropertyScreen3,
                                        //   arguments: {"add": manegeRoute},
                                        // );

                                        // Keep your (optional) validation flow here if you want to enforce before navigation.
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

  // ---------- Headings & small helpers ----------
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

  Widget _boxed(
      {required double width, required String label, required Widget child}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              label.tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
          SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _binaryChoice({
    required bool value,
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
                value: value,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) => onYes(),
              ),
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
                value: !value,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) => onNo(),
              ),
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

  // ---------- Image picker (unchanged) ----------
  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addPropertiesController.path = pickedFile.path;
      setState(() {});
      File imageFile = File(addPropertiesController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addPropertiesController.base64Image = base64Encode(imageBytes);
      print("!!!!!!!!!++++++++++++${addPropertiesController.base64Image}");
      setState(() {});
    }
  }

  // ---------- Reused textfield builder ----------
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
    return Container(
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
              color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
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
// import 'package:gotocarefinder/Api/config.dart';
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
// import 'package:gotocarefinder/model/routes_helper.dart';
//
// class AddPropertyScreen2 extends StatefulWidget {
//   const AddPropertyScreen2({super.key});
//
//   @override
//   State<AddPropertyScreen2> createState() => _AddPropertyScreen2State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen2State extends State<AddPropertyScreen2> {
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
//       setState(() {
//         addPropertiesController.propertyCapacityController.text =
//             addPropertiesController.ePropertyCapacity!.toString();
//         addPropertiesController.propertyBedsController.text =
//             addPropertiesController.ePropertyBeds!.toString();
//         addPropertiesController.privateRoomsAvailable =
//             addPropertiesController.ePrivateRoomsAvailable!;
//         addPropertiesController.noOfPrivateRoomsController.text =
//             addPropertiesController.eNoOfPrivateRooms!.toString();
//         addPropertiesController.privateRoomsHaveOwnBathroom =
//             addPropertiesController.ePrivateRoomsHaveOwnBathroom!;
//         addPropertiesController.sharedRoomsAvailable =
//             addPropertiesController.eSharedRoomsAvailable!;
//         addPropertiesController.noOfSharedRoomsController.text =
//             addPropertiesController.eNoOfSharedRooms!.toString();
//         List list = addPropertiesController.fList.split(",");
//         for (var i = 0; i < list.length; i++) {
//           if (dashBoardController.facilityInfo?.facilitylist![i].title ==
//               list[i]) {
//             addPropertiesController.selectedFeaturesIndexes
//                 .add(dashBoardController.facilityInfo!.facilitylist![i].id);
//           }
//         }
//       });
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
//                             "Home Features".tr,
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
//                                 ? "Step 2 of 8".tr
//                                 : "Step 2 of 7".tr,
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
//                             "Help Prospects Understand Your Home".tr,
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
//                         textfield(
//                           type: "How many residents can your home house?".tr,
//                           controller: addPropertiesController
//                               .propertyCapacityController,
//                           labelText: "Home Capacity".tr,
//                           textInputType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Home Capacity'.tr;
//                             }
//                             return null;
//                           },
//                         ),
//                         textfield(
//                           type: "How many beds do you have available?".tr,
//                           controller:
//                               addPropertiesController.propertyBedsController,
//                           labelText: "Beds Available".tr,
//                           textInputType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Beds Available'.tr;
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you have private rooms available?".tr,
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
//                                         .privateRoomsAvailable,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .privateRoomsAvailable = true;
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
//                                         .privateRoomsAvailable,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .privateRoomsAvailable = false;
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
//                         addPropertiesController.privateRoomsAvailable
//                             ? textfield(
//                                 type:
//                                     "How many private rooms do you have available?"
//                                         .tr,
//                                 controller: addPropertiesController
//                                     .noOfPrivateRoomsController,
//                                 labelText: "Private Rooms Available".tr,
//                                 textInputType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please Enter No Of Private Rooms'
//                                         .tr;
//                                   }
//                                   return null;
//                                 },
//                               )
//                             : SizedBox(),
//                         addPropertiesController.privateRoomsAvailable
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : SizedBox(),
//                         addPropertiesController.privateRoomsAvailable
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Do the private rooms have their own bathrooms & toilets?"
//                                       .tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : SizedBox(),
//                         addPropertiesController.privateRoomsAvailable
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : SizedBox(),
//                         addPropertiesController.privateRoomsAvailable
//                             ? Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       SizedBox(width: 10),
//                                       Transform.scale(
//                                         scale: 1,
//                                         child: Checkbox(
//                                           value: addPropertiesController
//                                               .privateRoomsHaveOwnBathroom,
//                                           side: const BorderSide(
//                                               color: Color(0xffC5CAD4)),
//                                           activeColor: blueColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                           ),
//                                           onChanged: (_) {
//                                             addPropertiesController
//                                                     .privateRoomsHaveOwnBathroom =
//                                                 true;
//
//                                             setState(() {});
//                                           },
//                                         ),
//                                       ),
//                                       Text(
//                                         "Yes",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20),
//                                     child: Divider(thickness: 1),
//                                   ),
//                                   Row(
//                                     children: [
//                                       SizedBox(width: 10),
//                                       Transform.scale(
//                                         scale: 1,
//                                         child: Checkbox(
//                                           value: !addPropertiesController
//                                               .privateRoomsHaveOwnBathroom,
//                                           side: const BorderSide(
//                                               color: Color(0xffC5CAD4)),
//                                           activeColor: blueColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                           ),
//                                           onChanged: (_) {
//                                             addPropertiesController
//                                                     .privateRoomsHaveOwnBathroom =
//                                                 false;
//
//                                             setState(() {});
//                                           },
//                                         ),
//                                       ),
//                                       Text(
//                                         "No",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             : SizedBox(),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Do you have shared rooms available?".tr,
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
//                                         .sharedRoomsAvailable,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .sharedRoomsAvailable = true;
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
//                                         .sharedRoomsAvailable,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController
//                                           .sharedRoomsAvailable = false;
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
//                         addPropertiesController.sharedRoomsAvailable
//                             ? textfield(
//                                 type:
//                                     "How many shared rooms do you have available?"
//                                         .tr,
//                                 controller: addPropertiesController
//                                     .noOfSharedRoomsController,
//                                 labelText: "Shared Rooms Available".tr,
//                                 textInputType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please Enter No Of Shared Rooms'.tr;
//                                   }
//                                   return null;
//                                 },
//                               )
//                             : SizedBox(),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Select Home Features".tr,
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
//                         ListView.builder(
//                           itemCount: dashBoardController
//                               .facilityInfo?.facilitylist!.length,
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
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
//                                             .selectedFeaturesIndexes
//                                             .contains(dashBoardController
//                                                 .facilityInfo
//                                                 ?.facilitylist![index]
//                                                 .id),
//                                         side: const BorderSide(
//                                             color: Color(0xffC5CAD4)),
//                                         activeColor: blueColor,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5),
//                                         ),
//                                         onChanged: (_) {
//                                           final facilityId = dashBoardController
//                                               .facilityInfo
//                                               ?.facilitylist![index]
//                                               .id;
//
//                                           if (addPropertiesController
//                                               .selectedFeaturesIndexes
//                                               .contains(facilityId)) {
//                                             addPropertiesController
//                                                 .selectedFeaturesIndexes
//                                                 .remove(facilityId); // unselect
//                                           } else {
//                                             addPropertiesController
//                                                 .selectedFeaturesIndexes
//                                                 .add(facilityId!); // select
//                                           }
//
//                                           setState(() {});
//                                         },
//                                       ),
//                                     ),
//                                     Text(
//                                       dashBoardController.facilityInfo
//                                               ?.facilitylist![index].title ??
//                                           "",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 17,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     Container(
//                                       height: 40,
//                                       width: 40,
//                                       padding: EdgeInsets.all(8),
//                                       child: Image.network(
//                                         "${Config.imageUrl}${dashBoardController.facilityInfo?.facilitylist![index].img ?? ""}",
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Color(0xFFeef4ff),
//                                         shape: BoxShape.circle,
//                                       ),
//                                     ),
//                                     SizedBox(width: 15),
//                                   ],
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 20),
//                                   child: Divider(thickness: 1),
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
//                             addPropertiesController.propertyCapacity =
//                                 int.parse(addPropertiesController
//                                     .propertyCapacityController.text);
//
//                             addPropertiesController.propertyBeds = int.parse(
//                                 addPropertiesController
//                                     .propertyBedsController.text);
//
//                             addPropertiesController.noOfPrivateRooms =
//                                 int.parse(addPropertiesController
//                                     .noOfPrivateRoomsController.text);
//
//                             addPropertiesController.noOfSharedRooms = int.parse(
//                                 addPropertiesController
//                                     .noOfSharedRoomsController.text);
//
//                             Get.toNamed(
//                               Routes.addPropertyScreen3,
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
