// lib/controller/add_proparty/addproperties_controller.dart
// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables,
// prefer_interpolation_to_compose_strings, non_constant_identifier_names

// COMMENTED OUT: Advert functionality disabled
// import 'dart:convert';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';

class AddPropartiesController extends GetxController implements GetxService {
  ListOfPropertyController listOfPropertiController = Get.find();

  // ---------------- TEXT EDITING CONTROLLERS ----------------
  TextEditingController propertyTitleController = TextEditingController();
  TextEditingController propertyDescriptionController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController propertyPriceController = TextEditingController();
  TextEditingController propertyBedsController = TextEditingController();
  TextEditingController propertyBathroomsController = TextEditingController();
  TextEditingController propertySizeController = TextEditingController();
  TextEditingController propertyShootDateController = TextEditingController();

  /// IDs we need for Stripe
  String? createdAdvertId; // set after create
  String? existingAdvertId; // set when editing (copied from propId)
  String? contactEmail; // optional (from profile/login)

  // Media
  String? path;
  String? base64Image;

  // Selects
  String countryId = "";
  String pType = "";
  String pbuySell = ""; // 1 = rent, 2 = sell
  String status = "";

  // Images
  String pImage = "";
  List<String> propertyImagesPaths = [];
  List<String> propertyImagesBase64 = [];

  // Facilities
  var selectedFacilities = [];

  // Map / Address
  double? lat;
  double? long;
  String? propertyAddress;
  String? propertyZipCode;
  String? propertyCountry;
  String? propertyCity;

  // Photos / bookings
  bool havePhotos = true;
  DateTime? propertyShootDate;
  String? propertyShootTime;
  bool consentToPhotographyTerms = false;

  void updateTime(String time) {
    propertyShootTime = time;
    update();
  }

  // ----------------- EDIT / EXISTING LISTING FIELDS -----------------
  String eTitle = "";
  String eNumber = "";
  String eAddress = "";
  String ePrice = "";
  String eTotalBeds = "";
  String eTotalBathroom = "";
  String eSqft = "";
  String eRating = "";
  String eCityAndCountry = "";
  String eDescription = "";
  String propId = ""; // server id
  String eImage = "";
  String eGest = "";
  String buyOrRent = "";
  String Id = "";
  String pShell = "0";

  String fList = "";
  String pName = "";
  String countryName = "";

  double? elat;
  double? elong;
  String ePropertyAddress = "";
  String ePropertyZipCode = "";
  String ePropertyCountry = "";
  String ePropertyCity = "";
  int? ePropertyCountryId;

  /// ------------- Called from property list when user taps "Edit" -------------
  /// Called from property list when user taps "Edit"
  void getEditDetails({
    String? eTitle1,
    String? eNumber1,
    String? eAddress1,
    String? ePrice1,
    String? ePropertyAddress1,
    String? eTotalBeds1,
    String? eTotalBathroom1,
    String? eSqft1,
    String? eRating1,
    String? eCityAndCountry1,
    String? eDescription1,
    dynamic lat1,
    dynamic long1,
    String? propId1,
    String? eImage1,
    String? eGest1,
    String? ebuyorRent,
    String? isShell,
    String? id,
    String? facelity1,
    String? pID,
    String? proName1,
    String? countryId1,
    String? countryName1,
  }) {
    // --- store raw values ---
    eTitle = eTitle1 ?? "";
    eNumber = eNumber1 ?? "";
    eAddress = eAddress1 ?? "";
    ePrice = ePrice1 ?? "";
    ePropertyAddress = ePropertyAddress1 ?? "";
    eTotalBeds = eTotalBeds1 ?? "";
    eTotalBathroom = eTotalBathroom1 ?? "";
    eSqft = eSqft1 ?? "";
    eRating = eRating1 ?? "";
    eCityAndCountry = eCityAndCountry1 ?? "";
    eDescription = eDescription1 ?? "";
    elat = lat1 == null ? null : double.tryParse(lat1.toString());
    elong = long1 == null ? null : double.tryParse(long1.toString());
    propId = propId1 ?? "";
    existingAdvertId = propId;
    eImage = eImage1 ?? "";
    eGest = eGest1 ?? "";
    buyOrRent = ebuyorRent ?? "";
    pShell = isShell ?? "0";
    Id = id ?? "";
    fList = facelity1 ?? "";
    pType = pID ?? "";
    pName = proName1 ?? "";
    countryId = countryId1 ?? "";
    countryName = countryName1 ?? "";

    // --- PREFILL TEXT FIELDS (THIS IS WHAT YOU WERE MISSING) ---
    propertyTitleController.text = eTitle;
    contactNumberController.text = eNumber;
    propertyDescriptionController.text = eDescription;
    propertyPriceController.text = ePrice;
    propertyBedsController.text = eTotalBeds;
    propertyBathroomsController.text = eTotalBathroom;
    propertySizeController.text = eSqft;

    // Map/address for the edit screen
    propertyAddress = ePropertyAddress;
    propertyCountry = ePropertyCountry;
    propertyCity = ePropertyCity;
    propertyZipCode = ePropertyZipCode;
    lat = elat;
    long = elong;

    update();
  }

  // Called on map tap too
  void getCurrentLatAndLong(double latitude, double longitude) {
    lat = latitude;
    long = longitude;
    update();
  }

