// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/controller/search_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;
import 'package:gotocarefinder/model/routes_helper.dart';

class AddPropertiesController extends GetxController implements GetxService {
  ListOfPropertiController listOfPropertiController = Get.find();
  DashBoardController dashBoardController = Get.find();
  HomePageController homePageController = Get.find();
  SelectCountryController selectCountryController = Get.find();
  SearchPropertyController searchController = Get.find();

  List<String> selectedAccreditations = [];
  List<String> allAccreditations = [
    "Joint Commission Accreditation (JCAHO)",
    "Accreditation Commission for Health Care (ACHC)",
    "Community Health Accreditation Partner (CHAP)",
    "National Association for Home Care & Hospice (NAHC) Accreditation",
    "Commission on Accreditation of Rehabilitation Facilities (CARF)",
    "State Department of Health AFH Licensing",
    "National Alliance for Caregiving (NAC) Accreditation"
  ];

  List<String> selectedCertifications = [];
  List<String> allCertifications = [
    "Certified Nursing Assistant (CNA)",
    "Registered Nurse (RN)",
    "Licensed Practical Nurse (LPN)",
    "Home Care Aide (HCA) Certification",
    "Basic Life Support (BLS) Certification",
    "CPR and First Aid Certification",
    "Certified Dementia Practitioner (CDP)",
    "Certified Senior Advisor (CSA)",
    "Certified Hospice and Palliative Nurse (CHPN)",
    "Advanced Cardiovascular Life Support (ACLS) Certification",
    "Medication Aide Certification (MA-C)",
    "Adult Family Home Administrator Training Certification"
  ];

  List<String> selectedMemberships = [];
  List<String> professionalMemberships = [
    "National Association for Home Care & Hospice (NAHC)",
    "Home Care Association of America (HCAOA)",
    "American Nurses Association (ANA)",
    "American Association for Homecare (AAHomecare)",
    "National Hospice and Palliative Care Organization (NHPCO)",
    "American Academy of Home Care Medicine (AAHCM)",
    "National Private Duty Association (NPDA)",
    "Washington State Residential Care Council (WSRCC) – For Washington-based AFHs",
    "National Adult Family Home Association (NAFHA)",
    "State-Specific AFH Associations (varies by state)"
  ];

  List<String> selectedSpecializedCertifications = [];
  List<String> specializedCertifications = [
    "Alzheimer's Disease and Dementia Care Training Certification",
    "Geriatric Care Manager Certification",
    "Palliative Care Certification",
    "Fall Prevention Specialist Certification",
    "Infection Control Certification",
    "Behavioral Health & Mental Health Certification",
    "End-of-Life Care Certification",
    "Trauma-Informed Care Certification",
    "Chronic Disease Management Certification"
  ];

  bool backgroundChecks = true;
  bool drugTesting = true;
  bool referenceVerification = true;

  String? path;
  String? base64Image;

  String photosBeingAdded = "Dining Areas";

  List<String> propertyImagesPaths = [];
  List<String> propertyImagesBase64 = [];

  List<String> diningImagesPaths = [];
  List<String> diningImagesBase64 = [];

  List<String> bedroomsImagesPaths = [];
  List<String> bedroomsImagesBase64 = [];

  List<String> commonLivingImagesPaths = [];
  List<String> commonLivingImagesBase64 = [];

  List<String> recreationalSpacesImagesPaths = [];
  List<String> recreationalSpacesImagesBase64 = [];

  List<String> outdoorImagesPaths = [];
  List<String> outdoorImagesBase64 = [];

  List<String> accessibleFacilitiesImagesPaths = [];
  List<String> accessibleFacilitiesImagesBase64 = [];

  List<String> staffQuartersImagesPaths = [];
  List<String> staffQuartersImagesBase64 = [];

  List<String> othersImagesPaths = [];
  List<String> othersImagesBase64 = [];

  String? logoPath;
  String? logoBase64Image;

  String countryId = "";

  String pType = "";
  String pbuySell = "";
  String status = "";

  String pImage = "";

  var selectedFeaturesIndexes = [];
  var selectedRecreationalFacilities = [];

  var lat;
  var long;
  var propertyAddress;
  var propertyZipCode;
  var propertyCountry;
  var propertyCity;

