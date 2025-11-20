// To parse this JSON data, do
//
//     final homesearchModel = homesearchModelFromJson(jsonString);

import 'dart:convert';

HomesearchModel homesearchModelFromJson(String str) =>
    HomesearchModel.fromJson(json.decode(str));

String homesearchModelToJson(HomesearchModel data) =>
    json.encode(data.toJson());

class HomesearchModel {
  List<SearchPropety>? searchPropety;
  String? responseCode;
  String? result;
  String? responseMsg;

  HomesearchModel({
    this.searchPropety,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory HomesearchModel.fromJson(Map<String, dynamic> json) =>
      HomesearchModel(
        searchPropety: json["search_propety"] == null
            ? []
            : List<SearchPropety>.from(
                json["search_propety"]!.map((x) => SearchPropety.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "search_propety": searchPropety == null
            ? []
            : List<dynamic>.from(searchPropety!.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class SearchPropety {
  String? id;
  String? name;
  String? rate;
  String? capacity;
  String? city;
  String? image;
  String? propertyType;
  String? propertyTypeTitle;
  String? price;
  int? isFavourite;

  SearchPropety({
    this.id,
    this.name,
    this.rate,
    this.capacity,
    this.city,
    this.image,
    this.propertyType,
    this.propertyTypeTitle,
    this.price,
    this.isFavourite,
  });

  factory SearchPropety.fromJson(Map<String, dynamic> json) => SearchPropety(
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
