// To parse this JSON data, do
//
//     final subDetailsInfo = subDetailsInfoFromJson(jsonString);

import 'dart:convert';

SubDetailsInfo subDetailsInfoFromJson(String str) => SubDetailsInfo.fromJson(json.decode(str));

String subDetailsInfoToJson(SubDetailsInfo data) => json.encode(data.toJson());

class SubDetailsInfo {
  List<Subscribedetail>? subscribedetails;
  int? isSubscribe;
  String? responseCode;
  String? result;
  String? responseMsg;

  SubDetailsInfo({
    this.subscribedetails,
    this.isSubscribe,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory SubDetailsInfo.fromJson(Map<String, dynamic> json) => SubDetailsInfo(
    subscribedetails: json["Subscribedetails"] == null ? [] : List<Subscribedetail>.from(json["Subscribedetails"]!.map((x) => Subscribedetail.fromJson(x))),
    isSubscribe: json["is_subscribe"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "Subscribedetails": subscribedetails == null ? [] : List<dynamic>.from(subscribedetails!.map((x) => x.toJson())),
    "is_subscribe": isSubscribe,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Subscribedetail {
  String? id;
  String? uid;
  String? planId;
  String? pName;
  DateTime? tDate;
  String? amount;
  String? day;
  String? planTitle;
  String? planDescription;
  DateTime? expireDate;
  DateTime? startDate;
  String? transId;
  String? planImage;

  Subscribedetail({
    this.id,
    this.uid,
    this.planId,
    this.pName,
    this.tDate,
    this.amount,
    this.day,
    this.planTitle,
    this.planDescription,
    this.expireDate,
    this.startDate,
    this.transId,
    this.planImage,
  });

  factory Subscribedetail.fromJson(Map<String, dynamic> json) => Subscribedetail(
    id: json["id"],
    uid: json["uid"],
    planId: json["plan_id"],
    pName: json["p_name"],
    tDate: json["t_date"] == null ? null : DateTime.parse(json["t_date"]),
    amount: json["amount"],
    day: json["day"],
    planTitle: json["plan_title"],
    planDescription: json["plan_description"],
    expireDate: json["expire_date"] == null ? null : DateTime.parse(json["expire_date"]),
    startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    transId: json["trans_id"],
    planImage: json["plan_image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "uid": uid,
    "plan_id": planId,
    "p_name": pName,
    "t_date": tDate?.toIso8601String(),
    "amount": amount,
    "day": day,
    "plan_title": planTitle,
    "plan_description": planDescription,
    "expire_date": "${expireDate!.year.toString().padLeft(4, '0')}-${expireDate!.month.toString().padLeft(2, '0')}-${expireDate!.day.toString().padLeft(2, '0')}",
    "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "trans_id": transId,
    "plan_image": planImage,
  };
}
