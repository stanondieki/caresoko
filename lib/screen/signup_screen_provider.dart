// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables

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

/// Signup screen for **care providers** (agencies / individual caregivers).
/// Collects the common fields plus provider-specific fields:
///   - agency_name, service_type, years_experience, license_number.
/// Sets `SignUpController.userType = "provider"` (already set by the role-select screen).
class SignUpScreenProvider extends StatefulWidget {
  @override
  State<SignUpScreenProvider> createState() => _SignUpScreenProviderState();
}

class _SignUpScreenProviderState extends State<SignUpScreenProvider> {
  final SignUpController signUpController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final HomePageController homePageController = Get.find();
  final SearchPropertyController searchController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String cuntryCode = "";
  int countrySelected = 0;
  bool isvalidate = false;
  late ColorNotifire notifire;

  static const List<String> _serviceTypes = [
    "Home Care",
    "Nursing",
    "Companion",
    "Therapy",
  ];

  @override
  void initState() {
    super.initState();
    // Ensure userType is set even if this screen is opened directly.
    // Direct field assignment (no update()) — calling setUserType() here
    // would mark GetBuilder<SignUpController> widgets dirty mid-build and
    // throw "setState() called during build".
    signUpController.userType = "provider";
    _getCountryData();
  }

  Future _getCountryData() async {
    await selectCountryController.getCountryApi();
    final list = selectCountryController.countryInfo?.countryData ?? [];
    for (int a = 0; a < list.length; a++) {
      if (list[a].dCon == "1") {
        setState(() => countrySelected = a);
      }
    }
  }

