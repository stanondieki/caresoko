// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unused_local_variable, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously, unused_field, non_constant_identifier_names, unused_element, deprecated_member_use, prefer_typing_uninitialized_variables
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/faq_controller.dart';
import 'package:gotocarefinder/controller/login_controller.dart';
import 'package:gotocarefinder/controller/mybooking_controller.dart';
import 'package:gotocarefinder/controller/pagelist_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/controller/wallet_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isdark = false;
  final LoginController loginController = Get.find();
  final PageListController pageListController = Get.find();
  final WalletController walletController = Get.find();
  final FaqController faqController = Get.find();
  final MyBookingController myBookingController = Get.find();
  final SelectCountryController selectCountryController = Get.find();

  String userName = "";
  SharedPreferences? prefs;

  String? path;
  String? networkimage;
  String? base64Image;
  final ImagePicker imgpicker = ImagePicker();
  PickedFile? imageFile;
  List imageList = [];

  late ColorNotifire notifire;

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
    if (getData.read("UserLogin") != null) {
      setState(() {
        userName = getData.read("UserLogin")["name"] ?? "";
        networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
        if (getData.read("UserLogin")["pro_pic"] != "null") {
          networkimageconvert();
        }
      });
    }
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  networkimageconvert() {
    (() async {
      http.Response response = await http.get(Uri.parse(Config.imageUrl + networkimage.toString()));
      if (mounted) {
        setState(() {
          base64Image = const Base64Encoder().convert(response.bodyBytes);
        });
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    final padding = R.screenPadding(context);
    final avatarSize = R.isDesktop(context)
        ? 160.0
        : R.isTablet(context)
        ? 140.0
        : 120.0;
    final tileHeight = R.isDesktop(context) ? 56.0 : 45.0;
    final iconSize = R.isDesktop(context) ? 34.0 : 30.0;

    return WillPopScope(
      onWillPop: () async => kIsWeb ? true : false, // allow browser back on web
      child: Scaffold(
        backgroundColor: notifire.getbgcolor,
        appBar: AppBar(
          backgroundColor: notifire.getbgcolor,
          elevation: 0,
          titleSpacing: R.isDesktop(context) ? 0 : null,
          leadingWidth: 64,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10, left: 14, bottom: 10),
            child: Image.asset("assets/images/applogo.png"),
          ),
          title: Text(
            "Profile".tr,
            style: TextStyle(fontSize: 18, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor),
          ),
          centerTitle: !R.isDesktop(context),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
            child: Scrollbar(
              thumbVisibility: kIsWeb,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: padding,
                  child: GetBuilder<SignUpController>(builder: (_) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 16),
                        // Avatar + Edit
                        GetBuilder<LoginController>(builder: (context) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              InkWell(
                                onTap: () => _openGallery(Get.context!),
                                child: SizedBox(
                                  height: avatarSize,
                                  width: avatarSize,
                                  child: path == null
                                      ? (networkimage != null && networkimage!.isNotEmpty)
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(avatarSize),
                                    child: Image.network("${Config.imageUrl}${networkimage ?? ""}", fit: BoxFit.cover),
                                  )
                                      : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: avatarSize / 2,
                                    child: Image.asset("assets/images/profile-default.png", fit: BoxFit.cover),
                                  )
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(avatarSize),
                                    child: Image.file(File(path.toString()), fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: InkWell(
                                  onTap: () => _openGallery(Get.context!),
                                  child: Container(
                                    height: 46,
                                    width: 46,
                                    decoration: BoxDecoration(color: notifire.getblackwhitecolor, shape: BoxShape.circle, boxShadow: [
                                      if (!kIsWeb) BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.08)),
                                    ]),
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset("assets/images/Edit.png"),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: 12),
                        Text(userName, style: TextStyle(fontFamily: FontFamily.gilroyBold, fontSize: 20, color: notifire.getwhiteblackcolor)),
                        SizedBox(height: 12),
                        Divider(color: notifire.getborderColor),
                        SizedBox(height: 8),

                        // ====== Primary Actions ======
                        _SettingRow(
                          children: [
                            _SettingTile(
                              title: "My Bookings".tr,
                              iconPath: "assets/images/Calendar.png",
                              onTap: () {
                                myBookingController.statusWiseBooking();
                                Get.toNamed(Routes.mybookingScreen);
                              },
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                          ],
                        ),

                        Divider(color: notifire.getborderColor),
                        SizedBox(height: 8),

                        _SettingRow(
                          children: [
                            _SettingTile(
                              title: "Profile".tr,
                              iconPath: "assets/images/user.png",
                              onTap: () => Get.toNamed(Routes.viewProfileScreen),
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                            _SettingTile(
                              title: "Notifications".tr,
                              iconPath: "assets/images/Notification.png",
                              onTap: () => Get.toNamed(Routes.notificationScreen),
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                          ],
                        ),

                        _SettingRow(
                          children: [
                            _SettingTile(
                              title: "Language".tr,
                              iconPath: "assets/images/Help Center.png",
                              trailingText: "English(US)".tr,
                              onTap: () => Get.toNamed(Routes.languageScreen),
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                          ],
                        ),

                        // Dark mode switch spans full row
                        Container(
                          height: tileHeight,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              _LeadingIcon(path: "assets/images/sun.png", size: iconSize, color: notifire.getwhiteblackcolor),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text("Dark Mode".tr, style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 16, color: notifire.getwhiteblackcolor)),
                              ),
                              Transform.scale(
                                scale: 0.9,
                                child: CupertinoSwitch(
                                  activeColor: Darkblue,
                                  value: notifire.isDark,
                                  onChanged: (value) async {
                                    final prefs = await SharedPreferences.getInstance();
                                    setState(() {
                                      notifire.isDark = value;
                                      notifire.setIsDark = value;
                                      prefs.setBool("setIsDark", value);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dynamic Page list
                        GetBuilder<PageListController>(builder: (_) {
                          if (!pageListController.isLodding) {
                            return Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                          }
                          final pages = pageListController.pageListInfo?.pagelist ?? [];
                          return _SettingRow(
                            children: [
                              for (final p in pages)
                                _SettingTile(
                                  title: p.title.toString(),
                                  iconPath: "assets/images/documentpage.png",
                                  onTap: () => Get.toNamed(Routes.loreamScreen, arguments: {"title": p.title, "description": p.description}),
                                  height: tileHeight,
                                  iconSize: iconSize,
                                  notifire: notifire,
                                ),
                            ],
                          );
                        }),

                        _SettingRow(
                          children: [
                            _SettingTile(
                              title: "Resident FAQs".tr,
                              iconPath: "assets/images/Help Center.png",
                              onTap: () {
                                faqController.faqType = "Resident";
                                faqController.getFaqDataApi();
                                Get.toNamed(Routes.faqScreen);
                              },
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                            _SettingTile(
                              title: "Provider FAQs".tr,
                              iconPath: "assets/images/Help Center.png",
                              onTap: () {
                                faqController.faqType = "Provider";
                                faqController.getFaqDataApi();
                                Get.toNamed(Routes.faqScreen);
                              },
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                          ],
                        ),

                        _SettingRow(
                          children: [
                            _SettingTile(
                              title: "Invite Friends".tr,
                              iconPath: "assets/images/invite friends.png",
                              onTap: () {
                                walletController.getReferData();
                                Get.toNamed(Routes.referFriendScreen);
                              },
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                            _SettingTile(
                              title: "Delete Account".tr,
                              iconPath: "assets/images/Delete.png",
                              onTap: () => deleteSheet(),
                              height: tileHeight,
                              iconSize: iconSize,
                              notifire: notifire,
                            ),
                          ],
                        ),

                        // Logout (accented)
                        Container(
                          height: tileHeight,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            onTap: () => logoutSheet(),
                            child: Row(
                              children: [
                                _LeadingIcon(path: "assets/images/Logout.png", size: iconSize, color: notifire.getredcolor),
                                SizedBox(width: 12),
                                Text("Logout".tr, style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 16, color: notifire.getredcolor)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> tokenemty() async {
    // CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
    // collectionReference.doc(getData.read("UserLogin")["id"]).update({"token": ""});
  }

  Future logoutSheet() {
    return Get.bottomSheet(
      Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(color: notifire.getbgcolor, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(children: [
              SizedBox(height: 16),
              Text("Logout".tr, style: TextStyle(fontSize: 20, fontFamily: FontFamily.gilroyBold, color: RedColor)),
              SizedBox(height: 16),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: notifire.getborderColor)),
              SizedBox(height: 10),
              Text("Are you sure you want to log out?".tr, style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 16, color: notifire.getwhiteblackcolor)),
              SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Color(0xFFeef4ff), borderRadius: BorderRadius.circular(45)),
                      child: Text("Cancel".tr, style: TextStyle(color: blueColor, fontFamily: FontFamily.gilroyBold, fontSize: 16)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      save('isLoginBack', true);
                      await prefs.remove('Firstuser');
                      getData.remove("UserLogin");
                      getData.remove("countryId");
                      getData.remove("countryName");
                      getData.remove("currentIndex");
                      await tokenemty();
                      if (mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                      }
                    },
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: blueColor, borderRadius: BorderRadius.circular(45)),
                      child: Text("Yes, Logout".tr, style: TextStyle(color: WhiteColor, fontFamily: FontFamily.gilroyBold, fontSize: 16)),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
      isScrollControlled: false,
    );
  }

  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      path = pickedFile.path;
      setState(() {});
      File imageFile = File(path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
      loginController.updateProfileImage(base64Image);
      setState(() {});
    }
  }

  Future deleteSheet() {
    return Get.bottomSheet(
      Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(color: notifire.getbgcolor, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(children: [
              SizedBox(height: 16),
              Text("Delete Account".tr, style: TextStyle(fontSize: 20, fontFamily: FontFamily.gilroyBold, color: RedColor)),
              SizedBox(height: 16),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: notifire.getgreycolor)),
              SizedBox(height: 10),
              Text("Are you sure you want to delete account?".tr, style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 16, color: notifire.getwhiteblackcolor)),
              SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Color(0xFFeef4ff), borderRadius: BorderRadius.circular(45)),
                      child: Text("Cancle".tr, style: TextStyle(color: blueColor, fontFamily: FontFamily.gilroyBold, fontSize: 16)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => pageListController.deletAccount(),
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.all(12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: blueColor, borderRadius: BorderRadius.circular(45)),
                      child: Text("Yes, Remove".tr, style: TextStyle(color: WhiteColor, fontFamily: FontFamily.gilroyBold, fontSize: 16)),
                    ),
                  ),
                )
              ])
            ]),
          ),
        ),
      ),
      isScrollControlled: false,
    );
  }
}

// ===================== Responsive Settings Layout =====================
class _SettingRow extends StatelessWidget {
  final List<_SettingTile> children;
  const _SettingRow({required this.children});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    // Guard for empty lists to avoid RangeError on wide screens
    if (children.isEmpty) return const SizedBox.shrink();

    // On narrow screens, or when there's only one tile, stack vertically
    if (!isWide || children.length == 1) {
      return Column(children: children);
    }

    // On wide screens, show two tiles per row; last row may have 1 tile
    final rows = <List<_SettingTile>>[];
    for (var i = 0; i < children.length; i += 2) {
      final end = (i + 2 > children.length) ? children.length : i + 2;
      rows.add(children.sublist(i, end));
    }

    return Column(
      children: [
        for (final row in rows)
          Row(
            children: [
              Expanded(child: row[0]),
              if (row.length == 2) ...[
                const SizedBox(width: 16),
                Expanded(child: row[1]),
              ],
            ],
          ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final String? trailingText;
  final VoidCallback onTap;
  final double height;
  final double iconSize;
  final ColorNotifire notifire;

  const _SettingTile({
    required this.title,
    required this.iconPath,
    required this.onTap,
    required this.height,
    required this.iconSize,
    required this.notifire,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _LeadingIcon(path: iconPath, size: iconSize, color: Provider.of<ColorNotifire>(context, listen: false).getwhiteblackcolor),
            SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 16, color: notifire.getwhiteblackcolor)),
            ),
            if ((trailingText ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(trailingText!, style: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 16, color: notifire.getwhiteblackcolor)),
              ),
            Icon(Icons.arrow_forward_ios, size: 17, color: notifire.getwhiteblackcolor),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final String path;
  final double size;
  final Color color;
  const _LeadingIcon({required this.path, required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Image.asset(path, height: size, width: size, color: color);
  }
}





// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unused_local_variable, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously, unused_field, non_constant_identifier_names, unused_element, deprecated_member_use, prefer_typing_uninitialized_variables
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/faq_controller.dart';
// import 'package:gotocarefinder/controller/login_controller.dart';
// import 'package:gotocarefinder/controller/mybooking_controller.dart';
// import 'package:gotocarefinder/controller/pagelist_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/controller/signup_controller.dart';
// import 'package:gotocarefinder/controller/wallet_controller.dart';
// import 'package:gotocarefinder/firebase/chats_list.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/login_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   bool isdark = false;
//   LoginController loginController = Get.find();
//
//   PageListController pageListController = Get.find();
//   WalletController walletController = Get.find();
//   FaqController faqController = Get.find();
//   MyBookingController myBookingController = Get.find();
//   SelectCountryController selectCountryController = Get.find();
//
//   String userName = "";
//   SharedPreferences? prefs;
//
//   String? path;
//   String? networkimage;
//   String? base64Image;
//   final ImagePicker imgpicker = ImagePicker();
//   PickedFile? imageFile;
//   List imageList = [];
//
//   @override
//   void initState() {
//     getdarkmodepreviousstate();
//     super.initState();
//     getData.read("UserLogin") != null
//         ? setState(() {
//             userName = getData.read("UserLogin")["name"] ?? "";
//             networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
//             getData.read("UserLogin")["pro_pic"] != "null"
//                 ? setState(() {
//                     networkimageconvert();
//                   })
//                 : const SizedBox();
//           })
//         : null;
//   }
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
//   networkimageconvert() {
//     (() async {
//       http.Response response =
//           await http.get(Uri.parse(Config.imageUrl + networkimage.toString()));
//       if (mounted) {
//         print(response.bodyBytes);
//         setState(() {
//           base64Image = const Base64Encoder().convert(response.bodyBytes);
//         });
//       }
//     })();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return WillPopScope(
//       onWillPop: () async {
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: notifire.getbgcolor,
//         appBar: AppBar(
//           backgroundColor: notifire.getbgcolor,
//           elevation: 0,
//           leading: Padding(
//             padding: const EdgeInsets.only(top: 15, left: 14, bottom: 15),
//             child: Image.asset(
//               "assets/images/applogo.png",
//               height: 10,
//               width: 10,
//             ),
//           ),
//           title: Text(
//             "Profile".tr,
//             style: TextStyle(
//               fontSize: 17,
//               fontFamily: FontFamily.gilroyBold,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         body: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: GetBuilder<SignUpController>(builder: (context) {
//             return SingleChildScrollView(
//               physics: BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     height: 20,
//                   ),
//                   GetBuilder<LoginController>(builder: (context) {
//                     return Stack(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             _openGallery(Get.context!);
//                           },
//                           child: SizedBox(
//                             height: 120,
//                             width: 120,
//                             child: path == null
//                                 ? networkimage != ""
//                                     ? ClipRRect(
//                                         borderRadius: BorderRadius.circular(80),
//                                         child: Image.network(
//                                           "${Config.imageUrl}${networkimage ?? ""}",
//                                           fit: BoxFit.cover,
//                                         ),
//                                       )
//                                     : CircleAvatar(
//                                         backgroundColor: Colors.transparent,
//                                         radius: Get.height / 17,
//                                         child: Image.asset(
//                                           "assets/images/profile-default.png",
//                                           fit: BoxFit.cover,
//                                         ),
//                                       )
//                                 : ClipRRect(
//                                     borderRadius: BorderRadius.circular(80),
//                                     child: Image.file(
//                                       File(path.toString()),
//                                       width: Get.width,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 5,
//                           right: -5,
//                           child: InkWell(
//                             onTap: () {
//                               _openGallery(Get.context!);
//                             },
//                             child: Container(
//                               height: 45,
//                               width: 45,
//                               padding: EdgeInsets.all(7),
//                               child: Image.asset(
//                                 "assets/images/Edit.png",
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   }),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     userName,
//                     style: TextStyle(
//                       fontFamily: FontFamily.gilroyBold,
//                       fontSize: 20,
//                       color: notifire.getwhiteblackcolor,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Divider(
//                       color: notifire.getborderColor,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   settingWidget(
//                     name: "My Bookings".tr,
//                     imagePath: "assets/images/Calendar.png",
//                     onTap: () {
//                       myBookingController.statusWiseBooking();
//                       Get.toNamed(Routes.mybookingScreen);
//                     },
//                   ),
//                   /*SizedBox(
//                     height: 10,
//                   ),
//                   settingWidget(
//                     name: "Wallet".tr,
//                     imagePath: "assets/images/Wallet.png",
//                     onTap: () {
//                       Get.toNamed(Routes.walletScreen);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   settingWidget(
//                     name: "Chat".tr,
//                     imagePath: "assets/images/Chat.png",
//                     onTap: () {
//                       Get.to(ChatList());
//                     },
//                   ),*/
//                   SizedBox(
//                     height: 5,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Divider(
//                       color: notifire.getborderColor,
//                       thickness: 1,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 5,
//                   ),
//                   settingWidget(
//                     name: "Profile".tr,
//                     imagePath: "assets/images/user.png",
//                     onTap: () {
//                       Get.toNamed(Routes.viewProfileScreen);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   settingWidget(
//                     name: "Notifications".tr,
//                     imagePath: "assets/images/Notification.png",
//                     onTap: () {
//                       Get.toNamed(Routes.notificationScreen);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   SizedBox(
//                     height: 40,
//                     width: Get.size.width,
//                     child: InkWell(
//                       onTap: () {
//                         selectCountryController.getCountryApi().then(
//                               (value) =>
//                                   Get.toNamed(Routes.selectCountryScreen),
//                             );
//                       },
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Image.asset(
//                             "assets/images/Locationa.png",
//                             height: 35,
//                             width: 30,
//                             color: notifire.getwhiteblackcolor,
//                           ),
//                           SizedBox(
//                             width: 15,
//                           ),
//                           Text(
//                             "Country".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                           Spacer(),
//                           Text(
//                             getData.read("countryName") == ""
//                                 ? ""
//                                 : getData.read("countryName"),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 17,
//                             color: notifire.getwhiteblackcolor,
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   SizedBox(
//                     height: 40,
//                     width: Get.size.width,
//                     child: InkWell(
//                       onTap: () {
//                         Get.toNamed(Routes.languageScreen);
//                       },
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Image.asset(
//                             "assets/images/Help Center.png",
//                             height: 35,
//                             width: 30,
//                             color: notifire.getwhiteblackcolor,
//                           ),
//                           SizedBox(
//                             width: 15,
//                           ),
//                           Text(
//                             "Language".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                           Spacer(),
//                           Text(
//                             "English(US)".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                           Icon(
//                             Icons.arrow_forward_ios,
//                             size: 17,
//                             color: notifire.getwhiteblackcolor,
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   darkModeWidget(),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   GetBuilder<PageListController>(builder: (context) {
//                     return pageListController.isLodding
//                         ? ListView.builder(
//                             itemCount: pageListController
//                                 .pageListInfo?.pagelist!.length,
//                             shrinkWrap: true,
//                             itemExtent: 60,
//                             physics: const NeverScrollableScrollPhysics(),
//                             padding: EdgeInsets.zero,
//                             itemBuilder: (context, index) {
//                               return InkWell(
//                                 child: Column(
//                                   children: [
//                                     settingWidget(
//                                       name: pageListController
//                                           .pageListInfo?.pagelist![index].title,
//                                       imagePath:
//                                           "assets/images/documentpage.png",
//                                       onTap: () {
//                                         Get.toNamed(Routes.loreamScreen,
//                                             arguments: {
//                                               "title": pageListController
//                                                   .pageListInfo
//                                                   ?.pagelist![index]
//                                                   .title,
//                                               "discription": pageListController
//                                                   .pageListInfo
//                                                   ?.pagelist![index]
//                                                   .description,
//                                             });
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           )
//                         : Center(
//                             child: CircularProgressIndicator(),
//                           );
//                   }),
//                   settingWidget(
//                     name: "Resident FAQs".tr,
//                     imagePath: "assets/images/Help Center.png",
//                     onTap: () {
//                       faqController.faqType = "Resident";
//                       faqController.getFaqDataApi();
//                       Get.toNamed(Routes.faqScreen);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   settingWidget(
//                     name: "Provider FAQs".tr,
//                     imagePath: "assets/images/Help Center.png",
//                     onTap: () {
//                       faqController.faqType = "Provider";
//                       faqController.getFaqDataApi();
//                       Get.toNamed(Routes.faqScreen);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   settingWidget(
//                     name: "Invite Friends".tr,
//                     imagePath: "assets/images/invite friends.png",
//                     onTap: () {
//                       walletController.getReferData();
//                       Get.toNamed(Routes.referFriendScreen);
//                     },
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   GetBuilder<PageListController>(builder: (context) {
//                     return InkWell(
//                       onTap: () {
//                         deleteSheet();
//                       },
//                       child: SizedBox(
//                         height: 45,
//                         width: Get.size.width,
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                             ),
//                             Image.asset(
//                               "assets/images/Delete.png",
//                               height: 30,
//                               width: 25,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             SizedBox(
//                               width: 15,
//                             ),
//                             Text(
//                               "Delete Account".tr,
//                               style: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 16,
//                                 color: notifire.getwhiteblackcolor,
//                               ),
//                             ),
//                             Spacer(),
//                             Icon(
//                               Icons.arrow_forward_ios,
//                               size: 17,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             SizedBox(
//                               width: 20,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   InkWell(
//                     onTap: () {
//                       logoutSheet();
//                     },
//                     child: SizedBox(
//                       height: 40,
//                       width: Get.size.width,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Image.asset(
//                             "assets/images/Logout.png",
//                             height: 35,
//                             width: 30,
//                             color: notifire.getredcolor,
//                           ),
//                           SizedBox(
//                             width: 15,
//                           ),
//                           Text(
//                             "Logout".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getredcolor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 30,
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
//
//   Future<dynamic> tokenemty() async {
//     CollectionReference collectionReference =
//         FirebaseFirestore.instance.collection('users');
//     collectionReference
//         .doc(getData.read("UserLogin")["id"])
//         .update({"token": ""});
//   }
//
//   Widget settingWidget({Function()? onTap, String? name, String? imagePath}) {
//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         height: 45,
//         width: Get.size.width,
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 20,
//             ),
//             Image.asset(
//               imagePath ?? "",
//               height: 35,
//               width: 30,
//               color: notifire.getwhiteblackcolor,
//             ),
//             SizedBox(
//               width: 15,
//             ),
//             Text(
//               name ?? "",
//               style: TextStyle(
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 16,
//                 color: notifire.getwhiteblackcolor,
//               ),
//             ),
//             Spacer(),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 17,
//               color: notifire.getwhiteblackcolor,
//             ),
//             SizedBox(
//               width: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget darkModeWidget() {
//     return SizedBox(
//       height: 40,
//       width: Get.size.width,
//       child: Row(
//         children: [
//           SizedBox(
//             width: 20,
//           ),
//           Image.asset(
//             "assets/images/sun.png",
//             height: 35,
//             width: 30,
//             color: notifire.getwhiteblackcolor,
//           ),
//           SizedBox(
//             width: 15,
//           ),
//           Text(
//             "Dark Mode".tr,
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyMedium,
//               fontSize: 16,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//           Spacer(),
//           Transform.scale(
//             scale: 0.7,
//             child: CupertinoSwitch(
//               activeColor: Darkblue,
//               value: notifire.isDark,
//               onChanged: (value) async {
//                 setState(() {
//                   notifire.isDark = value;
//                 });
//                 final prefs = await SharedPreferences.getInstance();
//                 setState(() {
//                   notifire.setIsDark = value;
//                   prefs.setBool("setIsDark", value);
//                 });
//               },
//             ),
//           ),
//           SizedBox(
//             width: 10,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future logoutSheet() {
//     return Get.bottomSheet(
//       Container(
//         height: 220,
//         width: Get.size.width,
//         child: Column(
//           children: [
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               "Logout".tr,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontFamily: FontFamily.gilroyBold,
//                 color: RedColor,
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//               ),
//               child: Divider(
//                 color: notifire.getborderColor,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               "Are you sure you want to log out?".tr,
//               style: TextStyle(
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 16,
//                 color: notifire.getwhiteblackcolor,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: Container(
//                       height: 60,
//                       margin: EdgeInsets.all(15),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Cancel".tr,
//                         style: TextStyle(
//                           color: blueColor,
//                           fontFamily: FontFamily.gilroyBold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         color: Color(0xFFeef4ff),
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () async {
//                       final prefs = await SharedPreferences.getInstance();
//                       setState(() async {
//                         save('isLoginBack', true);
//                         await prefs.remove('Firstuser');
//                         getData.remove("UserLogin");
//                         getData.remove("countryId");
//                         getData.remove("countryName");
//                         getData.remove("currentIndex");
//                         tokenemty();
//
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LoginScreen()));
//                       });
//                     },
//                     child: Container(
//                       height: 60,
//                       margin: EdgeInsets.all(15),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Yes, Logout".tr,
//                         style: TextStyle(
//                           color: WhiteColor,
//                           fontFamily: FontFamily.gilroyBold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         color: blueColor,
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             )
//           ],
//         ),
//         decoration: BoxDecoration(
//           color: notifire.getbgcolor,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//       ),
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
//
//   Future deleteSheet() {
//     return Get.bottomSheet(
//       Container(
//         height: 220,
//         width: Get.size.width,
//         child: Column(
//           children: [
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               "Delete Account".tr,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontFamily: FontFamily.gilroyBold,
//                 color: RedColor,
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 20,
//               ),
//               child: Divider(
//                 color: notifire.getgreycolor,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               "Are you sure you want to delete account?".tr,
//               style: TextStyle(
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 16,
//                 color: notifire.getwhiteblackcolor,
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: Container(
//                       height: 60,
//                       margin: EdgeInsets.all(15),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Cancle".tr,
//                         style: TextStyle(
//                           color: blueColor,
//                           fontFamily: FontFamily.gilroyBold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         color: Color(0xFFeef4ff),
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       pageListController.deletAccount();
//                     },
//                     child: Container(
//                       height: 60,
//                       margin: EdgeInsets.all(15),
//                       alignment: Alignment.center,
//                       child: Text(
//                         "Yes, Remove".tr,
//                         style: TextStyle(
//                           color: WhiteColor,
//                           fontFamily: FontFamily.gilroyBold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       decoration: BoxDecoration(
//                         color: blueColor,
//                         borderRadius: BorderRadius.circular(45),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             )
//           ],
//         ),
//         decoration: BoxDecoration(
//           color: notifire.getbgcolor,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }
