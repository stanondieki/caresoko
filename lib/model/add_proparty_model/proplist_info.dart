// To parse this JSON data, do
//
//     final propListInfo = propListInfoFromJson(jsonString);

import 'dart:convert';

PropListInfo propListInfoFromJson(String str) => PropListInfo.fromJson(json.decode(str));

String propListInfoToJson(PropListInfo data) => json.encode(data.toJson());

class PropListInfo {
  List<Proplist>? proplist;
  String? responseCode;
  String? result;
  String? responseMsg;

  PropListInfo({
    this.proplist,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory PropListInfo.fromJson(Map<String, dynamic> json) => PropListInfo(
    proplist: json["proplist"] == null ? [] : List<Proplist>.from(json["proplist"]!.map((x) => Proplist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "proplist": proplist == null ? [] : List<dynamic>.from(proplist!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Proplist {
  String? id;
  String? title;
  String? propertyType;
  String? propertyTypeId;
  String? image;
  String? countryId;
  String? countryTitle;
  String? price;
  String? beds;
  String? plimit;
  String? bathroom;
  String? sqrft;
  String? isSell;
  String? facilitySelect;
  String? status;
  String? latitude;
  String? longtitude;
  String? mobile;
  String? buyorrent;
  String? city;
  String? rate;
  String? description;
  String? address;

  Proplist({
    this.id,
    this.title,
    this.propertyType,
    this.propertyTypeId,
    this.image,
    this.countryId,
    this.countryTitle,
    this.price,
    this.beds,
    this.plimit,
    this.bathroom,
    this.sqrft,
    this.isSell,
    this.facilitySelect,
    this.status,
    this.latitude,
    this.longtitude,
    this.mobile,
    this.buyorrent,
    this.city,
    this.rate,
    this.description,
    this.address,
  });

  factory Proplist.fromJson(Map<String, dynamic> json) => Proplist(
    id: json["id"],
    title: json["title"],
    propertyType: json["property_type"],
    propertyTypeId: json["property_type_id"],
    image: json["image"],
    countryId: json["country_id"],
    countryTitle: json["country_title"],
    price: json["price"],
    beds: json["beds"],
    plimit: json["plimit"],
    bathroom: json["bathroom"],
    sqrft: json["sqrft"],
    isSell: json["is_sell"],
    facilitySelect: json["facility_select"],
    status: json["status"],
    latitude: json["latitude"],
    longtitude: json["longtitude"],
    mobile: json["mobile"],
    buyorrent: json["buyorrent"],
    city: json["city"],
    rate: json["rate"],
    description: json["description"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "property_type": propertyType,
    "property_type_id": propertyTypeId,
    "image": image,
    "country_id": countryId,
    "country_title": countryTitle,
    "price": price,
    "beds": beds,
    "plimit": plimit,
    "bathroom": bathroom,
    "sqrft": sqrft,
    "is_sell": isSell,
    "facility_select": facilitySelect,
    "status": status,
    "latitude": latitude,
    "longtitude": longtitude,
    "mobile": mobile,
    "buyorrent": buyorrent,
    "city": city,
    "rate": rate,
    "description": description,
    "address": address,
  };
}
