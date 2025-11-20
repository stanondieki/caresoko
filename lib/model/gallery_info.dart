// To parse this JSON data, do
//
//     final galleryInfo = galleryInfoFromJson(jsonString);

import 'dart:convert';

GalleryInfo galleryInfoFromJson(String str) => GalleryInfo.fromJson(json.decode(str));

String galleryInfoToJson(GalleryInfo data) => json.encode(data.toJson());

class GalleryInfo {
  List<Gallerydatum>? gallerydata;
  String? responseCode;
  String? result;
  String? responseMsg;

  GalleryInfo({
    this.gallerydata,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory GalleryInfo.fromJson(Map<String, dynamic> json) => GalleryInfo(
    gallerydata: json["gallerydata"] == null ? [] : List<Gallerydatum>.from(json["gallerydata"]!.map((x) => Gallerydatum.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "gallerydata": gallerydata == null ? [] : List<dynamic>.from(gallerydata!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Gallerydatum {
  String? title;
  List<String>? imglist;

  Gallerydatum({
    this.title,
    this.imglist,
  });

  factory Gallerydatum.fromJson(Map<String, dynamic> json) => Gallerydatum(
    title: json["title"],
    imglist: json["imglist"] == null ? [] : List<String>.from(json["imglist"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "imglist": imglist == null ? [] : List<dynamic>.from(imglist!.map((x) => x)),
  };
}
