// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/firebase/auth_service.dart';
import 'package:gotocarefinder/model/msgotp_model.dart';
import 'package:gotocarefinder/screen/viewprofile_screen.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController extends GetxController implements GetxService {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController referralCode = TextEditingController();

  // ===== Role-specific signup fields =====
  // userType: "recipient" (someone needing care) or "provider" (someone offering care).
  // Set by SignUpRoleSelectScreen before navigating to the corresponding signup form.
  String userType = "recipient";

  // Recipient-only
  String careNeededFor = "Self"; // Self / Parent / Spouse / Other

  // Provider-only
  TextEditingController agencyName = TextEditingController();
  String serviceType = "Home Care"; // Home Care / Adult Family Home
  TextEditingController yearsExperience = TextEditingController();
  TextEditingController licenseNumber = TextEditingController();

  void setUserType(String type) {
    userType = type;
    update();
  }

  void setCareNeededFor(String v) {
    careNeededFor = v;
    update();
  }

  void setServiceType(String v) {
    serviceType = v;
    update();
  }

  bool showPassword = true;
  bool chack = false;
  int currentIndex = 0;

  String userMessage = "";
  String resultCheck = "";
  String signUpMsg = "";

  showOfPassword() {
    showPassword = !showPassword;
    update();
  }

  checkTermsAndCondition(bool? newbool) {
    chack = newbool ?? false;
    update();
  }

  cleanFild() {
    name.text = "";
    email.text = "";
    number.text = "";
    password.text = "";
    referralCode.text = "";
    agencyName.text = "";
    yearsExperience.text = "";
    licenseNumber.text = "";
    careNeededFor = "Self";
    serviceType = "Home Care";
    chack = false;
    update();
  }

  changeIndex(int index) {
    currentIndex = index;
    update();
  }

  Future smstype() async {
    var response =
        await http.get(Uri.parse(Config.path + Config.smstype), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      var smsdecode = jsonDecode(response.body);
      update();
      print(
          " SMS CODE TYPE >>>>>>>>>>>>>> : : : : : :${smsdecode["SMS_TYPE"]}");
      return smsdecode;
    }
  }

  Future checkMobileNumber(String cuntryCode) async {
    print(cuntryCode);
    try {
      Map map = {
        "mobile": number.text,
        "ccode": cuntryCode,
      };
      Uri uri = Uri.parse(Config.path + Config.mobileChack);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        userMessage = result["ResponseMsg"];
        resultCheck = result["Result"];
        print("MMMMMMMMMMMMMMMMMM" + userMessage);

        showToastMessage(userMessage);
        return resultCheck;
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  Future checkMobileInResetPassword(
      {String? number, String? cuntryCode}) async {
    try {
      Map map = {
        "mobile": number,
        "ccode": cuntryCode,
      };
      Uri uri = Uri.parse(Config.path + Config.mobileChack);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        userMessage = result["ResponseMsg"];
        resultCheck = result["Result"];

        return resultCheck;
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  MsgotpModel? msgotpData;
  String otpCode = "";
  Future sendOtp(cuntryCode, number) async {
    Map body = {"mobile": cuntryCode + number};

    var response = await http.post(Uri.parse(Config.path + Config.msgotp),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        });
    print("><<<<<<<<<<<<<<<<<<$body");

    if (response.statusCode == 200) {
      var msgdecode = jsonDecode(response.body);

      if (msgdecode["Result"] == "true") {
        msgotpData = msgotpModelFromJson(response.body);
        otpCode = msgotpData!.otp.toString();
        print("><<<<<<<<<<<<<<<<<<$otpCode");
        update();
        return msgdecode;
      } else {
        showToastMessage(msgdecode["ResponseMsg"]);
      }
    } else {
      showToastMessage("Something went wrong!");
    }
  }

  String twilloCode = "";
  Future twilloOtp(cuntryCode, number) async {
    Map body = {"mobile": cuntryCode + number};

    var response = await http.post(Uri.parse(Config.path + Config.twillotp),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        });
    print("><<<<<<<<<<<<<<<<<<$body");

    if (response.statusCode == 200) {
      var msgdecode = jsonDecode(response.body);

      if (msgdecode["Result"] == "true") {
        print(" OTP CODE : >>> ${msgdecode["otp"]}");
        update();
        return msgdecode;
      } else {
        showToastMessage('Invalid Mobile Number');
      }
    } else {
      showToastMessage("Something went wrong!");
    }
  }

  // ========== LOCAL DEVELOPMENT BYPASS ==========
  // Set to true to skip real registration API and use mock user data
  // WARNING: Set back to false before deploying to production!
  static const bool LOCAL_DEV_BYPASS = false; // PRODUCTION READY
  
  Future setUserApiData(String cuntryCode) async {
    final prefs = await SharedPreferences.getInstance();

    // BYPASS MODE: Skip API call and create mock user for local testing
    if (LOCAL_DEV_BYPASS) {
      print("⚠️ LOCAL_DEV_BYPASS ENABLED - Skipping real registration API");
      
      // Create mock user data
      var mockUserData = {
        "id": "999",
        "name": name.text,
        "email": email.text,
        "mobile": number.text,
        "ccode": cuntryCode,
        "password": password.text,
        "pro_pic": "",
        "refercode": "MOCK123",
        "wallet": "0",
        "status": "1",
      };
      
      await prefs.setBool('Firstuser', true);
      save("UserLogin", mockUserData);
      signUpMsg = "Registration successful (Local Dev Mode)";
      showToastMessage(signUpMsg);
      
      print("✅ Mock user created: $mockUserData");
      update();
      
      return {
        "ResponseCode": "200",
        "Result": "true",
        "ResponseMsg": signUpMsg,
        "UserLogin": mockUserData
      };
    }

    // NORMAL MODE: Call actual registration API
    Map map = {
      "name": name.text,
      "email": email.text,
      "mobile": number.text,
      "ccode": cuntryCode,
      "password": password.text,
      "user_type": userType,
    };

    // Role-specific fields
    if (userType == "provider") {
      map["agency_name"] = agencyName.text;
      map["service_type"] = serviceType;
      map["years_experience"] = yearsExperience.text;
      map["license_number"] = licenseNumber.text;
    } else {
      map["care_needed_for"] = careNeededFor;
    }

    // Only send referral code if user actually entered one
    // FIXED: Backend expects 'refercode' not 'rcode'
    if (referralCode.text.isNotEmpty) {
      map["refercode"] = referralCode.text;
    }
    
    print("SIGNUP REQUEST DATA: $map");
    Uri uri = Uri.parse(Config.path + Config.registerUser);
    var response = await http.post(
      uri,
      body: jsonEncode(map),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print("SIGNUP API RESPONSE: $result");
      
      await prefs.setBool('Firstuser', true);
      signUpMsg = result["ResponseMsg"] ?? "Registration response received";
      showToastMessage(signUpMsg);
      
      if (result["UserLogin"] != null) {
        save("UserLogin", result["UserLogin"]);
        
        try {
          firebaseNewuser();
        } catch (e) {
          print("Firebase newuser error: $e");
        }
        
        try {
          var userId = result["UserLogin"]["id"];
          if (userId != null) {
            OneSignal.User.addTagWithKey("user_id", userId.toString());
          }
        } catch (e) {
          print("OneSignal tag error: $e");
        }
      } else {
        print("WARNING: UserLogin is null in response");
      }
      
      update();
    }
    print("${jsonDecode(response.body)}");
    return jsonDecode(response.body);
  }

  firebaseNewuser() async {
    AuthService authService = AuthService();
    try {
      var userLogin = getData.read("UserLogin");
      if (userLogin != null) {
        await authService.singUpAndStore(
            proPicPath: userLogin["pro_pic"] ?? "",
            email: email.text,
            uid: userLogin["id"]?.toString() ?? "");
      } else {
        print("Cannot create Firebase user - UserLogin is null");
      }
    } catch (e) {
      print("firebaseNewuser error: $e");
    }
  }

  editProfileApi({String? name, String? email}) async {
    try {
      Map map = {
        "name": name,
        "uid": getData.read("UserLogin")["id"].toString(),
        "password": getData.read("UserLogin")["password"],
        "email": email,
      };

      Uri uri = Uri.parse(Config.path + Config.editProfileApi);

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("jsonEncode(map)" + jsonEncode(map));
      print("uri" + uri.toString());
      if (response.statusCode == 200) {
        print("resulaat_________________" + response.body);
        var result = jsonDecode(response.body);
        print("result_________________" + jsonEncode(result));

        save("UserLogin", result["UserLogin"]);
        editProfile(getData.read("UserLogin")["id"], name ?? "");
      }

      Get.back();
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
