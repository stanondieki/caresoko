// To parse this JSON data, do
//
//     final statusWiseBookInfo = statusWiseBookInfoFromJson(jsonString);

import 'dart:convert';

StatusWiseBookInfo statusWiseBookInfoFromJson(String str) =>
    StatusWiseBookInfo.fromJson(json.decode(str));

String statusWiseBookInfoToJson(StatusWiseBookInfo data) =>
    json.encode(data.toJson());

class StatusWiseBookInfo {
  List<Statuswise>? statuswise;
  String? responseCode;
  String? result;
  String? responseMsg;

  StatusWiseBookInfo({
    this.statuswise,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory StatusWiseBookInfo.fromJson(Map<String, dynamic> json) =>
      StatusWiseBookInfo(
        statuswise: json["statuswise"] == null
            ? []
            : List<Statuswise>.from(
                json["statuswise"]!.map((x) => Statuswise.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "statuswise": statuswise == null
            ? []
            : List<dynamic>.from(statuswise!.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Statuswise {
  String? bookId;
  String? propId;
  String? propImg;
  String? address;
  String? propTitle;
  String? bookStatus;
  String? propType;
  String? totalRate;

  Statuswise({
    this.bookId,
    this.propId,
    this.propImg,
    this.address,
    this.propTitle,
    this.bookStatus,
    this.propType,
    this.totalRate,
  });

  factory Statuswise.fromJson(Map<String, dynamic> json) => Statuswise(
        bookId: json["book_id"],
        propId: json["prop_id"],
        propImg: json["prop_img"],
        address: json["address"],
        propTitle: json["prop_title"],
        bookStatus: json["book_status"],
        propType: json["prop_type"],
        totalRate: json["total_rate"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "prop_id": propId,
        "prop_img": propImg,
        "address": address,
        "prop_title": propTitle,
        "book_status": bookStatus,
        "prop_type": propType,
        "total_rate": totalRate,
      };
}