  OutlineInputBorder _border(Color c) =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: c));

  InputDecoration _dec(String label, {Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      focusedBorder: _border(blueColor),
      enabledBorder: _border(notifire.getborderColor),
      border: _border(notifire.getborderColor),
      prefixIcon: prefix,
      suffixIcon: suffix,
      labelText: label,
      labelStyle: TextStyle(color: notifire.getgreycolor),
    );
  }

  TextStyle get _inputStyle => TextStyle(
        fontFamily: FontFamily.gilroyBold,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: notifire.getwhiteblackcolor,
      );

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(18.0),
          child: InkWell(
            onTap: () => Get.back(),
            child: Image.asset('assets/images/back.png', color: notifire.getwhiteblackcolor),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Provider Sign Up".tr,
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tell us about the care services you offer.".tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    color: notifire.getgreycolor,
                  ),
                ),
                const SizedBox(height: 20),

                // ===== Common fields =====
                TextFormField(
                  controller: signUpController.name,
                  cursorColor: notifire.getwhiteblackcolor,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: _inputStyle,
                  decoration: _dec(
                    "Full Name".tr,
                    prefix: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset("assets/images/user.png", color: notifire.getgreycolor),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name'.tr : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: signUpController.email,
                  cursorColor: notifire.getwhiteblackcolor,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: _inputStyle,
                  decoration: _dec(
                    "Email Address".tr,
                    prefix: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset("assets/images/email.png", color: notifire.getgreycolor),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Please enter your email'.tr : null,
                ),
                const SizedBox(height: 20),
                IntlPhoneField(
                  disableLengthCheck: true,
                  keyboardType: TextInputType.number,
                  cursorColor: notifire.getwhiteblackcolor,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: signUpController.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialCountryCode: "US",
                  dropdownIcon: Icon(Icons.arrow_drop_down, color: notifire.getgreycolor),
                  dropdownTextStyle: TextStyle(color: notifire.getgreycolor),
                  style: _inputStyle,
                  onChanged: (value) {
                    setState(() {
                      isvalidate = signUpController.number.text.isEmpty;
                    });
                    cuntryCode = value.countryCode;
                  },
                  onCountryChanged: (_) => signUpController.number.text = '',
                  decoration: InputDecoration(
                    labelText: "Mobile Number".tr,
                    labelStyle: TextStyle(color: notifire.getgreycolor),
                    focusedBorder: _border(isvalidate ? Colors.red.shade700 : blueColor),
                    enabledBorder: _border(isvalidate ? Colors.red.shade700 : notifire.getborderColor),
                    border: _border(isvalidate ? Colors.red.shade700 : notifire.getborderColor),
                  ),
                  validator: (p0) =>
                      (p0!.completeNumber.isEmpty) ? 'Please enter your number'.tr : null,
                ),
                const SizedBox(height: 20),
                GetBuilder<SignUpController>(builder: (c) {
                  return TextFormField(
                    controller: signUpController.password,
                    obscureText: signUpController.showPassword,
                    cursorColor: notifire.getwhiteblackcolor,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: _inputStyle,
                    decoration: _dec(
                      "Password".tr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset("assets/images/Unlock.png", color: notifire.getgreycolor),
                      ),
                      suffix: InkWell(
                        onTap: signUpController.showOfPassword,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            signUpController.showPassword
                                ? "assets/images/showpassowrd.png"
                                : "assets/images/HidePassword.png",
                            color: notifire.getgreycolor,
                          ),
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter your password'.tr : null,
                  );
                }),

                // ===== Provider-specific fields =====
                const SizedBox(height: 28),
                Text(
                  "Service details".tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: signUpController.agencyName,
                  cursorColor: notifire.getwhiteblackcolor,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: _inputStyle,
                  decoration: _dec("Agency / Business name".tr),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Please enter your business name".tr : null,
                ),
                const SizedBox(height: 20),
                GetBuilder<SignUpController>(builder: (c) {
                  return DropdownButtonFormField<String>(
                    initialValue: signUpController.serviceType,
                    items: _serviceTypes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.tr)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) signUpController.setServiceType(v);
                    },
                    decoration: _dec("Primary service type".tr),
                    style: _inputStyle,
                    dropdownColor: notifire.getboxcolor,
                  );
                }),
                const SizedBox(height: 20),
                TextFormField(
                  controller: signUpController.yearsExperience,
                  cursorColor: notifire.getwhiteblackcolor,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: _inputStyle,
                  decoration: _dec("Years of experience".tr),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? "Please enter years of experience".tr : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: signUpController.licenseNumber,
                  cursorColor: notifire.getwhiteblackcolor,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: _inputStyle,
                  decoration: _dec("License / Certification number (optional)".tr),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: signUpController.referralCode,
                  cursorColor: notifire.getwhiteblackcolor,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: _inputStyle,
                  decoration: _dec("Referral code (optional)".tr),
                ),

                const SizedBox(height: 10),
                GetBuilder<SignUpController>(builder: (c) {
                  return Row(
                    children: [
                      Transform.scale(
                        scale: 1,
                        child: Checkbox(
                          value: signUpController.chack,
                          side: const BorderSide(color: Color(0xffC5CAD4)),
                          activeColor: blueColor,
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          onChanged: (newbool) async {
                            signUpController.checkTermsAndCondition(newbool);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('Remember', true);
                          },
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "By creating an account,you agree to our".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: notifire.getgreycolor,
                                fontFamily: FontFamily.gilroyMedium,
                              ),
                            ),
                            Text(
                              "Terms and Condition".tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: blueColor,
                                fontFamily: FontFamily.gilroyBold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                GestButton(
                  Width: Get.size.width,
                  height: 50,
                  buttoncolor: blueColor,
                  margin: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 30),
                  buttontext: "Continue".tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: WhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: _onSubmit,
                ),
                Center(
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
                        onTap: () => Get.to(LoginScreen()),
                        child: Text(
                          " ${"Login".tr}",
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
    );
  }

  void _onSubmit() {
    setState(() {
      isvalidate = signUpController.number.text.isEmpty;
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!signUpController.chack) {
      showToastMessage("Please select Terms and Condition".tr);
      return;
    }
    signUpController.smstype().then((msgtype) {
      signUpController.checkMobileNumber(cuntryCode).then((value) {
        if (value != "true") return;
        // OTP currently bypassed to mirror existing recipient flow.
        signUpController.setUserApiData(cuntryCode).then((result) {
          if (result["Result"] == "true") {
            final countryData = selectCountryController.countryInfo?.countryData;
            if (countryData != null && countrySelected < countryData.length) {
              save("countryId", countryData[countrySelected].id ?? "");
              save("countryName", countryData[countrySelected].title ?? "");
              selectCountryController.changeCountryIndex(countrySelected);
            }
            homePageController.getHomeDataApi(countryId: getData.read("countryId"));
            homePageController.getCatWiseData(
                countryId: getData.read("countryId"), cId: "0");
            searchController.getSearchData(countryId: getData.read("countryId"));
            Get.offAndToNamed(Routes.bottoBarScreen);
            _initPlatformState();
          } else {
            showToastMessage(result["ResponseMsg"] ?? "Signup failed".tr);
          }
        });
      });
    });
  }

  Future<void> _initPlatformState() async {
    OneSignal.initialize(Config.oneSignel);
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission $state");
    });
  }
}
