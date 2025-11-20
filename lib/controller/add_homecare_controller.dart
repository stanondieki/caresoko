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

class AddHomecareController extends GetxController implements GetxService {
  ListOfPropertiController listOfPropertiController = Get.find();
  DashBoardController dashBoardController = Get.find();
  HomePageController homePageController = Get.find();
  SelectCountryController selectCountryController = Get.find();
  SearchPropertyController searchController = Get.find();

  String? path;
  String? base64Image;

  //////////////////////

  List<String> agencyImagesPaths = [];
  List<String> agencyImagesBase64 = [];

  String? agencyName;

  var lat;
  var long;
  var agencyAddress;
  var agencyZipCode;
  var agencyCountry;
  var agencyCity;

  List<String> selectedAccreditations = [];
  List<String> allAccreditations = [
    "Joint Commission Accreditation (JCAHO)",
    "Accreditation Commission for Health Care (ACHC)",
    "Community Health Accreditation Partner (CHAP)",
    "National Association for Home Care & Hospice (NAHC) Accreditation",
    "Commission on Accreditation of Rehabilitation Facilities (CARF)"
  ];

  List<String> selectedCertifications = [];
  List<String> allCertifications = [
    "Certified Nursing Assistant (CNA)",
    "Registered Nurse (RN)",
    "Licensed Practical Nurse (LPN)",
    "Home Health Aide Certification (HHA)",
    "Basic Life Support (BLS) Certification",
    "CPR and First Aid Certification",
    "Certified Dementia Practitioner (CDP)",
    "Certified Senior Advisor (CSA)",
    "Certified Hospice and Palliative Nurse (CHPN)",
    "Advanced Cardiovascular Life Support (ACLS) Certification"
  ];

  List<String> selectedMemberships = [];
  List<String> professionalMemberships = [
    "National Association for Home Care & Hospice (NAHC)",
    "Home Care Association of America (HCAOA)",
    "American Nurses Association (ANA)",
    "American Association for Homecare (AAHomecare)",
    "National Hospice and Palliative Care Organization (NHPCO)",
    "American Academy of Home Care Medicine (AAHCM)",
    "National Private Duty Association (NPDA)"
  ];

  List<String> selectedSpecializedCertifications = [];
  List<String> specializedCertifications = [
    "Alzheimer's Disease and Dementia Care Training Certification",
    "Geriatric Care Manager Certification",
    "Palliative Care Certification",
    "Fall Prevention Specialist Certification",
    "Infection Control Certification"
  ];

  bool activitiesOfDailyLiving = true;
  bool mealPreparation = true;
  bool laundry = true;
  bool lightHousekeeping = true;
  bool mobilityAssistance = true;
  bool transportation = true;

  bool memoryCare = true;
  bool palliativeCare = true;
  bool chronicConditionManagement = true;
  bool postHospitalizationCare = true;
  bool respiteCare = true;

  List<String> selectedLanguages = [];
  List<String> languagesSpoken = ["English", "Spanish", "French", "German"];

  List<String> staffAvailability = [];

  bool weekendCoverage = true;
  bool holidayCoverage = true;

  bool petFriendly = true;

  bool readyPricing = true;
  String? pricing;
  bool privatePay = true;
  bool insurance = true;
  bool medicaid = true;

  String? agencyLicenseNo = "";

  String? whyTheyStandOut;

  bool backgroundChecks = true;
  bool drugTesting = true;
  bool referenceVerification = true;

  String agencyAbout = "",
      agencyMission = "",
      agencyVision = "",
      agencyWebsite = "";

  TextEditingController agencyNameController = TextEditingController(),
      agencyLicenseNoController = TextEditingController(),
      agencyLicenseExpiryController = TextEditingController(),
      agencyPricingController = TextEditingController(),
      whyTheyStandOutController = TextEditingController(),
      agencyAboutController = TextEditingController(),
      agencyMissionController = TextEditingController(),
      agencyVisionController = TextEditingController(),
      agencyWebsiteController = TextEditingController();

  //////////////////////

  String? logoPath;
  String? logoBase64Image;

  String countryId = "";

  String pType = "";
  String pbuySell = "";
  String status = "";

  String pImage = "";

  var selectedFeaturesIndexes = [];
  var selectedRecreationalFacilities = [];

  int propertyCapacity = 0,
      propertyBeds = 0,
      noOfPrivateRooms = 0,
      noOfSharedRooms = 0;

  bool havePhotos = true;
  DateTime? agencyShootDate;
  String? agencyShootTime;
  TextEditingController propertyShootDateController = TextEditingController();
  void updateTime(String time) {
    agencyShootTime = time;
    update();
  }

  bool consentToPhotographyTerms = false;

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
      propertyLicenseExpiryController = TextEditingController(),
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

  //Editing

  String eAgencyId = "";
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