  // ---------------- RESET WHEN CREATING NEW ADVERT ----------------
  void emptyAllDetails() {
    propertyTitleController.text = "";
    propertyDescriptionController.text = "";
    contactNumberController.text = "";
    propertyPriceController.text = "";
    propertyBedsController.text = "";
    propertyBathroomsController.text = "";
    propertySizeController.text = "";
    propertyShootDateController.text = "";

    path = null;
    base64Image = "";
    pbuySell = "";
    status = "";
    lat = null;
    long = null;
    pImage = "";
    selectedFacilities = [];
    havePhotos = true;
    propertyShootDate = null;
    propertyShootTime = null;
    consentToPhotographyTerms = false;

    update();
  }

  // ---------------------- ADD PROPERTY API (CREATE) ----------------------
  // COMMENTED OUT: Advert posting functionality disabled
  // Future<void> addPropertyApi() async {
  //   final facilities = selectedFacilities.join(",");
  //
  //   try {
  //     final map = {
  //       "uid": getData.read("UserLogin")["id"],
  //       "status": status.isEmpty ? "1" : status,
  //       "country_id": countryId.isEmpty ? "4" : countryId,
  //       "property type": pType,
  //       "property name": propertyTitleController.text,
  //       "property description": propertyDescriptionController.text,
  //       "property capacity": "0",
  //       "no of beds": propertyBedsController.text,
  //       "private rooms": "0",
  //       "no of private rooms": "0",
  //       "own bathrooms": propertyBathroomsController.text,
  //       "shared rooms": "0",
  //       "no of shared rooms": "0",
  //       "property features": facilities,
  //       "memory care clients": "0",
  //       "medicaid clients": "0",
  //       "hoyer clients": "0",
  //       "correctional clients": "0",
  //       "curated menus": "0",
  //       "medication reminders": "0",
  //       "recreational activities": "",
  //       "pricing ready": "0",
  //       "pricing": propertyPriceController.text,
  //       "license number": "",
  //       "accreditations": "",
  //       "certifications": "",
  //       "memberships": "",
  //       "specialized certifications": "",
  //       "background checks": "0",
  //       "drug testing": "0",
  //       "reference verification": "0",
  //       "typical day": "",
  //       "about": "",
  //       "mission": "",
  //       "vision": "",
  //       "website": "None",
  //       "logo": "0",
  //       "property address": propertyAddress ?? "",
  //       "property country": propertyCountry ?? "",
  //       "property city": propertyCity ?? "",
  //       "property zipcode": propertyZipCode ?? "",
  //       "latitude": lat?.toString() ?? "",
  //       "longitude": long?.toString() ?? "",
  //       "have photos": havePhotos ? 1 : 0,
  //       "property shoot date": propertyShootDate?.toIso8601String() ?? "",
  //       "property shoot time": propertyShootTime ?? "",
  //       "property images": propertyImagesBase64,
  //     };
  //
  //     final uri = Uri.parse(Config.path + Config.addPropartyApi);
  //     final response = await http.post(uri, body: jsonEncode(map));
  //
  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       if (result["Result"] == "true") {
  //         createdAdvertId = (result["prop_id"] ??
  //             result["id"] ??
  //             result["property_id"] ??
  //             result["insert_id"] ??
  //             result["unique_id"] ??
  //             (result["data"]?["id"]) ??
  //             (result["data"]?["prop_id"]))
  //             ?.toString();
  //
  //         listOfPropertiController.getPropertiList();
  //         showToastMessage(result["ResponseMsg"]);
  //
  //         if (createdAdvertId == null || createdAdvertId!.isEmpty) {
  //           throw Exception("Missing created advert id from server");
  //         }
  //       } else {
  //         showToastMessage(result["ResponseMsg"]);
  //         throw Exception("Create advert failed");
  //       }
  //     } else {
  //       throw Exception("Create advert HTTP ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }

  // ---------------------- EDIT PROPERTY API (UPDATE) ----------------------
  // COMMENTED OUT: Advert updating functionality disabled
  // Future<void> editPropertyApi() async {
  //   try {
  //     final facilities = selectedFacilities.join(",");
  //
  //     final map = {
  //       "uid": getData.read("UserLogin")["id"],
  //       "prop_id": propId,
  //       "status": status.isEmpty ? "1" : status,
  //       "country_id": countryId.isEmpty ? "4" : countryId,
  //       "property type": pType,
  //       "property name": propertyTitleController.text,
  //       "property description": propertyDescriptionController.text,
  //       "property capacity": "0",
  //       "no of beds": propertyBedsController.text,
  //       "own bathrooms": propertyBathroomsController.text,
  //       "property features": facilities,
  //       "pricing": propertyPriceController.text,
  //       "logo": path != null ? base64Image : "0",
  //       "property address": propertyAddress ?? ePropertyAddress,
  //       "property country": propertyCountry ?? ePropertyCountry,
  //       "property city": propertyCity ?? ePropertyCity,
  //       "property zipcode": propertyZipCode ?? ePropertyZipCode,
  //       "latitude": lat?.toString() ?? elat?.toString() ?? "",
  //       "longitude": long?.toString() ?? elong?.toString() ?? "",
  //       "property size": propertySizeController.text,
  //       "contact number": contactNumberController.text,
  //     };
  //
  //     final uri = Uri.parse(Config.path + Config.editPropertyApi);
  //     final response = await http.post(uri, body: jsonEncode(map));
  //
  //     if (response.statusCode == 200) {
  //       final result = jsonDecode(response.body);
  //       if (result["Result"] == "true") {
  //         existingAdvertId = (result["prop_id"] ?? propId).toString();
  //         listOfPropertiController.getPropertiList();
  //         showToastMessage(result["ResponseMsg"]);
  //       } else {
  //         showToastMessage(result["ResponseMsg"]);
  //         throw Exception("Edit advert failed");
  //       }
  //     } else {
  //       throw Exception("Edit advert HTTP ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }
}

// // ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:http/http.dart' as http;
//
// class AddPropartiesController extends GetxController implements GetxService {
//   ListOfPropertyController listOfPropertiController = Get.find();
//
//   // Form controllers
//   TextEditingController propertyTitleController = TextEditingController();
//   TextEditingController propertyDescriptionController = TextEditingController();
//   TextEditingController contactNumberController = TextEditingController();
//   TextEditingController propertyPriceController = TextEditingController();
//   TextEditingController propertyBedsController = TextEditingController();
//   TextEditingController propertyBathroomsController = TextEditingController();
//   TextEditingController propertySizeController = TextEditingController();
//
//   /// IDs we need for Stripe
//   String? createdAdvertId; // set after create
//   String? existingAdvertId; // set when editing (copied from propId)
//   String? contactEmail; // optional (set from profile / login if you want)
//
//   // Media
//   String? path;
//   String? base64Image;
//
//   // Selects
//   String countryId = "";
//   String pType = "";
//   String pbuySell = ""; // 1 = rent, 2 = sell
//   String status = "";
//
//   // Images
//   String pImage = "";
//   List<String> propertyImagesPaths = [];
//   List<String> propertyImagesBase64 = [];
//
//   // Facilities
//   var selectedFacilities = [];
//
//   // Map / Address
//   var lat;
//   var long;
//   var propertyAddress;
//   var propertyZipCode;
//   var propertyCountry;
//   var propertyCity;
//
//   // Photos / bookings
//   bool havePhotos = true;
//   DateTime? propertyShootDate;
//   String? propertyShootTime;
//   TextEditingController propertyShootDateController = TextEditingController();
//   bool consentToPhotographyTerms = false;
//
//   void updateTime(String time) {
//     propertyShootTime = time;
//     update();
//   }
//
//   // Edit fields (existing listing)
//   String eTitle = "";
//   String eNumber = "";
//   String eAddress = "";
//   String ePrice = "";
//   String eTotalBeds = "";
//   String eTotalBathroom = "";
//   String eSqft = "";
//   String eRating = "";
//   String eCityAndCountry = "";
//   String eDescription = ""; // <--- used to prefill description
//   String propId = ""; // server id
//   String eImage = "";
//   String eGest = "";
//   String buyOrRent = "";
//   String Id = "";
//   String pShell = "0";
//
//   String fList = "";
//   String pName = "";
//   String countryName = "";
//
//   var elat;
//   var elong;
//   var ePropertyAddress = "";
//   var ePropertyZipCode = "";
//   var ePropertyCountry = "";
//   var ePropertyCity = "";
//   int? ePropertyCountryId;
//
//   /// Called from property list when user taps "Edit"
//   getEditDetails({
//     String? eTitle1,
//     String? eNumber1,
//     String? eAddress1,
//     String? ePrice1,
//     String? ePropertyAddress1,
//     String? eTotalBeds1,
//     String? eTotalBathroom1,
//     String? eSqft1,
//     String? eRating1,
//     String? eCityAndCountry1,
//     String? eDescription1,
//     dynamic lat1,
//     dynamic long1,
//     String? propId1,
//     String? eImage1,
//     String? eGest1,
//     String? ebuyorRent,
//     String? isShell,
//     String? id,
//     String? facelity1,
//     String? pID,
//     String? proName1,
//     String? countryId1,
//     String? countryName1,
//   }) {
//     eTitle = eTitle1 ?? "";
//     eNumber = eNumber1 ?? "";
//     eAddress = eAddress1 ?? "";
//     ePrice = ePrice1 ?? "";
//     ePropertyAddress = ePropertyAddress1 ?? "";
//     eTotalBeds = eTotalBeds1 ?? "";
//     eTotalBathroom = eTotalBathroom1 ?? "";
//     eSqft = eSqft1 ?? "";
//     eRating = eRating1 ?? "";
//     eCityAndCountry = eCityAndCountry1 ?? "";
//     eDescription = eDescription1 ?? "";
//     elat = lat1 ?? "";
//     elong = long1 ?? "";
//     propId = propId1 ?? "";
//     existingAdvertId = propId; // for Stripe during edit
//     eImage = eImage1 ?? "";
//     eGest = eGest1 ?? "";
//     buyOrRent = ebuyorRent ?? "";
//     pShell = isShell ?? "0";
//     Id = id ?? "";
//     fList = facelity1 ?? "";
//     pType = pID ?? "";
//     pName = proName1 ?? "";
//     countryId = countryId1 ?? "";
//     countryName = countryName1 ?? "";
//     update();
//   }
//
//   getCurrentLatAndLong(double latitude, double longitude) {
//     lat = latitude;
//     long = longitude;
//     update();
//   }
//
//   emptyAllDetails() {
//     propertyTitleController.text = "";
//     propertyDescriptionController.text = "";
//     contactNumberController.text = "";
//     propertyPriceController.text = "";
//     propertyBedsController.text = "";
//     propertyBathroomsController.text = "";
//     propertySizeController.text = "";
//
//     path = null;
//     base64Image = "";
//     pbuySell = "";
//     status = "";
//     lat = null;
//     long = null;
//     pImage = "";
//     selectedFacilities = [];
//     havePhotos = true;
//     propertyShootDate = null;
//     propertyShootTime = null;
//     propertyShootDateController.text = "";
//     consentToPhotographyTerms = false;
//     // DO NOT clear createdAdvertId/existingAdvertId here, they are per-create/edit
//     update();
//   }
//
//   /// ---------------- ADD PROPERTY API (creation) ----------------
//   Future<void> addPropertyApi() async {
//     final facilities = selectedFacilities.join(",");
//
//     try {
//       final map = {
//         "uid": getData.read("UserLogin")["id"],
//         "status": status.isEmpty ? "1" : status,
//         "country_id": countryId.isEmpty ? "4" : countryId,
//         // the new PHP add API is care-specific, but we send only what we have with safe defaults
//         "property type": pType,
//         "property name": propertyTitleController.text,
//         "property description": propertyDescriptionController.text,
//         "property capacity": "0",
//         "no of beds": propertyBedsController.text,
//         "private rooms": "0",
//         "no of private rooms": "0",
//         "own bathrooms": propertyBathroomsController.text,
//         "shared rooms": "0",
//         "no of shared rooms": "0",
//         "property features": facilities,
//         "memory care clients": "0",
//         "medicaid clients": "0",
//         "hoyer clients": "0",
//         "correctional clients": "0",
//         "curated menus": "0",
//         "medication reminders": "0",
//         "recreational activities": "",
//         "pricing ready": "0",
//         "pricing": propertyPriceController.text,
//         "license number": "",
//         "accreditations": "",
//         "certifications": "",
//         "memberships": "",
//         "specialized certifications": "",
//         "background checks": "0",
//         "drug testing": "0",
//         "reference verification": "0",
//         "typical day": "",
//         "about": "",
//         "mission": "",
//         "vision": "",
//         "website": "None",
//         // logo for now is optional -> send "0"
//         "logo": "0",
//         "property address": propertyAddress ?? "",
//         "property country": propertyCountry ?? "",
//         "property city": propertyCity ?? "",
//         "property zipcode": propertyZipCode ?? "",
//         "latitude": lat?.toString() ?? "",
//         "longitude": long?.toString() ?? "",
//         "have photos": havePhotos ? 1 : 0,
//         "property shoot date": propertyShootDate?.toIso8601String() ?? "",
//         "property shoot time": propertyShootTime ?? "",
//         "property images": propertyImagesBase64,
//       };
//
//       final uri = Uri.parse(Config.path + Config.addPropartyApi);
//       final response = await http.post(uri, body: jsonEncode(map));
//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         if (result["Result"] == "true") {
//           // server now returns prop_id & unique_id
//           createdAdvertId = (result["prop_id"] ??
//               result["id"] ??
//               result["property_id"] ??
//               result["insert_id"] ??
//               result["unique_id"] ??
//               (result["data"]?["id"]) ??
//               (result["data"]?["prop_id"]))
//               ?.toString();
//
//           listOfPropertiController.getPropertiList();
//           showToastMessage(result["ResponseMsg"]);
//           if (createdAdvertId == null || createdAdvertId!.isEmpty) {
//             throw Exception("Missing created advert id from server");
//           }
//         } else {
//           showToastMessage(result["ResponseMsg"]);
//           throw Exception("Create advert failed");
//         }
//       } else {
//         throw Exception("Create advert HTTP ${response.statusCode}");
//       }
//     } catch (e) {
//       print(e);
//       rethrow;
//     }
//   }
//
//   /// ---------------- EDIT PROPERTY API (update) ----------------
//   ///
//   /// This is aligned with your PHP edit API:
//   /// - we use "property type", "property name", "property description", etc.
//   /// - we send safe defaults for fields you don't collectyet
//   Future<void> editPropertyApi() async {
//     try {
//       final facilities = selectedFacilities.join(",");
//
//       final map = {
//         "uid": getData.read("UserLogin")["id"],
//         "status": status.isEmpty ? "1" : status,
//         "country_id": countryId.isEmpty ? "4" : countryId,
//         "property type": pType,
//         "property name": propertyTitleController.text,
//         "property description": propertyDescriptionController.text,
//         // capacity removed from UI -> just send "0" to keep API happy
//         "property capacity": "0",
//         "no of beds": propertyBedsController.text,
//         "private rooms": "0",
//         "no of private rooms": "0",
//         "own bathrooms": propertyBathroomsController.text,
//         "shared rooms": "0",
//         "no of shared rooms": "0",
//         "property features": facilities,
//         "memory care clients": "0",
//         "medicaid clients": "0",
//         "hoyer clients": "0",
//         "correctional clients": "0",
//         "curated menus": "0",
//         "medication reminders": "0",
//         "accreditations": "",
//         "certifications": "",
//         "memberships": "",
//         "specialized certifications": "",
//         "background checks": "0",
//         "drug testing": "0",
//         "reference verification": "0",
//         "recreational activities": "",
//         "pricing ready": "0",
//         "pricing": propertyPriceController.text,
//         "license number": "",
//         "typical day": "",
//         "about": "",
//         "mission": "",
//         "vision": "",
//         "website": "None",
//         "logo": path != null ? base64Image : "0",
//         "property address": propertyAddress ?? ePropertyAddress,
//         "property country": propertyCountry ?? ePropertyCountry,
//         "property city": propertyCity ?? ePropertyCity,
//         "property zipcode": propertyZipCode ?? ePropertyZipCode,
//         "latitude": lat?.toString() ?? elat?.toString() ?? "",
//         "longitude": long?.toString() ?? elong?.toString() ?? "",
//         "prop_id": propId,
//       };
//
//       final uri = Uri.parse(Config.path + Config.editPropertyApi);
//       final response = await http.post(uri, body: jsonEncode(map));
//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         if (result["Result"] == "true") {
//           existingAdvertId = (result["prop_id"] ?? propId).toString();
//           listOfPropertiController.getPropertiList();
//           showToastMessage(result["ResponseMsg"]);
//         } else {
//           showToastMessage(result["ResponseMsg"]);
//           throw Exception("Edit advert failed");
//         }
//       } else {
//         throw Exception("Edit advert HTTP ${response.statusCode}");
//       }
//     } catch (e) {
//       print(e);
//       rethrow;
//     }
//   }
// }
//
//
//
//
//
// // // ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names
// //
// // import 'dart:convert';
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:gotocarefinder/Api/config.dart';
// // import 'package:gotocarefinder/Api/data_store.dart';
// // import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
// // import 'package:gotocarefinder/utils/Custom_widget.dart';
// // import 'package:http/http.dart' as http;
// //
// // class AddPropartiesController extends GetxController implements GetxService {
// //   ListOfPropertyController listOfPropertiController = Get.find();
// //
// //   // Form controllers
// //   TextEditingController propertyTitleController = TextEditingController();
// //   TextEditingController propertyDescriptionController = TextEditingController();
// //   TextEditingController contactNumberController = TextEditingController();
// //   TextEditingController propertyPriceController = TextEditingController();
// //   TextEditingController propertyBedsController = TextEditingController();
// //   TextEditingController propertyBathroomsController = TextEditingController();
// //   TextEditingController propertySizeController = TextEditingController();
// //   // TextEditingController propertyCapacityController = TextEditingController();
// //
// //   /// IDs we need for Stripe
// //   String? createdAdvertId;   // set after create
// //   String? existingAdvertId;  // set when editing (copied from propId)
// //   String? contactEmail;      // optional
// //
// //   // Media
// //   String? path;
// //   String? base64Image;
// //
// //   // Selects
// //   String countryId = "";
// //   String pType = "";
// //   String pbuySell = "";
// //   String status = "";
// //
// //   // Images
// //   String pImage = "";
// //   List<String> propertyImagesPaths = [];
// //   List<String> propertyImagesBase64 = [];
// //
// //   // Map / Address
// //   var selectedFacilities = [];
// //   var lat;
// //   var long;
// //   var propertyAddress;
// //   var propertyZipCode;
// //   var propertyCountry;
// //   var propertyCity;
// //
// //   // Photos / bookings
// //   bool havePhotos = true;
// //   DateTime? propertyShootDate;
// //   String? propertyShootTime;
// //   TextEditingController propertyShootDateController = TextEditingController();
// //   void updateTime(String time) {
// //     propertyShootTime = time;
// //     update();
// //   }
// //   bool consentToPhotographyTerms = false;
// //
// //   // Edit fields (existing listing)
// //   String eTitle = "";
// //   String eNumber = "";
// //   String eAddress = "";
// //   String ePrice = "";
// //   String eTotalBeds = "";
// //   String eTotalBathroom = "";
// //   String eSqft = "";
// //   String eRating = "";
// //   String eCityAndCountry = "";
// //   String propId = "";               // server id
// //   String eImage = "";
// //   String eGest = "";
// //   String buyOrRent = "";
// //   String Id = "";
// //   String pShell = "0";
// //
// //   String fList = "";
// //   String pName = "";
// //   String countryName = "";
// //
// //   var elat;
// //   var elong;
// //   var ePropertyAddress = "";
// //   var ePropertyZipCode = "";
// //   var ePropertyCountry = "";
// //   var ePropertyCity = "";
// //   int? ePropertyCountryId;
// //
// //   getEditDetails({
// //     String? eTitle1,
// //     eNumber1,
// //     eAddress1,
// //     ePrice1,
// //     ePropertyAddress1,
// //     eTotalBeds1,
// //     eTotalBathroom1,
// //     eSqft1,
// //     eRating1,
// //     eCityAndCountry1,
// //     lat1,
// //     long1,
// //     propId1,
// //     eImage1,
// //     eGest1,
// //     ebuyorRent,
// //     isShell,
// //     id,
// //     facelity1,
// //     pID,
// //     proName1,
// //     countryId1,
// //     countryName1,
// //   }) {
// //     eTitle = eTitle1 ?? "";
// //     eNumber = eNumber1 ?? "";
// //     eAddress = eAddress1 ?? "";
// //     ePrice = ePrice1 ?? "";
// //     ePropertyAddress = ePropertyAddress1 ?? "";
// //     eTotalBeds = eTotalBeds1 ?? "";
// //     eTotalBathroom = eTotalBathroom1 ?? "";
// //     eSqft = eSqft1 ?? "";
// //     eRating = eRating1 ?? "";
// //     eCityAndCountry = eCityAndCountry1 ?? "";
// //     elat = lat1 ?? "";
// //     elong = long1 ?? "";
// //     propId = propId1 ?? "";
// //     existingAdvertId = propId;           // <-- important for Stripe during edit
// //     eImage = eImage1 ?? "";
// //     eGest = eGest1 ?? "";
// //     buyOrRent = ebuyorRent;
// //     pShell = isShell;
// //     Id = id;
// //     fList = facelity1;
// //     pType = pID;
// //     pName = proName1;
// //     countryId = countryId1;
// //     countryName = countryName1;
// //     update();
// //   }
// //
// //   getCurrentLatAndLong(double latitude, double longitude) {
// //     lat = latitude;
// //     long = longitude;
// //     update();
// //   }
// //
// //   emptyAllDetails() {
// //     propertyTitleController.text = "";
// //     propertyDescriptionController.text = "";
// //     contactNumberController.text = "";
// //     propertyPriceController.text = "";
// //     propertyBedsController.text = "";
// //     propertyBathroomsController.text = "";
// //     propertySizeController.text = "";
// //     // propertyCapacityController.text = "";
// //     path = null;
// //     base64Image = "";
// //     pbuySell = "";
// //     status = "";
// //     lat = null;
// //     long = null;
// //     pImage = "";
// //     // do not clear createdAdvertId — we set it after API success
// //     update();
// //   }
// //
// //   Future<void> addPropertyApi() async {
// //     final facilities = selectedFacilities.join(",");
// //     try {
// //       final map = {
// //         "uid": getData.read("UserLogin")["id"],
// //         "status": status.isEmpty ? "1" : status,
// //         "country_id": countryId.isEmpty ? "4" : countryId,
// //         "pbuysell": pbuySell.isEmpty ? "2" : pbuySell,
// //         "ptype": pType,
// //         "title": propertyTitleController.text,
// //         "description": propertyDescriptionController.text,
// //         "facilities": facilities,
// //         "no of beds": propertyBedsController.text,
// //         "no of bathrooms": propertyBathroomsController.text,
// //         "property size": propertySizeController.text,
// //         // "property capacity": propertyCapacityController.text,
// //         "price": propertyPriceController.text,
// //         "contact number": contactNumberController.text,
// //         "property address": propertyAddress,
// //         "property country": propertyCountry,
// //         "property city": propertyCity,
// //         "property zipcode": propertyZipCode,
// //         "latitude": lat?.toString(),
// //         "longitude": long?.toString(),
// //         "have photos": havePhotos ? 1 : 0,
// //         "property shoot date": propertyShootDate?.toIso8601String() ?? "",
// //         "property shoot time": propertyShootTime ?? "",
// //         "property images": propertyImagesBase64,
// //       };
// //
// //       final uri = Uri.parse(Config.path + Config.addPropartyApi); // /user_api/create_property.php
// //       final response = await http.post(uri, body: jsonEncode(map));
// //       if (response.statusCode == 200) {
// //         final result = jsonDecode(response.body);
// //         if (result["Result"] == "true") {
// //           // try common id keys
// //           createdAdvertId =
// //               (result["id"] ??
// //                   result["prop_id"] ??
// //                   result["property_id"] ??
// //                   result["insert_id"] ??
// //                   (result["data"]?["id"]) ??
// //                   (result["data"]?["prop_id"]) ??
// //                   result["unique_id"])
// //                   ?.toString();
// //
// //           listOfPropertiController.getPropertiList();
// //           showToastMessage(result["ResponseMsg"]);
// //           // don't navigate away yet; payment follows
// //         } else {
// //           showToastMessage(result["ResponseMsg"]);
// //           throw Exception("Create advert failed");
// //         }
// //       } else {
// //         throw Exception("Create advert HTTP ${response.statusCode}");
// //       }
// //     } catch (e) {
// //       print(e);
// //       rethrow;
// //     }
// //   }
// //
// //   Future<void> editPropertyApi() async {
// //     try {
// //       final facilities = selectedFacilities.join(",");
// //       final map = {
// //         "uid": getData.read("UserLogin")["id"],
// //         "status": status.isEmpty ? "1" : status,
// //         "country_id": countryId,
// //         "pbuysell": pbuySell.isEmpty ? "2" : pbuySell,
// //         "title": propertyTitleController.text,
// //         "description": propertyDescriptionController.text,
// //         "facility": facilities,
// //         "ptype": pType,
// //         "beds": propertyBedsController.text,
// //         "bathroom": propertyBathroomsController.text,
// //         "sqft": propertySizeController.text,
// //         "latitude": lat?.toString(),
// //         "longitude": long?.toString(),
// //         "mobile": contactNumberController.text,
// //         "price": propertyPriceController.text,
// //         "img": path != null ? base64Image : "0",
// //         "prop_id": propId,
// //       };
// //
// //       final uri = Uri.parse(Config.path + Config.editPropertyApi); // /user_api/edit_property.php
// //       final response = await http.post(uri, body: jsonEncode(map));
// //       if (response.statusCode == 200) {
// //         final result = jsonDecode(response.body);
// //         if (result["Result"] == "true") {
// //           // server should echo prop_id back
// //           existingAdvertId = (result["prop_id"] ?? propId).toString();
// //           listOfPropertiController.getPropertiList();
// //           showToastMessage(result["ResponseMsg"]);
// //         } else {
// //           showToastMessage(result["ResponseMsg"]);
// //           throw Exception("Edit advert failed");
// //         }
// //       } else {
// //         throw Exception("Edit advert HTTP ${response.statusCode}");
// //       }
// //     } catch (e) {
// //       print(e);
// //       rethrow;
// //     }
// //   }
// // }
// //
// //
// //
// // // // ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names
// // //
// // // import 'dart:convert';
// // //
// // // import 'package:flutter/material.dart';
// // // import 'package:get/get.dart';
// // // import 'package:gotocarefinder/Api/config.dart';
// // // import 'package:gotocarefinder/Api/data_store.dart';
// // // import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
// // // import 'package:gotocarefinder/utils/Custom_widget.dart';
// // // import 'package:http/http.dart' as http;
// // //
// // // class AddPropartiesController extends GetxController implements GetxService {
// // //   ListOfPropertyController listOfPropertiController = Get.find();
// // //
// // //   TextEditingController propertyTitleController = TextEditingController();
// // //   TextEditingController propertyDescriptionController = TextEditingController();
// // //   TextEditingController contactNumberController = TextEditingController();
// // //   TextEditingController propertyPriceController = TextEditingController();
// // //   TextEditingController propertyBedsController = TextEditingController();
// // //   TextEditingController propertyBathroomsController = TextEditingController();
// // //   TextEditingController propertySizeController = TextEditingController();
// // //   TextEditingController propertyCapacityController = TextEditingController();
// // //
// // //   /// Set this after a successful "create advert" API call
// // //   String? createdAdvertId;
// // //
// // //   /// The advert id when editing an existing advert (populate when you load the edit screen)
// // //   String? existingAdvertId;
// // //
// // //   /// Optional: if you collect an email on the form, set it here; otherwise keep null
// // //   String? contactEmail;
// // //   String? path;
// // //   String? base64Image;
// // //
// // //   String countryId = "";
// // //
// // //   String pType = "";
// // //   String pbuySell = "";
// // //   String status = "";
// // //
// // //   String pImage = "";
// // //
// // //   var selectedFacilities = [];
// // //
// // //   var lat;
// // //   var long;
// // //   var propertyAddress;
// // //   var propertyZipCode;
// // //   var propertyCountry;
// // //   var propertyCity;
// // //
// // //   List<String> propertyImagesPaths = [];
// // //   List<String> propertyImagesBase64 = [];
// // //
// // //   bool havePhotos = true;
// // //   DateTime? propertyShootDate;
// // //   String? propertyShootTime;
// // //   TextEditingController propertyShootDateController = TextEditingController();
// // //   void updateTime(String time) {
// // //     propertyShootTime = time;
// // //     update();
// // //   }
// // //
// // //   bool consentToPhotographyTerms = false;
// // //
// // //   String eTitle = "";
// // //   String eNumber = "";
// // //   String eAddress = "";
// // //   String ePrice = "";
// // //   String eTotalBeds = "";
// // //   String eTotalBathroom = "";
// // //   String eSqft = "";
// // //   String eRating = "";
// // //   String eCityAndCountry = "";
// // //   String propId = "";
// // //   String eImage = "";
// // //   String eGest = "";
// // //   String buyOrRent = "";
// // //   String Id = "";
// // //   String pShell = "0";
// // //
// // //   String fList = "";
// // //   String pName = "";
// // //   String countryName = "";
// // //
// // //   var elat;
// // //   var elong;
// // //   var ePropertyAddress = "";
// // //   var ePropertyZipCode = "";
// // //   var ePropertyCountry = "";
// // //   var ePropertyCity = "";
// // //   int? ePropertyCountryId;
// // //
// // //   getEditDetails({
// // //     String? eTitle1,
// // //     eNumber1,
// // //     eAddress1,
// // //     ePrice1,
// // //     ePropertyAddress1,
// // //     eTotalBeds1,
// // //     eTotalBathroom1,
// // //     eSqft1,
// // //     eRating1,
// // //     eCityAndCountry1,
// // //     lat1,
// // //     long1,
// // //     propId1,
// // //     eImage1,
// // //     eGest1,
// // //     ebuyorRent,
// // //     isShell,
// // //     id,
// // //     facelity1,
// // //     pID,
// // //     proName1,
// // //     countryId1,
// // //     countryName1,
// // //   }) {
// // //     eTitle = eTitle1 ?? "";
// // //     eNumber = eNumber1 ?? "";
// // //     eAddress = eAddress1 ?? "";
// // //     ePrice = ePrice1 ?? "";
// // //     ePropertyAddress = ePropertyAddress1 ?? "";
// // //     eTotalBeds = eTotalBeds1 ?? "";
// // //     eTotalBathroom = eTotalBathroom1 ?? "";
// // //     eSqft = eSqft1 ?? "";
// // //     eRating = eRating1 ?? "";
// // //     eCityAndCountry = eCityAndCountry1 ?? "";
// // //     elat = lat1 ?? "";
// // //     elong = long1 ?? "";
// // //     propId = propId1 ?? "";
// // //     eImage = eImage1 ?? "";
// // //     eGest = eGest1 ?? "";
// // //     buyOrRent = ebuyorRent;
// // //     pShell = isShell;
// // //     Id = id;
// // //     fList = facelity1;
// // //     pType = pID;
// // //     pName = proName1;
// // //     countryId = countryId1;
// // //     countryName = countryName1;
// // //     update();
// // //   }
// // //
// // //   getCurrentLatAndLong(double latitude, double longitude) {
// // //     lat = latitude;
// // //     long = longitude;
// // //     update();
// // //   }
// // //
// // //   emptyAllDetails() {
// // //     propertyTitleController.text = "";
// // //     propertyDescriptionController.text = "";
// // //     contactNumberController.text = "";
// // //     propertyPriceController.text = "";
// // //     propertyBedsController.text = "";
// // //     propertyBathroomsController.text = "";
// // //     propertySizeController.text = "";
// // //     propertyCapacityController.text = "";
// // //     path = null;
// // //     base64Image = "";
// // //     pbuySell = "";
// // //     status = "";
// // //     lat = null;
// // //     long = null;
// // //     pImage = "";
// // //     update();
// // //   }
// // //
// // //   addPropertyApi() async {
// // //     String facilities = selectedFacilities.join(",");
// // //     try {
// // //       Map map = {
// // //         "uid": getData.read("UserLogin")["id"],
// // //         "status": status == "" ? "1" : status, // publish 1 /0
// // //         "country_id": "4",
// // //         "pbuysell": pbuySell == "" ? "2" : pbuySell,
// // //         "ptype": pType,
// // //         "title": propertyTitleController.text,
// // //         "description": propertyDescriptionController.text,
// // //         "facilities": facilities,
// // //         "no of beds": propertyBedsController.text,
// // //         "no of bathrooms": propertyBathroomsController.text,
// // //         "property size": propertySizeController.text,
// // //         "property capacity": propertyCapacityController.text,
// // //         "price": propertyPriceController.text,
// // //         "contact number": contactNumberController.text,
// // //         "property address": propertyAddress,
// // //         "property country": propertyCountry,
// // //         "property city": propertyCity,
// // //         "property zipcode": propertyZipCode,
// // //         "latitude": lat.toString(),
// // //         "longitude": long.toString(),
// // //         "have photos": havePhotos ? 1 : 0,
// // //         "property shoot date":
// // //             propertyShootDate != null ? propertyShootDate.toString() : "",
// // //         "property shoot time":
// // //             propertyShootTime != null ? propertyShootTime.toString() : "",
// // //         "property images": propertyImagesBase64,
// // //       };
// // //       print(":::::::::::::::" + map.toString());
// // //       Uri uri = Uri.parse(Config.path + Config.addPropartyApi);
// // //       var response = await http.post(
// // //         uri,
// // //         body: jsonEncode(map),
// // //       );
// // //       if (response.statusCode == 200) {
// // //         var result = jsonDecode(response.body);
// // //         print(result.toString());
// // //         if (result["Result"] == "true") {
// // //           listOfPropertiController.getPropertiList();
// // //           showToastMessage(result["ResponseMsg"]);
// // //           emptyAllDetails();
// // //           Get.back();
// // //         } else {
// // //           showToastMessage(result["ResponseMsg"]);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print(e.toString());
// // //     }
// // //   }
// // //
// // //   editPropertyApi() async {
// // //     try {
// // //       String facilities = selectedFacilities.join(",");
// // //       Map map = {
// // //         "uid": getData.read("UserLogin")["id"],
// // //         "status": status == "" ? "1" : status,
// // //         "property capacity": propertyCapacityController.text,
// // //         "country_id": countryId,
// // //         "pbuysell": pbuySell == "" ? "2" : pbuySell,
// // //         "title": propertyTitleController.text,
// // //         "description": propertyDescriptionController.text,
// // //         "facility": facilities,
// // //         "ptype": pType,
// // //         "beds": propertyBedsController.text,
// // //         "bathroom": propertyBathroomsController.text,
// // //         "sqft": propertySizeController.text,
// // //         "latitude": lat.toString(),
// // //         "longitude": long.toString(),
// // //         "mobile": contactNumberController.text,
// // //         "price": propertyPriceController.text,
// // //         "img": path != null ? base64Image : "0",
// // //         "prop_id": propId,
// // //       };
// // //       print(":::::::::::::::" + map.toString());
// // //       Uri uri = Uri.parse(Config.path + Config.editPropertyApi);
// // //       var response = await http.post(
// // //         uri,
// // //         body: jsonEncode(map),
// // //       );
// // //       if (response.statusCode == 200) {
// // //         var result = jsonDecode(response.body);
// // //         print(result.toString());
// // //         if (result["Result"] == "true") {
// // //           listOfPropertiController.getPropertiList();
// // //           showToastMessage(result["ResponseMsg"]);
// // //           Get.back();
// // //         } else {
// // //           showToastMessage(result["ResponseMsg"]);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       print(e.toString());
// // //     }
// // //   }
// // // }
