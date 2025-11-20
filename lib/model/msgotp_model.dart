// To parse this JSON data, do
//
//     final msgotpModel = msgotpModelFromJson(jsonString);

import 'dart:convert';

MsgotpModel msgotpModelFromJson(String str) => MsgotpModel.fromJson(json.decode(str));

String msgotpModelToJson(MsgotpModel data) => json.encode(data.toJson());

class MsgotpModel {
  String? responseCode;
  String? result;
  String? responseMsg;
  int? otp;

  MsgotpModel({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.otp,
  });

  factory MsgotpModel.fromJson(Map<String, dynamic> json) => MsgotpModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "otp": otp,
  };
}
