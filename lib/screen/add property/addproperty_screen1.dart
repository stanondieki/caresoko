// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
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
import 'package:latlong2/latlong.dart' as osm;
import 'package:gotocarefinder/model/routes_helper.dart';

class AddPropertyScreen1 extends StatefulWidget {
  const AddPropertyScreen1({super.key});

  @override
  State<AddPropertyScreen1> createState() => _AddPropertyScreen1State();
}

List<String> propertyType = ["Adult Family Home", "Assisted Living Facility"];
List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddPropertyScreen1State extends State<AddPropertyScreen1> {
  final AddPropertiesController addPropertiesController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments["add"];

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

  // Map
  final MapController mapController1 = MapController();
  final List<osm.LatLng> markers = <osm.LatLng>[];

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _onAddMarkerButtonPressed(double? lat, dynamic long) async {
    final parsedLat = double.tryParse(lat.toString());
    final parsedLng = double.tryParse(long.toString());
    if (parsedLat == null || parsedLng == null) {
      return;
    }

    final Uint8List markIcon =
        await getImages("assets/images/location_pin.png", 80);
    final position = osm.LatLng(parsedLat, parsedLng);
    markers
      ..clear()
      ..add(position);
    setState(() {});
  }

  Future<void> getCurrentLatAndLong(double latitude, double longitude) async {
    addPropertiesController.lat = latitude;
    addPropertiesController.long = longitude;

    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    final first = placemarks.first;

    if (manegeRoute == "Add") {
      addPropertiesController.propertyAddress =
          '${first.name}, ${first.locality}, ${first.country}';
      addPropertiesController.propertyZipCode = first.postalCode ?? '';
      addPropertiesController.propertyCountry = first.country ?? '';
      addPropertiesController.propertyCity = first.locality ?? '';
    } else {
      addPropertiesController.ePropertyAddress =
          '${first.name}, ${first.locality}, ${first.country}';
      addPropertiesController.ePropertyZipCode = first.postalCode ?? '';
      addPropertiesController.ePropertyCountry = first.country ?? '';
      addPropertiesController.ePropertyCity = first.locality ?? '';
    }
  }

  @override
  void initState() {
    super.initState();

    if (manegeRoute == "edit") {
      try {
        getCurrentLatAndLong(
            addPropertiesController.elat, addPropertiesController.elong);
        addPropertiesController.emptyAllDetails();
        addPropertiesController.propertyTitleController.text =
            addPropertiesController.ePropertyName ?? '';
        selectProperty = addPropertiesController.ePropertyType;
        addPropertiesController.propertyDescriptionController.text =
            addPropertiesController.ePropertyDescription ?? '';
        setState(() {});
      } catch (e, stackTrace) {
        print("Error: $e");
        print("Stack trace: $stackTrace");
      }
    } else {
      addPropertiesController.emptyAllDetails();
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
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;

            // Simple, friendly breakpoints
            final bool isPhone = width < 700;
            final bool isTablet = width >= 700 && width < 1100;
            final bool isDesktop = width >= 1100;

            // Max content width for big screens
            final double maxContentWidth =
                isDesktop ? 1100 : (isTablet ? 900 : width);

            // Side padding
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 12 : 20,
              vertical: isPhone ? 0 : 8,
            );

            // Map height by device
            final double mapHeight = isPhone ? 220 : (isTablet ? 320 : 420);

            // Field width in a Wrap (two columns on wide screens)
            final double fieldMaxWidth =
                isPhone ? width - 24 : (maxContentWidth - 20) / 2;

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
                                  SizedBox(height: 14),
                                  _h1("Let's Start Your Client-Finding Journey"),
                                  SizedBox(height: 20),
                                  _stepText(manegeRoute == "Add"
                                      ? "Step 1 of 8"
                                      : "Step 1 of 7"),
                                  SizedBox(height: 10),
                                  _h2("A Little About Your Home or Facility"),
                                  SizedBox(height: 10),
                                  Divider(
                                      height: 0.5,
                                      color: notifire.getgreycolor),
                                  SizedBox(height: 16),

                                  // ====== FORM GRID (Wrap -> 1 col on phone, 2 cols on tablet/desktop) ======
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 12,
                                    children: [
                                      // Home Type (Dropdown)
                                      _boxed(
                                        width: fieldMaxWidth,
                                        child: _dropdownHomeType(),
                                        label: "Home Type",
                                      ),

                                      // Home Name
                                      _boxed(
                                        width: fieldMaxWidth,
                                        child: textfield(
                                          type: null,
                                          labelText: "Home Name".tr,
                                          controller: addPropertiesController
                                              .propertyTitleController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please Enter Home Name'
                                                  .tr;
                                            }
                                            return null;
                                          },
                                        ),
                                        label: "Home Name",
                                      ),

                                      // Description (full width on phone; on large screens, make it span two columns)
                                      _boxed(
                                        width: isPhone
                                            ? fieldMaxWidth
                                            : (maxContentWidth - 20),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: 5, left: 3, right: 3),
                                          decoration: BoxDecoration(
                                            color: notifire.getblackwhitecolor,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: notifire.getborderColor),
                                          ),
                                          child: TextFormField(
                                            controller: addPropertiesController
                                                .propertyDescriptionController,
                                            minLines: 5,
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            cursorColor:
                                                notifire.getwhiteblackcolor,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            decoration: InputDecoration(
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: blueColor),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              border: InputBorder.none,
                                              hintText:
                                                  "Briefly describe your home or facility, including amenities, caregiver qualifications, accreditations, and the unique care services you offer"
                                                      .tr,
                                              hintStyle: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
                                                fontSize: 15,
                                              ),
                                            ),
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              fontSize: 16,
                                              color:
                                                  notifire.getwhiteblackcolor,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please Enter Home Description'
                                                    .tr;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        label: "Home Description",
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 16),
                                  _h2("Where is your home located?"),
                                  SizedBox(height: 8),

                                  // ====== MAP (responsive height) ======
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Container(
                                      height: mapHeight,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FlutterMap(
                                          mapController: mapController1,
                                          options: MapOptions(
                                            initialCenter: manegeRoute == "Add"
                                                ? const osm.LatLng(47.751076, -120.740135)
                                                : osm.LatLng(
                                                    addPropertiesController.elat,
                                                    addPropertiesController.elong,
                                                  ),
                                            initialZoom: 13,
                                            onTap: (tapPosition, argument) async {
                                            setState(() {});
                                            await _onAddMarkerButtonPressed(
                                                argument.latitude,
                                                argument.longitude);
                                            addPropertiesController.lat =
                                                argument.latitude;
                                            addPropertiesController.long =
                                                argument.longitude;

                                            await getCurrentLatAndLong(
                                              addPropertiesController.lat,
                                              addPropertiesController.long,
                                            );

                                            addPropertiesController.update();
                                          },
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              userAgentPackageName: 'com.caresoko.app',
                                            ),
                                            MarkerLayer(
                                              markers: markers
                                                  .map(
                                                    (p) => Marker(
                                                      point: p,
                                                      width: 40,
                                                      height: 40,
                                                      child: const Icon(Icons.location_on,
                                                          color: Colors.red, size: 34),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 24),
                                  // ====== NEXT BUTTON (stretches nicely) ======
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isPhone ? 24 : 35,
                                    ),
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
                                        addPropertiesController.propertyTitle =
                                            addPropertiesController
                                                .propertyTitleController.text;
                                        addPropertiesController
                                                .propertyDescription =
                                            addPropertiesController
                                                .propertyDescriptionController
                                                .text;

                                        Get.toNamed(
                                          Routes.addPropertyScreen2,
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }

  // ---------- Helpers: Headings & Boxes ----------
  Widget _h1(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          text.tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: notifire.getgreycolor,
          ),
        ),
      );

  Widget _boxed(
      {required double width, required Widget child, required String label}) {
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

  // ---------- Dropdown for Home Type ----------
  Widget _dropdownHomeType() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: DropdownButton<String>(
        dropdownColor: notifire.getbgcolor,
        hint: Text(
          "Select Home Type".tr,
          style: TextStyle(color: Colors.grey),
        ),
        value: selectProperty,
        icon: Image.asset(
          'assets/images/Arrow - Down.png',
          height: 20,
          width: 20,
          color: notifire.getwhiteblackcolor,
        ),
        underline: SizedBox.shrink(),
        isExpanded: true,
        items: dashBoardController.typeList
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                color: notifire.getwhiteblackcolor,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          for (var i = 0;
              i < (dashBoardController.proTypeInfo?.typelist?.length ?? 0);
              i++) {
            if (value == dashBoardController.proTypeInfo?.typelist![i].title) {
              addPropertiesController.pType =
                  dashBoardController.proTypeInfo?.typelist![i].id ?? "";
              print(addPropertiesController.pType);
            }
          }
          setState(() => selectProperty = value ?? "");
        },
      ),
    );
  }

  // ---------- Opening gallery (unchanged) ----------
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

  // ---------- Reused textfield builder (kept, but width/spacing handled by _boxed) ----------
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
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui' as ui;
//
// class AddPropertyScreen1 extends StatefulWidget {
//   const AddPropertyScreen1({super.key});
//
//   @override
//   State<AddPropertyScreen1> createState() => _AddPropertyScreen1State();
// }
//
// List<String> propertyType = ["Adult Family Home", "Assisted Living Facility"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen1State extends State<AddPropertyScreen1> {
//   AddPropertiesController addPropertiesController = Get.find();
//   DashBoardController dashBoardController = Get.find();
//   EnquiryController enquriryController = Get.find();
//   SelectCountryController selectCountryController = Get.find();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String manegeRoute = Get.arguments["add"];
//
//   String selectValue = propertyType.first;
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
//   //New location picker implementation
//
//   late GoogleMapController mapController1;
//   Set<Marker> markers = Set();
//   Future<Uint8List> getImages(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetHeight: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }
//
//   Future<void> _onAddMarkerButtonPressed(double? lat, long) async {
//     final Uint8List markIcon =
//         await getImages("assets/images/location_pin.png", 80);
//     markers.add(Marker(
//       markerId: const MarkerId("1"),
//       position:
//           LatLng(double.parse(lat.toString()), double.parse(long.toString())),
//       // icon: BitmapDescriptor.defaultMarker,
//       icon: BitmapDescriptor.fromBytes(markIcon),
//     ));
//     setState(() {});
//   }
//
//   getCurrentLatAndLong(double latitude, double longitude) async {
//     addPropertiesController.lat = latitude;
//     addPropertiesController.long = longitude;
//
//     await placemarkFromCoordinates(
//             addPropertiesController.lat, addPropertiesController.long)
//         .then((List<Placemark> placemarks) {
//       if (manegeRoute == "Add") {
//         addPropertiesController.propertyAddress =
//             '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';
//         addPropertiesController.propertyZipCode = placemarks.first.postalCode!;
//         addPropertiesController.propertyCountry = placemarks.first.country!;
//         addPropertiesController.propertyCity = placemarks.first.locality!;
//
//         print(
//             "FIRST USER CURRENT LOCATION : --${addPropertiesController.propertyAddress}");
//       } else {
//         //Editing
//         addPropertiesController.ePropertyAddress =
//             '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';
//         addPropertiesController.ePropertyZipCode = placemarks.first.postalCode!;
//         addPropertiesController.ePropertyCountry = placemarks.first.country!;
//         addPropertiesController.ePropertyCity = placemarks.first.locality!;
//       }
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     if (manegeRoute == "edit") {
//       try {
//         getCurrentLatAndLong(
//             addPropertiesController.elat, addPropertiesController.elong);
//         setState(() {
//           addPropertiesController.emptyAllDetails();
//           addPropertiesController.propertyTitleController.text =
//               addPropertiesController.ePropertyName!;
//           selectProperty = addPropertiesController.ePropertyType;
//           addPropertiesController.propertyDescriptionController.text =
//               addPropertiesController.ePropertyDescription!;
//         });
//       } catch (e, stackTrace) {
//         print("Error: $e");
//         print("Stack trace: $stackTrace");
//       }
//     } else {
//       addPropertiesController.emptyAllDetails();
//       /*addPropertiesController.selectedIndexes = [];
//       addPropertiesController.pType = "";
//       addPropertiesController.countryId = "";
//       selectProperty = null;
//       selectCountry = null;*/
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
//                             "Let's Start Your Client-Finding Journey".tr,
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
//                                 ? "Step 1 of 8".tr
//                                 : "Step 1 of 7".tr,
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
//                             "A Little About Your Home or Facility".tr,
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
//                             "Home Type".tr,
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
//                           height: 60,
//                           width: Get.size.width,
//                           alignment: Alignment.center,
//                           margin: EdgeInsets.symmetric(horizontal: 10),
//                           padding: EdgeInsets.only(left: 15, right: 15),
//                           child: DropdownButton(
//                             dropdownColor: notifire.getbgcolor,
//                             hint: Text(
//                               "Select Home Type".tr,
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                             value: selectProperty,
//                             icon: Image.asset(
//                               'assets/images/Arrow - Down.png',
//                               height: 20,
//                               width: 20,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             underline: SizedBox.shrink(),
//                             isExpanded: true,
//                             items: dashBoardController.typeList
//                                 .map<DropdownMenuItem<String>>((String value) {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(
//                                   value,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     color: notifire.getwhiteblackcolor,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               for (var i = 0;
//                                   i <
//                                       dashBoardController
//                                           .proTypeInfo!.typelist!.length;
//                                   i++) {
//                                 if (value ==
//                                     dashBoardController
//                                         .proTypeInfo?.typelist![i].title) {
//                                   addPropertiesController.pType =
//                                       dashBoardController
//                                               .proTypeInfo?.typelist![i].id ??
//                                           "";
//                                   print(addPropertiesController.pType);
//                                 }
//                               }
//                               setState(() {
//                                 selectProperty = value ?? "";
//                               });
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         textfield(
//                           type: "Home Name".tr,
//                           controller:
//                               addPropertiesController.propertyTitleController,
//                           labelText: "Home Name".tr,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Home Name'.tr;
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
//                             "Home Description".tr,
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
//                             controller: addPropertiesController
//                                 .propertyDescriptionController,
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
//                                   "Briefly describe your home or facility, including amenities, caregiver qualifications, accreditations, and the unique care services you offer"
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
//                                 return 'Please Enter Home Description'.tr;
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
//                           height: 10,
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Where is your home located?".tr,
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
//                         Padding(
//                           padding:
//                               const EdgeInsets.only(left: 10.0, right: 10.0),
//                           child: Container(
//                             height: 200,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: GoogleMap(
//                                 gestureRecognizers: {
//                                   Factory<OneSequenceGestureRecognizer>(
//                                       () => EagerGestureRecognizer())
//                                 },
//                                 initialCameraPosition: CameraPosition(
//                                     target: manegeRoute == "Add"
//                                         ? LatLng(47.751076, -120.740135)
//                                         : LatLng(addPropertiesController.elat,
//                                             addPropertiesController.elong),
//                                     zoom: 13),
//                                 mapType: MapType.normal,
//                                 markers: Set<Marker>.of(markers),
//                                 onTap: (argument) {
//                                   setState(() {});
//                                   _onAddMarkerButtonPressed(
//                                       argument.latitude, argument.longitude);
//                                   addPropertiesController.lat =
//                                       argument.latitude;
//                                   addPropertiesController.long =
//                                       argument.longitude;
//                                   /*getAddressFromLatLng(
//                                       addPropertiesController.lat,
//                                       addPropertiesController.long);*/
//                                   getCurrentLatAndLong(
//                                     addPropertiesController.lat,
//                                     addPropertiesController.long,
//                                   );
//                                   print(
//                                       "**lat****:--- ${addPropertiesController.lat}");
//                                   print(
//                                       "+++longo+++:--- ${addPropertiesController.long}");
//                                   print(
//                                       "--------------------------------------");
//                                   print(
//                                       "hfgjhvhjwfvhjuyfvf:-=---  ${addPropertiesController.propertyAddress}");
//
//                                   addPropertiesController.update();
//                                 },
//                                 myLocationEnabled: true,
//                                 zoomGesturesEnabled: true,
//                                 tiltGesturesEnabled: true,
//                                 zoomControlsEnabled: true,
//                                 onMapCreated: (controller) {
//                                   setState(() {
//                                     mapController1 = controller;
//                                   });
//                                 },
//                               ),
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
//                             addPropertiesController.propertyTitle =
//                                 addPropertiesController
//                                     .propertyTitleController.text;
//
//                             addPropertiesController.propertyDescription =
//                                 addPropertiesController
//                                     .propertyDescriptionController.text;
//
//                             Get.toNamed(
//                               Routes.addPropertyScreen2,
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
