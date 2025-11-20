// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_brace_in_string_interps, sized_box_for_whitespace, deprecated_member_use, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/login_controller.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add proparty/addproperty_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final TextEditingController fname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController number = TextEditingController();

  final LoginController loginController = Get.find();
  final SignUpController signUpController = Get.find();

  String? networkimage;
  String? base64Image;
  Uint8List? _pickedBytes; // works on web & mobile
  final ImagePicker _picker = ImagePicker();

  late ColorNotifire notifire;

  String selectValue = list.first; // from your existing list in Bookinformation screen

  @override
  void initState() {
    super.initState();
    _restoreTheme();
    if (getData.read("UserLogin") != null) {
      final u = getData.read("UserLogin");
      fname.text = u["name"] ?? "";
      number.text = u["mobile"] ?? "";
      email.text = u["email"] ?? "";
      networkimage = u["pro_pic"] ?? "";
    }
  }

  Future<void> _restoreTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final prev = prefs.getBool("setIsDark");
    notifire.setIsDark = prev ?? false;
  }

  bool get _hasNetworkAvatar {
    final s = networkimage?.trim() ?? "";
    return s.isNotEmpty && s.toLowerCase() != "null";
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final maxFormWidth = isWide ? 720.0 : 560.0;
    final avatarSize = isWide ? 160.0 : 120.0;
    final horizontalPad = isWide ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Profile".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        centerTitle: !isWide,
      ),
      body: Scrollbar(
        thumbVisibility: kIsWeb,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxFormWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 20),
                child: GetBuilder<SignUpController>(builder: (_) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      GetBuilder<LoginController>(builder: (context) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            InkWell(
                              onTap: _pickImage,
                              child: SizedBox(
                                height: avatarSize,
                                width: avatarSize,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(avatarSize),
                                  child: _pickedBytes != null
                                      ? Image.memory(_pickedBytes!, fit: BoxFit.cover)
                                      : (_hasNetworkAvatar
                                      ? Image.network(
                                    "${Config.imageUrl}${networkimage!}",
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => _fallbackAvatar(),
                                  )
                                      : _fallbackAvatar()),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: notifire.getblackwhitecolor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.08),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Image.asset("assets/images/Edit.png"),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20),

                      // Name
                      _field(
                        controller: fname,
                        hint: "First Name".tr,
                        keyboard: TextInputType.name,
                      ),
                      SizedBox(height: 16),

                      // Role dropdown (uses your existing `list`)
                      Container(
                        height: 50,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: notifire.getborderColor),
                        ),
                        child: DropdownButton<String>(
                          value: selectValue,
                          isExpanded: true,
                          underline: SizedBox.shrink(),
                          dropdownColor: notifire.getbgcolor,
                          icon: Image.asset('assets/images/Arrow - Down.png', height: 20, width: 20),
                          items: list.map<DropdownMenuItem<String>>((String v) {
                            return DropdownMenuItem<String>(
                              value: v,
                              child: Text(
                                v,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 14,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectValue = v ?? selectValue),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Email
                      _field(
                        controller: email,
                        hint: "Email".tr,
                        keyboard: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),

                      // Phone (read-only display as in your original)
                      Container(
                        height: 50,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: notifire.getborderColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "+91",
                              style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.gilroyMedium,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                number.text,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: notifire.getwhiteblackcolor,
                                  fontFamily: FontFamily.gilroyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Update Button
                      GestButton(
                        Width: double.infinity,
                        height: 50,
                        buttoncolor: blueColor,
                        margin: EdgeInsets.only(top: 8),
                        buttontext: "Update".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          color: WhiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        onclick: () {
                          if (fname.text.isNotEmpty && email.text.isNotEmpty) {
                            signUpController.editProfileApi(
                              name: fname.text,
                              email: email.text,
                            );
                          } else {
                            showToastMessage("Enter Data".tr);
                          }
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      "assets/images/profile-default.png",
      fit: BoxFit.cover,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      cursorColor: notifire.getwhiteblackcolor,
      style: TextStyle(
        fontFamily: FontFamily.gilroyMedium,
        fontSize: 14,
        color: notifire.getwhiteblackcolor,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: notifire.getborderColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: notifire.getborderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: notifire.getborderColor),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Please enter $hint'.tr : null,
    );
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final bytes = await picked.readAsBytes(); // works on web & mobile
    _pickedBytes = bytes;
    base64Image = base64Encode(bytes);

    // Update on server via controller (your existing API)
    loginController.updateProfileImage(base64Image);

    if (mounted) setState(() {});
  }
}




// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_brace_in_string_interps, sized_box_for_whitespace, deprecated_member_use, unused_element, unnecessary_string_interpolations
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/login_controller.dart';
// import 'package:gotocarefinder/controller/signup_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/screen/bookinformation_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ViewProfileScreen extends StatefulWidget {
//   const ViewProfileScreen({super.key});
//
//   @override
//   State<ViewProfileScreen> createState() => _ViewProfileScreenState();
// }
//
// class _ViewProfileScreenState extends State<ViewProfileScreen> {
//   TextEditingController fname = TextEditingController();
//   TextEditingController lname = TextEditingController();
//   TextEditingController email = TextEditingController();
//   TextEditingController number = TextEditingController();
//
//   LoginController loginController = Get.find();
//   SignUpController signUpController = Get.find();
//
//   String? path;
//   String? networkimage;
//   String? base64Image;
//   final ImagePicker imgpicker = ImagePicker();
//   PickedFile? imageFile;
//
//   late ColorNotifire notifire;
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     if (previusstate == null) {
//       notifire.setIsDark = false;
//     } else {
//       notifire.setIsDark = previusstate;
//     }
//   }
//
//   String selectValue = list.first;
//   String selectCountry = countryList.first;
//
//   @override
//   void initState() {
//     super.initState();
//     fname.text;
//     getData.read("UserLogin") != null
//         ? setState(() {
//             fname.text = getData.read("UserLogin")["name"] ?? "";
//             number.text = getData.read("UserLogin")["mobile"] ?? "";
//             email.text = getData.read("UserLogin")["email"] ?? "";
//             networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
//             networkimage != "null"
//                 ? setState(() {
//                     networkimageconvert();
//                   })
//                 : const SizedBox();
//           })
//         : null;
//   }
//
//   networkimageconvert() {
//     (() async {
//       http.Response response =
//           await http.get(Uri.parse(Config.imageUrl + networkimage.toString()));
//       if (mounted) {
//         print(response.bodyBytes);
//         setState(() {
//           base64Image = const Base64Encoder().convert(response.bodyBytes);
//           print(base64Image);
//         });
//       }
//     })();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getbgcolor,
//       appBar: AppBar(
//         backgroundColor: notifire.getbgcolor,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(
//             Icons.arrow_back,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//         title: Text(
//           "Profile".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: GetBuilder<SignUpController>(builder: (context) {
//         return SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 20,
//                 ),
//                 GetBuilder<LoginController>(builder: (context) {
//                   return Stack(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           _openGallery(Get.context!);
//                         },
//                         child: SizedBox(
//                           height: 120,
//                           width: 120,
//                           child: path == null
//                               ? networkimage != ""
//                                   ? ClipRRect(
//                                       borderRadius: BorderRadius.circular(80),
//                                       child: Image.network(
//                                         "${Config.imageUrl}${networkimage ?? ""}",
//                                         fit: BoxFit.cover,
//                                       ),
//                                     )
//                                   : CircleAvatar(
//                                       backgroundColor: Colors.transparent,
//                                       radius: Get.height / 17,
//                                       child: Image.asset(
//                                         "assets/images/profile-default.png",
//                                         fit: BoxFit.cover,
//                                       ),
//                                     )
//                               : ClipRRect(
//                                   borderRadius: BorderRadius.circular(80),
//                                   child: Image.file(
//                                     File(path.toString()),
//                                     width: Get.width,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 5,
//                         right: -5,
//                         child: InkWell(
//                           onTap: () {
//                             _openGallery(Get.context!);
//                           },
//                           child: Container(
//                             height: 45,
//                             width: 45,
//                             padding: EdgeInsets.all(7),
//                             child: Image.asset(
//                               "assets/images/Edit.png",
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: TextFormField(
//                     controller: fname,
//                     cursorColor: notifire.getwhiteblackcolor,
//                     style: TextStyle(
//                       fontFamily: FontFamily.gilroyMedium,
//                       fontSize: 14,
//                       color: notifire.getwhiteblackcolor,
//                     ),
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: notifire.getborderColor),
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: notifire.getborderColor),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: notifire.getborderColor),
//                       ),
//                       hintText: "First Name".tr,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your first name'.tr;
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   height: 50,
//                   width: Get.size.width,
//                   margin: EdgeInsets.symmetric(horizontal: 15),
//                   padding: EdgeInsets.only(left: 15, right: 15),
//                   child: DropdownButton(
//                     value: selectValue,
//                     icon: Image.asset(
//                       'assets/images/Arrow - Down.png',
//                       height: 20,
//                       width: 20,
//                     ),
//                     isExpanded: true,
//                     dropdownColor: notifire.getbgcolor,
//                     underline: SizedBox.shrink(),
//                     items: list.map<DropdownMenuItem<String>>((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(
//                           value,
//                           style: TextStyle(
//                             fontFamily: FontFamily.gilroyMedium,
//                             fontSize: 14,
//                             color: notifire.getwhiteblackcolor,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectValue = value ?? "";
//                       });
//                     },
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: notifire.getborderColor),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: TextFormField(
//                     controller: email,
//                     cursorColor: notifire.getwhiteblackcolor,
//                     style: TextStyle(
//                       fontFamily: FontFamily.gilroyMedium,
//                       fontSize: 14,
//                       color: notifire.getwhiteblackcolor,
//                     ),
//                     decoration: InputDecoration(
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: notifire.getborderColor),
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: notifire.getborderColor),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: notifire.getborderColor),
//                       ),
//                       hintText: "Email".tr,
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email'.tr;
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Container(
//                   height: 50,
//                   width: Get.size.width,
//                   margin: EdgeInsets.symmetric(horizontal: 15),
//                   padding: EdgeInsets.only(left: 15, right: 15),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "+91",
//                         style: TextStyle(
//                           color: notifire.getwhiteblackcolor,
//                           fontFamily: FontFamily.gilroyMedium,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                         "${number.text}",
//                         style: TextStyle(
//                           color: notifire.getwhiteblackcolor,
//                           fontFamily: FontFamily.gilroyMedium,
//                         ),
//                       ),
//                     ],
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(15),
//                     border: Border.all(color: notifire.getborderColor),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 GestButton(
//                   Width: Get.size.width,
//                   height: 50,
//                   buttoncolor: blueColor,
//                   margin: EdgeInsets.only(top: 15, left: 30, right: 30),
//                   buttontext: "Update".tr,
//                   style: TextStyle(
//                     fontFamily: FontFamily.gilroyBold,
//                     color: WhiteColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   onclick: () {
//                     if (fname.text.isNotEmpty && email.text.isNotEmpty) {
//                       signUpController.editProfileApi(
//                         name: fname.text,
//                         email: email.text,
//                       );
//                     } else {
//                       showToastMessage("Enter Data".tr);
//                     }
//                   },
//                 ),
//                 SizedBox(
//                   height: 30,
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   void _openGallery(BuildContext context) async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       path = pickedFile.path;
//       setState(() {});
//       File imageFile = File(path.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       base64Image = base64Encode(imageBytes);
//       loginController.updateProfileImage(base64Image);
//       setState(() {});
//     }
//   }
// }
//
Future<dynamic> editProfile(String uid, String name) async {
  // CollectionReference collectionReference =
  //     FirebaseFirestore.instance.collection('users');
  // collectionReference.doc(uid).update({"name": name});
}