  String propertyType = "Adult Family Home",
      propertyTitle = "",
      propertyDescription = "",
      propertyPricing = "",
      propertyLicenseNo = "",
      propertyTypicalDay = "Not entered",
      propertyAbout = "",
      propertyMission = "",
      propertyVision = "",
      propertyWebsite = "";

  int propertyCapacity = 0,
      propertyBeds = 0,
      noOfPrivateRooms = 0,
      noOfSharedRooms = 0;

  bool havePhotos = true;
  DateTime? propertyShootDate;
  String? propertyShootTime;
  TextEditingController propertyShootDateController = TextEditingController();
  void updateTime(String time) {
    propertyShootTime = time;
    update();
  }

  bool consentToPhotographyTerms = false;

  bool haveWebsite = true;
  int websiteIntention = 1; //One = Build, Two = Revamp
  DateTime? websiteCallDate;
  String? websiteCalTime;
  TextEditingController websiteCallDateController = TextEditingController();
  void updateWebsiteTime(String time) {
    websiteCalTime = time;
    update();
  }

  bool consentToWebsiteTerms = false;

  bool privateRoomsHaveOwnBathroom = true;
  bool privateRoomsAvailable = true;
  bool sharedRoomsAvailable = true;
  bool acceptMemoryCareClients = true;
  bool acceptMedicaidClients = true;
  bool acceptHoyerClients = true;
  bool acceptCorrectionalClients = true;
  bool provideCuratedMenus = true;
  bool provideMedicationReminders = true;
  bool pricingReady = true;

  TextEditingController propertyTitleController = TextEditingController(),
      propertyDescriptionController = TextEditingController(),
      propertyLicenseNoController = TextEditingController(),
      propertyPricingController = TextEditingController(),
      propertyTypicalDayController = TextEditingController(),
      propertyAboutController = TextEditingController(),
      propertyMissionController = TextEditingController(),
      propertyVisionController = TextEditingController(),
      propertyWebsiteController = TextEditingController(),
      propertyCapacityController = TextEditingController(),
      propertyBedsController = TextEditingController(),
      noOfPrivateRoomsController = TextEditingController(),
      noOfSharedRoomsController = TextEditingController();

  /*String eTitle = "";
  String eNumber = "";
  String eAddress = "";
  String ePrice = "";
  String ePropertyAddress = "";
  String eTotalBeds = "";
  String eTotalBathroom = "";
  String eSqft = "";
  String eRating = "";
  String eCityAndCountry = "";
  String propId = "";
  String eImage = "";
  String eGest = "";
  String Id = "";
  String pShell = "0";*/

  String ePropertyId = "";
  String fList = "";
  String pName = "";
  String countryName = "";

  String? eLogo = "";
  String? eLogoPath = "";
  String? eLogoBase64Image = "";

  int? ePTypeId;
  String? eStatus = "";

  String? ePImage = "";

  var elat;
  var elong;
  var ePropertyAddress = "";
  var ePropertyZipCode = "";
  var ePropertyCountry = "";
  var ePropertyCity = "";
  int? ePropertyCountryId;

  String? ePropertyType = "",
      ePropertyName = "",
      ePropertyDescription = "",
      ePropertyLicenseNo = "",
      ePropertyTypicalDay = "Not entered",
      ePropertyAbout = "",
      ePropertyMission = "",
      ePropertyVision = "",
      ePropertyWebsite = "";

  int? ePropertyCapacity = 0,
      ePropertyBeds = 0,
      eNoOfPrivateRooms = 0,
      eNoOfSharedRooms = 0;

  bool? ePrivateRoomsHaveOwnBathroom = true;
  bool? ePrivateRoomsAvailable = true;
  bool? eSharedRoomsAvailable = true;
  bool? eAcceptMemoryCareClients = true;
  bool? eAcceptMedicaidClients = true;
  bool? eAcceptHoyerClients = true;
  bool? eAcceptCorrectionalClients = true;
  bool? eProvideCuratedMenus = true;
  bool? eProvideMedicationReminders = true;
  bool? ePricingReady = true;
  String? ePropertyPricing = "";
  String? eRecreationalActivities;

