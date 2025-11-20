// To parse this JSON data, do
//
//     final searchInfo = searchInfoFromJson(jsonString);

import 'dart:convert';

SearchInfo searchInfoFromJson(String str) =>
    SearchInfo.fromJson(json.decode(str));

String searchInfoToJson(SearchInfo data) => json.encode(data.toJson());

class SearchInfo {
  SearchInfo({
    required this.id,
    required this.name,
    required this.rate,
    required this.capacity,
    required this.city,
    required this.image,
    required this.propertyType,
    required this.propertyTypeTitle,
    required this.price,
    required this.isFavourite,
  });

  String id;
  String name;
  String rate;
  String capacity;
  String city;
  String image;
  String propertyType;
  String propertyTypeTitle;
  String price;
  int isFavourite;

  factory SearchInfo.fromJson(Map<String, dynamic> json) => SearchInfo(
        id: json["id"],
        name: json["name"],
        rate: json["rate"],
        capacity: json["capacity"],
        city: json["city"],
        image: json["image"],
        propertyType: json["property_type"],
        propertyTypeTitle: json["property_type_title"],
        price: json["price"],
        isFavourite: json["IS_FAVOURITE"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "rate": rate,
        "capacity": capacity,
        "city": city,
        "image": image,
        "property_type": propertyType,
        "property_type_title": propertyTypeTitle,
        "price": price,
        "IS_FAVOURITE": isFavourite,
      };
}
