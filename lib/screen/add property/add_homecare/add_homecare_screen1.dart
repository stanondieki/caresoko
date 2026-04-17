// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/add_homecare_controller.dart';
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
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:latlong2/latlong.dart' as osm;

// NOTE: keep your imports as you have them

class AddHomeCareScreen1 extends StatefulWidget {
  const AddHomeCareScreen1({super.key});

  @override
  State<AddHomeCareScreen1> createState() => _AddHomeCareScreen1State();
}

const List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen1State extends State<AddHomeCareScreen1> {
  final AddHomecareController addHomecareController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments["add"];

  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  Future<Position> locateUser() async =>
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  // ---------- Map helpers ----------
  final MapController mapController1 = MapController();
  final List<osm.LatLng> markers = <osm.LatLng>[];

  Future<Uint8List> _loadMarkerBytes(String path, int targetHeight) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: targetHeight,
    );
    final fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // ✅ explicit double types; also replaces previous dynamic/parse crash
  Future<void> _onAddMarkerButtonPressed(double lat, double lng) async {
    final iconBytes =
        await _loadMarkerBytes("assets/images/location_pin.png", 80);
    markers
      ..clear()
      ..add(osm.LatLng(lat, lng));
    setState(() {});
  }

  Future<void> _reverseGeocodeAndSet(double latitude, double longitude) async {
    addHomecareController.lat = latitude;
    addHomecareController.long = longitude;

    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    final p = placemarks.first;

    addHomecareController.agencyAddress =
        '${p.name}, ${p.locality}, ${p.country}';
    addHomecareController.agencyZipCode = p.postalCode ?? '';
    addHomecareController.agencyCountry = p.country ?? '';
    addHomecareController.agencyCity = p.locality ?? '';
  }

  @override
  void initState() {
    super.initState();
    if (manegeRoute == "edit") {
      try {
        addHomecareController.emptyAllDetails();
        addHomecareController.agencyNameController.text =
            addHomecareController.ePropertyName ?? "";
        addHomecareController.lat = addHomecareController.elat;
        addHomecareController.long = addHomecareController.elong;
        // Pre-fill display address (safe even if rev-geo fails later)
        _reverseGeocodeAndSet(
            addHomecareController.elat, addHomecareController.elong);
      } catch (e, st) {
        // ignore but log
        // print("init error: $e\n$st");
      }
    } else {
      addHomecareController.emptyAllDetails();
    }
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isWide = width >= 900; // desktop/tablet
    final sidePad = isWide ? 24.0 : 10.0; // larger gutters on web
    final contentMaxWidth = 1100.0; // center column width cap
    final cardPad = EdgeInsets.symmetric(horizontal: sidePad);

    final initialTarget = (manegeRoute == "Add")
      ? const osm.LatLng(47.751076, -120.740135)
      : osm.LatLng(addHomecareController.elat, addHomecareController.elong);

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
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Padding(
                padding: cardPad,
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
                          _title("Let's Start Your Client-Finding Journey".tr),
                          const SizedBox(height: 16),
                          _subtitle(manegeRoute == "Add"
                              ? "Step 1 of 8".tr
                              : "Step 1 of 7".tr),
                          const SizedBox(height: 8),
                          _sectionHeader("A Little About Your Agency".tr),
                          const SizedBox(height: 12),
                          Divider(height: 0.5, color: notifire.getgreycolor),
                          const SizedBox(height: 16),

                          // Agency Name
                          _field(
                            label: "Agency Name".tr,
                            controller:
                                addHomecareController.agencyNameController,
                            hint: "Agency Name".tr,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please Enter Agency Name'.tr
                                : null,
                          ),

                          const SizedBox(height: 16),
                          _sectionHeader("Where is your agency located?".tr),
                          const SizedBox(height: 8),

                          // Google Map (responsive container)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              height: isWide ? 280 : 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: FlutterMap(
                                  mapController: mapController1,
                                  options: MapOptions(
                                    initialCenter: initialTarget,
                                    initialZoom: 13,
                                    onTap: (tapPosition, pos) async {
                                    await _onAddMarkerButtonPressed(
                                        pos.latitude, pos.longitude);
                                    await _reverseGeocodeAndSet(
                                        pos.latitude, pos.longitude);
                                    addHomecareController.update();
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

                          const SizedBox(height: 24),

                          // NEXT button (centered, responsive left/right padding)
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
                                addHomecareController.agencyName =
                                    addHomecareController
                                        .agencyNameController.text;
                                // You can validate if you want:
                                // if (!(_formKey.currentState?.validate() ?? false)) return;
                                // COMMENTED OUT: Advert functionality disabled
                                // Get.toNamed(
                                //   Routes.addHomecareScreen2,
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

  // ---------- Small UI helpers (clean & reusable) ----------

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

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? inputType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(label),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: notifire.getblackwhitecolor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: notifire.getwhiteblackcolor,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
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

  // (Kept for future: image picker if you add in step-1 later)
  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addHomecareController.path = pickedFile.path;
      final imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      addHomecareController.base64Image = base64Encode(bytes);
      setState(() {});
    }
  }
}

// class AddHomeCareScreen1 extends StatefulWidget {
//   const AddHomeCareScreen1({super.key});
//
//   @override
//   State<AddHomeCareScreen1> createState() => _AddHomeCareScreen1State();
// }
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen1State extends State<AddHomeCareScreen1> {
//   AddHomecareController addHomecareController = Get.find();
//   DashBoardController dashBoardController = Get.find();
//   EnquiryController enquriryController = Get.find();
//   SelectCountryController selectCountryController = Get.find();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String manegeRoute = Get.arguments["add"];
//
//   String? selectProperty;
//   String? selectCountry;
//   String slectStatus = propartyStatus.first;
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
//     addHomecareController.lat = latitude;
//     addHomecareController.long = longitude;
//
//     await placemarkFromCoordinates(
//             addHomecareController.lat, addHomecareController.long)
//         .then((List<Placemark> placemarks) {
//       addHomecareController.agencyAddress =
//           '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';
//       addHomecareController.agencyZipCode = placemarks.first.postalCode!;
//       addHomecareController.agencyCountry = placemarks.first.country!;
//       addHomecareController.agencyCity = placemarks.first.locality!;
//
//       print(
//           "FIRST USER CURRENT LOCATION : --${addHomecareController.agencyAddress}");
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     if (manegeRoute == "edit") {
//       try {
//         print("CURRENT SCREEN STATE: $manegeRoute");
//         getCurrentLatAndLong(
//             addHomecareController.elat, addHomecareController.elong);
//         setState(() {
//           addHomecareController.emptyAllDetails();
//           addHomecareController.agencyNameController.text =
//               addHomecareController.ePropertyName!;
//           addHomecareController.lat = addHomecareController.elat;
//           addHomecareController.long = addHomecareController.elong;
//         });
//       } catch (e, stackTrace) {
//         print("Error: $e");
//         print("Stack trace: $stackTrace");
//       }
//     } else {
//       addHomecareController.emptyAllDetails();
//       /*addHomecareController.selectedIndexes = [];
//       addHomecareController.pType = "";
//       addHomecareController.countryId = "";
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
//                             "A Little About Your Agency".tr,
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
//                           type: "Agency Name".tr,
//                           controller:
//                               addHomecareController.agencyNameController,
//                           labelText: "Agency Name".tr,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Agency Name'.tr;
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Where is your agency located?".tr,
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
//                                         : LatLng(addHomecareController.elat,
//                                             addHomecareController.elong),
//                                     zoom: 13),
//                                 mapType: MapType.normal,
//                                 markers: Set<Marker>.of(markers),
//                                 onTap: (argument) {
//                                   setState(() {});
//                                   _onAddMarkerButtonPressed(
//                                       argument.latitude, argument.longitude);
//                                   addHomecareController.lat = argument.latitude;
//                                   addHomecareController.long =
//                                       argument.longitude;
//                                   /*getAddressFromLatLng(
//                                       addHomecareController.lat,
//                                       addHomecareController.long);*/
//                                   getCurrentLatAndLong(
//                                     addHomecareController.lat,
//                                     addHomecareController.long,
//                                   );
//                                   print(
//                                       "**lat****:--- ${addHomecareController.lat}");
//                                   print(
//                                       "+++longo+++:--- ${addHomecareController.long}");
//                                   print(
//                                       "--------------------------------------");
//                                   print(
//                                       "hfgjhvhjwfvhjuyfvf:-=---  ${addHomecareController.agencyAddress}");
//
//                                   addHomecareController.update();
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
//                             addHomecareController.agencyName =
//                                 addHomecareController.agencyNameController.text;
//
//                             Get.toNamed(
//                               Routes.addHomecareScreen2,
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
