// To parse this JSON data, do
//
//     final galleryCatInfo = galleryCatInfoFromJson(jsonString);

import 'dart:convert';

GalleryCatInfo galleryCatInfoFromJson(String str) =>
    GalleryCatInfo.fromJson(json.decode(str));

String galleryCatInfoToJson(GalleryCatInfo data) => json.encode(data.toJson());

class GalleryCatInfo {
  GalleryCatInfo({
    required this.galcatlist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  List<Galcatlist> galcatlist;
  String responseCode;
  String result;
  String responseMsg;

  factory GalleryCatInfo.fromJson(Map<String, dynamic> json) => GalleryCatInfo(
        galcatlist: List<Galcatlist>.from(
            json["galcatlist"].map((x) => Galcatlist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "galcatlist": List<dynamic>.from(galcatlist.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Galcatlist {
  Galcatlist({
    required this.id,
    required this.catTitle,
    required this.propertyTitle,
    required this.propertyId,
    required this.status,
  });

  String id;
  String catTitle;
  String propertyTitle;
  String propertyId;
  String status;

  factory Galcatlist.fromJson(Map<String, dynamic> json) => Galcatlist(
        id: json["id"],
        catTitle: json["cat_title"],
        propertyTitle: json["property_title"],
        propertyId: json["property_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cat_title": catTitle,
        "property_title": propertyTitle,
        "property_id": propertyId,
        "status": status,
      };
}
