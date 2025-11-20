// To parse this JSON data, do
//
//     final homeDatatInfo = homeDatatInfoFromJson(jsonString);

import 'dart:convert';

HomeDatatInfo homeDatatInfoFromJson(String str) => HomeDatatInfo.fromJson(json.decode(str));

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
    homeData: json["HomeData"] == null ? null : HomeData.fromJson(json["HomeData"]),
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
  List<Property>? featuredProperty;
  List<Property>? cateWiseProperty;
  String? showAddProperty;

  HomeData({
    this.catlist,
    this.currency,
    this.featuredProperty,
    this.cateWiseProperty,
    this.showAddProperty,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    catlist: json["Catlist"] == null ? [] : List<Catlist>.from(json["Catlist"]!.map((x) => Catlist.fromJson(x))),
    currency: json["currency"],
    featuredProperty: json["Featured_Property"] == null ? [] : List<Property>.from(json["Featured_Property"]!.map((x) => Property.fromJson(x))),
    cateWiseProperty: json["cate_wise_property"] == null ? [] : List<Property>.from(json["cate_wise_property"]!.map((x) => Property.fromJson(x))),
    showAddProperty: json["show_add_property"],
  );

  Map<String, dynamic> toJson() => {
    "Catlist": catlist == null ? [] : List<dynamic>.from(catlist!.map((x) => x.toJson())),
    "currency": currency,
    "Featured_Property": featuredProperty == null ? [] : List<dynamic>.from(featuredProperty!.map((x) => x.toJson())),
    "cate_wise_property": cateWiseProperty == null ? [] : List<dynamic>.from(cateWiseProperty!.map((x) => x.toJson())),
    "show_add_property": showAddProperty,
  };
}

class Property {
  String? id;
  String? title;
  String? buyorrent;
  String? latitude;
  String? longtitude;
  String? capacity;
  String? rate;
  String? city;
  String? propertyType;
  String? beds;
  String? bathrooms;
  String? size;
  String? image;
  String? price;
  int? isFavourite;

  Property({
    this.id,
    this.title,
    this.buyorrent,
    this.latitude,
    this.longtitude,
    this.capacity,
    this.rate,
    this.city,
    this.propertyType,
    this.beds,
    this.bathrooms,
    this.size,
    this.image,
    this.price,
    this.isFavourite,
  });

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json["id"],
    title: json["title"],
    buyorrent: json["buyorrent"],
    latitude: json["latitude"],
    longtitude: json["longtitude"],
    capacity: json["capacity"],
    rate: json["rate"],
    city: json["city"],
    propertyType: json["property_type"],
    beds: json["beds"],
    bathrooms: json["bathrooms"],
    size: json["size"],
    image: json["image"],
    price: json["price"],
    isFavourite: json["IS_FAVOURITE"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "buyorrent": buyorrent,
    "latitude": latitude,
    "longtitude": longtitude,
    "capacity": capacity,
    "rate": rate,
    "city": city,
    "property_type": propertyType,
    "beds": beds,
    "bathrooms": bathrooms,
    "size": size,
    "image": image,
    "price": price,
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