  String? eCertifications = "";
  String? eSpecializedCertifications = "";
  String? eAccreditations = "";
  String? eMemberships = "";
  bool? eBackgroundChecks = true;
  bool? eDrugTesting = true;
  bool? eReferenceVerification = true;

  bool? eLogoUpdated = false;

  getEditDetails(
      {String ePropertyId1 = "",
      String? eLogo1 = "",
      int? ePTypeId1,
      String? ePropertyType1 = "",
      String? eStatus1 = "",
      String? ePImage1 = "",
      var elat1,
      var elong1,
      var ePropertyAddress1 = "",
      var ePropertyZipCode1 = "",
      var ePropertyCountry1 = "",
      var ePropertyCity1 = "",
      int? ePropertyCountryId1,
      String? ePropertyName1 = "",
      String? ePropertyDescription1 = "",
      String? ePropertyLicenseNo1 = "",
      String? ePropertyTypicalDay1 = "Not entered",
      String? ePropertyAbout1 = "",
      String? ePropertyMission1 = "",
      String? ePropertyVision1 = "",
      String? ePropertyWebsite1 = "",
      String? facility1 = "",
      int? ePropertyCapacity1 = 0,
      int? ePropertyBeds1 = 0,
      int? eNoOfPrivateRooms1 = 0,
      int? eNoOfSharedRooms1 = 0,
      bool? ePrivateRoomsHaveOwnBathroom1 = true,
      bool? ePrivateRoomsAvailable1 = true,
      bool? eSharedRoomsAvailable1 = true,
      bool? eAcceptMemoryCareClients1 = true,
      bool? eAcceptMedicaidClients1 = true,
      bool? eAcceptHoyerClients1 = true,
      bool? eAcceptCorrectionalClients1 = true,
      bool? eProvideCuratedMenus1 = true,
      bool? eProvideMedicationReminders1 = true,
      bool? ePricingReady1 = true,
      String? ePropertyPricing1 = "",
      String? eRecreationalActivities1,
      String? eCertifications1 = "",
      String? eSpecializedCertifications1 = "",
      String? eAccreditations1 = "",
      String? eMemberships1 = "",
      bool? eBackgroundChecks1 = true,
      bool? eDrugTesting1 = true,
      bool? eReferenceVerification1 = true}) {
    ePropertyId = ePropertyId1;
    eLogo = eLogo1;
    ePTypeId = ePTypeId1;
    ePropertyType = ePropertyType1;
    eStatus = eStatus1;
    ePImage = ePImage1;
    elat = elat1;
    elong = elong1;
    ePropertyAddress = ePropertyAddress1;
    ePropertyZipCode = ePropertyZipCode1;
    ePropertyCountry = ePropertyCountry1;
    ePropertyCity = ePropertyCity1;
    ePropertyCountryId = ePropertyCountryId1;
    ePropertyName = ePropertyName1;
    ePropertyDescription = ePropertyDescription1;
    ePropertyLicenseNo = ePropertyLicenseNo1;
    ePropertyTypicalDay = ePropertyTypicalDay1;
    ePropertyAbout = ePropertyAbout1;
    ePropertyMission = ePropertyMission1;
    ePropertyVision = ePropertyVision1;
    ePropertyWebsite = ePropertyWebsite1;
    fList = facility1!;
    ePropertyCapacity = ePropertyCapacity1;
    ePropertyBeds = ePropertyBeds1;
    eNoOfPrivateRooms = eNoOfPrivateRooms1;
    eNoOfSharedRooms = eNoOfSharedRooms1;
    ePrivateRoomsHaveOwnBathroom = ePrivateRoomsHaveOwnBathroom1;
    ePrivateRoomsAvailable = ePrivateRoomsAvailable1;
    eSharedRoomsAvailable = eSharedRoomsAvailable1;
    eAcceptMemoryCareClients = eAcceptMemoryCareClients1;
    eAcceptMedicaidClients = eAcceptMedicaidClients1;
    eAcceptHoyerClients = eAcceptHoyerClients1;
    eAcceptCorrectionalClients = eAcceptCorrectionalClients1;
    eProvideCuratedMenus = eProvideCuratedMenus1;
    eProvideMedicationReminders = eProvideMedicationReminders1;
    ePricingReady1 = ePricingReady;
    ePropertyPricing = ePropertyPricing1;
    eRecreationalActivities = eRecreationalActivities1;
    eCertifications = eCertifications1;
    eSpecializedCertifications = eSpecializedCertifications1;
    eAccreditations = eAccreditations1;
    eMemberships = eMemberships1;
    eBackgroundChecks = eBackgroundChecks1;
    eDrugTesting = eDrugTesting1;
    eReferenceVerification = eReferenceVerification1;
    update();
  }

