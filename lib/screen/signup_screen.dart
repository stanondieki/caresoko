// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../controller/homepage_controller.dart';
import '../controller/search_controller.dart';
import '../controller/selectcountry_controller.dart';
import '../model/routes_helper.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountryData();
  }

  SignUpController signUpController = Get.find();
  SelectCountryController selectCountryController = Get.find();
  HomePageController homePageController = Get.find();
  SearchPropertyController searchController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String cuntryCode = "";

  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  Future getCountryData() async {
    selectCountryController.getCountryApi().then((value) {
      for (int a = 0;
          a < selectCountryController.countryInfo!.countryData!.length;
          a++) {
        if (selectCountryController.countryInfo?.countryData![a].dCon == "1") {
          setState(() {
            countrySelected = a;
          });
        }
      }
    });
  }

  int countrySelected = 0;

  bool isvalidate = false;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(18.0),
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: Image.asset(
              'assets/images/back.png',
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: Get.size.height,
            width: Get.size.width,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Get Started!".tr,
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: FontFamily.gilroyBold,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      "Create an account to continue.".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: signUpController.name,
                      cursorColor: notifire.getwhiteblackcolor,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: notifire.getwhiteblackcolor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: blueColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: notifire.getborderColor,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: notifire.getborderColor),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/images/user.png",
                            height: 10,
                            width: 10,
                            color: notifire.getgreycolor,
                          ),
                        ),
                        labelText: "Full Name".tr,
                        labelStyle: TextStyle(
                          color: notifire.getgreycolor,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: signUpController.email,
                      cursorColor: notifire.getwhiteblackcolor,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: notifire.getwhiteblackcolor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: blueColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: notifire.getborderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: notifire.getborderColor,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/images/email.png",
                            height: 10,
                            width: 10,
                            color: notifire.getgreycolor,
                          ),
                        ),
                        labelText: "Email Address".tr,
                        labelStyle: TextStyle(
                          color: notifire.getgreycolor,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: IntlPhoneField(
                      disableLengthCheck: true,
                      keyboardType: TextInputType.number,
                      cursorColor: notifire.getwhiteblackcolor,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: signUpController.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialCountryCode: "US",
                      dropdownIcon: Icon(
                        Icons.arrow_drop_down,
                        color: notifire.getgreycolor,
                      ),
                      dropdownTextStyle: TextStyle(
                        color: notifire.getgreycolor,
                      ),
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: notifire.getwhiteblackcolor,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (signUpController.number.text.isNotEmpty) {
                            isvalidate = false;
                          } else {
                            isvalidate = true;
                          }
                        });
                        cuntryCode = value.countryCode;
                      },
                      onCountryChanged: (value) {
                        signUpController.number.text = '';
                      },
                      decoration: InputDecoration(
                        helperText: null,
                        labelText: "Mobile Number".tr,
                        labelStyle: TextStyle(
                          color: notifire.getgreycolor,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: isvalidate ? Colors.red.shade700 : blueColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isvalidate
                                ? Colors.red.shade700
                                : notifire.getborderColor,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: isvalidate
                                ? Colors.red.shade700
                                : notifire.getborderColor,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (p0) {
                        if (p0!.completeNumber.isEmpty) {
                          return 'Please enter your number'.tr;
                        } else {}
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GetBuilder<SignUpController>(builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        controller: signUpController.password,
                        obscureText: signUpController.showPassword,
                        cursorColor: notifire.getwhiteblackcolor,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: notifire.getwhiteblackcolor,
                        ),
                        onChanged: (value) {},
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: blueColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: notifire.getborderColor,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: notifire.getborderColor,
                            ),
                          ),
                          suffixIcon: InkWell(
                            onTap: () {
                              signUpController.showOfPassword();
                            },
                            child: !signUpController.showPassword
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/images/showpassowrd.png",
                                      height: 10,
                                      width: 10,
                                      color: notifire.getgreycolor,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      "assets/images/HidePassword.png",
                                      height: 10,
                                      width: 10,
                                      color: notifire.getgreycolor,
                                    ),
                                  ),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              "assets/images/Unlock.png",
                              height: 10,
                              width: 10,
                              color: notifire.getgreycolor,
                            ),
                          ),
                          labelText: "Password".tr,
                          labelStyle: TextStyle(
                            color: notifire.getgreycolor,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password'.tr;
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: signUpController.referralCode,
                      cursorColor: notifire.getwhiteblackcolor,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: notifire.getwhiteblackcolor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: blueColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: notifire.getborderColor,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: notifire.getborderColor,
                          ),
                        ),
                        labelText: "Referral code (optional)".tr,
                        labelStyle: TextStyle(
                          color: notifire.getgreycolor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GetBuilder<SignUpController>(builder: (context) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Transform.scale(
                          scale: 1,
                          child: Checkbox(
                            value: signUpController.chack,
                            side: const BorderSide(color: Color(0xffC5CAD4)),
                            activeColor: blueColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            onChanged: (newbool) async {
                              signUpController.checkTermsAndCondition(newbool);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('Remember', true);
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "By creating an account,you agree to our".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: notifire.getgreycolor,
                                fontFamily: FontFamily.gilroyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "Terms and Condition".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: blueColor,
                                fontFamily: FontFamily.gilroyBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  }),
                  GestButton(
                    Width: Get.size.width,
                    height: 50,
                    buttoncolor: blueColor,
                    margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                    buttontext: "Continue".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: WhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: () {
                      setState(() {
                        if (signUpController.number.text.isNotEmpty) {
                          isvalidate = false;
                        } else {
                          isvalidate = true;
                        }
                      });
                      if ((_formKey.currentState?.validate() ?? false) &&
                          (signUpController.chack == true)) {
                        signUpController.smstype().then((msgtype) {
                          signUpController
                              .checkMobileNumber(cuntryCode)
                              .then((value) {
                            if (value == "true") {
                              if (msgtype["otp_auth"] == "No") {
                                signUpController
                                    .setUserApiData(cuntryCode)
                                    .then(
                                  (value) {
                                    if (value["Result"] == "true") {
                                      setState(() {
                                        save(
                                            "countryId",
                                            selectCountryController
                                                    .countryInfo
                                                    ?.countryData![
                                                        countrySelected]
                                                    .id ??
                                                "");
                                        save(
                                            "countryName",
                                            selectCountryController
                                                    .countryInfo
                                                    ?.countryData![
                                                        countrySelected]
                                                    .title ??
                                                "");
                                      });

                                      selectCountryController
                                          .changeCountryIndex(countrySelected);
                                      homePageController.getHomeDataApi(
                                          countryId: getData.read("countryId"));
                                      homePageController.getCatWiseData(
                                          countryId: getData.read("countryId"),
                                          cId: "0");
                                      searchController.getSearchData(
                                          countryId: getData.read("countryId"));
                                      Get.offAndToNamed(Routes.bottoBarScreen);
                                      initPlatformState();
                                    } else {
                                      showToastMessage(value["ResponseMsg"]);
                                    }
                                  },
                                );
                              } else {
                                if (msgtype["SMS_TYPE"] == "Msg91") {
                                  signUpController
                                      .sendOtp(cuntryCode,
                                          signUpController.number.text)
                                      .then((value) {
                                    if (value["Result"] == "true") {
                                      Get.toNamed(Routes.otpScreen, arguments: {
                                        "number": signUpController.number.text,
                                        "cuntryCode": cuntryCode,
                                        "route": "signUpScreen",
                                        "otpCode": value["otp"].toString(),
                                      });
                                    } else {
                                      showToastMessage(
                                          'Invalid Mobile Number'.tr);
                                    }
                                  });
                                } else if (msgtype["SMS_TYPE"] == "Twilio") {
                                  signUpController
                                      .twilloOtp(cuntryCode,
                                          signUpController.number.text)
                                      .then((value) {
                                    if (value["Result"] == "true") {
                                      Get.toNamed(Routes.otpScreen, arguments: {
                                        "number": signUpController.number.text,
                                        "cuntryCode": cuntryCode,
                                        "route": "signUpScreen",
                                        "otpCode": value["otp"]
                                      });
                                    } else {
                                      showToastMessage(
                                          'Invalid Mobile Number'.tr);
                                    }
                                  });
                                }
                              }
                            }
                          });
                        });
                      } else {
                        if (signUpController.chack == false) {
                          showToastMessage(
                              "Please select Terms and Condition".tr);
                        }
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 45),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            color: notifire.getgreycolor,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(LoginScreen());
                          },
                          child: Text(
                            "Login".tr,
                            style: TextStyle(
                              color: blueColor,
                              fontFamily: FontFamily.gilroyBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    // Initialize OneSignal with your App ID
    OneSignal.initialize(Config.oneSignel);

    // Request permission for push notifications
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });
  }
}
