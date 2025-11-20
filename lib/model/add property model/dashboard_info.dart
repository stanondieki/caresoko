// To parse this JSON data, do
//
//     final dashBoardInfo = dashBoardInfoFromJson(jsonString);

import 'dart:convert';

DashBoardInfo dashBoardInfoFromJson(String str) =>
    DashBoardInfo.fromJson(json.decode(str));

String dashBoardInfoToJson(DashBoardInfo data) => json.encode(data.toJson());

class DashBoardInfo {
  DashBoardInfo({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.reportData,
    required this.isSubscribe,
    required this.memberData,
    required this.withdrawLimit,
  });

  String responseCode;
  String result;
  String responseMsg;
  List<ReportDatum> reportData;
  int isSubscribe;
  List<MemberDatum> memberData;
  String withdrawLimit;

  factory DashBoardInfo.fromJson(Map<String, dynamic> json) => DashBoardInfo(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        reportData: List<ReportDatum>.from(
            json["report_data"].map((x) => ReportDatum.fromJson(x))),
        isSubscribe: json["is_subscribe"],
        memberData: List<MemberDatum>.from(
            json["member_data"].map((x) => MemberDatum.fromJson(x))),
        withdrawLimit: json["withdraw_limit"],
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "report_data": List<dynamic>.from(reportData.map((x) => x.toJson())),
        "is_subscribe": isSubscribe,
        "member_data": List<dynamic>.from(memberData.map((x) => x.toJson())),
        "withdraw_limit": withdrawLimit,
      };
}

class MemberDatum {
  MemberDatum({
    required this.title,
    required this.reportData,
  });

  String title;
  String reportData;

  factory MemberDatum.fromJson(Map<String, dynamic> json) => MemberDatum(
        title: json["title"],
        reportData: json["report_data"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "report_data": reportData,
      };
}

class ReportDatum {
  ReportDatum({
    required this.title,
    required this.reportData,
    required this.url,
  });

  String title;
  String reportData;
  String url;

  factory ReportDatum.fromJson(Map<String, dynamic> json) => ReportDatum(
        title: json["title"],
        reportData: json["report_data"].toString(),
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "report_data": reportData,
        "url": url,
      };
}