  getCurrentLatAndLong(double latitude, double longitude) {
    lat = latitude;
    long = longitude;
    update();
  }

  emptyAllDetails() {
    propertyTitleController.text = "";
    propertyDescriptionController.text = "";
    propertyCapacityController.text = "";
    propertyBedsController.text = "";
    noOfPrivateRoomsController.text = "";
    noOfSharedRoomsController.text = "";
    propertyPricingController.text = "";
    propertyLicenseNoController.text = "";
    propertyTypicalDayController.text = "";
    propertyAboutController.text = "";
    propertyMissionController.text = "";
    propertyVisionController.text = "";
    propertyWebsiteController.text = "";

    path = null;
    base64Image = "";
    logoPath = null;
    logoBase64Image = "";
    lat = null;
    long = null;
    propertyAddress = null;
    propertyZipCode = null;
    propertyCountry = null;

    selectedFeaturesIndexes.clear();
    selectedRecreationalFacilities.clear();

    pImage = "";

    propertyImagesPaths = [];
    propertyImagesBase64 = [];

    diningImagesPaths = [];
    diningImagesBase64 = [];

    bedroomsImagesPaths = [];
    bedroomsImagesBase64 = [];

    commonLivingImagesPaths = [];
    commonLivingImagesBase64 = [];

    recreationalSpacesImagesPaths = [];
    recreationalSpacesImagesBase64 = [];

    outdoorImagesPaths = [];
    outdoorImagesBase64 = [];

    accessibleFacilitiesImagesPaths = [];
    accessibleFacilitiesImagesBase64 = [];

    staffQuartersImagesPaths = [];
    staffQuartersImagesBase64 = [];

    othersImagesPaths = [];
    othersImagesBase64 = [];

    update();
  }

  addPropertyApi() async {
    String accreditations = selectedAccreditations.join(",");
    String certifications = selectedCertifications.join(",");
    String memberships = selectedMemberships.join(",");
    String specializedCertifications =
        selectedSpecializedCertifications.join(",");
    String selectedFeatures = selectedFeaturesIndexes.join(",");
    String recreationalActivities = selectedRecreationalFacilities.join(",");
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "status": "1", // publish 1 /0
        "country_id": "4" /*countryId*/,
        "property type": pType,
        "property name": propertyTitle,
        "property description": propertyDescription,
        "property capacity": propertyCapacity,
        "property beds": propertyBeds,
        "private rooms": privateRoomsAvailable ? 1 : 0,
        "no of private rooms": noOfPrivateRooms,
        "own bathrooms": privateRoomsHaveOwnBathroom ? 1 : 0,
        "shared rooms": sharedRoomsAvailable ? 1 : 0,
        "no of shared rooms": noOfSharedRooms,
        "property features": selectedFeatures,
        "memory care clients": acceptMemoryCareClients ? 1 : 0,
        "medicaid clients": acceptMedicaidClients ? 1 : 0,
        "hoyer clients": acceptHoyerClients ? 1 : 0,
        "correctional clients": acceptCorrectionalClients ? 1 : 0,
        "curated menus": provideCuratedMenus ? 1 : 0,
        "medication reminders": provideMedicationReminders ? 1 : 0,
        "recreational activities": recreationalActivities,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "background checks": backgroundChecks ? 1 : 0,
        "drug testing": drugTesting ? 1 : 0,
        "reference verification": referenceVerification ? 1 : 0,
        "pricing ready": pricingReady ? 1 : 0,
        "pricing": propertyPricing,
        "license number": propertyLicenseNo,
        "typical day": propertyTypicalDay,
        "about": propertyAboutController.text,
        "mission": propertyMissionController.text,
        "vision": propertyVisionController.text,
        "website": propertyWebsiteController.text.isNotEmpty
            ? propertyWebsiteController.text
            : "None",
        "logo": logoBase64Image,
        "property address": propertyAddress,
        "property country": propertyCountry,
        "property city": propertyCity,
        "property zipcode": propertyZipCode,
        "latitude": lat.toString(),
        "longitude": long.toString(),
        "have photos": havePhotos ? 1 : 0,
        "property shoot date":
            propertyShootDate != null ? propertyShootDate.toString() : "",
        "property shoot time":
            propertyShootTime != null ? propertyShootTime.toString() : "",
        "property images": propertyImagesBase64,
      };

