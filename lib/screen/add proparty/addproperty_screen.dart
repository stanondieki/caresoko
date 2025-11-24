// ignore_for_file: file_names, prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/add_proparty/addproperties_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/enquiry_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gotocarefinder/Api/data_store.dart'; // for getData.read("UserLogin")
import 'package:gotocarefinder/services/stripe_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

/// Purpose & status lists
const List<String> list = ["Sell", "Rent Out"];
const List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final AddPropartiesController addPropertiesController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// route arg
  late final String manegeRoute = Get.arguments["add"]; // "Add" or "edit"
  bool get isEdit => manegeRoute == "edit";

  String propertyPurpose = list.first;
  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  /// Cross-platform toast (no plugins)
  Future<void> showToastMessage(
      String message, {
        String title = '',
        bool error = false,
        SnackPosition position = SnackPosition.BOTTOM,
      }) async {
    if (Get.isSnackbarOpen) Get.back();
    Get.snackbar(
      title,
      message,
      snackPosition: position,
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
      backgroundColor:
      error ? const Color(0xFFE53935) : const Color(0xFF323232),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<Position> locateUser() async =>
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  late GoogleMapController mapController1;
  final Set<Marker> markers = <Marker>{};

  /// Robust double parser
  double _asDouble(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      if (v.trim().isEmpty) return fallback;
      final parsed = double.tryParse(v);
      return parsed ?? fallback;
    }
    return fallback;
  }

  Future<Uint8List> getImages(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    final fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _onAddMarkerButtonPressed(double lat, double lng) async {
    final markIcon = await getImages("assets/images/location_pin.png", 80);
    markers
      ..clear()
      ..add(
        Marker(
          markerId: const MarkerId("1"),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.fromBytes(markIcon),
        ),
      );
    setState(() {});
  }

  Future<void> getCurrentLatAndLong(double latitude, double longitude) async {
    addPropertiesController.lat = latitude;
    addPropertiesController.long = longitude;

    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return;
    final p = placemarks.first;

    if (!isEdit) {
      addPropertiesController.propertyAddress =
      '${p.name}, ${p.locality}, ${p.country}';
      addPropertiesController.propertyZipCode = p.postalCode ?? '';
      addPropertiesController.propertyCountry = p.country ?? '';
      addPropertiesController.propertyCity = p.locality ?? '';
    } else {
      addPropertiesController.ePropertyAddress =
      '${p.name}, ${p.locality}, ${p.country}';
      addPropertiesController.ePropertyZipCode = p.postalCode ?? '';
      addPropertiesController.ePropertyCountry = p.country ?? '';
      addPropertiesController.ePropertyCity = p.locality ?? '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: addPropertiesController.propertyShootDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
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
  void initState() {
    super.initState();

    if (isEdit) {
      // ***** DO NOT emptyAllDetails() here *****
      // PREFILL ON EDIT from e* fields (must be set before navigation)
      addPropertiesController.propertyTitleController.text =
          addPropertiesController.eTitle;
      addPropertiesController.contactNumberController.text =
          addPropertiesController.eNumber;
      addPropertiesController.propertyPriceController.text =
          addPropertiesController.ePrice;
      addPropertiesController.propertyBedsController.text =
          addPropertiesController.eTotalBeds;
      addPropertiesController.propertyBathroomsController.text =
          addPropertiesController.eTotalBathroom;
      addPropertiesController.propertySizeController.text =
          addPropertiesController.eSqft;
      addPropertiesController.propertyDescriptionController.text =
          addPropertiesController.eDescription;

      addPropertiesController.lat = _asDouble(addPropertiesController.elat);
      addPropertiesController.long = _asDouble(addPropertiesController.elong);

      // restore selected facilities from CSV titles
      final fCsv = (addPropertiesController.fList ?? '').split(",");
      final facilities =
          dashBoardController.propartyFacilityInfo?.facilitylist ?? [];
      for (var i = 0; i < fCsv.length; i++) {
        final csvTitle = fCsv[i].trim();
        final match =
        facilities.firstWhereOrNull((f) => (f.title ?? '') == csvTitle);
        if (match != null) {
          addPropertiesController.selectedFacilities.add(match.id);
        }
      }
      ///
      ///
      propertyPurpose =
      addPropertiesController.pbuySell == "2" ? "Sell" : "Rent Out";
      selectProperty = addPropertiesController.pName;
      selectCountry  = addPropertiesController.countryName;
      ///
      selectProperty = addPropertiesController.pName;
      selectCountry = addPropertiesController.countryName;

      // property purpose + status
      propertyPurpose =
      (addPropertiesController.pbuySell == "2") ? "Sell" : "Rent Out";
      slectStatus =
      addPropertiesController.status == "1" ? "Publish" : "UnPublish";
    } else {
      // ***** Only clear for Add mode *****
      addPropertiesController.emptyAllDetails();
      addPropertiesController.selectedFacilities = [];
      addPropertiesController.pType = "";
      addPropertiesController.countryId = "";
      selectProperty = null;
      selectCountry = null;
    }

    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 900;
    final horizPad = isWide ? 24.0 : 10.0;

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
          isEdit ? "Edit Advert".tr : "Create An Advert".tr,
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
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizPad),
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

                          // --- The rest of your UI is unchanged ---
                          // (I’ll keep content identical, only button is changed)

                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Selling Or Renting Out Your Property?".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 18,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "You're In The Right Place".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 14,
                                color: notifire.getgreycolor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Let's Find You A Buyer Or Tenant".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 0.5, color: notifire.getgreycolor),
                          const SizedBox(height: 16),

                          /// Purpose
                          _label(
                              "What are you looking to do with your property?"
                                  .tr),
                          _dropdown<String>(
                            value: propertyPurpose,
                            items: list,
                            onChanged: (value) {
                              setState(() {
                                addPropertiesController.pbuySell =
                                (value == "Sell") ? "2" : "1";
                                propertyPurpose = value ?? list.first;
                              });
                            },
                          ),

                          /// Property Type
                          _label("Property Type".tr),
                          _dropdown<String>(
                            value: selectProperty,
                            hint: "Select Property Type".tr,
                            items: dashBoardController.propartyTypeList,
                            onChanged: (value) {
                              final types =
                                  dashBoardController.propartyTypeInfo
                                      ?.typelist ??
                                      [];
                              for (final t in types) {
                                if (value == t.title) {
                                  addPropertiesController.pType = t.id ?? "";
                                  break;
                                }
                              }
                              setState(() => selectProperty = value);
                            },
                          ),

                          /// Title
                          _textfield(
                            type: "Property Name Or Title".tr,
                            controller:
                            addPropertiesController.propertyTitleController,
                            labelText: "Property Name".tr,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Property Title'.tr
                                : null,
                          ),

                          const SizedBox(height: 6),
                          _label("Where is your property located?".tr),

                          /// Google Map
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: GoogleMap(
                                  gestureRecognizers: {
                                    Factory<OneSequenceGestureRecognizer>(
                                            () => EagerGestureRecognizer())
                                  },
                                  initialCameraPosition: CameraPosition(
                                    target: (!isEdit)
                                        ? const LatLng(47.751076, -120.740135)
                                        : LatLng(
                                      _asDouble(
                                          addPropertiesController.elat,
                                          fallback: 0),
                                      _asDouble(
                                          addPropertiesController.elong,
                                          fallback: 0),
                                    ),
                                    zoom: 13,
                                  ),
                                  mapType: MapType.normal,
                                  markers: markers,
                                  onTap: (pos) async {
                                    await _onAddMarkerButtonPressed(
                                        pos.latitude, pos.longitude);
                                    addPropertiesController.lat = pos.latitude;
                                    addPropertiesController.long =
                                        pos.longitude;
                                    await getCurrentLatAndLong(
                                        pos.latitude, pos.longitude);
                                    addPropertiesController.update();
                                  },
                                  myLocationEnabled: true,
                                  zoomGesturesEnabled: true,
                                  tiltGesturesEnabled: true,
                                  zoomControlsEnabled: true,
                                  onMapCreated: (controller) => setState(
                                          () => mapController1 = controller),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// Description
                          _label("Property Description".tr),
                          _multiline(
                            controller: addPropertiesController
                                .propertyDescriptionController,
                            hint:
                            "Describe the property to your prospects. Highlight the living environment, available care services, key amenities, and any unique features that set it apart. Keep it clear and inviting to help prospects make an informed decision."
                                .tr,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Property Description'.tr
                                : null,
                          ),

                          /// Numeric fields
                          _textfield(
                            type: "How many beds does your property have?".tr,
                            controller:
                            addPropertiesController.propertyBedsController,
                            labelText: "Number of beds".tr,
                            textInputType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Total Beds'.tr
                                : null,
                          ),
                          _textfield(
                            type: "How many bathrooms does your property have?"
                                .tr,
                            controller: addPropertiesController
                                .propertyBathroomsController,
                            labelText: "Number of bathrooms".tr,
                            textInputType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Number Of Bathrooms'.tr
                                : null,
                          ),
                          _textfield(
                            type: "Property Size (sq. ft.) - ".tr +
                                (propertyPurpose == "Sell"
                                    ? "Enter the total square footage of the property to give potential buyers a sense of space"
                                    .tr
                                    : "Enter the total square footage of the property to give potential tenants a sense of space"
                                    .tr),
                            controller:
                            addPropertiesController.propertySizeController,
                            labelText: "Property size".tr,
                            textInputType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Property Size'.tr
                                : null,
                          ),

                          const SizedBox(height: 8),
                          _label("Select Property Facilities".tr),

                          /// Facilities
                          GetBuilder<AddPropartiesController>(builder: (_) {
                            final fl = dashBoardController
                                .propartyFacilityInfo?.facilitylist ??
                                [];
                            return ListView.separated(
                              itemCount: fl.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (_, __) => Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(thickness: 1),
                              ),
                              itemBuilder: (context, index) {
                                final item = fl[index];
                                final selected = addPropertiesController
                                    .selectedFacilities
                                    .contains(item.id);
                                return Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    Checkbox(
                                      value: selected,
                                      side: const BorderSide(
                                          color: Color(0xffC5CAD4)),
                                      activeColor: blueColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(5)),
                                      onChanged: (_) {
                                        setState(() {
                                          if (selected) {
                                            addPropertiesController
                                                .selectedFacilities
                                                .remove(item.id);
                                          } else {
                                            addPropertiesController
                                                .selectedFacilities
                                                .add(item.id);
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.title ?? "",
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          fontSize: 17,
                                          color: notifire.getwhiteblackcolor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      width: 40,
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFeef4ff),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.network(
                                        "${Config.imageUrl}${item.img ?? ""}",
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                  ],
                                );
                              },
                            );
                          }),

                          /// Price / Rent
                          _textfield(
                            type: propertyPurpose == "Sell"
                                ? "Selling Price".tr
                                : "Property Rent".tr,
                            controller:
                            addPropertiesController.propertyPriceController,
                            labelText: propertyPurpose == "Sell"
                                ? "Price".tr
                                : "Rent Amount".tr,
                            textInputType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (propertyPurpose == "Sell"
                                ? 'Please Enter The Selling Price'.tr
                                : 'Please Enter The Rent Amount'.tr)
                                : null,
                          ),

                          /// Contact
                          _textfield(
                            type: "Contact Number".tr,
                            controller:
                            addPropertiesController.contactNumberController,
                            labelText:
                            "Enter a phone number prospects can contact you on"
                                .tr,
                            textInputType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Mobile Number'.tr
                                : null,
                          ),

                          const SizedBox(height: 16),
                          _label("High-Quality Photos To Showcase Your Property"
                              .tr),
                          const SizedBox(height: 8),
                          Divider(height: 0.5, color: notifire.getgreycolor),
                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Do you have high quality photos of your property? (If not, you can book our professional photographers to take compliant photos of your property)"
                                  .tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          /// Have Photos toggle
                          Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Checkbox(
                                    value: addPropertiesController.havePhotos,
                                    side: const BorderSide(
                                        color: Color(0xffC5CAD4)),
                                    activeColor: blueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    onChanged: (_) => setState(() =>
                                    addPropertiesController.havePhotos =
                                    true),
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
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(thickness: 1),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 10),
                                  Checkbox(
                                    value: !addPropertiesController.havePhotos,
                                    side: const BorderSide(
                                        color: Color(0xffC5CAD4)),
                                    activeColor: blueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    onChanged: (_) => setState(() =>
                                    addPropertiesController.havePhotos =
                                    false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "No, and I would like to book your professional photographers",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 17,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(
                            height:
                            addPropertiesController.havePhotos ? 15 : 25,
                          ),

                          /// Booking photographers (if no photos)
                          if (!addPropertiesController.havePhotos) ...[
                            _label("Book Our Professional Photographers".tr),
                            const SizedBox(height: 10),
                            _dateTextField(
                              type: "When would you like to have the shoot?",
                              labelText: "Select Date",
                              controller: addPropertiesController
                                  .propertyShootDateController,
                              isDatePicker: true,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                "What time on that day works best for you?".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final TimeOfDay? selectedTime =
                                      await Get.dialog(
                                        Theme(
                                          data: Get.theme.copyWith(
                                            timePickerTheme:
                                            TimePickerThemeData(
                                              backgroundColor:
                                              notifire.getblackwhitecolor,
                                              hourMinuteTextColor:
                                              notifire.getwhiteblackcolor,
                                              dialHandColor: blueColor,
                                              dialBackgroundColor: notifire
                                                  .getblackwhitecolor
                                                  .withOpacity(0.1),
                                              entryModeIconColor:
                                              notifire.getwhiteblackcolor,
                                            ),
                                            textButtonTheme:
                                            TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                  foregroundColor: blueColor),
                                            ),
                                          ),
                                          child: TimePickerDialog(
                                            initialTime: TimeOfDay.now(),
                                          ),
                                        ),
                                      );
                                      if (selectedTime != null) {
                                        final now = DateTime.now();
                                        final dt = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          selectedTime.hour,
                                          selectedTime.minute,
                                        );
                                        final formattedTime =
                                        DateFormat('hh:mm a').format(dt);
                                        addPropertiesController
                                            .updateTime(formattedTime);
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      height: 55,
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: notifire.getblackwhitecolor,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color: notifire.getborderColor),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              (addPropertiesController
                                                  .propertyShootTime
                                                  ?.isNotEmpty ??
                                                  false)
                                                  ? addPropertiesController
                                                  .propertyShootTime!
                                                  : "Pick time".tr,
                                              style: TextStyle(
                                                fontFamily:
                                                FontFamily.gilroyMedium,
                                                color: (addPropertiesController
                                                    .propertyShootTime
                                                    ?.isNotEmpty ??
                                                    false)
                                                    ? notifire
                                                    .getwhiteblackcolor
                                                    : notifire.getgreycolor,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/Calendar.png",
                                            height: 25,
                                            width: 25,
                                            color: (addPropertiesController
                                                .propertyShootTime
                                                ?.isNotEmpty ??
                                                false)
                                                ? notifire.getwhiteblackcolor
                                                : notifire.getgreycolor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _label("Terms Of Service".tr),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Checkbox(
                                  value: addPropertiesController
                                      .consentToPhotographyTerms,
                                  side: const BorderSide(
                                      color: Color(0xffC5CAD4)),
                                  activeColor: blueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (_) => setState(() {
                                    addPropertiesController
                                        .consentToPhotographyTerms =
                                    !addPropertiesController
                                        .consentToPhotographyTerms;
                                  }),
                                ),
                                Expanded(
                                  child: Text(
                                    "I consent to GoToCareFinder's terms of service, including permission for the photographer to access the property and use the images on the platform",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 17,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          /// Upload photos (if user has their own)
                          if (addPropertiesController.havePhotos) ...[
                            _label("Upload Photos".tr),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _openGallery(context),
                              child: Center(
                                child: Container(
                                  width: media.size.width - 20,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xff3D5BF6)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Upload Photos (Multiple)".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (addPropertiesController
                                .propertyImagesPaths.isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  height: 170,
                                  child: ListView.builder(
                                    clipBehavior: Clip.none,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(bottom: 10),
                                    itemCount: addPropertiesController
                                        .propertyImagesPaths.length,
                                    itemBuilder: (context, index) {
                                      final path = addPropertiesController
                                          .propertyImagesPaths[index];
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: 300,
                                            width: 150,
                                            margin: const EdgeInsets.only(
                                                right: 15),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: FileImage(File(path)),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 5,
                                            top: -8,
                                            child: GestureDetector(
                                              onTap: () {
                                                addPropertiesController
                                                    .propertyImagesBase64
                                                    .removeAt(index);
                                                addPropertiesController
                                                    .propertyImagesPaths
                                                    .removeAt(index);
                                                setState(() {});
                                              },
                                              child: Container(
                                                height: 26,
                                                width: 26,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xff3D5BF6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],

                          /// Status
                          _label("Advert Status".tr),
                          _dropdown<String>(
                            value: slectStatus,
                            items: propartyStatus,
                            onChanged: (value) {
                              if (value == "Publish") {
                                addPropertiesController.status = "1";
                              } else if (value == "UnPublish") {
                                addPropertiesController.status = "0";
                              }
                              setState(() =>
                              slectStatus = value ?? propartyStatus.first);
                            },
                          ),

                          const SizedBox(height: 12),
                          if (addPropertiesController.pShell == "0")
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isWide ? 120 : 35),
                              child: GestButton(
                                Width: double.infinity,
                                height: 55,
                                buttoncolor: blueColor,
                                margin: const EdgeInsets.only(top: 5),
                                buttontext: isEdit
                                    ? "Update".tr
                                    : "Create Advert".tr,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  color: WhiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),

                                // IMPORTANT: GestButton uses `onclick`
                                onclick: () async {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    await showToastMessage(
                                      "Please fill all required fields".tr,
                                      error: true,
                                    );
                                    return;
                                  }
                                  if ((addPropertiesController.lat == null) ||
                                      (addPropertiesController.long == null)) {
                                    await showToastMessage(
                                      "Please add your property location".tr,
                                      error: true,
                                    );
                                    return;
                                  }

                                  final user =
                                      getData.read("UserLogin") ?? {};
                                  final userId = user["id"].toString();

                                  try {
                                    if (isEdit) {
                                      // --------- EDIT FLOW -> update-property.php ----------
                                      final resp = await http.post(
                                        Uri.parse(
                                            "${baseUrl}update-property.php"),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: jsonEncode({
                                          "prop_id":
                                          addPropertiesController.propId,
                                          "uid": userId,
                                          "status":
                                          addPropertiesController.status,
                                          "title": addPropertiesController
                                              .propertyTitleController.text,
                                          "price": addPropertiesController
                                              .propertyPriceController.text,
                                          "address": addPropertiesController
                                              .propertyAddress,
                                          "description":
                                          addPropertiesController
                                              .propertyDescriptionController
                                              .text,
                                          "ccount":
                                          addPropertiesController
                                              .propertyCity ??
                                              "",
                                          "ptype":
                                          addPropertiesController.pType,
                                          "facility": addPropertiesController
                                              .selectedFacilities,
                                          "beds": addPropertiesController
                                              .propertyBedsController.text,
                                          "bathroom":
                                          addPropertiesController
                                              .propertyBathroomsController
                                              .text,
                                          "sqft": addPropertiesController
                                              .propertySizeController.text,
                                          "rate": "0",
                                          "latitude":
                                          addPropertiesController.lat,
                                          "longtitude":
                                          addPropertiesController.long,
                                          "mobile": addPropertiesController
                                              .contactNumberController.text,
                                          "plimit": "",
                                          "country_id":
                                          addPropertiesController
                                              .countryId,
                                          "pbuysell":
                                          addPropertiesController.pbuySell,
                                          "img": "0", // keep existing image
                                        }),
                                      );

                                      print(
                                          "update-property => ${resp.statusCode} ${resp.body}");

                                      final data =
                                      jsonDecode(resp.body.toString());

                                      if (resp.statusCode != 200 ||
                                          data["Result"] != "true") {
                                        await showToastMessage(
                                          data["ResponseMsg"] ??
                                              "Could not update property",
                                          error: true,
                                        );
                                        return;
                                      }

                                      await showToastMessage(
                                          "Property updated successfully".tr);
                                      Get.back(); // or refresh list
                                    } else {
                                      // --------- ADD FLOW -> create order + Stripe + finalize ----------
                                      final orderResp = await http.post(
                                        Uri.parse(
                                            "${baseUrl}create-advert-order.php"),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: jsonEncode({"uid": userId}),
                                      );
                                      print(
                                          "create-advert-order => ${orderResp.statusCode} ${orderResp.body}");

                                      final order =
                                      jsonDecode(orderResp.body);
                                      if (order["Result"] != "true") {
                                        await showToastMessage(
                                          order["ResponseMsg"] ??
                                              "Could not create order",
                                          error: true,
                                        );
                                        return;
                                      }

                                      final int orderId = int.parse(
                                          order["order_id"].toString());
                                      final int amount = int.parse(
                                          order["amount"].toString());
                                      final String currency =
                                      (order["currency"] ?? "USD")
                                          .toString();

                                      final stripe = StripeService();
                                      final bool paid =
                                      await stripe.payOrder(
                                          orderId, amount * 100, currency);

                                      if (!paid) {
                                        await showToastMessage("Payment Failed",
                                            error: true);
                                        return;
                                      }

                                      final advertResp = await http.post(
                                        Uri.parse(
                                            "${baseUrl}finalize-advert.php"),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: jsonEncode({
                                          "order_id": orderId,
                                          "uid": userId,
                                          "title": addPropertiesController
                                              .propertyTitleController.text,
                                          "price": addPropertiesController
                                              .propertyPriceController.text,
                                          "address": addPropertiesController
                                              .propertyAddress,
                                          "description":
                                          addPropertiesController
                                              .propertyDescriptionController
                                              .text,
                                          "ptype":
                                          addPropertiesController.pType,
                                          "facility": addPropertiesController
                                              .selectedFacilities,
                                          "beds": addPropertiesController
                                              .propertyBedsController.text,
                                          "bathroom":
                                          addPropertiesController
                                              .propertyBathroomsController
                                              .text,
                                          "sqft": addPropertiesController
                                              .propertySizeController.text,
                                          "pbuysell":
                                          addPropertiesController.pbuySell,
                                          "latitude":
                                          addPropertiesController.lat,
                                          "longtitude":
                                          addPropertiesController.long,
                                          "country_id":
                                          addPropertiesController
                                              .countryId,
                                          "mobile": addPropertiesController
                                              .contactNumberController.text,
                                          "image": addPropertiesController
                                                  .propertyImagesBase64.isNotEmpty
                                              ? addPropertiesController
                                                  .propertyImagesBase64.first
                                              : "",
                                        }),
                                      );

                                      print(
                                          "finalize-advert => ${advertResp.statusCode} ${advertResp.body}");

                                      if (advertResp.statusCode != 200) {
                                        await showToastMessage(
                                          "Server error while creating advert (code ${advertResp.statusCode})",
                                          error: true,
                                        );
                                        return;
                                      }

                                      final adv =
                                      jsonDecode(advertResp.body.toString());
                                      if (adv["Result"] == "true") {
                                        await showToastMessage(
                                            "Advert created successfully".tr);
                                        Get.offAllNamed("/success");
                                      } else {
                                        await showToastMessage(
                                          adv["ResponseMsg"] ??
                                              "Could not create advert",
                                          error: true,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print(
                                        "${isEdit ? "Update" : "Create"} advert error: $e");
                                    await showToastMessage(
                                      "Something went wrong while processing request"
                                          .tr,
                                      error: true,
                                    );
                                  }
                                },
                              ),
                            ),

                          const SizedBox(height: 24),
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

  // ---------------------- UI helpers ----------------------

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 15, top: 6, bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: FontFamily.gilroyBold,
        fontSize: 16,
        color: notifire.getwhiteblackcolor,
      ),
    ),
  );

  Widget _dropdown<T>({
    required T? value,
    String? hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: hint == null
            ? null
            : Text(
          hint,
          style: const TextStyle(color: Colors.grey),
        ),
        dropdownColor: notifire.getbgcolor,
        icon: Image.asset(
          'assets/images/Arrow - Down.png',
          height: 20,
          width: 20,
          color: notifire.getwhiteblackcolor,
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: items
            .map(
              (e) => DropdownMenuItem<T>(
            value: e,
            child: Text(
              e.toString(),
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                color: notifire.getwhiteblackcolor,
                fontSize: 14,
              ),
            ),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _textfield({
    String? type,
    String? labelText,
    TextEditingController? controller,
    TextInputType? textInputType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type != null) _label(type),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: notifire.getwhiteblackcolor,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: const TextStyle(
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
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifire.getborderColor),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _multiline({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: TextFormField(
        controller: controller,
        minLines: 5,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        cursorColor: notifire.getwhiteblackcolor,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: blueColor),
            borderRadius: BorderRadius.circular(15),
          ),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 15,
          ),
        ),
        style: TextStyle(
          fontFamily: FontFamily.gilroyMedium,
          fontSize: 16,
          color: notifire.getwhiteblackcolor,
        ),
        validator: validator,
      ),
    );
  }

  Widget _dateTextField({
    String? type,
    String? labelText,
    TextEditingController? controller,
    bool isDatePicker = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type != null) _label(type),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            readOnly: isDatePicker,
            onTap: isDatePicker ? () => _selectDate(context) : null,
            cursorColor: notifire.getwhiteblackcolor,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: "Gilroy Medium",
                fontSize: 16,
              ),
              suffixIcon: isDatePicker
                  ? Icon(Icons.calendar_today,
                  color: notifire.getwhiteblackcolor)
                  : null,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: blueColor),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifire.getborderColor),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifire.getborderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openGallery(BuildContext context) async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addPropertiesController.path = pickedFile.path;
      addPropertiesController.propertyImagesPaths.add(pickedFile.path);

      final imageFile = File(pickedFile.path);
      final imageBytes = imageFile.readAsBytesSync();
      addPropertiesController.base64Image = base64Encode(imageBytes);
      addPropertiesController.propertyImagesBase64
          .add(addPropertiesController.base64Image!);
      setState(() {});
    }
  }
}




// // ignore_for_file: file_names, prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unused_local_variable
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui' as ui;
//
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, Factory;
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/add_proparty/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/enquiry_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gotocarefinder/Api/data_store.dart'; // for getData.read("UserLogin")
//
// import 'package:gotocarefinder/services/stripe_service.dart';
//
// class AddPropertyScreen extends StatefulWidget {
//   const AddPropertyScreen({super.key});
//
//   @override
//   State<AddPropertyScreen> createState() => _AddPropertyScreenState();
// }
//
// /// Purpose & status lists
// const List<String> list = ["Sell", "Rent Out"];
// const List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreenState extends State<AddPropertyScreen> {
//   final AddPropartiesController addPropertiesController = Get.find();
//   final DashBoardController dashBoardController = Get.find();
//   final EnquiryController enquriryController = Get.find();
//   final SelectCountryController selectCountryController = Get.find();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   /// route arg
//   late final String manegeRoute = Get.arguments["add"];
//
//   String propertyPurpose = list.first;
//   String? selectProperty;
//   String? selectCountry;
//   String slectStatus = propartyStatus.first;
//
//   late ColorNotifire notifire;
//
//   Future<void> getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
//   }
//
//   /// Cross-platform toast (no plugins)
//   Future<void> showToastMessage(
//     String message, {
//     String title = '',
//     bool error = false,
//     SnackPosition position = SnackPosition.BOTTOM,
//   }) async {
//     if (Get.isSnackbarOpen) Get.back();
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: position,
//       margin: const EdgeInsets.all(12),
//       borderRadius: 8,
//       backgroundColor:
//           error ? const Color(0xFFE53935) : const Color(0xFF323232),
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   Future<Position> locateUser() async =>
//       Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//   late GoogleMapController mapController1;
//   final Set<Marker> markers = <Marker>{};
//
//   /// Robust double parser
//   double _asDouble(dynamic v, {double fallback = 0}) {
//     if (v == null) return fallback;
//     if (v is double) return v;
//     if (v is int) return v.toDouble();
//     if (v is String) {
//       if (v.trim().isEmpty) return fallback;
//       final parsed = double.tryParse(v);
//       return parsed ?? fallback;
//     }
//     return fallback;
//   }
//
//   Future<Uint8List> getImages(String path, int width) async {
//     final data = await rootBundle.load(path);
//     final codec = await ui.instantiateImageCodec(
//       data.buffer.asUint8List(),
//       targetHeight: width,
//     );
//     final fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }
//
//   Future<void> _onAddMarkerButtonPressed(double lat, double lng) async {
//     final markIcon = await getImages("assets/images/location_pin.png", 80);
//     markers
//       ..clear()
//       ..add(
//         Marker(
//           markerId: const MarkerId("1"),
//           position: LatLng(lat, lng),
//           icon: BitmapDescriptor.fromBytes(markIcon),
//         ),
//       );
//     setState(() {});
//   }
//
//   Future<void> getCurrentLatAndLong(double latitude, double longitude) async {
//     addPropertiesController.lat = latitude;
//     addPropertiesController.long = longitude;
//
//     final placemarks = await placemarkFromCoordinates(latitude, longitude);
//     if (placemarks.isEmpty) return;
//     final p = placemarks.first;
//
//     if (manegeRoute == "Add") {
//       addPropertiesController.propertyAddress =
//           '${p.name}, ${p.locality}, ${p.country}';
//       addPropertiesController.propertyZipCode = p.postalCode ?? '';
//       addPropertiesController.propertyCountry = p.country ?? '';
//       addPropertiesController.propertyCity = p.locality ?? '';
//     } else {
//       addPropertiesController.ePropertyAddress =
//           '${p.name}, ${p.locality}, ${p.country}';
//       addPropertiesController.ePropertyZipCode = p.postalCode ?? '';
//       addPropertiesController.ePropertyCountry = p.country ?? '';
//       addPropertiesController.ePropertyCity = p.locality ?? '';
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: addPropertiesController.propertyShootDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//       builder: (context, child) => Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Colors.black,
//             onPrimary: Colors.white,
//             onSurface: Colors.black,
//           ),
//         ),
//         child: child!,
//       ),
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
//   void initState() {
//     super.initState();
//
//     if (manegeRoute == "edit") {
//       addPropertiesController.emptyAllDetails();
//       // PREFILL ON EDIT
//       addPropertiesController.propertyTitleController.text =
//           addPropertiesController.eTitle;
//       addPropertiesController.contactNumberController.text =
//           addPropertiesController.eNumber;
//       addPropertiesController.propertyPriceController.text =
//           addPropertiesController.ePrice;
//       addPropertiesController.propertyBedsController.text =
//           addPropertiesController.eTotalBeds;
//       addPropertiesController.propertyBathroomsController.text =
//           addPropertiesController.eTotalBathroom;
//       addPropertiesController.propertySizeController.text =
//           addPropertiesController.eSqft;
//       addPropertiesController.propertyDescriptionController.text =
//           addPropertiesController.eDescription;
//
//       addPropertiesController.lat = _asDouble(addPropertiesController.elat);
//       addPropertiesController.long = _asDouble(addPropertiesController.elong);
//
//       // restore selected facilities from CSV titles
//       final fCsv = addPropertiesController.fList.split(",");
//       final facilities =
//           dashBoardController.propartyFacilityInfo?.facilitylist ?? [];
//       for (var i = 0; i < fCsv.length && i < facilities.length; i++) {
//         if (facilities[i].title == fCsv[i]) {
//           addPropertiesController.selectedFacilities.add(facilities[i].id);
//         }
//       }
//       selectProperty = addPropertiesController.pName;
//       selectCountry = addPropertiesController.countryName;
//       setState(() {});
//     } else {
//       addPropertiesController.emptyAllDetails();
//       addPropertiesController.selectedFacilities = [];
//       addPropertiesController.pType = "";
//       addPropertiesController.countryId = "";
//       selectProperty = null;
//       selectCountry = null;
//     }
//
//     getdarkmodepreviousstate();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//
//     final media = MediaQuery.of(context);
//     final isWide = media.size.width >= 900;
//     final horizPad = isWide ? 24.0 : 10.0;
//
//     return Scaffold(
//       backgroundColor: notifire.getfevAndSearch,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: Get.back,
//           icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
//         ),
//         backgroundColor: notifire.getblackwhitecolor,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           "Create An Advert".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1100),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: horizPad),
//                 child: Scrollbar(
//                   thumbVisibility: isWide,
//                   child: SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     child: Container(
//                       color: notifire.getblackwhitecolor,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 12),
//
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15),
//                             child: Text(
//                               "Selling Or Renting Out Your Property?".tr,
//                               style: TextStyle(
//                                 fontFamily: FontFamily.gilroyBold,
//                                 fontSize: 18,
//                                 color: notifire.getwhiteblackcolor,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15),
//                             child: Text(
//                               "You're In The Right Place".tr,
//                               style: TextStyle(
//                                 fontFamily: FontFamily.gilroyBold,
//                                 fontSize: 14,
//                                 color: notifire.getgreycolor,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15),
//                             child: Text(
//                               "Let's Find You A Buyer Or Tenant".tr,
//                               style: TextStyle(
//                                 fontFamily: FontFamily.gilroyBold,
//                                 fontSize: 16,
//                                 color: notifire.getwhiteblackcolor,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Divider(height: 0.5, color: notifire.getgreycolor),
//                           const SizedBox(height: 16),
//
//                           /// Purpose
//                           _label(
//                               "What are you looking to do with your property?"
//                                   .tr),
//                           _dropdown<String>(
//                             value: propertyPurpose,
//                             items: list,
//                             onChanged: (value) {
//                               setState(() {
//                                 addPropertiesController.pbuySell =
//                                     (value == "Sell") ? "2" : "1";
//                                 propertyPurpose = value ?? list.first;
//                               });
//                             },
//                           ),
//
//                           /// Property Type
//                           _label("Property Type".tr),
//                           _dropdown<String>(
//                             value: selectProperty,
//                             hint: "Select Property Type".tr,
//                             items: dashBoardController.propartyTypeList,
//                             onChanged: (value) {
//                               final types = dashBoardController
//                                       .propartyTypeInfo?.typelist ??
//                                   [];
//                               for (final t in types) {
//                                 if (value == t.title) {
//                                   addPropertiesController.pType = t.id ?? "";
//                                   break;
//                                 }
//                               }
//                               setState(() => selectProperty = value);
//                             },
//                           ),
//
//                           /// Title
//                           _textfield(
//                             type: "Property Name Or Title".tr,
//                             controller:
//                                 addPropertiesController.propertyTitleController,
//                             labelText: "Property Name".tr,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? 'Please Enter Property Title'.tr
//                                 : null,
//                           ),
//
//                           const SizedBox(height: 6),
//                           _label("Where is your property located?".tr),
//
//                           /// Google Map
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                             child: Container(
//                               height: 200,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(15),
//                                 child: GoogleMap(
//                                   gestureRecognizers: {
//                                     Factory<OneSequenceGestureRecognizer>(
//                                         () => EagerGestureRecognizer())
//                                   },
//                                   initialCameraPosition: CameraPosition(
//                                     target: (manegeRoute == "Add")
//                                         ? const LatLng(47.751076, -120.740135)
//                                         : LatLng(
//                                             _asDouble(
//                                                 addPropertiesController.elat,
//                                                 fallback: 0),
//                                             _asDouble(
//                                                 addPropertiesController.elong,
//                                                 fallback: 0),
//                                           ),
//                                     zoom: 13,
//                                   ),
//                                   mapType: MapType.normal,
//                                   markers: markers,
//                                   onTap: (pos) async {
//                                     await _onAddMarkerButtonPressed(
//                                         pos.latitude, pos.longitude);
//                                     addPropertiesController.lat = pos.latitude;
//                                     addPropertiesController.long =
//                                         pos.longitude;
//                                     await getCurrentLatAndLong(
//                                         pos.latitude, pos.longitude);
//                                     addPropertiesController.update();
//                                   },
//                                   myLocationEnabled: true,
//                                   zoomGesturesEnabled: true,
//                                   tiltGesturesEnabled: true,
//                                   zoomControlsEnabled: true,
//                                   onMapCreated: (controller) => setState(
//                                       () => mapController1 = controller),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 10),
//
//                           /// Description
//                           _label("Property Description".tr),
//                           _multiline(
//                             controller: addPropertiesController
//                                 .propertyDescriptionController,
//                             hint:
//                                 "Describe the property to your prospects. Highlight the living environment, available care services, key amenities, and any unique features that set it apart. Keep it clear and inviting to help prospects make an informed decision."
//                                     .tr,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? 'Please Enter Property Description'.tr
//                                 : null,
//                           ),
//
//                           /// Numeric fields (beds, bathrooms, size)
//                           _textfield(
//                             type: "How many beds does your property have?".tr,
//                             controller:
//                                 addPropertiesController.propertyBedsController,
//                             labelText: "Number of beds".tr,
//                             textInputType: TextInputType.number,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? 'Please Enter Total Beds'.tr
//                                 : null,
//                           ),
//                           _textfield(
//                             type: "How many bathrooms does your property have?"
//                                 .tr,
//                             controller: addPropertiesController
//                                 .propertyBathroomsController,
//                             labelText: "Number of bathrooms".tr,
//                             textInputType: TextInputType.number,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? 'Please Enter Number Of Bathrooms'.tr
//                                 : null,
//                           ),
//                           _textfield(
//                             type: "Property Size (sq. ft.) - ".tr +
//                                 (propertyPurpose == "Sell"
//                                     ? "Enter the total square footage of the property to give potential buyers a sense of space"
//                                         .tr
//                                     : "Enter the total square footage of the property to give potential tenants a sense of space"
//                                         .tr),
//                             controller:
//                                 addPropertiesController.propertySizeController,
//                             labelText: "Property size".tr,
//                             textInputType: TextInputType.number,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? 'Please Enter Property Size'.tr
//                                 : null,
//                           ),
//
//                           const SizedBox(height: 8),
//                           _label("Select Property Facilities".tr),
//
//                           /// Facilities
//                           GetBuilder<AddPropartiesController>(builder: (_) {
//                             final fl = dashBoardController
//                                     .propartyFacilityInfo?.facilitylist ??
//                                 [];
//                             return ListView.separated(
//                               itemCount: fl.length,
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               separatorBuilder: (_, __) => Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: Divider(thickness: 1),
//                               ),
//                               itemBuilder: (context, index) {
//                                 final item = fl[index];
//                                 final selected = addPropertiesController
//                                     .selectedFacilities
//                                     .contains(item.id);
//                                 return Row(
//                                   children: [
//                                     const SizedBox(width: 10),
//                                     Checkbox(
//                                       value: selected,
//                                       side: const BorderSide(
//                                           color: Color(0xffC5CAD4)),
//                                       activeColor: blueColor,
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(5)),
//                                       onChanged: (_) {
//                                         setState(() {
//                                           if (selected) {
//                                             addPropertiesController
//                                                 .selectedFacilities
//                                                 .remove(item.id);
//                                           } else {
//                                             addPropertiesController
//                                                 .selectedFacilities
//                                                 .add(item.id);
//                                           }
//                                         });
//                                       },
//                                     ),
//                                     Expanded(
//                                       child: Text(
//                                         item.title ?? "",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 17,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       height: 40,
//                                       width: 40,
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: const BoxDecoration(
//                                         color: Color(0xFFeef4ff),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Image.network(
//                                         "${Config.imageUrl}${item.img ?? ""}",
//                                       ),
//                                     ),
//                                     const SizedBox(width: 15),
//                                   ],
//                                 );
//                               },
//                             );
//                           }),
//
//                           /// Price / Rent
//                           _textfield(
//                             type: propertyPurpose == "Sell"
//                                 ? "Selling Price".tr
//                                 : "Property Rent".tr,
//                             controller:
//                                 addPropertiesController.propertyPriceController,
//                             labelText: propertyPurpose == "Sell"
//                                 ? "Price".tr
//                                 : "Rent Amount".tr,
//                             textInputType: TextInputType.number,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? (propertyPurpose == "Sell"
//                                     ? 'Please Enter The Selling Price'.tr
//                                     : 'Please Enter The Rent Amount'.tr)
//                                 : null,
//                           ),
//
//                           /// Contact
//                           _textfield(
//                             type: "Contact Number".tr,
//                             controller:
//                                 addPropertiesController.contactNumberController,
//                             labelText:
//                                 "Enter a phone number prospects can contact you on"
//                                     .tr,
//                             textInputType: TextInputType.number,
//                             validator: (v) => (v == null || v.isEmpty)
//                                 ? 'Please Enter Mobile Number'.tr
//                                 : null,
//                           ),
//
//                           const SizedBox(height: 16),
//                           _label("High-Quality Photos To Showcase Your Property"
//                               .tr),
//                           const SizedBox(height: 8),
//                           Divider(height: 0.5, color: notifire.getgreycolor),
//                           const SizedBox(height: 16),
//
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 15),
//                             child: Text(
//                               "Do you have high quality photos of your property? (If not, you can book our professional photographers to take compliant photos of your property)"
//                                   .tr,
//                               style: TextStyle(
//                                 fontFamily: FontFamily.gilroyBold,
//                                 fontSize: 16,
//                                 color: notifire.getwhiteblackcolor,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//
//                           /// Have Photos toggle
//                           Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   const SizedBox(width: 10),
//                                   Checkbox(
//                                     value: addPropertiesController.havePhotos,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) => setState(() =>
//                                         addPropertiesController.havePhotos =
//                                             true),
//                                   ),
//                                   Text(
//                                     "Yes",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 17,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: Divider(thickness: 1),
//                               ),
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const SizedBox(width: 10),
//                                   Checkbox(
//                                     value: !addPropertiesController.havePhotos,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) => setState(() =>
//                                         addPropertiesController.havePhotos =
//                                             false),
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       "No, and I would like to book your professional photographers",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 17,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),
//                                 ],
//                               ),
//                             ],
//                           ),
//
//                           SizedBox(
//                             height:
//                                 addPropertiesController.havePhotos ? 15 : 25,
//                           ),
//
//                           /// Booking photographers (if no photos)
//                           if (!addPropertiesController.havePhotos) ...[
//                             _label("Book Our Professional Photographers".tr),
//                             const SizedBox(height: 10),
//                             _dateTextField(
//                               type: "When would you like to have the shoot?",
//                               labelText: "Select Date",
//                               controller: addPropertiesController
//                                   .propertyShootDateController,
//                               isDatePicker: true,
//                             ),
//                             const SizedBox(height: 10),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 15),
//                               child: Text(
//                                 "What time on that day works best for you?".tr,
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: notifire.getwhiteblackcolor,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () async {
//                                       final TimeOfDay? selectedTime =
//                                           await Get.dialog(
//                                         Theme(
//                                           data: Get.theme.copyWith(
//                                             timePickerTheme:
//                                                 TimePickerThemeData(
//                                               backgroundColor:
//                                                   notifire.getblackwhitecolor,
//                                               hourMinuteTextColor:
//                                                   notifire.getwhiteblackcolor,
//                                               dialHandColor: blueColor,
//                                               dialBackgroundColor: notifire
//                                                   .getblackwhitecolor
//                                                   .withOpacity(0.1),
//                                               entryModeIconColor:
//                                                   notifire.getwhiteblackcolor,
//                                             ),
//                                             textButtonTheme:
//                                                 TextButtonThemeData(
//                                               style: TextButton.styleFrom(
//                                                   foregroundColor: blueColor),
//                                             ),
//                                           ),
//                                           child: TimePickerDialog(
//                                             initialTime: TimeOfDay.now(),
//                                           ),
//                                         ),
//                                       );
//                                       if (selectedTime != null) {
//                                         final now = DateTime.now();
//                                         final dt = DateTime(
//                                           now.year,
//                                           now.month,
//                                           now.day,
//                                           selectedTime.hour,
//                                           selectedTime.minute,
//                                         );
//                                         final formattedTime =
//                                             DateFormat('hh:mm a').format(dt);
//                                         addPropertiesController
//                                             .updateTime(formattedTime);
//                                         setState(() {});
//                                       }
//                                     },
//                                     child: Container(
//                                       height: 55,
//                                       margin: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: notifire.getblackwhitecolor,
//                                         borderRadius: BorderRadius.circular(15),
//                                         border: Border.all(
//                                             color: notifire.getborderColor),
//                                       ),
//                                       alignment: Alignment.centerLeft,
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 15),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               (addPropertiesController
//                                                           .propertyShootTime
//                                                           ?.isNotEmpty ??
//                                                       false)
//                                                   ? addPropertiesController
//                                                       .propertyShootTime!
//                                                   : "Pick time".tr,
//                                               style: TextStyle(
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 color: (addPropertiesController
//                                                             .propertyShootTime
//                                                             ?.isNotEmpty ??
//                                                         false)
//                                                     ? notifire
//                                                         .getwhiteblackcolor
//                                                     : notifire.getgreycolor,
//                                               ),
//                                             ),
//                                           ),
//                                           Image.asset(
//                                             "assets/images/Calendar.png",
//                                             height: 25,
//                                             width: 25,
//                                             color: (addPropertiesController
//                                                         .propertyShootTime
//                                                         ?.isNotEmpty ??
//                                                     false)
//                                                 ? notifire.getwhiteblackcolor
//                                                 : notifire.getgreycolor,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             _label("Terms Of Service".tr),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const SizedBox(width: 10),
//                                 Checkbox(
//                                   value: addPropertiesController
//                                       .consentToPhotographyTerms,
//                                   side: const BorderSide(
//                                       color: Color(0xffC5CAD4)),
//                                   activeColor: blueColor,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   onChanged: (_) => setState(() {
//                                     addPropertiesController
//                                             .consentToPhotographyTerms =
//                                         !addPropertiesController
//                                             .consentToPhotographyTerms;
//                                   }),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     "I consent to GoToCareFinder's terms of service, including permission for the photographer to access the property and use the images on the platform",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 17,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                           ],
//
//                           /// Upload photos (if user has their own)
//                           if (addPropertiesController.havePhotos) ...[
//                             _label("Upload Photos".tr),
//                             const SizedBox(height: 8),
//                             InkWell(
//                               onTap: () => _openGallery(context),
//                               child: Center(
//                                 child: Container(
//                                   width: media.size.width - 20,
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(
//                                         color: const Color(0xff3D5BF6)),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "Upload Photos (Multiple)".tr,
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyBold,
//                                         fontSize: 16,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             if (addPropertiesController
//                                 .propertyImagesPaths.isNotEmpty)
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 15),
//                                 child: SizedBox(
//                                   height: 170,
//                                   child: ListView.builder(
//                                     clipBehavior: Clip.none,
//                                     shrinkWrap: true,
//                                     scrollDirection: Axis.horizontal,
//                                     padding: const EdgeInsets.only(bottom: 10),
//                                     itemCount: addPropertiesController
//                                         .propertyImagesPaths.length,
//                                     itemBuilder: (context, index) {
//                                       final path = addPropertiesController
//                                           .propertyImagesPaths[index];
//                                       return Stack(
//                                         clipBehavior: Clip.none,
//                                         children: [
//                                           Container(
//                                             height: 300,
//                                             width: 150,
//                                             margin: const EdgeInsets.only(
//                                                 right: 15),
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               image: DecorationImage(
//                                                 image: FileImage(File(path)),
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             right: 5,
//                                             top: -8,
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 addPropertiesController
//                                                     .propertyImagesBase64
//                                                     .removeAt(index);
//                                                 addPropertiesController
//                                                     .propertyImagesPaths
//                                                     .removeAt(index);
//                                                 setState(() {});
//                                               },
//                                               child: Container(
//                                                 height: 26,
//                                                 width: 26,
//                                                 decoration: const BoxDecoration(
//                                                   color: Color(0xff3D5BF6),
//                                                   shape: BoxShape.circle,
//                                                 ),
//                                                 child: const Center(
//                                                   child: Icon(
//                                                     Icons.close,
//                                                     color: Colors.white,
//                                                     size: 18,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                           ],
//
//                           /// Status
//                           _label("Advert Status".tr),
//                           _dropdown<String>(
//                             value: slectStatus,
//                             items: propartyStatus,
//                             onChanged: (value) {
//                               if (value == "Publish") {
//                                 addPropertiesController.status = "1";
//                               } else if (value == "UnPublish") {
//                                 addPropertiesController.status = "0";
//                               }
//                               setState(() =>
//                                   slectStatus = value ?? propartyStatus.first);
//                             },
//                           ),
//
//                           const SizedBox(height: 12),
//                           if (addPropertiesController.pShell == "0")
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 35),
//                               child: GestButton(
//                                 Width: double.infinity,
//                                 height: 55,
//                                 buttoncolor: blueColor,
//                                 margin: const EdgeInsets.only(top: 5),
//                                 buttontext: manegeRoute == "Add" ? "Create Advert".tr : "Update".tr,
//                                 style: TextStyle(
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: WhiteColor,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//
//                                 // IMPORTANT: GestButton uses `onclick`
//                                   onclick: () async {
//                                     if (!(_formKey.currentState?.validate() ?? false)) {
//                                       await showToastMessage("Please fill all required fields".tr, error: true);
//                                       return;
//                                     }
//                                     if ((addPropertiesController.lat == null) ||
//                                         (addPropertiesController.long == null)) {
//                                       await showToastMessage("Please add your property location".tr, error: true);
//                                       return;
//                                     }
//
//                                     final userId = getData.read("UserLogin")["id"].toString();
//
//                                     try {
//                                       if (manegeRoute == "Add") {
//                                         // your existing Stripe + finalize-advert flow (create)
//                                         // ...
//                                       } else {
//                                         // ------------- EDIT FLOW -------------
//                                         final resp = await http.post(
//                                           Uri.parse("${baseUrl}update-property.php"),
//                                           headers: {"Content-Type": "application/json"},
//                                           body: jsonEncode({
//                                             "prop_id": addPropertiesController.propId,
//                                             "uid": userId,
//                                             "status": addPropertiesController.status,
//                                             "title": addPropertiesController.propertyTitleController.text,
//                                             "price": addPropertiesController.propertyPriceController.text,
//                                             "address": addPropertiesController.propertyAddress,
//                                             "description":
//                                             addPropertiesController.propertyDescriptionController.text,
//                                             "ccount": addPropertiesController.propertyCity,
//                                             "ptype": addPropertiesController.pType,
//                                             "facility": addPropertiesController.selectedFacilities,
//                                             "beds": addPropertiesController.propertyBedsController.text,
//                                             "bathroom":
//                                             addPropertiesController.propertyBathroomsController.text,
//                                             "sqft": addPropertiesController.propertySizeController.text,
//                                             "rate": "0",
//                                             "latitude": addPropertiesController.lat,
//                                             "longtitude": addPropertiesController.long,
//                                             "mobile":
//                                             addPropertiesController.contactNumberController.text,
//                                             "plimit": "",
//                                             "country_id": addPropertiesController.countryId,
//                                             "pbuysell": addPropertiesController.pbuySell,
//                                             "img": "0", // or base64 string if you support editing main image
//                                           }),
//                                         );
//
//                                         print("update-property => ${resp.statusCode} ${resp.body}");
//
//                                         if (resp.statusCode != 200) {
//                                           await showToastMessage(
//                                             "Server error while updating property (code ${resp.statusCode})",
//                                             error: true,
//                                           );
//                                           return;
//                                         }
//
//                                         final data = jsonDecode(resp.body);
//                                         if (data["Result"] == "true") {
//                                           await showToastMessage("Property updated successfully".tr);
//                                           Get.back(); // or refresh list
//                                         } else {
//                                           await showToastMessage(
//                                             data["ResponseMsg"] ?? "Could not update property",
//                                             error: true,
//                                           );
//                                         }
//                                       }
//                                     } catch (e) {
//                                       print("Update property error: $e");
//                                       await showToastMessage(
//                                         "Something went wrong while updating property".tr,
//                                         error: true,
//                                       );
//                                     }
//                                   }
//
//                                 // onclick: () async {
//                                 //   // 0) Validate as before
//                                 //   if (!(_formKey.currentState?.validate() ?? false)) {
//                                 //     await showToastMessage(
//                                 //       "Please fill all required fields".tr,
//                                 //       error: true,
//                                 //     );
//                                 //     return;
//                                 //   }
//                                 //   if ((addPropertiesController.lat == null) ||
//                                 //       (addPropertiesController.long == null)) {
//                                 //     await showToastMessage(
//                                 //       "Please add your property location".tr,
//                                 //       error: true,
//                                 //     );
//                                 //     return;
//                                 //   }
//                                 //
//                                 //   try {
//                                 //     // Logged in user
//                                 //     final userId = getData.read("UserLogin")["id"].toString();
//                                 //
//                                 //     // -------- 1) CREATE ORDER (tbl_payment row) ----------
//                                 //     final orderResp = await http.post(
//                                 //       Uri.parse("${baseUrl}create-advert-order.php"),
//                                 //       headers: {"Content-Type": "application/json"},
//                                 //       body: jsonEncode({"uid": userId}),
//                                 //     );
//                                 //     print("create-advert-order => "
//                                 //         "${orderResp.statusCode} ${orderResp.body}");
//                                 //
//                                 //     final order = jsonDecode(orderResp.body);
//                                 //     if (order["Result"] != "true") {
//                                 //       await showToastMessage(
//                                 //         order["ResponseMsg"] ?? "Could not create order",
//                                 //         error: true,
//                                 //       );
//                                 //       return;
//                                 //     }
//                                 //
//                                 //     final int orderId = int.parse(order["order_id"].toString());
//                                 //     final int amount = int.parse(order["amount"].toString()); // 50
//                                 //     final String currency =
//                                 //     (order["currency"] ?? "USD").toString();
//                                 //
//                                 //     // -------- 2) STRIPE PAYMENT ----------
//                                 //     final stripe = StripeService();
//                                 //     final bool paid =
//                                 //     await stripe.payOrder(orderId, amount * 100, currency); // cents
//                                 //
//                                 //     if (!paid) {
//                                 //       await showToastMessage("Payment Failed", error: true);
//                                 //       return;
//                                 //     }
//                                 //
//                                 //     // -------- 3) FINALIZE ADVERT (INSERT INTO tbl_proparty) ----------
//                                 //     // ---------- 3) FINALIZE ADVERT (INSERT INTO tbl_proparty) ----------
//                                 //     final advertResp = await http.post(
//                                 //       Uri.parse("${baseUrl}finalize-advert.php"),
//                                 //       headers: {"Content-Type": "application/json"},
//                                 //       body: jsonEncode({
//                                 //         "order_id": orderId,
//                                 //         "uid": userId,
//                                 //         "title": addPropertiesController.propertyTitleController.text,
//                                 //         "price": addPropertiesController.propertyPriceController.text,
//                                 //         "address": addPropertiesController.propertyAddress,
//                                 //         "description":
//                                 //         addPropertiesController.propertyDescriptionController.text,
//                                 //         "ptype": addPropertiesController.pType,
//                                 //         "facility": addPropertiesController.selectedFacilities,
//                                 //         "beds": addPropertiesController.propertyBedsController.text,
//                                 //         "bathroom":
//                                 //         addPropertiesController.propertyBathroomsController.text,
//                                 //         "sqft": addPropertiesController.propertySizeController.text,
//                                 //         "pbuysell": addPropertiesController.pbuySell,
//                                 //         "latitude": addPropertiesController.lat,
//                                 //         "longtitude": addPropertiesController.long,
//                                 //         "country_id": addPropertiesController.countryId,
//                                 //         "mobile":
//                                 //         addPropertiesController.contactNumberController.text,
//                                 //       }),
//                                 //     );
//                                 //
//                                 //     print("finalize-advert => "
//                                 //         "${advertResp.statusCode} ${advertResp.body}");
//                                 //
//                                 //     if (advertResp.statusCode != 200) {
//                                 //       await showToastMessage(
//                                 //         "Server error while creating advert (code ${advertResp.statusCode})",
//                                 //         error: true,
//                                 //       );
//                                 //       return;
//                                 //     }
//                                 //
//                                 //     final adv = jsonDecode(advertResp.body);
//                                 //     if (adv["Result"] == "true") {
//                                 //       await showToastMessage("Advert created successfully".tr);
//                                 //       Get.offAllNamed("/success");
//                                 //     } else {
//                                 //       await showToastMessage(
//                                 //         adv["ResponseMsg"] ?? "Could not create advert",
//                                 //         error: true,
//                                 //       );
//                                 //     }
//                                 //     print("finalize-advert => "
//                                 //         "${advertResp.statusCode} ${advertResp.body}");
//                                 //
//                                 //     // final adv = jsonDecode(advertResp.body);
//                                 //     if (adv["Result"] == "true") {
//                                 //       await showToastMessage("Advert created successfully".tr);
//                                 //       Get.offAllNamed("/success");
//                                 //     } else {
//                                 //       await showToastMessage(
//                                 //         adv["ResponseMsg"] ?? "Could not create advert",
//                                 //         error: true,
//                                 //       );
//                                 //     }
//                                 //   } catch (e) {
//                                 //     print("Create advert + payment error: $e");
//                                 //     await showToastMessage(
//                                 //       "Something went wrong while processing payment".tr,
//                                 //       error: true,
//                                 //     );
//                                 //   }
//                                 // },
//                               ),
//                             ),
//                           const SizedBox(height: 24),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ---------------------- UI helpers ----------------------
//
//   Widget _label(String text) => Padding(
//         padding: const EdgeInsets.only(left: 15, top: 6, bottom: 6),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       );
//
//   Widget _dropdown<T>({
//     required T? value,
//     String? hint,
//     required List<T> items,
//     required ValueChanged<T?> onChanged,
//   }) {
//     return Container(
//       height: 60,
//       alignment: Alignment.center,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         color: notifire.getblackwhitecolor,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: notifire.getborderColor),
//       ),
//       child: DropdownButton<T>(
//         value: value,
//         hint: hint == null
//             ? null
//             : Text(
//                 hint,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//         dropdownColor: notifire.getbgcolor,
//         icon: Image.asset(
//           'assets/images/Arrow - Down.png',
//           height: 20,
//           width: 20,
//           color: notifire.getwhiteblackcolor,
//         ),
//         isExpanded: true,
//         underline: const SizedBox.shrink(),
//         items: items
//             .map(
//               (e) => DropdownMenuItem<T>(
//                 value: e,
//                 child: Text(
//                   e.toString(),
//                   style: TextStyle(
//                     fontFamily: FontFamily.gilroyMedium,
//                     color: notifire.getwhiteblackcolor,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//         onChanged: onChanged,
//       ),
//     );
//   }
//
//   Widget _textfield({
//     String? type,
//     String? labelText,
//     TextEditingController? controller,
//     TextInputType? textInputType,
//     String? Function(String?)? validator,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (type != null) _label(type),
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: notifire.getblackwhitecolor,
//           ),
//           child: TextFormField(
//             controller: controller,
//             keyboardType: textInputType,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             cursorColor: notifire.getwhiteblackcolor,
//             style: TextStyle(
//               color: notifire.getwhiteblackcolor,
//               fontFamily: FontFamily.gilroyMedium,
//               fontSize: 18,
//             ),
//             decoration: InputDecoration(
//               hintText: labelText,
//               hintStyle: const TextStyle(
//                 color: Colors.grey,
//                 fontFamily: "Gilroy Medium",
//                 fontSize: 16,
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: blueColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _multiline({
//     required TextEditingController controller,
//     required String hint,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
//       decoration: BoxDecoration(
//         color: notifire.getblackwhitecolor,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: notifire.getborderColor),
//       ),
//       child: TextFormField(
//         controller: controller,
//         minLines: 5,
//         maxLines: null,
//         keyboardType: TextInputType.multiline,
//         cursorColor: notifire.getwhiteblackcolor,
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         decoration: InputDecoration(
//           contentPadding: const EdgeInsets.all(10),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: blueColor),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           border: InputBorder.none,
//           hintText: hint,
//           hintStyle: const TextStyle(
//             fontFamily: FontFamily.gilroyMedium,
//             fontSize: 15,
//           ),
//         ),
//         style: TextStyle(
//           fontFamily: FontFamily.gilroyMedium,
//           fontSize: 16,
//           color: notifire.getwhiteblackcolor,
//         ),
//         validator: validator,
//       ),
//     );
//   }
//
//   Widget _dateTextField({
//     String? type,
//     String? labelText,
//     TextEditingController? controller,
//     bool isDatePicker = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (type != null) _label(type),
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             color: notifire.getblackwhitecolor,
//           ),
//           child: TextFormField(
//             controller: controller,
//             readOnly: isDatePicker,
//             onTap: isDatePicker ? () => _selectDate(context) : null,
//             cursorColor: notifire.getwhiteblackcolor,
//             style: TextStyle(
//               color: notifire.getwhiteblackcolor,
//               fontFamily: FontFamily.gilroyMedium,
//               fontSize: 18,
//             ),
//             decoration: InputDecoration(
//               hintText: labelText,
//               hintStyle: const TextStyle(
//                 color: Colors.grey,
//                 fontFamily: "Gilroy Medium",
//                 fontSize: 16,
//               ),
//               suffixIcon: isDatePicker
//                   ? Icon(Icons.calendar_today,
//                       color: notifire.getwhiteblackcolor)
//                   : null,
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: blueColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _openGallery(BuildContext context) async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       addPropertiesController.path = pickedFile.path;
//       addPropertiesController.propertyImagesPaths.add(pickedFile.path);
//
//       final imageFile = File(pickedFile.path);
//       final imageBytes = imageFile.readAsBytesSync();
//       addPropertiesController.base64Image = base64Encode(imageBytes);
//       addPropertiesController.propertyImagesBase64
//           .add(addPropertiesController.base64Image!);
//       setState(() {});
//     }
//   }
// }