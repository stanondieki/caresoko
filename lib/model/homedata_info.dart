// To parse this JSON data, do
//
//     final homeDatatInfo = homeDatatInfoFromJson(jsonString);

import 'dart:convert';

HomeDatatInfo homeDatatInfoFromJson(String str) =>
    HomeDatatInfo.fromJson(json.decode(str));

String homeDatatInfoToJson(HomeDatatInfo data) => json.encode(data.toJson());

class HomeDatatInfo {
  String? responseCode;
  String? result;
  String? responseMsg;
  HomeData? homeData;

  HomeDatatInfo({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.homeData,
  });

  factory HomeDatatInfo.fromJson(Map<String, dynamic> json) => HomeDatatInfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        homeData: json["HomeData"] == null
            ? null
            : HomeData.fromJson(json["HomeData"]),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "HomeData": homeData?.toJson(),
      };
}

class HomeData {
  List<Catlist>? catlist;
  String? currency;
  String? wallet;
  List<Property>? featuredProperty;
  List<Property>? cateWiseProperty;
  String? showAddProperty;

  HomeData({
    this.catlist,
    this.currency,
    this.wallet,
    this.featuredProperty,
    this.cateWiseProperty,
    this.showAddProperty,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
        catlist: json["Catlist"] == null
            ? []
            : List<Catlist>.from(
                json["Catlist"]!.map((x) => Catlist.fromJson(x))),
        currency: json["currency"],
        wallet: json["wallet"],
        featuredProperty: json["Featured_Property"] == null
            ? []
            : List<Property>.from(
                json["Featured_Property"]!.map((x) => Property.fromJson(x))),
        cateWiseProperty: json["cate_wise_property"] == null
            ? []
            : List<Property>.from(
                json["cate_wise_property"]!.map((x) => Property.fromJson(x))),
        showAddProperty: json["show_add_property"],
      );

  Map<String, dynamic> toJson() => {
        "Catlist": catlist == null
            ? []
            : List<dynamic>.from(catlist!.map((x) => x.toJson())),
        "currency": currency,
        "wallet": wallet,
        "Featured_Property": featuredProperty == null
            ? []
            : List<dynamic>.from(featuredProperty!.map((x) => x.toJson())),
        "cate_wise_property": cateWiseProperty == null
            ? []
            : List<dynamic>.from(cateWiseProperty!.map((x) => x.toJson())),
        "show_add_property": showAddProperty,
      };
}

class Property {
  String? id;
  String? name;
  String? latitude;
  String? longtitude;
  String? capacity;
  String? beds;
  String? zipcode;
  String? rate;
  String? city;
  String? propertyType;
  String? propertyTypeTitle;
  int? privateRooms;
  int? sharedRooms;
  String? image;
  String? pricing;
  int? isFavourite;

  Property({
    this.id,
    this.name,
    this.latitude,
    this.longtitude,
    this.capacity,
    this.beds,
    this.zipcode,
    this.rate,
    this.city,
    this.propertyType,
    this.propertyTypeTitle,
    this.privateRooms,
    this.sharedRooms,
    this.image,
    this.pricing,
    this.isFavourite,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
        id: json["id"],
        name: json["name"],
        latitude: json["latitude"],
        longtitude: json["longtitude"],
        capacity: json["capacity"],
        beds: json["beds"],
        zipcode: json["zipcode"],
        rate: json["rate"],
        city: json["city"],
        propertyType: json["property_type"],
        propertyTypeTitle: json["property_type_title"],
        privateRooms: json["private_rooms"],
        sharedRooms: json["shared_rooms"],
        image: json["image"],
        pricing: json["pricing"],
        isFavourite: json["IS_FAVOURITE"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longtitude": longtitude,
        "capacity": capacity,
        "zipcode": zipcode,
        "rate": rate,
        "city": city,
        "property_type": propertyType,
        "private_rooms": privateRooms,
        "shared_rooms": sharedRooms,
        "image": image,
        "pricing": pricing,
        "IS_FAVOURITE": isFavourite,
      };
}

class Catlist {
  String? id;
  String? title;
  String? img;
  String? status;

  Catlist({
    this.id,
    this.title,
    this.img,
    this.status,
  });

  factory Catlist.fromJson(Map<String, dynamic> json) => Catlist(
        id: json["id"],
        title: json["title"],
        img: json["img"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img": img,
        "status": status,
      };
}
