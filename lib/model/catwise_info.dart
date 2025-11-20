// To parse this JSON data, do
//
//     final catWiseInfo = catWiseInfoFromJson(jsonString);

import 'dart:convert';

CatWiseInfo catWiseInfoFromJson(String str) =>
    CatWiseInfo.fromJson(json.decode(str));

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
        propertyCat: json["Property_cat"] == null
            ? []
            : List<PropertyCat>.from(
                json["Property_cat"]!.map((x) => PropertyCat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "Property_cat": propertyCat == null
            ? []
            : List<dynamic>.from(propertyCat!.map((x) => x.toJson())),
      };
}

class PropertyCat {
  String? id;
  String? name;
  String? capacity;
  String? zipcode;
  String? rate;
  String? city;
  String? propertyType;
  String? propertyTypeTitle;
  String? sqrft;
  String? image;
  String? pricing;
  int? isFavourite;

  PropertyCat({
    this.id,
    this.name,
    this.capacity,
    this.zipcode,
    this.rate,
    this.city,
    this.propertyType,
    this.propertyTypeTitle,
    this.sqrft,
    this.image,
    this.pricing,
    this.isFavourite,
  });

  factory PropertyCat.fromJson(Map<String, dynamic> json) => PropertyCat(
        id: json["id"],
        name: json["name"],
        capacity: json["capacity"],
        zipcode: json["zipcode"],
        rate: json["rate"],
        city: json["city"],
        propertyType: json["property_type"],
        propertyTypeTitle: json["property_type_title"],
        sqrft: json["sqrft"],
        image: json["image"],
        pricing: json["pricing"],
        isFavourite: json["IS_FAVOURITE"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "capacity": capacity,
        "zipcode": zipcode,
        "rate": rate,
        "city": city,
        "property_type": propertyType,
        "property_type_title": propertyTypeTitle,
        "sqrft": sqrft,
        "image": image,
        "pricing": pricing,
        "IS_FAVOURITE": isFavourite,
      };
}
