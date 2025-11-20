// ignore_for_file: prefer_const_constructors, must_be_immutable, use_key_in_widget_constructors, unnecessary_string_interpolations, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/login_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  static String verifay = "";

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  SignUpController signUpController = Get.find();
  LoginController loginController = Get.put(LoginController());

  TextEditingController number = TextEditingController();

  String cuntryCode = "";

  final _formKey = GlobalKey<FormState>();

  bool isvalidate = false;

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

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: SafeArea(
        child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 10),
                  padding: EdgeInsets.all(15),
                  child: Image.asset(
                    'assets/images/back.png',
                    color: notifire.getwhiteblackcolor,
                  ),
                  decoration: BoxDecoration(
                    color: notifire.getboxcolor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  "Reset Password".tr,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Gilroy Bold",
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
                  "Please enter your phone number to request a\npassword reset"
                      .tr,
                  maxLines: 2,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontFamily: FontFamily.gilroyMedium,
                    color: notifire.getgreycolor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: IntlPhoneField(
                    disableLengthCheck: true,
                    keyboardType: TextInputType.number,
                    cursorColor: notifire.getwhiteblackcolor,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    initialCountryCode: 'IN',
                    controller: number,
                    onChanged: (value) {
                      setState(() {
                        if (number.text.isNotEmpty) {
                          isvalidate = false;
                        } else {
                          isvalidate = true;
                        }
                      });
                      cuntryCode = value.countryCode;
                    },
                    onCountryChanged: (value) {
                      number.text = '';
                    },
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
                    decoration: InputDecoration(
                      helperText: null,
                      labelText: "Mobile Number".tr,
                      labelStyle: TextStyle(
                        color: notifire.getborderColor,
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
              ),
              SizedBox(
                height: 30,
              ),
              GestButton(
                Width: Get.size.width,
                height: 50,
                buttoncolor: blueColor,
                margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                buttontext: "Request OTP".tr,
                style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: WhiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                onclick: () async {
                  setState(() {
                    if (number.text.isNotEmpty) {
                      isvalidate = false;
                      signUpController.smstype().then((msgType) {
                        signUpController
                            .checkMobileInResetPassword(
                                number: number.text, cuntryCode: cuntryCode)
                            .then((value) {
                          if (value == "false") {
                            if (msgType["otp_auth"] == "No") {
                              forgetPasswordBottomSheet();
                            } else {
                              if (msgType["SMS_TYPE"] == "Msg91") {
                                signUpController
                                    .sendOtp(cuntryCode, number.text)
                                    .then((value) {
                                  if (value["Result"] == "true") {
                                    Get.toNamed(Routes.otpScreen, arguments: {
                                      "number": number.text,
                                      "cuntryCode": cuntryCode,
                                      "route": "resetScreen",
                                      "otpCode": value["otp"].toString(),
                                    });
                                  } else {
                                    showToastMessage(
                                        'Invalid Mobile Number'.tr);
                                  }
                                });
                              } else if (msgType["SMS_TYPE"] == "Twilio") {
                                signUpController
                                    .twilloOtp(cuntryCode, number.text)
                                    .then((value) {
                                  if (value["Result"] == "true") {
                                    Get.toNamed(Routes.otpScreen, arguments: {
                                      "number": number.text,
                                      "cuntryCode": cuntryCode,
                                      "route": "resetScreen",
                                      "otpCode": value["otp"].toString(),
                                    });
                                  } else {
                                    showToastMessage(
                                        'Invalid Mobile Number'.tr);
                                  }
                                });
                              }
                            }
                          } else {
                            showToastMessage('Invalid Mobile Number'.tr);
                          }
                        });
                      });
                    } else {
                      isvalidate = true;
                    }
                  });
                  if (_formKey.currentState?.validate() ?? false) {}
                },
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "You remember your password?".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyMedium,
                          color: notifire.getgreycolor,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.login);
                        },
                        child: Text(
                          "Log In".tr,
                          style: TextStyle(
                            color: blueColor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future forgetPasswordBottomSheet() {
    return Get.bottomSheet(
      GetBuilder<LoginController>(builder: (context) {
        return SingleChildScrollView(
          child: Container(
            height: 350,
            width: Get.size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Forgot Password".tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Divider(
                    color: notifire.getgreycolor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 5, left: 15),
                  child: Text(
                    "Create Your New Password".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: loginController.newPassword,
                    obscureText: loginController.newShowPassword,
                    cursorColor: notifire.getwhiteblackcolor,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.gilroyMedium,
                      color: notifire.getwhiteblackcolor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          loginController.newShowOfPassword();
                        },
                        child: !loginController.newShowPassword
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
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: loginController.newConformPassword,
                    obscureText: loginController.conformPassword,
                    cursorColor: notifire.getwhiteblackcolor,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 14,
                      color: notifire.getwhiteblackcolor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          loginController.newConformShowOfPassword();
                        },
                        child: !loginController.conformPassword
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
                      labelText: "Conform Password".tr,
                      labelStyle: TextStyle(
                        color: notifire.getgreycolor,
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestButton(
                  Width: Get.size.width,
                  height: 50,
                  buttoncolor: blueColor,
                  margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                  buttontext: "Continue".tr,
                  style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: WhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: () {
                    if (loginController.newPassword.text ==
                        loginController.newConformPassword.text) {
                      loginController.setForgetPasswordApi(
                          ccode: cuntryCode, mobile: number.text);
                    } else {
                      showToastMessage("Please Enter Valid Password".tr);
                    }
                  },
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: notifire.getbgcolor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        );
      }),
    );
  }
}