  DateTime? ePropertyLicenseExpiry;

  int? ePropertyCapacity = 0,
      ePropertyBeds = 0,
      eNoOfPrivateRooms = 0,
      eNoOfSharedRooms = 0;

  bool? ePrivateRoomsHaveOwnBathroom = true;
  bool? ePrivateRoomsAvailable = true;
  bool? eSharedRoomsAvailable = true;
  bool? eAcceptMedicaidClients = true;
  bool? eAcceptHoyerClients = true;
  bool? eAcceptCorrectionalClients = true;
  bool? eProvideCuratedMenus = true;
  bool? eProvideMedicationReminders = true;
  bool? ePricingReady = true;
  String? ePropertyPricing = "";
  String? eRecreationalActivities;

  bool? eActivitiesOfDailyLiving = true;
  bool? eMealPreparation = true;
  bool? eLaundry = true;
  bool? eLightHousekeeping = true;
  bool? eMobilityAssistance = true;
  bool? eTransportation = true;

  bool? eMemoryCare = true;
  bool? ePalliativeCare = true;
  bool? eChronicConditionManagement = true;
  bool? ePostHospitalizationCare = true;
  bool? eRespiteCare = true;

  String? eStaffAvailability = "";
  bool? eWeekendCoverage = true;
  bool? eHolidayCoverage = true;

  String? eCertifications = "";
  String? eSpecializedCertifications = "";
  String? eAccreditations = "";
  String? eMemberships = "";
  bool? eBackgroundChecks = true;
  bool? eDrugTesting = true;
  bool? eReferenceVerification = true;

  bool? eReadyPricing = true;
  String? ePricing;
  bool? ePrivatePay = true;
  bool? eInsurance = true;
  bool? eMedicaid = true;

  String? eLanguages = "";
  String? eWhyTheyStandOut = "";

  String? eAgencyAbout = "",
      eAgencyMission = "",
      eAgencyVision = "",
      eAgencyWebsite = "";

  String? eAgencyLicenseNo = "";

  bool? eLogoUpdated = false;

