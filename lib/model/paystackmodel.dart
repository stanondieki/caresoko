// To parse this JSON data, do
//
//     final paystackModel = paystackModelFromJson(jsonString);

import 'dart:convert';

PaystackModel paystackModelFromJson(String str) => PaystackModel.fromJson(json.decode(str));

String paystackModelToJson(PaystackModel data) => json.encode(data.toJson());

class PaystackModel {
  bool? status;
  String? message;
  Data? data;

  PaystackModel({
    this.status,
    this.message,
    this.data,
  });

  factory PaystackModel.fromJson(Map<String, dynamic> json) => PaystackModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String? authorizationUrl;
  String? accessCode;
  String? reference;

  Data({
    this.authorizationUrl,
    this.accessCode,
    this.reference,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    authorizationUrl: json["authorization_url"],
    accessCode: json["access_code"],
    reference: json["reference"],
  );

  Map<String, dynamic> toJson() => {
    "authorization_url": authorizationUrl,
    "access_code": accessCode,
    "reference": reference,
  };
}
