// To parse this JSON data, do
//
//     final paymentInfo = paymentInfoFromJson(jsonString);

import 'dart:convert';

PaymentInfo paymentInfoFromJson(String str) => PaymentInfo.fromJson(json.decode(str));

String paymentInfoToJson(PaymentInfo data) => json.encode(data.toJson());

class PaymentInfo {
  List<Paymentdatum>? paymentdata;
  String? responseCode;
  String? result;
  String? responseMsg;

  PaymentInfo({
    this.paymentdata,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) => PaymentInfo(
    paymentdata: json["paymentdata"] == null ? [] : List<Paymentdatum>.from(json["paymentdata"]!.map((x) => Paymentdatum.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "paymentdata": paymentdata == null ? [] : List<dynamic>.from(paymentdata!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Paymentdatum {
  String? id;
  String? title;
  String? img;
  String? attributes;
  String? status;
  String? subtitle;
  String? pShow;
  String? sShow;

  Paymentdatum({
    this.id,
    this.title,
    this.img,
    this.attributes,
    this.status,
    this.subtitle,
    this.pShow,
    this.sShow,
  });

  factory Paymentdatum.fromJson(Map<String, dynamic> json) => Paymentdatum(
    id: json["id"],
    title: json["title"],
    img: json["img"],
    attributes: json["attributes"],
    status: json["status"],
    subtitle: json["subtitle"],
    pShow: json["p_show"],
    sShow: json["s_show"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img": img,
    "attributes": attributes,
    "status": status,
    "subtitle": subtitle,
    "p_show": pShow,
    "s_show": sShow,
  };
}
