// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:gotocarefinder/utils/Colors.dart';

class ColorNotifire with ChangeNotifier {
  bool isDark = false;
  set setIsDark(value) {
    isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;
  get getbgcolor => isDark ? darkmode : bgcolor;
  get getboxcolor => isDark ? boxcolor : WhiteColor;
  get getlightblackcolor => isDark ? boxcolor : lightBlack;
  get getwhiteblackcolor => isDark ? WhiteColor : BlackColor;
  get getgreycolor => isDark ? greyColor : greyColor;
  get getwhitebluecolor => isDark ? WhiteColor : Darkblue;
  get getblackgreycolor => isDark ? lightBlack2 : greyColor;
  get getcardcolor => isDark ? darkmode : WhiteColor;
  get getgreywhite => isDark ? WhiteColor : greyColor;
  get getredcolor => isDark ? RedColor : RedColor2;
  get getprocolor => isDark ? yelloColor : yelloColor2;
  get getblackwhitecolor => isDark ? BlackColor : Colors.grey.shade100;
  get getlightblack => isDark ? lightBlack2 : lightBlack2;
  get getbuttonscolor => isDark ? lightgrey : lightgrey2;
  get getbuttoncolor => isDark ? greyColor : onoffColor;
  get getdarkbluecolor => isDark ? Darkblue : Darkblue;
  get getdarkscolor => isDark ? BlackColor : bgcolor;
  get getdarkwhitecolor => isDark ? WhiteColor : WhiteColor;
  get getblackblue => isDark ? blueColor : BlackColor;
  get getfevAndSearch => isDark ? darkmode : fevAndSearchColor;
  get getlightblackwhite => isDark ? BlackColor : fevAndSearchColor;
  get getborderColor => isDark ? const Color(0xff282828) : Colors.grey.shade200;
}
