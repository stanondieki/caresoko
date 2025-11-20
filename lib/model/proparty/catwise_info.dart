// To parse this JSON data, do
//
//     final catWiseInfo = catWiseInfoFromJson(jsonString);


import 'dart:convert';

CatWiseInfo catWiseInfoFromJson(String str) => CatWiseInfo.fromJson(json.decode(str));

String catWiseInfoToJson(CatWiseInfo data) => json.encode(data.toJson());

class CatWiseInfo {
  String? responseCode;
  String? result;
  String? responseMsg;
  List<PropertyCat>? propertyCat;

  CatWiseInfo({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.propertyCat,
  });

  factory CatWiseInfo.fromJson(Map<String, dynamic> json) => CatWiseInfo(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    propertyCat: json["Property_cat"] == null ? [] : List<PropertyCat>.from(json["Property_cat"]!.map((x) => PropertyCat.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "Property_cat": propertyCat == null ? [] : List<dynamic>.from(propertyCat!.map((x) => x.toJson())),
  };
}

class PropertyCat {
  String? id;
  String? title;
  String? buyorrent;
  String? capacity;
  String? rate;
  String? zipcode;
  String? city;
  String? propertyType;
  String? beds;
  String? bathrooms;
  String? size;
  String? image;
  String? price;
  int? isFavourite;

  PropertyCat({
    this.id,
    this.title,
    this.buyorrent,
    this.capacity,
    this.rate,
    this.zipcode,
    this.city,
    this.propertyType,
    this.beds,
    this.bathrooms,
    this.size,
    this.image,
    this.price,
    this.isFavourite,
  });

  factory PropertyCat.fromJson(Map<String, dynamic> json) => PropertyCat(
    id: json["id"],
    title: json["title"],
    buyorrent: json["buyorrent"],
    capacity: json["capacity"],
    rate: json["rate"],
    zipcode: json["zipcode"],
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
    "capacity": capacity,
    "rate": rate,
    "zipcode": zipcode,
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