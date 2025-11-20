// To parse this JSON data, do
//
//     final earningInfo = earningInfoFromJson(jsonString);

import 'dart:convert';

EarningInfo earningInfoFromJson(String str) => EarningInfo.fromJson(json.decode(str));

String earningInfoToJson(EarningInfo data) => json.encode(data.toJson());

class EarningInfo {
  List<Statuswise>? statuswise;
  String? responseCode;
  String? result;
  String? responseMsg;

  EarningInfo({
    this.statuswise,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory EarningInfo.fromJson(Map<String, dynamic> json) => EarningInfo(
    statuswise: json["statuswise"] == null ? [] : List<Statuswise>.from(json["statuswise"]!.map((x) => Statuswise.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "statuswise": statuswise == null ? [] : List<dynamic>.from(statuswise!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Statuswise {
  String? bookId;
  String? propId;
  String? propImg;
  String? propTitle;
  String? pMethodId;
  String? propPrice;
  String? totalDay;
  String? rate;
  String? bookStatus;

  Statuswise({
    this.bookId,
    this.propId,
    this.propImg,
    this.propTitle,
    this.pMethodId,
    this.propPrice,
    this.totalDay,
    this.rate,
    this.bookStatus,
  });

  factory Statuswise.fromJson(Map<String, dynamic> json) => Statuswise(
    bookId: json["book_id"],
    propId: json["prop_id"],
    propImg: json["prop_img"],
    propTitle: json["prop_title"],
    pMethodId: json["p_method_id"],
    propPrice: json["prop_price"],
    totalDay: json["total_day"],
    rate: json["rate"],
    bookStatus: json["book_status"],
  );

  Map<String, dynamic> toJson() => {
    "book_id": bookId,
    "prop_id": propId,
    "prop_img": propImg,
    "prop_title": propTitle,
    "p_method_id": pMethodId,
    "prop_price": propPrice,
    "total_day": totalDay,
    "rate": rate,
    "book_status": bookStatus,
  };
}
