// ignore_for_file: non_constant_identifier_names, prefer_const_constructors, prefer_const_literals_to_create_immutables, file_names

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gotocarefinder/utils/Colors.dart';

Button(
    {String? buttontext,
    Function()? onclick,
    double? Width,
    Color? buttoncolor}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: 50,
      width: Width,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: buttoncolor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              "assets/images/phone.png",
              color: WhiteColor,
            ),
          ),
          Text(
            buttontext!,
            style: TextStyle(
              fontFamily: "Gilroy Bold",
              color: WhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

GestButton({
  String? buttontext,
  Function()? onclick,
  double? Width,
  double? height,
  Color? buttoncolor,
  EdgeInsets? margin,
  TextStyle? style,
}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: height,
      width: Width,
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: buttoncolor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(
              0.5,
              0.5,
            ),
            blurRadius: 1,
          ),
        ],
      ),
      child: Text(buttontext!, style: style),
    ),
  );
}

showToastMessage(message) {
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: BlackColor.withOpacity(0.9),
    textColor: Colors.white,
    fontSize: 14.0,
  );
}
