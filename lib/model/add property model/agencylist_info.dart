// To parse this JSON data, do
//
//     final propListInfo = propListInfoFromJson(jsonString);

import 'dart:convert';

AgencyListInfo propListInfoFromJson(String str) =>
    AgencyListInfo.fromJson(json.decode(str));

String propListInfoToJson(AgencyListInfo data) => json.encode(data.toJson());

class AgencyListInfo {
  List<Agencylist>? agencylist;
  String? responseCode;
  String? result;
  String? responseMsg;

  AgencyListInfo({
    this.agencylist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory AgencyListInfo.fromJson(Map<String, dynamic> json) => AgencyListInfo(
        agencylist: json["agencylist"] == null
            ? []
            : List<Agencylist>.from(
                json["agencylist"]!.map((x) => Agencylist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "agencylist": agencylist == null
            ? []
            : List<dynamic>.from(agencylist!.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Agencylist{
  String? id;
  String? userId;
  String? name;
  String? image;
  String? propertyType;
  String? propertyTypeTitle;
  int? activitiesOfDailyLiving;
  int? mealPreparation;
  int? laundry;
  int? lightHouseKeeping;
  int? mobilityAssistance;
  int? transportation;
  int? memoryCare;
  int? palliativeCare;
  int? chronicConditionManagement;
  int? postHospitalizationCare;
  int? respiteCare;
  String? staffAvailability;
  String? accreditations;
  String? certifications;
  String? memberships;
  String? specializedCertifications;
  String? languages;
  int? weekendCoverage;
  int? holidayCoverage;
  int? pricingReady;
  String? pricing;
  int? privatePay;
  int? insurance;
  int? medicaid;
  String? whyTheyStandOut;
  int? backgroundChecks;
  int? drugTesting;
  int? referenceVerification;
  String? licenseNumber;
  String? about;
  String? mission;
  String? vision;
  String? website;
  String? logo;
  String? agencyAddress;
  String? city;
  String? agencyCountry;
  String? agencyZipcode;
  String? latitude;
  String? longitude;
  String? rate;

  Agencylist(
      {this.id,
      this.userId,
      this.name,
      this.image,
      this.propertyType,
      this.propertyTypeTitle,
      this.activitiesOfDailyLiving,
      this.mealPreparation,
      this.laundry,
      this.lightHouseKeeping,
      this.mobilityAssistance,
      this.transportation,
      this.memoryCare,
      this.palliativeCare,
      this.chronicConditionManagement,
      this.postHospitalizationCare,
      this.respiteCare,
      this.staffAvailability,
      this.accreditations,
      this.certifications,
      this.memberships,
      this.specializedCertifications,
      this.languages,
      this.weekendCoverage,
      this.holidayCoverage,
      this.pricingReady,
      this.pricing,
      this.privatePay,
      this.insurance,
      this.medicaid,
      this.whyTheyStandOut,
      this.backgroundChecks,
      this.drugTesting,
      this.referenceVerification,
      this.licenseNumber,
      this.about,
      this.mission,
      this.vision,
      this.website,
      this.logo,
      this.agencyAddress,
      this.city,
      this.agencyCountry,
      this.agencyZipcode,
      this.latitude,
      this.longitude,
      this.rate,});

  factory Agencylist.fromJson(Map<String, dynamic> json) =>
      Agencylist(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        image: json["image"],
        propertyType: json["property_type"],
        propertyTypeTitle: json["property_type_title"],
        activitiesOfDailyLiving: json["activities of daily living"],
        mealPreparation: json["meal preparation"],
        laundry: json["laundry"],
        lightHouseKeeping: json["light house keeping"],
        mobilityAssistance: json["mobility assistance"],
        transportation: json["transportation"],
        memoryCare: json["memory care"],
        palliativeCare: json["palliative care"],
        chronicConditionManagement: json["chronic condition management"],
        postHospitalizationCare: json["post hospitalization care"],
        respiteCare: json["respite care"],
        staffAvailability: json["staff availability"],
        accreditations: json["accreditations"],
        certifications: json["certifications"],
        memberships: json["memberships"],
        specializedCertifications: json["specialized certifications"],
        languages: json["languages"],
        weekendCoverage: json["weekend coverage"],
        holidayCoverage: json["holiday coverage"],
        pricingReady: json["pricing ready"],
        pricing: json["pricing"],
        privatePay: json["private pay"],
        insurance: json["insurance"],
        medicaid: json["medicaid"],
        whyTheyStandOut: json["why they stand out"],
        backgroundChecks: json["background checks"],
        drugTesting: json["drug testing"],
        referenceVerification: json["reference verification"],
        licenseNumber: json["license number"],
        about: json["about"],
        mission: json["mission"],
        vision: json["vision"],
        website: json["website"],
        logo: json["logo"],
        agencyAddress: json["address"],
        city: json["city"],
        agencyCountry: json["agency country"],
        agencyZipcode: json["agency zipcode"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        rate: json["rate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "image": image,
        "property_type": propertyType,
        "property_type_title": propertyTypeTitle,
        "activities of daily living": activitiesOfDailyLiving,
        "meal preparation": mealPreparation,
        "laundry": laundry,
        "light house keeping": lightHouseKeeping,
        "mobility assistance": mobilityAssistance,
        "transportation": transportation,
        "memory care": memoryCare,
        "palliative care": palliativeCare,
        "chronic condition management": chronicConditionManagement,
        "post hospitalization care": postHospitalizationCare,
        "respite care": respiteCare,
        "staff availability": staffAvailability,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "languages": languages,
        "weekend coverage": weekendCoverage,
        "holiday coverage": holidayCoverage,
        "pricing ready": pricingReady,
        "pricing": pricing,
        "private pay": privatePay,
        "insurance": insurance,
        "medicaid": medicaid,
        "why they stand out": whyTheyStandOut,
        "background checks": backgroundChecks,
        "drug testing": drugTesting,
        "reference verification": referenceVerification,
        "license number": licenseNumber,
        "about": about,
        "mission": mission,
        "vision": vision,
        "website": website,
        "logo": logo,
        "address": agencyAddress,
        "city": city,
        "agency country": agencyCountry,
        "agency zipcode": agencyZipcode,
        "latitude": latitude,
        "longitude": longitude,
        "rate": rate,
      };
}