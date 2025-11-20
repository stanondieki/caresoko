// To parse this JSON data, do
//
//     final propetydetailsInfo = propetydetailsInfoFromJson(jsonString);

import 'dart:convert';

PropetydetailsInfo propetydetailsInfoFromJson(String str) =>
    PropetydetailsInfo.fromJson(json.decode(str));

String propetydetailsInfoToJson(PropetydetailsInfo data) =>
    json.encode(data.toJson());

class PropetydetailsInfo {
  Propetydetails? propetydetails;
  List<Facility>? facility;
  List<String>? gallery;
  List<Reviewlist>? reviewlist;
  int? totalReview;
  String? responseCode;
  String? result;
  String? responseMsg;

  PropetydetailsInfo({
    this.propetydetails,
    this.facility,
    this.gallery,
    this.reviewlist,
    this.totalReview,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory PropetydetailsInfo.fromJson(Map<String, dynamic> json) =>
      PropetydetailsInfo(
        propetydetails: json["propetydetails"] == null
            ? null
            : Propetydetails.fromJson(json["propetydetails"]),
        facility: json["facility"] == null
            ? []
            : List<Facility>.from(
                json["facility"]!.map((x) => Facility.fromJson(x))),
        gallery: json["gallery"] == null
            ? []
            : List<String>.from(json["gallery"]!.map((x) => x)),
        reviewlist: json["reviewlist"] == null
            ? []
            : List<Reviewlist>.from(
                json["reviewlist"]!.map((x) => Reviewlist.fromJson(x))),
        totalReview: json["total_review"],
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "propetydetails": propetydetails?.toJson(),
        "facility": facility == null
            ? []
            : List<dynamic>.from(facility!.map((x) => x.toJson())),
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "reviewlist": reviewlist == null
            ? []
            : List<dynamic>.from(reviewlist!.map((x) => x.toJson())),
        "total_review": totalReview,
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Facility {
  String? img;
  String? title;

  Facility({
    this.img,
    this.title,
  });

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        img: json["img"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "img": img,
        "title": title,
      };
}

class Propetydetails {
  String? id;
  String? userId;
  String? name;
  String? rate;
  String? city;
  List<Image>? image;
  String? propertyType;
  String? propertyTitle;
  int? isEnquiry;
  String? address;
  String? ownerImage;
  String? ownerName;
  String? description;
  String? latitude;
  String? longtitude;
  String? capacity;
  String? beds;
  int? privateRooms;
  int? sharedRooms;
  int? ownBathrooms;
  int? noOfPrivateRooms;
  int? noOfSharedRooms;
  int? memoryCareClients;
  int? medicaidClients;
  int? hoyerClients;
  int? correctionalClients;
  int? curatedMenus;
  int? medicationReminders;
  String? recreationalActivities;
  int? pricingReady;
  String? pricing;
  String? accreditations;
  String? certifications;
  String? memberships;
  String? specializedCertifications;
  int? backgroundChecks;
  int? drugTesting;
  int? referenceVerification;
  String? licenseNo;
  String? typicalDay;
  String? about;
  String? mission;
  String? vision;
  String? website;
  String? logo;
  int? isFavourite;

  Propetydetails({
    this.id,
    this.userId,
    this.name,
    this.rate,
    this.city,
    this.image,
    this.propertyType,
    this.propertyTitle,
    this.isEnquiry,
    this.address,
    this.ownerImage,
    this.ownerName,
    this.description,
    this.latitude,
    this.longtitude,
    this.capacity,
    this.beds,
    this.privateRooms,
    this.sharedRooms,
    this.ownBathrooms,
    this.noOfPrivateRooms,
    this.noOfSharedRooms,
    this.memoryCareClients,
    this.medicaidClients,
    this.hoyerClients,
    this.correctionalClients,
    this.curatedMenus,
    this.medicationReminders,
    this.recreationalActivities,
    this.pricingReady,
    this.pricing,
    this.accreditations,
    this.certifications,
    this.memberships,
    this.specializedCertifications,
    this.backgroundChecks,
    this.drugTesting,
    this.referenceVerification,
    this.licenseNo,
    this.typicalDay,
    this.about,
    this.mission,
    this.vision,
    this.website,
    this.logo,
    this.isFavourite,
  });

  factory Propetydetails.fromJson(Map<String, dynamic> json) => Propetydetails(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        rate: json["rate"],
        city: json["city"],
        image: json["image"] == null
            ? []
            : List<Image>.from(json["image"]!.map((x) => Image.fromJson(x))),
        propertyType: json["property_type"],
        propertyTitle: json["property_title"],
        isEnquiry: json["is_enquiry"],
        address: json["address"],
        ownerImage: json["owner_image"],
        ownerName: json["owner_name"],
        description: json["description"],
        latitude: json["latitude"],
        longtitude: json["longtitude"],
        capacity: json["capacity"],
        beds: json["beds"],
        privateRooms: json["private_rooms"],
        sharedRooms: json["shared_rooms"],
        ownBathrooms: json["own_bathrooms"],
        noOfPrivateRooms: json["no_of_private_rooms"],
        noOfSharedRooms: json["no_of_shared_rooms"],
        memoryCareClients: json["memory_care_clients"],
        medicaidClients: json["medicaid_clients"],
        hoyerClients: json["hoyer_clients"],
        correctionalClients: json["correctional_clients"],
        curatedMenus: json["curated_menus"],
        medicationReminders: json["medication_reminders"],
        recreationalActivities: json["recreational_activities"],
        pricingReady: json["pricing_ready"],
        pricing: json["pricing"],
        accreditations: json["accreditations"],
        certifications: json["certifications"],
        memberships: json["memberships"],
        specializedCertifications: json["specialized certifications"],
        backgroundChecks: json["background checks"],
        drugTesting: json["drug testing"],
        referenceVerification: json["reference verification"],
        licenseNo: json["license_no"],
        typicalDay: json["typical_day"],
        about: json["about"],
        mission: json["mission"],
        vision: json["vision"],
        website: json["website"],
        logo: json["logo"],
        isFavourite: json["IS_FAVOURITE"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "rate": rate,
        "city": city,
        "image": image == null
            ? []
            : List<dynamic>.from(image!.map((x) => x.toJson())),
        "property_type": propertyType,
        "property_title": propertyTitle,
        "is_enquiry": isEnquiry,
        "address": address,
        "owner_image": ownerImage,
        "owner_name": ownerName,
        "description": description,
        "latitude": latitude,
        "longtitude": longtitude,
        "capacity": capacity,
        "beds": beds,
        "private_rooms": privateRooms,
        "shared_rooms": sharedRooms,
        "own_bathrooms": ownBathrooms,
        "no_of_private_rooms": noOfPrivateRooms,
        "no_of_shared_rooms": noOfSharedRooms,
        "memory_care_clients": memoryCareClients,
        "medicaid_clients": medicaidClients,
        "hoyer_clients": hoyerClients,
        "correctional_clients": correctionalClients,
        "curated_menus": curatedMenus,
        "medication_reminders": medicationReminders,
        "recreational_activities": recreationalActivities,
        "pricing_ready": pricingReady,
        "pricing": pricing,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "background checks": backgroundChecks,
        "drug testing": drugTesting,
        "reference verification": referenceVerification,
        "license_no": licenseNo,
        "typical_day": typicalDay,
        "about": about,
        "mission": mission,
        "vision": vision,
        "website": website,
        "logo": logo,
        "IS_FAVOURITE": isFavourite,
      };
}

HomecareAgencyDetailsInfo homecareAgencyDetailsInfoFromJson(String str) =>
    HomecareAgencyDetailsInfo.fromJson(json.decode(str));

String homecareAgencyDetailsInfoToJson(HomecareAgencyDetailsInfo data) =>
    json.encode(data.toJson());

class HomecareAgencyDetailsInfo {
  HomecareAgencyDetails? homecareAgencyDetails;
  List<String>? gallery;
  List<Reviewlist>? reviewlist;
  int? totalReview;
  String? responseCode;
  String? result;
  String? responseMsg;

  HomecareAgencyDetailsInfo({
    this.homecareAgencyDetails,
    this.gallery,
    this.reviewlist,
    this.totalReview,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory HomecareAgencyDetailsInfo.fromJson(Map<String, dynamic> json) =>
      HomecareAgencyDetailsInfo(
        homecareAgencyDetails: json["homecare agency details"] == null
            ? null
            : HomecareAgencyDetails.fromJson(json["homecare agency details"]),
        gallery: json["gallery"] == null
            ? []
            : List<String>.from(json["gallery"]!.map((x) => x)),
        reviewlist: json["reviewlist"] == null
            ? []
            : List<Reviewlist>.from(
                json["reviewlist"]!.map((x) => Reviewlist.fromJson(x))),
        totalReview: json["total_review"],
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "homecare agency details": homecareAgencyDetails?.toJson(),
        "gallery":
            gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
        "reviewlist": reviewlist == null
            ? []
            : List<dynamic>.from(reviewlist!.map((x) => x.toJson())),
        "total_review": totalReview,
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class HomecareAgencyDetails {
  String? id;
  String? userId;
  String? name;
  List<Image>? image;
  String? propertyType;
  String? propertyTypeTitle;
  int? isEnquiry;
  String? ownerImage;
  String? ownerName;
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
  String? licenseExpiry;
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
  int? isFavourite;

  HomecareAgencyDetails(
      {this.id,
      this.userId,
      this.name,
      this.image,
      this.propertyType,
      this.propertyTypeTitle,
      this.isEnquiry,
      this.ownerName,
      this.ownerImage,
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
      this.licenseExpiry,
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
      this.rate,
      this.isFavourite});

  factory HomecareAgencyDetails.fromJson(Map<String, dynamic> json) =>
      HomecareAgencyDetails(
        id: json["id"],
        userId: json["user_id"],
        name: json["name"],
        image: json["image"] == null
            ? []
            : List<Image>.from(json["image"]!.map((x) => Image.fromJson(x))),
        propertyType: json["property_type"],
        propertyTypeTitle: json["property_type_title"],
        isEnquiry: json["is_enquiry"],
        ownerImage: json["owner_image"],
        ownerName: json["owner_name"],
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
        licenseExpiry: json["license expiry"],
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
        isFavourite: json["IS_FAVOURITE"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "image": image == null
            ? []
            : List<dynamic>.from(image!.map((x) => x.toJson())),
        "property_type": propertyType,
        "property_type_title": propertyTypeTitle,
        "is_enquiry": isEnquiry,
        "owner_image": ownerImage,
        "owner_name": ownerName,
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
        "license expiry": licenseExpiry,
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
        "IS_FAVOURITE": isFavourite
      };
}

class Image {
  String? image;
  String? isPanorama;

  Image({
    this.image,
    this.isPanorama,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        image: json["image"],
        isPanorama: json["is_panorama"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "is_panorama": isPanorama,
      };
}

class Reviewlist {
  dynamic userImg;
  String? userTitle;
  String? userRate;
  String? userDesc;

  Reviewlist({
    this.userImg,
    this.userTitle,
    this.userRate,
    this.userDesc,
  });

  factory Reviewlist.fromJson(Map<String, dynamic> json) => Reviewlist(
        userImg: json["user_img"],
        userTitle: json["user_title"],
        userRate: json["user_rate"],
        userDesc: json["user_desc"],
      );

  Map<String, dynamic> toJson() => {
        "user_img": userImg,
        "user_title": userTitle,
        "user_rate": userRate,
        "user_desc": userDesc,
      };
}