      print(":::::::::::::::" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.addPropertyApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          //listOfPropertiController.getPropertiList();
          print("PROPERTY ADDITION RESULT -> ${result["ResponseMsg"]}");
          showToastMessage(result["ResponseMsg"]);
          emptyAllDetails();
          homePageController.getCatWiseData(
              countryId: getData.read("countryId"), cId: "0");
          searchController.getSearchData(countryId: getData.read("countryId"));
          homePageController
              .getHomeDataApi(countryId: getData.read("countryId"))
              .then(
            (value) {
              Get.offAndToNamed(Routes.bottoBarScreen);
            },
          );
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  editPropertyApi() async {
    try {
      String selectedFeatures = selectedFeaturesIndexes.join(",");
      String recreationalActivities = selectedRecreationalFacilities.join(",");

      String accreditations = selectedAccreditations.join(",");
      String certifications = selectedCertifications.join(",");
      String memberships = selectedMemberships.join(",");
      String specializedCertifications =
          selectedSpecializedCertifications.join(",");

      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "status": "1", // publish 1 /0
        "country_id": "4" /*countryId*/,
        "property type": ePTypeId.toString(),
        "property name": propertyTitle,
        "property description": propertyDescription,
        "property capacity": propertyCapacity,
        "property beds": propertyBeds,
        "private rooms": privateRoomsAvailable ? 1 : 0,
        "no of private rooms": noOfPrivateRooms,
        "own bathrooms": privateRoomsHaveOwnBathroom ? 1 : 0,
        "shared rooms": sharedRoomsAvailable ? 1 : 0,
        "no of shared rooms": noOfSharedRooms,
        "property features": selectedFeatures,
        "memory care clients": acceptMemoryCareClients ? 1 : 0,
        "medicaid clients": acceptMedicaidClients ? 1 : 0,
        "hoyer clients": acceptHoyerClients ? 1 : 0,
        "correctional clients": acceptCorrectionalClients ? 1 : 0,
        "curated menus": provideCuratedMenus ? 1 : 0,
        "medication reminders": provideMedicationReminders ? 1 : 0,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "background checks": backgroundChecks ? 1 : 0,
        "drug testing": drugTesting ? 1 : 0,
        "reference verification": referenceVerification ? 1 : 0,
        "recreational activities": recreationalActivities,
        "pricing ready": pricingReady ? 1 : 0,
        "pricing": propertyPricing,
        "license number": propertyLicenseNo,
        "typical day": propertyTypicalDay,
        "about": propertyAboutController.text,
        "mission": propertyMissionController.text,
        "vision": propertyVisionController.text,
        "website": propertyWebsiteController.text.isNotEmpty
            ? propertyWebsiteController.text
            : "None",
        "logo": eLogoUpdated! ? logoBase64Image : "0",
        "property address": ePropertyAddress,
        "property country": ePropertyCountry,
        "property zipcode": ePropertyZipCode,
        "property city": ePropertyCity,
        "latitude": elat.toString(),
        "longitude": eNoOfSharedRooms.toString(),
        "prop_id": ePropertyId
      };
      print(":::::::::::::::" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.editPropertyApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          showToastMessage(result["ResponseMsg"]);
          listOfPropertiController.getPropertiList();
          homePageController.getCatWiseData(
              countryId: getData.read("countryId"), cId: "0");
          searchController.getSearchData(countryId: getData.read("countryId"));
          homePageController
              .getHomeDataApi(countryId: getData.read("countryId"))
              .then(
            (value) {
              Get.offAndToNamed(Routes.bottoBarScreen);
            },
          );
        } else {
          showToastMessage(result["ResponseMsg"]);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
