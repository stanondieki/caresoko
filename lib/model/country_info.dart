// To parse this JSON data, do
//
//     final countryInfo = countryInfoFromJson(jsonString);
import 'dart:convert';

CountryInfo countryInfoFromJson(String str) => CountryInfo.fromJson(json.decode(str));

String countryInfoToJson(CountryInfo data) => json.encode(data.toJson());

class CountryInfo {
  List<CountryDatum>? countryData;
  String? responseCode;
  String? result;
  String? responseMsg;

  CountryInfo({
    this.countryData,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) => CountryInfo(
    countryData: json["CountryData"] == null ? [] : List<CountryDatum>.from(json["CountryData"]!.map((x) => CountryDatum.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "CountryData": countryData == null ? [] : List<dynamic>.from(countryData!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class CountryDatum {
  String? id;
  String? title;
  String? img;
  String? status;
  String? dCon;

  CountryDatum({
    this.id,
    this.title,
    this.img,
    this.status,
    this.dCon,
  });

  factory CountryDatum.fromJson(Map<String, dynamic> json) => CountryDatum(
    id: json["id"],
    title: json["title"],
    img: json["img"],
    status: json["status"],
    dCon: json["d_con"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img": img,
    "status": status,
    "d_con": dCon,
  };
}
