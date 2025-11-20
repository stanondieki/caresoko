// To parse this JSON data, do
//
//     final walletInfo = walletInfoFromJson(jsonString);

import 'dart:convert';

WalletInfo walletInfoFromJson(String str) => WalletInfo.fromJson(json.decode(str));

String walletInfoToJson(WalletInfo data) => json.encode(data.toJson());

class WalletInfo {
  List<Walletitem>? walletitem;
  String? wallet;
  String? responseCode;
  String? result;
  String? responseMsg;

  WalletInfo({
    this.walletitem,
    this.wallet,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) => WalletInfo(
    walletitem: json["Walletitem"] == null ? [] : List<Walletitem>.from(json["Walletitem"]!.map((x) => Walletitem.fromJson(x))),
    wallet: json["wallet"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "Walletitem": walletitem == null ? [] : List<dynamic>.from(walletitem!.map((x) => x.toJson())),
    "wallet": wallet,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Walletitem {
  String? message;
  String? status;
  String? amt;
  String? tdate;

  Walletitem({
    this.message,
    this.status,
    this.amt,
    this.tdate,
  });

  factory Walletitem.fromJson(Map<String, dynamic> json) => Walletitem(
    message: json["message"],
    status: json["status"],
    amt: json["amt"],
    tdate: json["tdate"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "amt": amt,
    "tdate": tdate,
  };
}
