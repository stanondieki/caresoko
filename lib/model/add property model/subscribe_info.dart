// To parse this JSON data, do
//
//     final subscribeInfo = subscribeInfoFromJson(jsonString);

import 'dart:convert';

SubscribeInfo subscribeInfoFromJson(String str) => SubscribeInfo.fromJson(json.decode(str));

String subscribeInfoToJson(SubscribeInfo data) => json.encode(data.toJson());

class SubscribeInfo {
  String? responseCode;
  String? result;
  String? responseMsg;
  List<PackageDatum>? packageData;
  int? isSubscribe;

  SubscribeInfo({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.packageData,
    this.isSubscribe,
  });

  factory SubscribeInfo.fromJson(Map<String, dynamic> json) => SubscribeInfo(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    packageData: json["PackageData"] == null ? [] : List<PackageDatum>.from(json["PackageData"]!.map((x) => PackageDatum.fromJson(x))),
    isSubscribe: json["is_subscribe"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "PackageData": packageData == null ? [] : List<dynamic>.from(packageData!.map((x) => x.toJson())),
    "is_subscribe": isSubscribe,
  };
}

class PackageDatum {
  String? id;
  String? title;
  String? image;
  String? description;
  String? status;
  String? day;
  String? price;

  PackageDatum({
    this.id,
    this.title,
    this.image,
    this.description,
    this.status,
    this.day,
    this.price,
  });

  factory PackageDatum.fromJson(Map<String, dynamic> json) => PackageDatum(
    id: json["id"],
    title: json["title"],
    image: json["image"],
    description: json["description"],
    status: json["status"],
    day: json["day"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image": image,
    "description": description,
    "status": status,
    "day": day,
    "price": price,
  };
}
