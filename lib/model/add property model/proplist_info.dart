// To parse this JSON data, do
//
//     final propListInfo = propListInfoFromJson(jsonString);

import 'dart:convert';

PropListInfo propListInfoFromJson(String str) =>
    PropListInfo.fromJson(json.decode(str));

String propListInfoToJson(PropListInfo data) => json.encode(data.toJson());

class PropListInfo {
  List<Proplist>? proplist;
  String? responseCode;
  String? result;
  String? responseMsg;

  PropListInfo({
    this.proplist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory PropListInfo.fromJson(Map<String, dynamic> json) => PropListInfo(
        proplist: json["proplist"] == null
            ? []
            : List<Proplist>.from(
                json["proplist"]!.map((x) => Proplist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "proplist": proplist == null
            ? []
            : List<dynamic>.from(proplist!.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Proplist {
  String? id;
  String? name;
  String? propertyType;
  String? propertyTypeId;
  String? image;
  String? countryId;
  String? countryTitle;
  String? pricing;
  String? capacity;
  String? facilitySelect;
  String? status;
  String? latitude;
  String? longtitude;
  String? city;
  String? rate;
  String? description;
  String? address;

  String? logo;
  String? zipCode;

  String? licenseNo, typicalDay, about, mission, vision, website;

  int? beds, noOfPrivateRooms, noOfSharedRooms;

  bool? privateRoomsHaveOwnBathroom;
  bool? privateRoomsAvailable;
  bool? sharedRoomsAvailable;
  bool? acceptMemoryCareClients;
  bool? acceptMedicaidClients;
  bool? acceptHoyerClients;
  bool? acceptCorrectionalClients;
  bool? provideCuratedMenus;
  bool? provideMedicationReminders;
  bool? pricingReady;

  String? accreditations;
  String? certifications;
  String? memberships;
  String? specializedCertifications;

  int? backgroundChecks;
  int? drugTesting;
  int? referenceVerification;

  String? recreationalActivities;

  Proplist(
      {this.id,
      this.name,
      this.propertyType,
      this.propertyTypeId,
      this.image,
      this.countryId,
      this.countryTitle,
      this.pricing,
      this.capacity,
      this.facilitySelect,
      this.status,
      this.latitude,
      this.longtitude,
      this.city,
      this.rate,
      this.description,
      this.address,
      this.logo,
      this.zipCode,
      this.licenseNo,
      this.typicalDay,
      this.about,
      this.mission,
      this.vision,
      this.website,
      this.beds,
      this.noOfPrivateRooms,
      this.noOfSharedRooms,
      this.privateRoomsHaveOwnBathroom,
      this.privateRoomsAvailable,
      this.sharedRoomsAvailable,
      this.acceptMemoryCareClients,
      this.acceptMedicaidClients,
      this.acceptHoyerClients,
      this.acceptCorrectionalClients,
      this.provideCuratedMenus,
      this.provideMedicationReminders,
      this.pricingReady,
      this.accreditations,
      this.certifications,
      this.memberships,
      this.specializedCertifications,
      this.backgroundChecks,
      this.drugTesting,
      this.referenceVerification,
      this.recreationalActivities});

  factory Proplist.fromJson(Map<String, dynamic> json) => Proplist(
        id: json["id"],
        name: json["name"],
        propertyType: json["property_type"],
        propertyTypeId: json["property_type_id"],
        image: json["image"],
        countryId: json["country_id"],
        countryTitle: json["country_title"],
        pricing: json["pricing"],
        capacity: json["capacity"],
        facilitySelect: json["facility_select"],
        accreditations: json["accreditations"],
        certifications: json["certifications"],
        memberships: json["memberships"],
        specializedCertifications: json["specialized certifications"],
        backgroundChecks: json["background checks"],
        drugTesting: json["drug testing"],
        referenceVerification: json["reference verification"],
        recreationalActivities: json["recreational_activities"],
        status: json["status"],
        latitude: json["latitude"],
        longtitude: json["longtitude"],
        city: json["city"],
        rate: json["rate"],
        description: json["description"],
        address: json["address"],
        logo: json["logo"],
        zipCode: json["zipcode"],
        licenseNo: json["license_no"],
        typicalDay: json["typical_day"],
        about: json["about"],
        mission: json["mission"],
        vision: json["vision"],
        website: json["website"],
        beds: int.parse(json["beds"]),
        noOfPrivateRooms: int.parse(json["no_of_private_rooms"]),
        noOfSharedRooms: int.parse(json["no_of_shared_rooms"]),
        privateRoomsHaveOwnBathroom: json["own_bathrooms"] == "1",
        privateRoomsAvailable: json["private_rooms_available"] == "1",
        sharedRoomsAvailable: json["shared_rooms_available"] == "1",
        acceptMemoryCareClients: json["accept_memory_care_clients"] == "1",
        acceptMedicaidClients: json["accept_medicaid_clients"] == "1",
        acceptHoyerClients: json["accept_hoyer_clients"] == "1",
        acceptCorrectionalClients: json["accept_correctional_clients"] == "1",
        provideCuratedMenus: json["provide_curated_menus"] == "1",
        provideMedicationReminders: json["provide_medication_reminders"] == "1",
        pricingReady: json["pricing_ready"] == "1",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "property_type": propertyType,
        "property_type_id": propertyTypeId,
        "image": image,
        "country_id": countryId,
        "country_title": countryTitle,
        "pricing": pricing,
        "capacity": capacity,
        "facility_select": facilitySelect,
        "status": status,
        "latitude": latitude,
        "longtitude": longtitude,
        "city": city,
        "rate": rate,
        "description": description,
        "address": address,
        "logo": logo,
        "zipcode": zipCode,
        "license_no": licenseNo,
        "typical_day": typicalDay,
        "about": about,
        "mission": mission,
        "vision": vision,
        "website": website,
        "beds": beds,
        "no_of_private_rooms": noOfPrivateRooms,
        "no_of_shared_rooms": noOfSharedRooms,
        "own_bathrooms": privateRoomsHaveOwnBathroom,
        "private_rooms_available": privateRoomsAvailable,
        "shared_rooms_available": sharedRoomsAvailable,
        "accept_memory_care_clients": acceptMemoryCareClients,
        "accept_medicaid_clients": acceptMedicaidClients,
        "accept_hoyer_clients": acceptHoyerClients,
        "accept_correctional_clients": acceptCorrectionalClients,
        "provide_curated_menus": provideCuratedMenus,
        "provide_medication_reminders": provideMedicationReminders,
        "pricing_ready": pricingReady,
        "accreditations": accreditations,
        "certifications": certifications,
        "memberships": memberships,
        "specialized certifications": specializedCertifications,
        "background checks": backgroundChecks,
        "drug testing": drugTesting,
        "reference verification": referenceVerification,
        "recreational activities": recreationalActivities
      };
}
