// To parse this JSON data, do
//
//     final facilityInfo = facilityInfoFromJson(jsonString);

import 'dart:convert';

FacilityInfo facilityInfoFromJson(String str) => FacilityInfo.fromJson(json.decode(str));

String facilityInfoToJson(FacilityInfo data) => json.encode(data.toJson());

class FacilityInfo {
  List<Facilitylist>? facilitylist;
  String? responseCode;
  String? result;
  String? responseMsg;

  FacilityInfo({
    this.facilitylist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory FacilityInfo.fromJson(Map<String, dynamic> json) => FacilityInfo(
    facilitylist: json["facilitylist"] == null ? [] : List<Facilitylist>.from(json["facilitylist"]!.map((x) => Facilitylist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "facilitylist": facilitylist == null ? [] : List<dynamic>.from(facilitylist!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Facilitylist {
  String? id;
  String? title;
  String? img;

  Facilitylist({
    this.id,
    this.title,
    this.img,
  });

  factory Facilitylist.fromJson(Map<String, dynamic> json) => Facilitylist(
    id: json["id"],
    title: json["title"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img": img,
  };
}