  getEditDetails({
    String eAgencyId1 = "",
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
    int? ePropertyCountryId1,
    String? ePropertyName1 = "",
    String? ePropertyDescription1 = "",
    String? ePropertyLicenseNo1 = "",
    String? ePropertyTypicalDay1 = "Not entered",
    String? ePropertyAbout1 = "",
    String? ePropertyMission1 = "",
    String? ePropertyVision1 = "",
    String? ePropertyWebsite1 = "",
    DateTime? ePropertyLicenseExpiry1,
    String? facility1 = "",
    int? ePropertyCapacity1 = 0,
    int? ePropertyBeds1 = 0,
    int? eNoOfPrivateRooms1 = 0,
    int? eNoOfSharedRooms1 = 0,
    bool? ePrivateRoomsHaveOwnBathroom1 = true,
    bool? ePrivateRoomsAvailable1 = true,
    bool? eSharedRoomsAvailable1 = true,
    bool? eAcceptMedicaidClients1 = true,
    bool? eAcceptHoyerClients1 = true,
    bool? eAcceptCorrectionalClients1 = true,
    bool? eProvideCuratedMenus1 = true,
    bool? eProvideMedicationReminders1 = true,
    bool? ePricingReady1 = true,
    String? ePropertyPricing1 = "",
    String? eRecreationalActivities1,
    bool? eActivitiesOfDailyLiving1 = true,
    bool? eMealPreparation1 = true,
    bool? eLaundry1 = true,
    bool? eLightHousekeeping1 = true,
    bool? eMobilityAssistance1 = true,
    bool? eTransportation1 = true,
    bool? eMemoryCare1 = true,
    bool? ePalliativeCare1 = true,
    bool? eChronicConditionManagement1 = true,
    bool? ePostHospitalizationCare1 = true,
    bool? eRespiteCare1 = true,
    String? eStaffAvailability1 = "",
    bool? eWeekendCoverage1 = true,
    bool? eHolidayCoverage1 = true,
    String? eCertifications1 = "",
    String? eSpecializedCertifications1 = "",
    String? eAccreditations1 = "",
    String? eMemberships1 = "",
    bool? eBackgroundChecks1 = true,
    bool? eDrugTesting1 = true,
    bool? eReferenceVerification1 = true,
    bool? eReadyPricing1 = true,
    String? ePricing1 = "",
    bool? ePrivatePay1 = true,
    bool? eInsurance1 = true,
    bool? eMedicaid1 = true,
    String? eAgencyLicenseNo1 = "",
    String? eLanguages1 = "",
    String? eWhyTheyStandOut1 = "",
    String? eAgencyAbout1 = "",
    String? eAgencyMission1 = "",
    String? eAgencyVision1 = "",
    String? eAgencyWebsite1 = "",
  }) {
    eAgencyId = eAgencyId1;
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
    ePropertyCountryId = ePropertyCountryId1;
    ePropertyName = ePropertyName1;
    ePropertyDescription = ePropertyDescription1;
    ePropertyLicenseNo = ePropertyLicenseNo1;
    ePropertyTypicalDay = ePropertyTypicalDay1;
    ePropertyAbout = ePropertyAbout1;
    ePropertyMission = ePropertyMission1;
    ePropertyVision = ePropertyVision1;
    ePropertyWebsite = ePropertyWebsite1;
    ePropertyLicenseExpiry = ePropertyLicenseExpiry1;
    fList = facility1!;
    ePropertyCapacity = ePropertyCapacity1;
    ePropertyBeds = ePropertyBeds1;
    eNoOfPrivateRooms = eNoOfPrivateRooms1;
    eNoOfSharedRooms = eNoOfSharedRooms1;
    ePrivateRoomsHaveOwnBathroom = ePrivateRoomsHaveOwnBathroom1;
    ePrivateRoomsAvailable = ePrivateRoomsAvailable1;
    eSharedRoomsAvailable = eSharedRoomsAvailable1;
    eAcceptMedicaidClients = eAcceptMedicaidClients1;
    eAcceptHoyerClients = eAcceptHoyerClients1;
    eAcceptCorrectionalClients = eAcceptCorrectionalClients1;
    eProvideCuratedMenus = eProvideCuratedMenus1;
    eProvideMedicationReminders = eProvideMedicationReminders1;
    ePricingReady1 = ePricingReady;
    ePropertyPricing = ePropertyPricing1;
    eRecreationalActivities = eRecreationalActivities1;
    eActivitiesOfDailyLiving = eActivitiesOfDailyLiving1;
    eMealPreparation = eMealPreparation1;
    eLaundry = eLaundry1;
    eLightHousekeeping = eLightHousekeeping1;
    eMobilityAssistance = eMobilityAssistance1;
    eTransportation = eTransportation1;
    eMemoryCare = eMemoryCare1;
    ePalliativeCare = ePalliativeCare1;
    eChronicConditionManagement = eChronicConditionManagement1;
    ePostHospitalizationCare = ePostHospitalizationCare1;
    eRespiteCare = eRespiteCare1;
    eStaffAvailability = eStaffAvailability1;
    eWeekendCoverage = eWeekendCoverage1;
    eHolidayCoverage = eHolidayCoverage1;
    eCertifications = eCertifications1;
    eSpecializedCertifications = eSpecializedCertifications1;
    eAccreditations = eAccreditations1;
    eMemberships = eMemberships1;
    eBackgroundChecks = eBackgroundChecks1;
    eDrugTesting = eDrugTesting1;
    eReferenceVerification = eReferenceVerification1;
    eReadyPricing = eReadyPricing1;
    ePricing = ePricing1;
    ePrivatePay = ePrivatePay1;
    eInsurance = eInsurance1;
    eMedicaid = eMedicaid1;
    eAgencyLicenseNo = eAgencyLicenseNo1;
    eLanguages = eLanguages1;
    eWhyTheyStandOut = eWhyTheyStandOut1;
    eAgencyAbout = eAgencyAbout1;
    eAgencyMission = eAgencyMission1;
    eAgencyVision = eAgencyVision1;
    eAgencyWebsite = eAgencyWebsite1;
    update();
  }

  getCurrentLatAndLong(double latitude, double longitude) {
    lat = latitude;
    long = longitude;
    update();
  }

  emptyAllDetails() {
    agencyNameController.text = "";
    agencyLicenseNoController.text = "";
    agencyLicenseExpiryController.text = "";
    agencyPricingController.text = "";
    whyTheyStandOutController.text = "";
    agencyAboutController.text = "";
    agencyMissionController.text = "";
    agencyVisionController.text = "";
    agencyWebsiteController.text = "";

    path = null;
    base64Image = "";
    logoPath = null;
    logoBase64Image = "";
    lat = null;
    long = null;
    agencyAddress = null;
    agencyZipCode = null;
    agencyCountry = null;

    selectedFeaturesIndexes.clear();
    selectedRecreationalFacilities.clear();

    pImage = "";

    update();
  }

