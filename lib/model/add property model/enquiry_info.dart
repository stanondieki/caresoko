// To parse this JSON data, do
//
//     final enquiryInfo = enquiryInfoFromJson(jsonString);

import 'dart:convert';

EnquiryInfo enquiryInfoFromJson(String str) => EnquiryInfo.fromJson(json.decode(str));

String enquiryInfoToJson(EnquiryInfo data) => json.encode(data.toJson());

class EnquiryInfo {
  String? responseCode;
  String? result;
  String? responseMsg;
  List<EnquiryDatum>? enquiryData;

  EnquiryInfo({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.enquiryData,
  });

  factory EnquiryInfo.fromJson(Map<String, dynamic> json) => EnquiryInfo(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    enquiryData: json["EnquiryData"] == null ? [] : List<EnquiryDatum>.from(json["EnquiryData"]!.map((x) => EnquiryDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "EnquiryData": enquiryData == null ? [] : List<dynamic>.from(enquiryData!.map((x) => x.toJson())),
  };
}

class EnquiryDatum {
  String? title;
  String? image;
  dynamic name;
  String? mobile;
  String? isSell;

  EnquiryDatum({
    this.title,
    this.image,
    this.name,
    this.mobile,
    this.isSell,
  });

  factory EnquiryDatum.fromJson(Map<String, dynamic> json) => EnquiryDatum(
    title: json["title"],
    image: json["image"],
    name: json["name"],
    mobile: json["mobile"],
    isSell: json["is_sell"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "image": image,
    "name": name,
    "mobile": mobile,
    "is_sell": isSell,
  };
}
