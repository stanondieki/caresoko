// To parse this JSON data, do
//
//     final riviewInfo = riviewInfoFromJson(jsonString);

import 'dart:convert';

RiviewInfo riviewInfoFromJson(String str) => RiviewInfo.fromJson(json.decode(str));

String riviewInfoToJson(RiviewInfo data) => json.encode(data.toJson());

class RiviewInfo {
  List<Reviewlist>? reviewlist;
  String? responseCode;
  String? result;
  String? responseMsg;

  RiviewInfo({
    this.reviewlist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory RiviewInfo.fromJson(Map<String, dynamic> json) => RiviewInfo(
    reviewlist: json["reviewlist"] == null ? [] : List<Reviewlist>.from(json["reviewlist"]!.map((x) => Reviewlist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "reviewlist": reviewlist == null ? [] : List<dynamic>.from(reviewlist!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Reviewlist {
  String? totalRate;
  String? rateText;

  Reviewlist({
    this.totalRate,
    this.rateText,
  });

  factory Reviewlist.fromJson(Map<String, dynamic> json) => Reviewlist(
    totalRate: json["total_rate"],
    rateText: json["rate_text"],
  );

  Map<String, dynamic> toJson() => {
    "total_rate": totalRate,
    "rate_text": rateText,
  };
}
