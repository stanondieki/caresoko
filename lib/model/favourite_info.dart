// To parse this JSON data, do
//
//     final favouriteInfo = favouriteInfoFromJson(jsonString);

import 'dart:convert';

FavouriteInfo favouriteInfoFromJson(String str) =>
    FavouriteInfo.fromJson(json.decode(str));

String favouriteInfoToJson(FavouriteInfo data) => json.encode(data.toJson());

class FavouriteInfo {
  List<Propetylist>? propetylist;
  String? responseCode;
  String? result;
  String? responseMsg;

  FavouriteInfo({
    this.propetylist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory FavouriteInfo.fromJson(Map<String, dynamic> json) => FavouriteInfo(
        propetylist: json["propetylist"] == null
            ? []
            : List<Propetylist>.from(
                json["propetylist"]!.map((x) => Propetylist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "propetylist": propetylist == null
            ? []
            : List<dynamic>.from(propetylist!.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Propetylist {
  String? id;
  String? name;
  String? rate;
  String? city;
  String? capacity;
  String? propertyType;
  String? propertyTypeTitle;
  String? image;
  String? price;
  int? isFavourite;

  Propetylist({
    this.id,
    this.name,
    this.rate,
    this.city,
    this.capacity,
    this.propertyType,
    this.propertyTypeTitle,
    this.image,
    this.price,
    this.isFavourite,
  });

  factory Propetylist.fromJson(Map<String, dynamic> json) => Propetylist(
        id: json["id"],
        name: json["name"],
        rate: json["rate"],
        city: json["city"],
        capacity: json["capacity"],
        propertyType: json["property_type"],
        propertyTypeTitle: json["property_type_title"],
        image: json["image"],
        price: json["price"],
        isFavourite: json["IS_FAVOURITE"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "rate": rate,
        "city": city,
        "capacity": capacity,
        "property_type": propertyType,
        "property_type_title": propertyTypeTitle,
        "image": image,
        "price": price,
        "IS_FAVOURITE": isFavourite,
      };
}
