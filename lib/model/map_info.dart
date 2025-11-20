// To parse this JSON data, do
//
//     final mapInfo = mapInfoFromJson(jsonString);

import 'dart:convert';

MapInfo mapInfoFromJson(String str) => MapInfo.fromJson(json.decode(str));

String mapInfoToJson(MapInfo data) => json.encode(data.toJson());

class MapInfo {
  String id;
  String title;
  String buyorrent;
  String latitude;
  String longtitude;
  String plimit;
  String rate;
  String city;
  String propertyType;
  String image;
  String price;
  int isFavourite;

  MapInfo({
    required this.id,
    required this.title,
    required this.buyorrent,
    required this.latitude,
    required this.longtitude,
    required this.plimit,
    required this.rate,
    required this.city,
    required this.propertyType,
    required this.image,
    required this.price,
    required this.isFavourite,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) => MapInfo(
        id: json["id"],
        title: json["title"],
        buyorrent: json["buyorrent"],
        latitude: json["latitude"],
        longtitude: json["longtitude"],
        plimit: json["plimit"],
        rate: json["rate"],
        city: json["city"],
        propertyType: json["property_type"],
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
        "plimit": plimit,
        "rate": rate,
        "city": city,
        "property_type": propertyType,
        "image": image,
        "price": price,
        "IS_FAVOURITE": isFavourite,
      };
}
