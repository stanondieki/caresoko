// To parse this JSON data, do
//
//     final extraListInfo = extraListInfoFromJson(jsonString);

import 'dart:convert';

ExtraListInfo extraListInfoFromJson(String str) => ExtraListInfo.fromJson(json.decode(str));

String extraListInfoToJson(ExtraListInfo data) => json.encode(data.toJson());

class ExtraListInfo {
  List<Extralist>? extralist;
  String? responseCode;
  String? result;
  String? responseMsg;

  ExtraListInfo({
    this.extralist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory ExtraListInfo.fromJson(Map<String, dynamic> json) => ExtraListInfo(
    extralist: json["extralist"] == null ? [] : List<Extralist>.from(json["extralist"]!.map((x) => Extralist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "extralist": extralist == null ? [] : List<dynamic>.from(extralist!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Extralist {
  String? id;
  String? propertyTitle;
  String? propertyId;
  String? image;
  String? status;

  Extralist({
    this.id,
    this.propertyTitle,
    this.propertyId,
    this.image,
    this.status,
  });

  factory Extralist.fromJson(Map<String, dynamic> json) => Extralist(
    id: json["id"],
    propertyTitle: json["property_title"],
    propertyId: json["property_id"],
    image: json["image"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "property_title": propertyTitle,
    "property_id": propertyId,
    "image": image,
    "status": status,
  };
}