  addHomecareApi() async {
    String accreditations = selectedAccreditations.join(",");
    String certifications = selectedCertifications.join(",");
    String memberships = selectedMemberships.join(",");
    String specializedCertifications =
        selectedSpecializedCertifications.join(",");
    String languages = selectedLanguages.join(",");
    String selectedStaffAvailability = staffAvailability.join(",");

    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "status": "1", // publish 1 /0
        "country_id": "4" /*countryId*/,
        "property type": "3",
        "agency name": agencyName,
        "activities of daily living": activitiesOfDailyLiving ? 1 : 0,
        "meal preparation": mealPreparation ? 1 : 0,
        "laundry": laundry ? 1 : 0,
        "light house keeping": lightHousekeeping ? 1 : 0,
        "mobility assistance": mobilityAssistance ? 1 : 0,
        "transportation": transportation ? 1 : 0,
        "memory care": memoryCare ? 1 : 0,
        "palliative care": palliativeCare ? 1 : 0,
        "chronic condition management": chronicConditionManagement ? 1 : 0,
        "post hospitalization care": postHospitalizationCare ? 1 : 0,
        "respite care": respiteCare ? 1 : 0,
        "staff availability": selectedStaffAvailability,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "languages": languages,
        "weekend coverage": weekendCoverage ? 1 : 0,
        "holiday coverage": holidayCoverage ? 1 : 0,
        "pricing ready": readyPricing ? 1 : 0,
        "pricing": pricing,
        "private pay": privatePay ? 1 : 0,
        "insurance": insurance ? 1 : 0,
        "medicaid": medicaid ? 1 : 0,
        "why they stand out": whyTheyStandOut,
        "background checks": backgroundChecks ? 1 : 0,
        "drug testing": drugTesting ? 1 : 0,
        "reference verification": referenceVerification ? 1 : 0,
        "license number": agencyLicenseNo,
        "about": agencyAboutController.text,
        "mission": agencyMissionController.text,
        "vision": agencyVisionController.text,
        "website": agencyWebsiteController.text.isNotEmpty
            ? agencyWebsiteController.text
            : "None",
        "logo": logoBase64Image,
        "agency address": agencyAddress,
        "agency country": agencyCountry,
        "agency city": agencyCity,
        "agency zipcode": agencyZipCode,
        "latitude": lat.toString(),
        "longitude": long.toString(),
        "have photos": havePhotos ? 1 : 0,
        "agency shoot date":
            agencyShootDate != null ? agencyShootDate.toString() : "",
        "agency shoot time":
            agencyShootTime != null ? agencyShootTime.toString() : "",
        "agency images": agencyImagesBase64,
      };

      print(":::::::::::::::" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.addHomecareApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          print("HOMECARE AGENCY ADDITION RESULT -> ${result["ResponseMsg"]}");
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

  editHomecareApi() async {
    try {
      String accreditations = selectedAccreditations.join(",");
      String certifications = selectedCertifications.join(",");
      String memberships = selectedMemberships.join(",");
      String specializedCertifications =
          selectedSpecializedCertifications.join(",");
      String languages = selectedLanguages.join(",");
      String selectedStaffAvailability = staffAvailability.join(",");

      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "status": "1", // publish 1 /0
        "country_id": "4" /*countryId*/,
        "agency name": agencyName,
        "activities of daily living": activitiesOfDailyLiving ? 1 : 0,
        "meal preparation": mealPreparation ? 1 : 0,
        "laundry": laundry ? 1 : 0,
        "light house keeping": lightHousekeeping ? 1 : 0,
        "mobility assistance": mobilityAssistance ? 1 : 0,
        "transportation": transportation ? 1 : 0,
        "memory care": memoryCare ? 1 : 0,
        "palliative care": palliativeCare ? 1 : 0,
        "chronic condition management": chronicConditionManagement ? 1 : 0,
        "post hospitalization care": postHospitalizationCare ? 1 : 0,
        "respite care": respiteCare ? 1 : 0,
        "staff availability": selectedStaffAvailability,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "languages": languages,
        "weekend coverage": weekendCoverage ? 1 : 0,
        "holiday coverage": holidayCoverage ? 1 : 0,
        "pricing ready": readyPricing ? 1 : 0,
        "pricing": pricing,
        "private pay": privatePay ? 1 : 0,
        "insurance": insurance ? 1 : 0,
        "medicaid": medicaid ? 1 : 0,
        "why they stand out": whyTheyStandOut,
        "background checks": backgroundChecks ? 1 : 0,
        "drug testing": drugTesting ? 1 : 0,
        "reference verification": referenceVerification ? 1 : 0,
        "license number": agencyLicenseNo,
        "about": agencyAboutController.text,
        "mission": agencyMissionController.text,
        "vision": agencyVisionController.text,
        "website": agencyWebsiteController.text.isNotEmpty
            ? agencyWebsiteController.text
            : "None",
        "logo": eLogoUpdated! ? logoBase64Image : "0",
        "agency address": agencyAddress,
        "agency country": agencyCountry,
        "agency city": agencyCity,
        "agency zipcode": agencyZipCode,
        "latitude": lat.toString(),
        "longitude": long.toString(),
        "agency id": eAgencyId,
      };

      print(":::::::::::::::" + map.toString());
      Uri uri = Uri.parse(Config.path + Config.editAgencyApi);
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
