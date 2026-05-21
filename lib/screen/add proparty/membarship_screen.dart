// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unnecessary_brace_in_string_interps, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/extraimage_controller.dart';
import 'package:gotocarefinder/controller/reviewlist_controller.dart';
import 'package:gotocarefinder/firebase/chats_list.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/booking_controller.dart';
import '../../controller/enquiry_controller.dart';
import '../../controller/gallerycategory_controller.dart';
import '../../controller/galleryimage_controller.dart';
import '../../controller/listofproperti_controller.dart';
import '../../controller/myearning_controller.dart';
import '../login_screen.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  DashBoardController dashBoardController = Get.find();
  ReviewlistController reviewlistController = Get.put(ReviewlistController());
  MyEarningController myEarningController = Get.find();
  ListOfPropertiController listOfPropertiController = Get.find();
  ExtraImageController extraImageController = Get.find();
  GalleryCategoryController galleryCategoryController = Get.find();
  GalleryImageController galleryImageController = Get.find();
  BookingController bookingController = Get.find();
  EnquiryController enquiryController = Get.find();

  // COMMENTED OUT: Advert functionality disabled
  List<String> routesList = [];
  // List<String> routesList = [
  //   Routes.listOfPropertyScreen,
  //   Routes.extraImageScreen,
  //   Routes.galleryCategoryScreen,
  //   Routes.galleryImageScreen,
  //   Routes.bookingScreen,
  //   Routes.myEarningsScreen,
  //   Routes.enquiryScreen,
  //   Routes.reviewlistScreen,
  //   Routes.myPayoutScreen,
  // ];

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

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
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Get.to(ChatList());
            },
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Center(
                child: Image.asset(
                  "assets/images/Chat.png",
                  // height: 2,
                  width: 28,
                  fit: BoxFit.cover,
                  color: blueColor,
                ),
              ),
              decoration: BoxDecoration(
                border: Border.all(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
        leading: getData.read("userType") == "admin"
            ? GestureDetector(
                onTap: () {
                  logoutSheet();
                },
                child: Image.asset(
                  "assets/images/Logout.png",
                  height: 20,
                  width: 30,
                  scale: 3,
                  color: notifire.getredcolor,
                ),
              )
            : BackButton(
                color: notifire.getwhiteblackcolor,
                onPressed: () {
                  Get.back();
                },
              ),
        title: Image.asset(
          "assets/images/applogo.png",
          height: 30,
          width: 30,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 2),
            () {
              dashBoardController.getDashBoardData();
            },
          );
        },
        child: GetBuilder<DashBoardController>(builder: (context) {
          return dashBoardController.isLoading
              ? SizedBox(
                  height: Get.size.height,
                  width: Get.size.width,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        getData.read("userType") == "admin"
                            ? SizedBox()
                            : Column(
                                children: [
                                  Center(
                                    child: InkWell(
                                      onTap: () {
                                        dashBoardController
                                            .getSubScribeDetails();
                                        // COMMENTED OUT: Advert functionality disabled
                                        // Get.toNamed(Routes.memberShipDetails);
                                      },
                                      child: Container(
                                        height: 50,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        // width: 295,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/verified_user.png",
                                              height: 25,
                                              width: 25,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  dashBoardController
                                                      .membershipData[0],
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    fontSize: 16,
                                                    color: Color(0xff3D5BF6),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  "Membership".tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    fontSize: 16,
                                                    color: notifire
                                                        .getwhiteblackcolor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Container(
                                              height: 25,
                                              width: 70,
                                              alignment: Alignment.center,
                                              child: Text(
                                                "ACTIVE".tr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: WhiteColor,
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Color(0xff3D5BF6),
                                              ),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: notifire.getborderColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Valid Till: ".tr,
                                          style: TextStyle(
                                            color: notifire.getwhiteblackcolor,
                                            fontFamily: FontFamily.gilroyMedium,
                                          ),
                                        ),
                                        Text(
                                          dashBoardController.membershipData[1],
                                          style: TextStyle(
                                            color: Color(0xff3D5BF6),
                                            fontFamily: FontFamily.gilroyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: GridView.builder(
                              itemCount: getData.read("userType") == "admin"
                                  ? dashBoardController
                                          .dashBoardInfo!.reportData.length -
                                      1
                                  : dashBoardController
                                      .dashBoardInfo!.reportData.length,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                mainAxisExtent: 115,
                              ),
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    if (index == 7) {
                                      reviewlistController.reviewlist().then(
                                        (value) {
                                          if (value["Result"] == "true") {
                                            Get.toNamed(routesList[index]);
                                          } else {
                                            showToastMessage("No Review");
                                          }
                                        },
                                      );
                                    } else if (index == 5) {
                                      myEarningController
                                          .getEarningsData()
                                          .then(
                                        (value) {
                                          Get.toNamed(routesList[index]);
                                        },
                                      );
                                    } else if (index == 0) {
                                      listOfPropertiController
                                          .getPropertiList();
                                      Get.toNamed(routesList[index]);
                                    } else if (index == 1) {
                                      extraImageController.getExtraImageList();
                                      Get.toNamed(routesList[index]);
                                    } else if (index == 2) {
                                      galleryCategoryController
                                          .getGalleryCategoryList();
                                      Get.toNamed(routesList[index]);
                                    } else if (index == 3) {
                                      galleryImageController
                                          .getGalleryImageList()
                                          .then(
                                        (value) {
                                          Get.toNamed(routesList[index]);
                                        },
                                      );
                                    } else if (index == 4) {
                                      bookingController.getBookingStatusWise();
                                      Get.toNamed(routesList[index]);
                                    } else if (index == 6) {
                                      enquiryController.enquiryListApi();
                                      Get.toNamed(routesList[index]);
                                    } else {
                                      Get.toNamed(routesList[index]);
                                    }
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 115,
                                        width: 170,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: getData.read("lCode") ==
                                                      "ar_IN"
                                                  ? EdgeInsets.only(right: 15)
                                                  : EdgeInsets.only(left: 15),
                                              child: index / 5 == 1
                                                  ? Text(
                                                      "${currency}${dashBoardController.dashBoardInfo?.reportData[index].reportData ?? ""}",
                                                      style: TextStyle(
                                                        fontSize: 25,
                                                        color:
                                                            Color(0xff3D5BF6),
                                                        fontFamily: FontFamily
                                                            .gilroyExtraBold,
                                                      ),
                                                    )
                                                  : index / 8 == 1
                                                      ? Text(
                                                          "${currency}${dashBoardController.dashBoardInfo?.reportData[index].reportData ?? ""}",
                                                          style: TextStyle(
                                                            fontSize: 25,
                                                            color: Color(
                                                                0xff3D5BF6),
                                                            fontFamily: FontFamily
                                                                .gilroyExtraBold,
                                                          ),
                                                        )
                                                      : Text(
                                                          "${dashBoardController.dashBoardInfo?.reportData[index].reportData ?? ""}",
                                                          style: TextStyle(
                                                            fontSize: 25,
                                                            color: Color(
                                                                0xff3D5BF6),
                                                            fontFamily: FontFamily
                                                                .gilroyExtraBold,
                                                          ),
                                                        ),
                                            ),
                                            Padding(
                                              padding: getData.read("lCode") ==
                                                      "ar_IN"
                                                  ? EdgeInsets.only(right: 15)
                                                  : EdgeInsets.only(left: 15),
                                              child: Text(
                                                dashBoardController
                                                        .dashBoardInfo
                                                        ?.reportData[index]
                                                        .title ??
                                                    "",
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Color(0xff3D5BF6),
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 15,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade200),
                                          image: DecorationImage(
                                            image: getData.read("lCode") ==
                                                    "ar_IN"
                                                ? AssetImage(
                                                    "assets/images/Frame2.png")
                                                : AssetImage(
                                                    "assets/images/Frame.png"),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0.5,
                                        right: 16.5,
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(15),
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                "${Config.imageUrl}${dashBoardController.dashBoardInfo?.reportData[index].url ?? ""}",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: 20, left: 10, right: 10, bottom: 10),
                          child: Image.asset(
                            height: 270,
                            "assets/images/addpropartyimg.png",
                            fit: BoxFit.fill,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        }),
      ),
    );
  }

  Future<dynamic> isUserLogOut(String uid) async {
    // CollectionReference collectionReference =
    // FirebaseFirestore.instance.collection('users');
    // collectionReference.doc(uid).update({"token": ""});
  }

  Future logoutSheet() {
    return Get.bottomSheet(
      Container(
        height: 220,
        width: Get.size.width,
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Logout".tr,
              style: TextStyle(
                fontSize: 20,
                fontFamily: FontFamily.gilroyBold,
                color: RedColor,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Divider(
                color: notifire.getborderColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Are you sure you want to log out?".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Cancle".tr,
                        style: TextStyle(
                          color: blueColor,
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFeef4ff),
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      setState(() async {
                        isUserLogOut(getData.read("UserLogin")["id"]).then(
                          (value) async {
                            save('isLoginBack', true);
                            await prefs.remove('Firstuser');
                            getData.remove("UserLogin");
                            getData.remove("countryId");
                            getData.remove("countryName");
                            getData.remove("currentIndex");
                            tokenemty();

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                        );
                      });
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes, Logout".tr,
                        style: TextStyle(
                          color: WhiteColor,
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 16,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
        decoration: BoxDecoration(
          color: notifire.getbgcolor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }

  Future<dynamic> tokenemty() async {
    // CollectionReference collectionReference =
    // FirebaseFirestore.instance.collection('users');
    // collectionReference
    //     .doc(getData.read("UserLogin")["id"])
    //     .update({"token": ""});
  }
}
