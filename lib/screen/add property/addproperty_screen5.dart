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
import 'package:intl/intl.dart';

class AddPropertyScreen5 extends StatefulWidget {
  const AddPropertyScreen5({super.key});

  @override
  State<AddPropertyScreen5> createState() => _AddPropertyScreen5State();
}

List<String> list = ["Buy", "Rent"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreen5State extends State<AddPropertyScreen5> {
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
    getdarkmodepreviousstate();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: addPropertiesController.propertyShootDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != addPropertiesController.propertyShootDate) {
      setState(() {
        addPropertiesController.propertyShootDate = picked;
        addPropertiesController.propertyShootDateController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
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
          "Add Home Or Facility".tr,
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
                isDesktop ? 1100 : (isTablet ? 900 : w);
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 12 : 20,
              vertical: isPhone ? 0 : 8,
            );

            // For galleries
            final bool useGridGalleries = !isPhone;
            final int gridCols = isDesktop ? 5 : (isTablet ? 4 : 3);
            final double gridSpacing = 12;

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
                                  _h1("Photos Of Your Home"),
                                  SizedBox(height: 20),
                                  _stepText("Step 5 of 8"),
                                  SizedBox(height: 10),
                                  _h2("High-Quality Photos To Showcase Your Home"),
                                  SizedBox(height: 10),
                                  Divider(
                                      height: 0.5,
                                      color: notifire.getgreycolor),
                                  SizedBox(height: 18),

                                  // ===== Do you have photos? =====
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Text(
                                      "Do you have high quality photos of your home or facility? (If not, you can book our professional photographers to take compliant photos of your home or facility)"
                                          .tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  _ynBlock(
                                    yesChecked:
                                        addPropertiesController.havePhotos,
                                    yesLabel: "Yes",
                                    noChecked:
                                        !addPropertiesController.havePhotos,
                                    noLabel:
                                        "No, and I would like to book your professional photographers",
                                    onYes: () => setState(() {
                                      addPropertiesController.havePhotos = true;
                                    }),
                                    onNo: () => setState(() {
                                      addPropertiesController.havePhotos =
                                          false;
                                    }),
                                  ),

                                  // ===== Booking section (only when NO photos) =====
                                  if (!addPropertiesController.havePhotos) ...[
                                    SizedBox(height: 20),
                                    _h2("Book Our Professional Photographers"),
                                    SizedBox(height: 12),
                                    _bookingSection(isPhone, isTablet),
                                  ],

                                  // ===== Upload buttons + galleries (only when YES photos) =====
                                  if (addPropertiesController.havePhotos) ...[
                                    _h2("Upload Photos"),
                                    SizedBox(height: 8),
                                    _uploadTile(
                                      label: "Dining Areas (Upload Multiple)",
                                      onTap: () => _pickFor("Dining Areas"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .diningImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Dining Areas",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label: "Bedrooms (Upload Multiple)",
                                      onTap: () => _pickFor("Bedrooms"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .bedroomsImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Bedrooms",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label:
                                          "Common Living Areas (Upload Multiple)",
                                      onTap: () =>
                                          _pickFor("Common Living Areas"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .commonLivingImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Common Living Areas",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label:
                                          "Recreational Spaces (Upload Multiple)",
                                      onTap: () =>
                                          _pickFor("Recreational Spaces"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .recreationalSpacesImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Recreational Spaces",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label: "Outdoor Areas (Upload Multiple)",
                                      onTap: () => _pickFor("Outdoor Areas"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .outdoorImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Outdoor Areas",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label:
                                          "Accessible Facilities (Eg Bathrooms, Ramps)",
                                      onTap: () =>
                                          _pickFor("Accessible Facilities"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .accessibleFacilitiesImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Accessible Facilities",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label: "Staff Quarters (Optional)",
                                      onTap: () => _pickFor("Staff Quarters"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .staffQuartersImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Staff Quarters",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                    SizedBox(height: 10),
                                    _uploadTile(
                                      label: "Others (Optional)",
                                      onTap: () => _pickFor("Others"),
                                    ),
                                    _gallery(
                                      paths: addPropertiesController
                                          .othersImagesPaths,
                                      onRemove: (i) => _removeAt(
                                        bucket: "Others",
                                        index: i,
                                      ),
                                      useGrid: useGridGalleries,
                                      gridCols: gridCols,
                                      spacing: gridSpacing,
                                    ),
                                  ],

                                  SizedBox(height: 22),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isPhone ? 24 : 35),
                                    child: GestButton(
                                      Width: double.infinity,
                                      height: 55,
                                      buttoncolor:
                                          addPropertiesController.havePhotos
                                              ? blueColor
                                              : (addPropertiesController
                                                      .consentToPhotographyTerms
                                                  ? blueColor
                                                  : greyColor),
                                      margin: EdgeInsets.zero,
                                      buttontext: "Next".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        color: WhiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onclick:
                                          addPropertiesController.havePhotos
                                              ? () {
                                                  // COMMENTED OUT: Advert functionality disabled
                                                  // Get.toNamed(
                                                  //   Routes.addPropertyScreen6,
                                                  //   arguments: {"add": "Add"},
                                                  // );
                                                }
                                              : (addPropertiesController
                                                      .consentToPhotographyTerms
                                                  ? () {
                                                      // After booking consent, you might want to move to confirmation or same step.
                                                      // COMMENTED OUT: Advert functionality disabled
                                                      // Get.toNamed(
                                                      //   Routes.addPropertyScreen5,
                                                      //   arguments: {"add": "Add"},
                                                      // );
                                                    }
                                                  : null),
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

  // =============== Reusable UI helpers ===============

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

  // Booking section (responsive 2-column on tablet/desktop)
  Widget _bookingSection(bool isPhone, bool isTablet) {
    final labelStyle = TextStyle(
      fontSize: 18,
      fontFamily: FontFamily.gilroyBold,
      color: notifire.getwhiteblackcolor,
    );

    final dateField = dateTextField(
      type: "When would you like to have the shoot?".tr,
      labelText: "Select Date".tr,
      controller: addPropertiesController.propertyShootDateController,
      isDatePicker: true,
      onDateSelected: (DateTime? date) {},
    );

    final timeField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            "What time on that day works best for you?".tr,
            style: labelStyle,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final TimeOfDay? selectedTime = await Get.dialog(
                    Theme(
                      data: Get.theme.copyWith(
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: notifire.getblackwhitecolor,
                          hourMinuteTextColor: notifire.getwhiteblackcolor,
                          dialHandColor: blueColor,
                          dialBackgroundColor:
                              notifire.getblackwhitecolor.withOpacity(0.1),
                          entryModeIconColor: notifire.getwhiteblackcolor,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style:
                              TextButton.styleFrom(foregroundColor: blueColor),
                        ),
                      ),
                      child: TimePickerDialog(initialTime: TimeOfDay.now()),
                    ),
                  );

                  if (selectedTime != null) {
                    final now = DateTime.now();
                    final dt = DateTime(now.year, now.month, now.day,
                        selectedTime.hour, selectedTime.minute);
                    final formattedTime = DateFormat('hh:mm a').format(dt);
                    addPropertiesController.updateTime(formattedTime);
                    setState(() {});
                  }
                },
                child: Container(
                  height: 55,
                  margin: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: notifire.getblackwhitecolor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: notifire.getborderColor),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 15),
                      Text(
                        addPropertiesController.propertyShootTime?.isNotEmpty ==
                                true
                            ? addPropertiesController.propertyShootTime!
                            : "Pick time".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          color: addPropertiesController
                                      .propertyShootTime?.isNotEmpty ==
                                  true
                              ? notifire.getwhiteblackcolor
                              : notifire.getgreycolor,
                        ),
                      ),
                      Spacer(),
                      Image.asset(
                        "assets/images/Calendar.png",
                        height: 25,
                        width: 25,
                        color: addPropertiesController
                                    .propertyShootTime?.isNotEmpty ==
                                true
                            ? notifire.getwhiteblackcolor
                            : notifire.getgreycolor,
                      ),
                      SizedBox(width: 5),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    final terms = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _h2("Terms Of Service"),
        SizedBox(height: 8),
        Row(
          children: [
            SizedBox(width: 10),
            Transform.scale(
              scale: 1,
              child: Checkbox(
                value: addPropertiesController.consentToPhotographyTerms,
                side: const BorderSide(color: Color(0xffC5CAD4)),
                activeColor: blueColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onChanged: (_) {
                  addPropertiesController.consentToPhotographyTerms =
                      !addPropertiesController.consentToPhotographyTerms;
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: Text(
                "I consent to GoToCareFinder's terms of service, including permission for the photographer to access the home or facility and use the images on the platform"
                    .tr,
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

    if (isPhone) {
      return Column(
        children: [
          dateField,
          SizedBox(height: 10),
          timeField,
          SizedBox(height: 10),
          terms,
        ],
      );
    }

    // Tablet/desktop: 2-column layout
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: dateField),
          SizedBox(width: 16),
          Expanded(child: timeField),
        ],
      ),
    ).buildWithBelow(terms);
  }

  // Upload tile
  Widget _uploadTile({required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff3D5BF6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label.tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Gallery that switches to grid on larger screens
  Widget _gallery({
    required List<String> paths,
    required Function(int index) onRemove,
    required bool useGrid,
    required int gridCols,
    required double spacing,
  }) {
    if (paths.isEmpty) return SizedBox.shrink();

    if (!useGrid) {
      // horizontal strip (mobile)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: SizedBox(
          height: 170,
          child: ListView.builder(
            clipBehavior: Clip.none,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: 10),
            itemCount: paths.length,
            itemBuilder: (context, index) {
              return _previewThumb(paths[index], () => onRemove(index));
            },
          ),
        ),
      );
    }

    // grid (tablet/desktop)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
      child: LayoutBuilder(
        builder: (context, box) {
          final tileWidth =
              (box.maxWidth - spacing * (gridCols - 1)) / gridCols;
          final tileHeight = 150.0;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(paths.length, (i) {
              return SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: _previewThumb(paths[i], () => onRemove(i)),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _previewThumb(String path, VoidCallback onRemove) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: FileImage(File(path)), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 5,
          top: -8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: const Color(0xff3D5BF6),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =============== Data handlers (unchanged logic) ===============

  void _pickFor(String bucket) {
    addPropertiesController.photosBeingAdded = bucket;
    _openGallery(context);
  }

  void _removeAt({required String bucket, required int index}) {
    switch (bucket) {
      case "Dining Areas":
        addPropertiesController.propertyImagesPaths
            .remove(addPropertiesController.diningImagesPaths[index]);
        addPropertiesController.propertyImagesBase64
            .remove(addPropertiesController.diningImagesBase64[index]);
        addPropertiesController.diningImagesPaths.removeAt(index);
        addPropertiesController.diningImagesBase64.removeAt(index);
        break;
      case "Bedrooms":
        addPropertiesController.propertyImagesPaths
            .remove(addPropertiesController.bedroomsImagesPaths[index]);
        addPropertiesController.propertyImagesBase64
            .remove(addPropertiesController.bedroomsImagesBase64[index]);
        addPropertiesController.bedroomsImagesPaths.removeAt(index);
        addPropertiesController.bedroomsImagesBase64.removeAt(index);
        break;
      case "Common Living Areas":
        addPropertiesController.propertyImagesPaths
            .remove(addPropertiesController.commonLivingImagesPaths[index]);
        addPropertiesController.propertyImagesBase64
            .remove(addPropertiesController.commonLivingImagesBase64[index]);
        addPropertiesController.commonLivingImagesPaths.removeAt(index);
        addPropertiesController.commonLivingImagesBase64.removeAt(index);
        break;
      case "Recreational Spaces":
        addPropertiesController.propertyImagesPaths.remove(
            addPropertiesController.recreationalSpacesImagesPaths[index]);
        addPropertiesController.propertyImagesBase64.remove(
            addPropertiesController.recreationalSpacesImagesBase64[index]);
        addPropertiesController.recreationalSpacesImagesPaths.removeAt(index);
        addPropertiesController.recreationalSpacesImagesBase64.removeAt(index);
        break;
      case "Outdoor Areas":
        addPropertiesController.propertyImagesPaths
            .remove(addPropertiesController.outdoorImagesPaths[index]);
        addPropertiesController.propertyImagesBase64
            .remove(addPropertiesController.outdoorImagesBase64[index]);
        addPropertiesController.outdoorImagesPaths.removeAt(index);
        addPropertiesController.outdoorImagesBase64.removeAt(index);
        break;
      case "Accessible Facilities":
        addPropertiesController.propertyImagesPaths.remove(
            addPropertiesController.accessibleFacilitiesImagesPaths[index]);
        addPropertiesController.propertyImagesBase64.remove(
            addPropertiesController.accessibleFacilitiesImagesBase64[index]);
        addPropertiesController.accessibleFacilitiesImagesPaths.removeAt(index);
        addPropertiesController.accessibleFacilitiesImagesBase64
            .removeAt(index);
        break;
      case "Staff Quarters":
        addPropertiesController.propertyImagesPaths
            .remove(addPropertiesController.staffQuartersImagesPaths[index]);
        addPropertiesController.propertyImagesBase64
            .remove(addPropertiesController.staffQuartersImagesBase64[index]);
        addPropertiesController.staffQuartersImagesPaths.removeAt(index);
        addPropertiesController.staffQuartersImagesBase64.removeAt(index);
        break;
      case "Others":
        addPropertiesController.propertyImagesPaths
            .remove(addPropertiesController.othersImagesPaths[index]);
        addPropertiesController.propertyImagesBase64
            .remove(addPropertiesController.othersImagesBase64[index]);
        addPropertiesController.othersImagesPaths.removeAt(index);
        addPropertiesController.othersImagesBase64.removeAt(index);
        break;
    }
    setState(() {});
  }

  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addPropertiesController.path = pickedFile.path;
      addPropertiesController.propertyImagesPaths
          .add(addPropertiesController.path!);

      File imageFile = File(addPropertiesController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addPropertiesController.base64Image = base64Encode(imageBytes);
      addPropertiesController.propertyImagesBase64
          .add(addPropertiesController.base64Image!);

      switch (addPropertiesController.photosBeingAdded) {
        case "Dining Areas":
          addPropertiesController.diningImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.diningImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Bedrooms":
          addPropertiesController.bedroomsImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.bedroomsImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Common Living Areas":
          addPropertiesController.commonLivingImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.commonLivingImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Recreational Spaces":
          addPropertiesController.recreationalSpacesImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.recreationalSpacesImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Outdoor Areas":
          addPropertiesController.outdoorImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.outdoorImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Accessible Facilities":
          addPropertiesController.accessibleFacilitiesImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.accessibleFacilitiesImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Staff Quarters":
          addPropertiesController.staffQuartersImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.staffQuartersImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
        case "Others":
          addPropertiesController.othersImagesPaths
              .add(addPropertiesController.path!);
          addPropertiesController.othersImagesBase64
              .add(addPropertiesController.base64Image!);
          break;
      }
      setState(() {});
    }
  }

  // ===== legacy field helpers (kept for parity) =====
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

  Widget dateTextField({
    String? type,
    String? labelText,
    String? prefixtext,
    Widget? suffix,
    Color? labelcolor,
    Color? prefixcolor,
    Color? floatingLabelColor,
    Color? focusedBorderColor,
    TextDecoration? decoration,
    bool? readOnly,
    double? Width,
    int? max,
    TextEditingController? controller,
    TextInputType? textInputType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool? isDatePicker,
    Function(DateTime?)? onDateSelected,
    double? Height,
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
            readOnly: isDatePicker == true ? true : readOnly ?? false,
            onTap: isDatePicker == true ? () => _selectDate(context) : null,
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
              suffixIcon: isDatePicker == true
                  ? Icon(Icons.calendar_today,
                      color: notifire.getwhiteblackcolor)
                  : suffix,
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

// small extension for stacking a widget "below" a row section
extension _Below on Widget {
  Widget buildWithBelow(Widget below) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        this,
        SizedBox(height: 12),
        below,
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
// import 'package:intl/intl.dart';
//
// class AddPropertyScreen5 extends StatefulWidget {
//   const AddPropertyScreen5({super.key});
//
//   @override
//   State<AddPropertyScreen5> createState() => _AddPropertyScreen5State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen5State extends State<AddPropertyScreen5> {
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
//     getdarkmodepreviousstate();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: addPropertiesController.propertyShootDate ?? DateTime.now(),
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
//     if (picked != null && picked != addPropertiesController.propertyShootDate) {
//       setState(() {
//         addPropertiesController.propertyShootDate = picked;
//         addPropertiesController.propertyShootDateController.text =
//             DateFormat('dd/MM/yyyy').format(picked);
//       });
//     }
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
//           "Add Home Or Facility".tr,
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
//                             "Photos Of Your Home".tr,
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
//                             "Step 5 of 8".tr,
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
//                             "High-Quality Photos To Showcase Your Home".tr,
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
//                           padding: const EdgeInsets.only(left: 15, right: 15),
//                           child: Text(
//                             "Do you have high quality photos of your home or facility? (If not, you can book our professional photographers to take compliant photos of your home or facility)"
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
//                                     value: addPropertiesController.havePhotos,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.havePhotos = true;
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
//                                     value: !addPropertiesController.havePhotos,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.havePhotos =
//                                           false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 60,
//                                   child: Text(
//                                     "No, and I would like to book your professional photographers",
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
//                         !addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 25,
//                               )
//                             : SizedBox(
//                                 height: 15,
//                               ),
//                         !addPropertiesController.havePhotos
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Book Our Professional Photographers".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 15,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? dateTextField(
//                                 type: "When would you like to have the shoot?",
//                                 labelText: "Select Date",
//                                 controller: addPropertiesController
//                                     .propertyShootDateController,
//                                 isDatePicker: true,
//                                 onDateSelected: (DateTime? date) {
//                                   // Handle the selected date
//                                   if (date != null) {
//                                     print(
//                                         'Selected shoot date: ${DateFormat('dd/MM/yyyy').format(date)}');
//                                   }
//                                 },
//                               )
//                             : SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? Row(
//                                 children: [
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(left: 15),
//                                       child: Text(
//                                         "What time on that day works best for you?"
//                                             .tr,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontFamily: FontFamily.gilroyBold,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? Row(
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         final TimeOfDay? selectedTime =
//                                             await Get.dialog(
//                                           Theme(
//                                             data: Get.theme.copyWith(
//                                               timePickerTheme:
//                                                   TimePickerThemeData(
//                                                 backgroundColor:
//                                                     notifire.getblackwhitecolor,
//                                                 hourMinuteTextColor:
//                                                     notifire.getwhiteblackcolor,
//                                                 dialHandColor: blueColor,
//                                                 dialBackgroundColor: notifire
//                                                     .getblackwhitecolor
//                                                     .withOpacity(0.1),
//                                                 entryModeIconColor:
//                                                     notifire.getwhiteblackcolor,
//                                               ),
//                                               textButtonTheme:
//                                                   TextButtonThemeData(
//                                                 style: TextButton.styleFrom(
//                                                   foregroundColor: blueColor,
//                                                 ),
//                                               ),
//                                             ),
//                                             child: TimePickerDialog(
//                                               initialTime: TimeOfDay.now(),
//                                             ),
//                                           ),
//                                         );
//
//                                         if (selectedTime != null) {
//                                           final now = DateTime.now();
//                                           final dt = DateTime(
//                                               now.year,
//                                               now.month,
//                                               now.day,
//                                               selectedTime.hour,
//                                               selectedTime.minute);
//                                           final formattedTime =
//                                               DateFormat('hh:mm a').format(dt);
//                                           addPropertiesController
//                                               .updateTime(formattedTime);
//                                           setState(() {});
//                                         }
//                                       },
//                                       child: Container(
//                                         height: 55,
//                                         margin: EdgeInsets.all(8),
//                                         child: Row(
//                                           children: [
//                                             SizedBox(width: 15),
//                                             Text(
//                                               addPropertiesController
//                                                           .propertyShootTime
//                                                           ?.isNotEmpty ==
//                                                       true
//                                                   ? addPropertiesController
//                                                       .propertyShootTime!
//                                                   : "Pick time".tr,
//                                               style: TextStyle(
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 color: addPropertiesController
//                                                             .propertyShootTime
//                                                             ?.isNotEmpty ==
//                                                         true
//                                                     ? notifire
//                                                         .getwhiteblackcolor
//                                                     : notifire.getgreycolor,
//                                               ),
//                                             ),
//                                             Spacer(),
//                                             Image.asset(
//                                               "assets/images/Calendar.png",
//                                               height: 25,
//                                               width: 25,
//                                               color: addPropertiesController
//                                                           .propertyShootTime
//                                                           ?.isNotEmpty ==
//                                                       true
//                                                   ? notifire.getwhiteblackcolor
//                                                   : notifire.getgreycolor,
//                                             ),
//                                             SizedBox(width: 5),
//                                           ],
//                                         ),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           color: notifire.getblackwhitecolor,
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                           border: Border.all(
//                                               color: notifire.getborderColor),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Terms Of Service".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.havePhotos
//                             ? Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       SizedBox(width: 10),
//                                       Transform.scale(
//                                         scale: 1,
//                                         child: Checkbox(
//                                           value: addPropertiesController
//                                               .consentToPhotographyTerms,
//                                           side: const BorderSide(
//                                               color: Color(0xffC5CAD4)),
//                                           activeColor: blueColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                           ),
//                                           onChanged: (_) {
//                                             addPropertiesController
//                                                     .consentToPhotographyTerms =
//                                                 !addPropertiesController
//                                                     .consentToPhotographyTerms;
//
//                                             setState(() {});
//                                           },
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: Get.size.width - 60,
//                                         child: Text(
//                                           "I consent to GoToCareFinder's terms of service, including permission for the photographer to access the home or facility and use the images on the platform",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 17,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Upload Photos".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Dining Areas";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Dining Areas (Upload Multiple)".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.diningImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .diningImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .diningImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .diningImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .diningImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .diningImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Bedrooms";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Bedrooms (Upload Multiple)".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.bedroomsImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .bedroomsImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .bedroomsImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .bedroomsImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .bedroomsImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .bedroomsImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Common Living Areas";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Common Living Areas (Upload Multiple)"
//                                             .tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.commonLivingImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .commonLivingImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .commonLivingImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .commonLivingImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .commonLivingImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .commonLivingImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Recreational Spaces";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Recreational Spaces (Upload Multiple)"
//                                             .tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController
//                                 .recreationalSpacesImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .recreationalSpacesImagesPaths
//                                             .length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .recreationalSpacesImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .recreationalSpacesImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .recreationalSpacesImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .recreationalSpacesImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Outdoor Areas";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Outdoor Areas (Upload Multiple)".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.outdoorImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .outdoorImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .outdoorImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .outdoorImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .outdoorImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .outdoorImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Accessible Facilities";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Accessible Facilities (Eg Bathrooms, Ramps)"
//                                             .tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController
//                                 .accessibleFacilitiesImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .accessibleFacilitiesImagesPaths
//                                             .length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .accessibleFacilitiesImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .accessibleFacilitiesImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .accessibleFacilitiesImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .accessibleFacilitiesImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Staff Quarters";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Staff Quarters (Optional)".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.staffQuartersImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .staffQuartersImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .staffQuartersImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .staffQuartersImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .staffQuartersImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .staffQuartersImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   addPropertiesController.photosBeingAdded =
//                                       "Others";
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Others (Optional)".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addPropertiesController.othersImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addPropertiesController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addPropertiesController
//                                             .othersImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addPropertiesController
//                                                                     .othersImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addPropertiesController
//                                                         .propertyImagesPaths
//                                                         .remove(addPropertiesController
//                                                                 .othersImagesPaths[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .propertyImagesBase64
//                                                         .remove(addPropertiesController
//                                                                 .othersImagesBase64[
//                                                             index]);
//                                                     addPropertiesController
//                                                         .othersImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         GestButton(
//                           Width: Get.size.width,
//                           height: 55,
//                           buttoncolor: addPropertiesController.havePhotos
//                               ? blueColor
//                               : (addPropertiesController
//                                       .consentToPhotographyTerms
//                                   ? blueColor
//                                   : greyColor),
//                           margin: EdgeInsets.only(top: 5, left: 35, right: 35),
//                           buttontext: "Next".tr,
//                           style: TextStyle(
//                             fontFamily: FontFamily.gilroyBold,
//                             color: WhiteColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           onclick: addPropertiesController.havePhotos
//                               ? () {
//                                   Get.toNamed(
//                                     Routes.addPropertyScreen6,
//                                     arguments: {"add": "Add"},
//                                   );
//                                   /*if (_formKey.currentState?.validate() ??
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
//                                 }
//                               : (addPropertiesController
//                                       .consentToPhotographyTerms
//                                   ? () {
//                                       Get.toNamed(
//                                         Routes.addPropertyScreen5,
//                                         arguments: {"add": "Add"},
//                                       );
//                                       /*if (_formKey.currentState?.validate() ??
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
//                                     }
//                                   : null),
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
//       addPropertiesController.propertyImagesPaths
//           .add(addPropertiesController.path!);
//
//       File imageFile = File(addPropertiesController.path.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       addPropertiesController.base64Image = base64Encode(imageBytes);
//       addPropertiesController.propertyImagesBase64
//           .add(addPropertiesController.base64Image!);
//
//       switch (addPropertiesController.photosBeingAdded) {
//         case "Dining Areas":
//           addPropertiesController.diningImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.diningImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Bedrooms":
//           addPropertiesController.bedroomsImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.bedroomsImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Common Living Areas":
//           addPropertiesController.commonLivingImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.commonLivingImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Recreational Spaces":
//           addPropertiesController.recreationalSpacesImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.recreationalSpacesImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Outdoor Areas":
//           addPropertiesController.outdoorImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.outdoorImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Accessible Facilities":
//           addPropertiesController.accessibleFacilitiesImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.accessibleFacilitiesImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Staff Quarters":
//           addPropertiesController.staffQuartersImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.staffQuartersImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//         case "Others":
//           addPropertiesController.othersImagesPaths
//               .add(addPropertiesController.path!);
//           addPropertiesController.othersImagesBase64
//               .add(addPropertiesController.base64Image!);
//           break;
//       }
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
//   dateTextField(
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
//   }
// }
