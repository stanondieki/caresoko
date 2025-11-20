// To parse this JSON data, do
//
//     final proDetailsInfo = proDetailsInfoFromJson(jsonString);

import 'dart:convert';

ProDetailsInfo proDetailsInfoFromJson(String str) =>
    ProDetailsInfo.fromJson(json.decode(str));

String proDetailsInfoToJson(ProDetailsInfo data) => json.encode(data.toJson());

class ProDetailsInfo {
  Bookdetails? bookdetails;
  String? responseCode;
  String? result;
  String? responseMsg;

  ProDetailsInfo({
    this.bookdetails,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory ProDetailsInfo.fromJson(Map<String, dynamic> json) => ProDetailsInfo(
        bookdetails: json["bookdetails"] == null
            ? null
            : Bookdetails.fromJson(json["bookdetails"]),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "bookdetails": bookdetails?.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Bookdetails {
  String? bookId;
  String? propId;
  String? uid;
  String? propTitle;
  String? address;
  String? propType;
  String? bookingDate;
  String? date;
  String? time;
  String? message;
  String? bookStatus;
  String? checkIntime;
  String? checkOuttime;
  String? bookFor;
  String? isRate;
  String? totalRate;
  String? rateText;
  String? cancleReason;
  String? customerName;
  String? customerMobile;

  Bookdetails({
    this.bookId,
    this.propId,
    this.uid,
    this.propTitle,
    this.address,
    this.propType,
    this.bookingDate,
    this.date,
    this.time,
    this.message,
    this.bookStatus,
    this.checkIntime,
    this.checkOuttime,
    this.bookFor,
    this.isRate,
    this.totalRate,
    this.rateText,
    this.cancleReason,
    this.customerName,
    this.customerMobile,
  });

  factory Bookdetails.fromJson(Map<String, dynamic> json) => Bookdetails(
        bookId: json["book_id"],
        propId: json["prop_id"],
        uid: json["uid"],
        propTitle: json["prop_title"],
        address: json["address"],
        propType: json["prop_type"],
        bookingDate: json["book_date"],
        date: json["date"],
        time: json["time"],
        message: json["message"],
        bookStatus: json["book_status"],
        checkIntime: json["check_intime"],
        checkOuttime: json["check_outtime"],
        bookFor: json["book_for"],
        isRate: json["is_rate"],
        totalRate: json["total_rate"],
        rateText: json["rate_text"],
        cancleReason: json["cancle_reason"],
        customerName: json["customer_name"],
        customerMobile: json["customer_mobile"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "prop_id": propId,
        "uid": uid,
        "prop_title": propTitle,
        "address": address,
        "prop_type": propType,
        "book_date": bookingDate,
        "date": date,
        "time": time,
        "message": message,
        "book_status": bookStatus,
        "check_intime": checkIntime,
        "check_outtime": checkOuttime,
        "book_for": bookFor,
        "is_rate": isRate,
        "total_rate": totalRate,
        "rate_text": rateText,
        "cancle_reason": cancleReason,
        "customer_name": customerName,
        "customer_mobile": customerMobile,
      };
}
