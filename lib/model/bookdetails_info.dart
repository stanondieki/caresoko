import 'dart:convert';

BookDetailsInfo bookDetailsInfoFromJson(String str) =>
    BookDetailsInfo.fromJson(json.decode(str));

String bookDetailsInfoToJson(BookDetailsInfo data) =>
    json.encode(data.toJson());

class BookDetailsInfo {
  Bookdetails? bookdetails;
  String? responseCode;
  String? result;
  String? responseMsg;

  BookDetailsInfo({
    this.bookdetails,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory BookDetailsInfo.fromJson(Map<String, dynamic> json) =>
      BookDetailsInfo(
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
  String? bookFor;
  String? isRate;
  String? totalRate;
  String? rateText;
  String? cancleReason;
  String? fname;
  String? lname;
  String? gender;
  String? email;
  String? mobile;
  String? ccode;
  String? country;

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
    this.bookFor,
    this.isRate,
    this.totalRate,
    this.rateText,
    this.cancleReason,
    this.fname,
    this.lname,
    this.gender,
    this.email,
    this.mobile,
    this.ccode,
    this.country,
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
        bookFor: json["book_for"],
        isRate: json["is_rate"],
        totalRate: json["total_rate"],
        rateText: json["rate_text"],
        cancleReason: json["cancle_reason"],
        fname: json["fname"],
        lname: json["lname"],
        gender: json["gender"],
        email: json["email"],
        mobile: json["mobile"],
        ccode: json["ccode"],
        country: json["country"],
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
        "book_for": bookFor,
        "is_rate": isRate,
        "total_rate": totalRate,
        "rate_text": rateText,
        "cancle_reason": cancleReason,
        "fname": fname,
        "lname": lname,
        "gender": gender,
        "email": email,
        "mobile": mobile,
        "ccode": ccode,
        "country": country,
      };
}
