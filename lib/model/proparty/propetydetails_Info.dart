// To parse this JSON data, do
//
//     final propetydetailsInfo = propetydetailsInfoFromJson(jsonString);

import 'dart:convert';

PropetydetailsInfo propetydetailsInfoFromJson(String str) => PropetydetailsInfo.fromJson(json.decode(str));

String propetydetailsInfoToJson(PropetydetailsInfo data) => json.encode(data.toJson());

class PropetydetailsInfo {
  Propetydetails? propetydetails;
  List<Facility>? facility;
  List<String>? gallery;
  List<Reviewlist>? reviewlist;
  int? totalReview;
  String? responseCode;
  String? result;
  String? responseMsg;

  PropetydetailsInfo({
    this.propetydetails,
    this.facility,
    this.gallery,
    this.reviewlist,
    this.totalReview,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory PropetydetailsInfo.fromJson(Map<String, dynamic> json) => PropetydetailsInfo(
    propetydetails: json["propetydetails"] == null ? null : Propetydetails.fromJson(json["propetydetails"]),
    facility: json["facility"] == null ? [] : List<Facility>.from(json["facility"]!.map((x) => Facility.fromJson(x))),
    gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x)),
    reviewlist: json["reviewlist"] == null ? [] : List<Reviewlist>.from(json["reviewlist"]!.map((x) => Reviewlist.fromJson(x))),
    totalReview: json["total_review"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "propetydetails": propetydetails?.toJson(),
    "facility": facility == null ? [] : List<dynamic>.from(facility!.map((x) => x.toJson())),
    "gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
    "reviewlist": reviewlist == null ? [] : List<dynamic>.from(reviewlist!.map((x) => x.toJson())),
    "total_review": totalReview,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Facility {
  String? img;
  String? title;

  Facility({
    this.img,
    this.title,
  });

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
    img: json["img"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "img": img,
    "title": title,
  };
}

class Propetydetails {
  String? id;
  String? userId;
  String? title;
  String? rate;
  String? city;
  List<Image>? image;
  String? propertyType;
  String? propertyTitle;
  String? price;
  String? buyorrent;
  int? isEnquiry;
  String? address;
  String? beds;
  String? ownerImage;
  String? ownerName;
  String? bathrooms;
  String? size;
  String? description;
  String? latitude;
  String? contact;
  String? capacity;
  String? longtitude;
  int? isFavourite;

  Propetydetails({
    this.id,
    this.userId,
    this.title,
    this.rate,
    this.city,
    this.image,
    this.propertyType,
    this.propertyTitle,
    this.price,
    this.buyorrent,
    this.isEnquiry,
    this.address,
    this.beds,
    this.ownerImage,
    this.ownerName,
    this.bathrooms,
    this.size,
    this.description,
    this.latitude,
    this.contact,
    this.capacity,
    this.longtitude,
    this.isFavourite,
  });

  factory Propetydetails.fromJson(Map<String, dynamic> json) => Propetydetails(
    id: json["id"],
    userId: json["user_id"],
    title: json["title"],
    rate: json["rate"],
    city: json["city"],
    image: json["image"] == null ? [] : List<Image>.from(json["image"]!.map((x) => Image.fromJson(x))),
    propertyType: json["property_type"],
    propertyTitle: json["property_title"],
    price: json["price"],
    buyorrent: json["buyorrent"],
    isEnquiry: json["is_enquiry"],
    address: json["address"],
    beds: json["beds"],
    ownerImage: json["owner_image"],
    ownerName: json["owner_name"],
    bathrooms: json["bathrooms"],
    size: json["size"],
    description: json["description"],
    latitude: json["latitude"],
    contact: json["contact"],
    capacity: json["capacity"],
    longtitude: json["longtitude"],
    isFavourite: json["IS_FAVOURITE"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "rate": rate,
    "city": city,
    "image": image == null ? [] : List<dynamic>.from(image!.map((x) => x.toJson())),
    "property_type": propertyType,
    "property_title": propertyTitle,
    "price": price,
    "buyorrent": buyorrent,
    "is_enquiry": isEnquiry,
    "address": address,
    "beds": beds,
    "owner_image": ownerImage,
    "owner_name": ownerName,
    "bathrooms": bathrooms,
    "size": size,
    "description": description,
    "latitude": latitude,
    "contact": contact,
    "capacity": capacity,
    "longtitude": longtitude,
    "IS_FAVOURITE": isFavourite,
  };
}

class Image {
  String? image;
  String? isPanorama;

  Image({
    this.image,
    this.isPanorama,
  });

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    image: json["image"],
    isPanorama: json["is_panorama"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "is_panorama": isPanorama,
  };
}

class Reviewlist {
  dynamic userImg;
  String? userTitle;
  String? userRate;
  String? userDesc;

  Reviewlist({
    this.userImg,
    this.userTitle,
    this.userRate,
    this.userDesc,
  });

  factory Reviewlist.fromJson(Map<String, dynamic> json) => Reviewlist(
    userImg: json["user_img"],
    userTitle: json["user_title"],
    userRate: json["user_rate"],
    userDesc: json["user_desc"],
  );

  Map<String, dynamic> toJson() => {
    "user_img": userImg,
    "user_title": userTitle,
    "user_rate": userRate,
    "user_desc": userDesc,
  };
}
