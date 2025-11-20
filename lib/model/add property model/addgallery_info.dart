// To parse this JSON data, do
//
//     final addGalleryInfo = addGalleryInfoFromJson(jsonString);

import 'dart:convert';

AddGalleryInfo addGalleryInfoFromJson(String str) =>
    AddGalleryInfo.fromJson(json.decode(str));

String addGalleryInfoToJson(AddGalleryInfo data) => json.encode(data.toJson());

class AddGalleryInfo {
  AddGalleryInfo({
    required this.gallerylist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  List<Gallerylist> gallerylist;
  String responseCode;
  String result;
  String responseMsg;

  factory AddGalleryInfo.fromJson(Map<String, dynamic> json) => AddGalleryInfo(
        gallerylist: List<Gallerylist>.from(
            json["gallerylist"].map((x) => Gallerylist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "gallerylist": List<dynamic>.from(gallerylist.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Gallerylist {
  Gallerylist({
    required this.id,
    required this.propertyTitle,
    required this.propertyId,
    required this.categoryTitle,
    required this.categoryId,
    required this.image,
    required this.status,
  });

  String id;
  String propertyTitle;
  String propertyId;
  String categoryTitle;
  String categoryId;
  String image;
  String status;

  factory Gallerylist.fromJson(Map<String, dynamic> json) => Gallerylist(
        id: json["id"],
        propertyTitle: json["property_title"],
        propertyId: json["property_id"],
        categoryTitle: json["category_title"],
        categoryId: json["category_id"],
        image: json["image"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "property_title": propertyTitle,
        "property_id": propertyId,
        "category_title": categoryTitle,
        "category_id": categoryId,
        "image": image,
        "status": status,
      };
}
