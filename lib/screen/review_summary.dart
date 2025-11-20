// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, prefer_final_fields, unused_local_variable, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_string_interpolations, prefer_const_constructors_in_immutables, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/mybooking_controller.dart';
import 'package:gotocarefinder/controller/paystack_controller.dart';
import 'package:gotocarefinder/screen/payment/2checkout.dart';
import 'package:gotocarefinder/screen/payment/Paystackweb.dart';
import 'package:gotocarefinder/screen/payment/payfast.dart';
import 'package:gotocarefinder/screen/payment/senangpay.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../controller/bookrealestate_controller.dart';
import '../controller/coupon_controller.dart';
import '../controller/homepage_controller.dart';
import '../controller/login_controller.dart';
import '../controller/reviewsummary_controller.dart';
import '../controller/wallet_controller.dart';
import '../model/fontfamily_model.dart';
import '../model/routes_helper.dart';
import '../screen/home_screen.dart';
import '../screen/payment/FlutterWave.dart';
import '../screen/payment/InputFormater.dart';
import '../screen/payment/PaymentCard.dart';
import '../screen/payment/Paytm.dart';
import '../screen/payment/StripeWeb.dart';
import '../screen/payment/khalti.dart';
import '../screen/payment/mercadopago.dart';
import '../screen/payment/midtrans.dart';
import '../screen/paypal/flutter_paypal.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import '../utils/Dark_lightmode.dart';

class ReviewSummaryScreen extends StatefulWidget {
  ReviewSummaryScreen({super.key});

  @override
  State<ReviewSummaryScreen> createState() => _ReviewSummaryScreenState();
}

class _ReviewSummaryScreenState extends State<ReviewSummaryScreen> {
  BookrealEstateController bookrealEstateController = Get.find();

  ReviewSummaryController reviewSummaryController = Get.find();
  CouponController couponController = Get.find();
  MyBookingController myBookingController = Get.find();
  HomePageController homePageController = Get.find();
  LoginController loginController = Get.find();
  PaystackController paystackController = Get.put(PaystackController());

  dynamic copAmt = Get.arguments["copAmt"];
  bool coupAdded = false;
  String fname = Get.arguments["fname"];
  String lname = Get.arguments["lname"];
  String email = Get.arguments["email"];
  String mobile = Get.arguments["mobile"];
  String ccode = Get.arguments["ccode"];

  String couponCode = Get.arguments["couponCode"];

  var tempWallet = 0.0;
  dynamic totalprice = 0.00;
  dynamic currentTotalprice = 0.00;
  bool status = false;
  var useWallet = 0.0;
  String wallet = "";
  dynamic tex = 0.00;

  late Razorpay _razorpay;

  int? _value = 0;
  int curretnIndex = 0;
  int? _groupValue;

  double price = 0;

  String? selectidPay = "0";
  String razorpaykey = "";
  String paystackID = "";
  String? paymenttital;
  String formattedDate = "";

  bool? checkLogin;

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
  void initState() {
    super.initState();
    print("------------  ===========${fname}");
    print("------------  ===========${mobile}");

    couponController.couponMsg = "";
    checkLoginOrContinue();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    price = 0;
    setState(() {
      totalprice = 0;

      wallet = homePageController.homeDatatInfo?.homeData!.wallet ?? "";

      tex = 0;

      print("££££££@@@@@@" + tex.toString());
    });
    setState(() {
      var now = DateTime.now();
      var formatter = DateFormat('dd/MM/yyyy');
      formattedDate = formatter.format(now);
      print(formattedDate);
    });
  }

  checkLoginOrContinue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print(homePageController.currentIndex);

      checkLogin = prefs.getBool('Firstuser') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        title: Text(
          "Booking Summary".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final r = _R(w);
          final isTwoCol = r.isTablet || r.isDesktop;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: GetBuilder<WalletController>(builder: (context) {
              return GetBuilder<HomePageController>(builder: (context) {
                return GetBuilder<BookrealEstateController>(builder: (context) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: r.maxContentWidth()),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: r.isPhone ? 10 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: r.spacing(10)),

                            // ==== TOP SUMMARY: image/info + date/time ====
                            if (isTwoCol)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // LEFT: image card
                                  Expanded(
                                    flex: 5,
                                    child: _SummaryCard(
                                      notifire: notifire,
                                      reviewSummaryController: reviewSummaryController,
                                      homePageController: homePageController,
                                      height: r.isDesktop ? 170 : 150,
                                    ),
                                  ),
                                  SizedBox(width: r.spacing(12)),
                                  // RIGHT: booking date/time
                                  Expanded(
                                    flex: 5,
                                    child: _BookingWhenCard(
                                      notifire: notifire,
                                      dateText: bookrealEstateController.dateOfTour,
                                      timeText: bookrealEstateController.selectedTime.toString(),
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _SummaryCard(
                                notifire: notifire,
                                reviewSummaryController: reviewSummaryController,
                                homePageController: homePageController,
                                height: 140,
                              ),
                              SizedBox(height: r.spacing(12)),
                              _BookingWhenCard(
                                notifire: notifire,
                                dateText: bookrealEstateController.dateOfTour,
                                timeText: bookrealEstateController.selectedTime.toString(),
                              ),
                            ],

                            SizedBox(height: r.spacing(16)),

                            // ==== CONTINUE / LOGIN BUTTON (constrained on web) ====
                            Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: r.isPhone ? double.infinity : 320,
                                  maxWidth: r.isPhone ? double.infinity : 420,
                                ),
                                child: GestButton(
                                  Width: double.infinity,
                                  height: 52,
                                  buttoncolor: blueColor,
                                  margin: EdgeInsets.only(
                                    top: r.spacing(8),
                                    left: r.isPhone ? 20 : 0,
                                    right: r.isPhone ? 20 : 0,
                                  ),
                                  buttontext: checkLogin == true ? "Continue".tr : "Login".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: WhiteColor,
                                    fontSize: r.t(16, desktop: 17),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onclick: () {
                                    if (checkLogin == true) {
                                      bookApiData("0");
                                    } else {
                                      Get.toNamed(Routes.login);
                                    }
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: r.spacing(20)),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              });
            }),
          );
        },
      ),
      // body: SingleChildScrollView(
      //   physics: BouncingScrollPhysics(),
      //   child: GetBuilder<WalletController>(builder: (context) {
      //     return GetBuilder<HomePageController>(builder: (context) {
      //       return GetBuilder<BookrealEstateController>(builder: (context) {
      //         return Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Container(
      //               height: 140,
      //               margin: EdgeInsets.all(10),
      //               child: Row(
      //                 children: [
      //                   Stack(
      //                     children: [
      //                       Container(
      //                         height: 140,
      //                         width: 130,
      //                         margin: EdgeInsets.all(10),
      //                         child: ClipRRect(
      //                           borderRadius: BorderRadius.circular(15),
      //                           child: FadeInImage.assetNetwork(
      //                             imageErrorBuilder:
      //                                 (context, error, stackTrace) {
      //                               return Center(
      //                                 child: Image.asset(
      //                                   "assets/images/emty.gif",
      //                                   fit: BoxFit.cover,
      //                                   height: Get.height,
      //                                 ),
      //                               );
      //                             },
      //                             fit: BoxFit.cover,
      //                             image:
      //                                 "${Config.imageUrl}${reviewSummaryController.pImage}",
      //                             placeholder:
      //                                 "assets/images/ezgif.com-crop.gif",
      //                           ),
      //                         ),
      //                         decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(15),
      //                         ),
      //                       ),
      //                       Positioned(
      //                         top: 15,
      //                         right: 20,
      //                         child: Container(
      //                           height: 20,
      //                           width: 45,
      //                           child: Row(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: [
      //                               Icon(
      //                                 Icons.star,
      //                                 size: 12,
      //                                 color: yelloColor,
      //                               ),
      //                               Text(
      //                                 "${homePageController.rate.toString()}",
      //                                 style: TextStyle(
      //                                   fontFamily: FontFamily.gilroyMedium,
      //                                   color: blueColor,
      //                                 ),
      //                               )
      //                             ],
      //                           ),
      //                           decoration: BoxDecoration(
      //                             color: Color(0xFFedeeef),
      //                             borderRadius: BorderRadius.circular(15),
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     width: 8,
      //                   ),
      //                   Expanded(
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Row(
      //                           children: [
      //                             Expanded(
      //                               child: Text(
      //                                 reviewSummaryController.pTitle,
      //                                 maxLines: 2,
      //                                 style: TextStyle(
      //                                   fontSize: 17,
      //                                   fontFamily: FontFamily.gilroyBold,
      //                                   color: notifire.getwhiteblackcolor,
      //                                   overflow: TextOverflow.ellipsis,
      //                                 ),
      //                               ),
      //                             ),
      //                             SizedBox(
      //                               width: 20,
      //                             ),
      //                           ],
      //                         ),
      //                         SizedBox(
      //                           height: 10,
      //                         ),
      //                         Text(
      //                           reviewSummaryController.pCity,
      //                           maxLines: 1,
      //                           style: TextStyle(
      //                             color: notifire.getgreycolor,
      //                             fontFamily: FontFamily.gilroyMedium,
      //                             overflow: TextOverflow.ellipsis,
      //                           ),
      //                         ),
      //                         SizedBox(height: 10),
      //                         Text(
      //                           "${reviewSummaryController.pType}",
      //                           style: TextStyle(
      //                             fontSize: 15,
      //                             fontFamily: FontFamily.gilroyBold,
      //                             color: blueColor,
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //               decoration: BoxDecoration(
      //                 color: notifire.getblackwhitecolor,
      //                 borderRadius: BorderRadius.circular(15),
      //               ),
      //             ),
      //             Container(
      //               margin: EdgeInsets.symmetric(horizontal: 10),
      //               width: Get.size.width,
      //               child: Column(
      //                 children: [
      //                   SizedBox(
      //                     height: 20,
      //                   ),
      //                   Row(
      //                     children: [
      //                       SizedBox(
      //                         width: 20,
      //                       ),
      //                       Text(
      //                         "Booking Date".tr,
      //                         style: TextStyle(
      //                           fontFamily: FontFamily.gilroyMedium,
      //                           fontSize: 15,
      //                           color: notifire.getwhiteblackcolor,
      //                         ),
      //                       ),
      //                       Spacer(),
      //                       Text(
      //                         bookrealEstateController.dateOfTour,
      //                         style: TextStyle(
      //                           fontFamily: FontFamily.gilroyBold,
      //                           fontSize: 15,
      //                           color: notifire.getwhiteblackcolor,
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         width: 20,
      //                       ),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 20,
      //                   ),
      //                   Row(
      //                     children: [
      //                       SizedBox(
      //                         width: 20,
      //                       ),
      //                       Text(
      //                         "Time".tr,
      //                         style: TextStyle(
      //                           fontFamily: FontFamily.gilroyMedium,
      //                           fontSize: 15,
      //                           color: notifire.getwhiteblackcolor,
      //                         ),
      //                       ),
      //                       Spacer(),
      //                       Text(
      //                         bookrealEstateController.selectedTime.toString(),
      //                         style: TextStyle(
      //                           fontFamily: FontFamily.gilroyBold,
      //                           fontSize: 15,
      //                           color: notifire.getwhiteblackcolor,
      //                         ),
      //                       ),
      //                       SizedBox(
      //                         width: 20,
      //                       ),
      //                     ],
      //                   ),
      //                   SizedBox(
      //                     height: 20,
      //                   ),
      //                 ],
      //               ),
      //               decoration: BoxDecoration(
      //                 color: notifire.getblackwhitecolor,
      //                 borderRadius: BorderRadius.circular(15),
      //               ),
      //             ),
      //             SizedBox(
      //               height: 20,
      //             ),
      //             GestButton(
      //               Width: Get.size.width,
      //               height: 50,
      //               buttoncolor: blueColor,
      //               margin: EdgeInsets.only(top: 15, left: 30, right: 30),
      //               buttontext: checkLogin == true ? "Continue".tr : "Login".tr,
      //               style: TextStyle(
      //                 fontFamily: FontFamily.gilroyBold,
      //                 color: WhiteColor,
      //                 fontSize: 16,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //               onclick: () {
      //                 if (checkLogin == true) {
      //                   bookApiData("0");
      //                 } else {
      //                   Get.toNamed(Routes.login);
      //                 }
      //               },
      //             ),
      //             SizedBox(
      //               height: 20,
      //             ),
      //           ],
      //         );
      //       });
      //     });
      //   }),
      // ),
    );
  }

  walletCalculation(value) {
    if (value == true) {
      if (double.parse(wallet.toString()) <
          double.parse(currentTotalprice.toString())) {
        tempWallet = double.parse(currentTotalprice.toString()) -
            double.parse(wallet.toString());

        useWallet = double.parse(wallet.toString());
        currentTotalprice = (double.parse(currentTotalprice.toString()) -
                double.parse(wallet.toString()))
            .toString();
        tempWallet = 0;
        setState(() {});
      } else {
        tempWallet = double.parse(wallet.toString()) -
            double.parse(currentTotalprice.toString());
        useWallet = double.parse(wallet.toString()) - tempWallet;
        currentTotalprice = 0;
      }
    } else {
      tempWallet = double.parse(wallet.toString());
      currentTotalprice = valuePlus(currentTotalprice, useWallet);
      useWallet = 0;
      setState(() {});
    }
  }

  valuePlus(first, second) {
    return (double.parse(first.toString()) + double.parse(second.toString()))
        .toStringAsFixed(2);
  }

  Widget walletDetail() {
    return wallet != "0"
        ? Container(
            width: Get.width,
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: notifire.getblackwhitecolor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10),
                  child: Text(
                    "Pay from Wallet".tr,
                    style: TextStyle(
                        fontSize: 16,
                        color: notifire.getwhiteblackcolor,
                        letterSpacing: 0.5,
                        fontFamily: FontFamily.gilroyBold,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: notifire.getblackwhitecolor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: notifire.getborderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/viewdataWallet.svg",
                              height: 30,
                              color: notifire.getwhiteblackcolor,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Balance $currency${tempWallet.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: notifire.getwhiteblackcolor,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text("Available for Payment ".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 12,
                                      color: notifire.getwhiteblackcolor,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: blueColor,
                            value: status,
                            onChanged: (value) {
                              setState(() {
                                status = value;
                              });
                              print("VALUR  >>>>>>>>>>>>>>> >  $status");
                              walletCalculation(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          )
        : SizedBox();
  }
  Future<void> congratiulationDialog() {
  return Get.dialog(
    Dialog(
      backgroundColor: notifire.getblackwhitecolor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: LayoutBuilder(
        builder: (context, c) {
          final double w = c.maxWidth;          // dialog’s available width
          final bool isWide = w >= 520;         // tablets/web
          final double maxW = 520;              // cap dialog width on web
          final double imgSize = isWide ? 160 : 140;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    SizedBox(
                      height: imgSize,
                      width: imgSize,
                      child: Image.asset("assets/images/payment.png", fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          "Thank You!".tr,
                          style: TextStyle(
                            color: blueColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: isWide ? 22 : 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Message
                    Text(
                      "Booking\n successful. You can view your bookings\n from your profile".tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: notifire.getwhiteblackcolor,
                        fontSize: isWide ? 16 : 15,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buttons: column on narrow, row on wide
                    if (!isWide) ...[
                      _PrimaryBtn(
                        text: "View Bookings".tr,
                        onTap: () {
                          couponCode = "";
                          couponController.couponMsg = "";
                          homePageController.getHomeDataApi(
                            countryId: getData.read("countryId"),
                          );
                          homePageController.getCatWiseData(
                            cId: "0",
                            countryId: getData.read("countryId"),
                          );
                          reviewSummaryController.cleanOtherDetails();
                          Get.back();
                          myBookingController.statusWiseBooking();
                          Get.offAndToNamed(Routes.mybookingScreen);
                          save("backHome", true);
                        },
                      ),
                      const SizedBox(height: 10),
                      _SecondaryBtn(
                        text: "Back Home".tr,
                        onTap: () {
                          couponCode = "";
                          couponController.couponMsg = "";
                          homePageController.getHomeDataApi(
                            countryId: getData.read("countryId"),
                          );
                          homePageController.getCatWiseData(
                            cId: "0",
                            countryId: getData.read("countryId"),
                          );
                          reviewSummaryController.cleanOtherDetails();
                          Get.back();
                          Get.offAllNamed(Routes.bottoBarScreen);
                        },
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _SecondaryBtn(
                              text: "Back Home".tr,
                              onTap: () {
                                couponCode = "";
                                couponController.couponMsg = "";
                                homePageController.getHomeDataApi(
                                  countryId: getData.read("countryId"),
                                );
                                homePageController.getCatWiseData(
                                  cId: "0",
                                  countryId: getData.read("countryId"),
                                );
                                reviewSummaryController.cleanOtherDetails();
                                Get.back();
                                Get.offAllNamed(Routes.bottoBarScreen);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PrimaryBtn(
                              text: "View Bookings".tr,
                              onTap: () {
                                couponCode = "";
                                couponController.couponMsg = "";
                                homePageController.getHomeDataApi(
                                  countryId: getData.read("countryId"),
                                );
                                homePageController.getCatWiseData(
                                  cId: "0",
                                  countryId: getData.read("countryId"),
                                );
                                reviewSummaryController.cleanOtherDetails();
                                Get.back();
                                myBookingController.statusWiseBooking();
                                Get.offAndToNamed(Routes.mybookingScreen);
                                save("backHome", true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
    barrierDismissible: false, // keep the WillPopScope behavior
  );
}

/// --- Buttons (reuse styles) ---


  // Future congratiulationDialog() {
  //   return Get.defaultDialog(
  //     backgroundColor: notifire.getblackwhitecolor,
  //     title: "",
  //     content: WillPopScope(
  //       onWillPop: () async {
  //         return false;
  //       },
  //       child: Container(
  //         height: 460,
  //         width: Get.size.width,
  //         child: Column(
  //           children: [
  //             Image.asset(
  //               "assets/images/payment.png",
  //               height: 150,
  //               width: 150,
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(left: 15),
  //               child: Text(
  //                 "Thank You!".tr,
  //                 style: TextStyle(
  //                   color: blueColor,
  //                   fontFamily: FontFamily.gilroyBold,
  //                   fontSize: 20,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             Text(
  //               "Booking\n successful. You can view your bookings\n from your profile"
  //                   .tr,
  //               maxLines: 3,
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontFamily: FontFamily.gilroyMedium,
  //                 color: notifire.getwhiteblackcolor,
  //               ),
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 couponCode = "";
  //                 couponController.couponMsg = "";
  //                 homePageController.getHomeDataApi(
  //                   countryId: getData.read("countryId"),
  //                 );
  //                 homePageController.getCatWiseData(
  //                   cId: "0",
  //                   countryId: getData.read("countryId"),
  //                 );
  //                 reviewSummaryController.cleanOtherDetails();
  //                 Get.back();
  //                 myBookingController.statusWiseBooking();
  //                 Get.offAndToNamed(Routes.mybookingScreen);
  //                 save("backHome", true);
  //               },
  //               child: Container(
  //                 height: 60,
  //                 margin: EdgeInsets.all(15),
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   "View Bookings".tr,
  //                   style: TextStyle(
  //                     color: WhiteColor,
  //                     fontFamily: FontFamily.gilroyBold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: blueColor,
  //                   borderRadius: BorderRadius.circular(45),
  //                 ),
  //               ),
  //             ),
  //             InkWell(
  //               onTap: () {
  //                 couponCode = "";
  //                 couponController.couponMsg = "";
  //
  //                 homePageController.getHomeDataApi(
  //                   countryId: getData.read("countryId"),
  //                 );
  //
  //                 homePageController.getCatWiseData(
  //                   cId: "0",
  //                   countryId: getData.read("countryId"),
  //                 );
  //
  //                 reviewSummaryController.cleanOtherDetails();
  //
  //                 Get.back();
  //
  //                 Get.offAllNamed(Routes.bottoBarScreen);
  //               },
  //               child: Container(
  //                 height: 60,
  //                 margin: EdgeInsets.all(15),
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   "Back Home".tr,
  //                   style: TextStyle(
  //                     color: blueColor,
  //                     fontFamily: FontFamily.gilroyBold,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Color(0xFFeef4ff),
  //                   borderRadius: BorderRadius.circular(45),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(40),
  //           color: notifire.getblackwhitecolor,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget sugestlocationtype(
      {Function()? ontap,
      title,
      val,
      image,
      adress,
      radio,
      Color? borderColor,
      Color? titleColor}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        splashColor: Colors.transparent,
        onTap: ontap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width / 18),
          child: Container(
            height: Get.height / 10,
            decoration: BoxDecoration(
                border: Border.all(color: borderColor!, width: 1),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                SizedBox(width: Get.width / 55),
                Container(
                    height: Get.height / 12,
                    width: Get.width / 5.5,
                    decoration: BoxDecoration(
                        color: const Color(0xffF2F4F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: FadeInImage(
                          placeholder:
                              const AssetImage("assets/images/loading2.gif"),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Image.asset(
                                "assets/images/emty.gif",
                                fit: BoxFit.cover,
                                height: Get.height,
                              ),
                            );
                          },
                          image: NetworkImage(image)),
                    )),
                SizedBox(width: Get.width / 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Get.height * 0.01),
                    Text(title,
                        style: TextStyle(
                          fontSize: Get.height / 55,
                          fontFamily: 'Gilroy_Bold',
                          color: titleColor,
                        )),
                    SizedBox(
                      width: Get.width * 0.50,
                      child: Text(adress,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: Get.height / 65,
                              fontFamily: 'Gilroy_Medium',
                              color: Colors.grey)),
                    ),
                  ],
                ),
                const Spacer(),
                radio
              ],
            ),
          ),
        ),
      );
    });
  }

  Future paymentSheett() {
    return showModalBottomSheet(
      backgroundColor: notifire.getbgcolor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Wrap(children: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Container(
                    height: Get.height / 80,
                    width: Get.width / 5,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
                SizedBox(height: Get.height / 50),
                Row(children: [
                  SizedBox(width: Get.width / 14),
                  Text("Select Payment Method".tr,
                      style: TextStyle(
                          color: notifire.getwhiteblackcolor,
                          fontSize: Get.height / 40,
                          fontFamily: 'Gilroy_Bold')),
                ]),
                SizedBox(height: Get.height / 50),
                SizedBox(
                  height: Get.height * 0.50,
                  child:
                      GetBuilder<ReviewSummaryController>(builder: (context) {
                    return reviewSummaryController.isLodding
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: reviewSummaryController
                                .paymentInfo?.paymentdata!.length,
                            itemBuilder: (ctx, i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: sugestlocationtype(
                                  borderColor: selectidPay ==
                                          reviewSummaryController
                                              .paymentInfo?.paymentdata![i].id
                                      ? buttonColor
                                      : notifire.getborderColor,
                                  title: reviewSummaryController
                                          .paymentInfo?.paymentdata![i].title ??
                                      "",
                                  titleColor: notifire.getwhiteblackcolor,
                                  val: 0,
                                  image: Config.imageUrl +
                                      "${reviewSummaryController.paymentInfo!.paymentdata![i].img}",
                                  adress: reviewSummaryController.paymentInfo
                                          ?.paymentdata![i].subtitle ??
                                      "",
                                  ontap: () async {
                                    setState(() {
                                      paystackID = reviewSummaryController
                                          .paymentInfo!
                                          .paymentdata![i]
                                          .attributes
                                          .toString()
                                          .split(",")
                                          .last;
                                      print(
                                          " PAYSTACK ATTRIBUTE > L > L> > L >L> L>  L>  L> L > L > $paystackID");
                                      razorpaykey =
                                          "${reviewSummaryController.paymentInfo!.paymentdata![i].attributes}";
                                      paymenttital = reviewSummaryController
                                          .paymentInfo!.paymentdata![i].title;
                                      selectidPay = reviewSummaryController
                                              .paymentInfo
                                              ?.paymentdata![i]
                                              .id ??
                                          "";
                                      _groupValue = i;
                                    });
                                  },
                                  radio: Radio(
                                    fillColor: MaterialStateColor.resolveWith(
                                        (states) => i == _groupValue
                                            ? blueColor
                                            : notifire.getborderColor),
                                    activeColor: buttonColor,
                                    value: i,
                                    groupValue: _groupValue,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
                ),
                Container(
                  height: 80,
                  width: Get.size.width,
                  alignment: Alignment.center,
                  child: GestButton(
                    Width: Get.size.width,
                    height: 50,
                    buttoncolor: blueColor,
                    margin: EdgeInsets.only(top: 10, left: 30, right: 30),
                    buttontext: "Continue".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: WhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: () async {
                      print(paymenttital);
                      if (paymenttital == "Razorpay") {
                        Get.back();
                        openCheckout();
                      } else if (paymenttital == "Pay TO Owner") {
                        bookApiData("0");
                      } else if (paymenttital == "Paypal") {
                        List<String> keyList = razorpaykey.split(",");
                        paypalPayment(
                          currentTotalprice.toString(),
                          keyList[0],
                          keyList[1],
                        );
                      } else if (paymenttital == "Stripe") {
                        Get.back();
                        stripePayment();
                      } else if (paymenttital == "PayStack") {
                        print(
                            "< > >< >< >< >< >< >< >< >< ><>>< ${paystackID}>");
                        paystackController
                            .paystack(currentTotalprice.toString())
                            .then(
                          (value) {
                            Get.to(() => Paystackweb(
                                      url: paystackController
                                          .paystackData!.data!.authorizationUrl,
                                      skID: paystackID,
                                    ))!
                                .then((otid) {
                              if (verifyPaystack == 1) {
                                bookApiData(otid);
                                //showToastMessage("Payment Successfully");
                              } else {
                                Get.back();
                              }
                            });
                          },
                        );
                      } else if (paymenttital == "FlutterWave") {
                        Get.to(() => FlutterWave(
                                  totalAmount: currentTotalprice.toString(),
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "Paytm") {
                        Get.to(() => PayTmPayment(
                                  totalAmount: currentTotalprice.toString(),
                                  uid: getData
                                      .read("UserLogin")["id"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "SenangPay") {
                        Get.to(() => Senangpay(
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                  name: getData
                                      .read("UserLogin")["name"]
                                      .toString(),
                                  phone: getData
                                      .read("UserLogin")["mobile"]
                                      .toString(),
                                  totalAmount: currentTotalprice.toString(),
                                ))!
                            .then(
                          (otid) {
                            if (otid != null) {
                              bookApiData(otid);
                              //showToastMessage("Payment Successfully");
                            } else {
                              Get.back();
                            }
                          },
                        );
                      } else if (paymenttital == "Midtrans") {
                        Get.to(() => MidTrans(
                                  phonNumber: getData
                                      .read("UserLogin")["mobile"]
                                      .toString(),
                                  totalAmount: currentTotalprice.toString(),
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "MercadoPago") {
                        Get.to(() => MercadoPago(
                                  totalAmount: currentTotalprice.toString(),
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "Khalti Payment") {
                        Get.to(() => Khalti(
                                  totalAmount: currentTotalprice.toString(),
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "2checkout") {
                        Get.to(() => CheckOutPayment(
                                  totalAmount: currentTotalprice.toString(),
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "Payfast") {
                        Get.to(() => PayFast(
                                  totalAmount: currentTotalprice.toString(),
                                  email: getData
                                      .read("UserLogin")["email"]
                                      .toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookApiData(otid);
                          } else {
                            Get.back();
                          }
                        });
                      }
                    },
                  ),
                  decoration: BoxDecoration(
                    color: notifire.getblackwhitecolor,
                  ),
                ),
              ],
            );
          }),
        ]);
      },
    );
  }

  @override
  void dispose() {
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardTypee cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard.type = cardType;
    });
  }

  void openCheckout() async {
    var username = getData.read("UserLogin")["name"] ?? "";
    var mobile = getData.read("UserLogin")["mobile"] ?? "";
    var email = getData.read("UserLogin")["email"] ?? "";
    var options = {
      'key': razorpaykey,
      'amount': (double.parse(currentTotalprice.toString()) * 100).toString(),
      'name': username,
      'description': "",
      'timeout': 300,
      'prefill': {'contact': mobile, 'email': email},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    bookApiData(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
        'Error Response: ${"ERROR: " + response.code.toString() + " - " + response.message!}');
    showToastMessage(response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showToastMessage(response.walletName!);
  }

  paypalPayment(
    String amt,
    String key,
    String secretKey,
  ) {
    print("----------->>" + key.toString());
    print("----------->>" + secretKey.toString());
    Get.back();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UsePaypal(
            sandboxMode: true,
            clientId: key,
            secretKey: secretKey,
            returnURL:
                "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-35S7886705514393E",
            cancelURL: Config.paymentBaseUrl + "restate/paypal/cancle.php",
            transactions: [
              {
                "amount": {
                  "total": amt,
                  "currency": "USD",
                  "details": {
                    "subtotal": amt,
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "The payment transaction description.",
                "item_list": {
                  "items": [
                    {
                      "name": "A demo product",
                      "quantity": 1,
                      "price": amt,
                      "currency": "USD"
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) {
              Get.back();
              bookApiData(params["paymentId"].toString());
              congratiulationDialog();
            },
            onError: (error) {
              showToastMessage(error.toString());
            },
            onCancel: (params) {
              showToastMessage(params.toString());
            },
          );
        },
      ),
    );
  }

  bookApiData(otid) {
    bookrealEstateController.bookApiData(
      pid: reviewSummaryController.id,
      bookFor: bookrealEstateController.chack ? 'other' : 'self',
      fname: fname,
      lname: lname,
      email: email,
      mobile: mobile,
      ccode: ccode,
      country: "",
      noGuest: bookrealEstateController.count.toString(),
    );

    bookrealEstateController.count = 1;
    bookrealEstateController.dateOfTour = '';
    bookrealEstateController.selectedDate = DateTime.now();
    bookrealEstateController.selectedTime = '';

    congratiulationDialog();
    //showToastMessage("Payment Successfully");
  }

  String _getReference() {
    var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    final thisDate = DateTime.now().millisecondsSinceEpoch;
    return 'ChargedFrom${platform}_$thisDate';
  }

  chargeCard(int amount, String email) async {}

  final _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  final _paymentCard = PaymentCardCreated();
  var _autoValidateMode = AutovalidateMode.disabled;
  bool isloading = false;

  final _card = PaymentCardCreated();

  stripePayment() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: notifire.getbgcolor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Ink(
                child: Column(
                  children: [
                    SizedBox(height: Get.height / 45),
                    Center(
                      child: Container(
                        height: Get.height / 85,
                        width: Get.width / 5,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.03),
                          Text("Add Your payment information".tr,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5)),
                          SizedBox(height: Get.height * 0.02),
                          Form(
                            key: _formKey,
                            autovalidateMode: _autoValidateMode,
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(19),
                                    CardNumberInputFormatter()
                                  ],
                                  controller: numberController,
                                  onSaved: (String? value) {
                                    _paymentCard.number =
                                        CardUtils.getCleanedNumber(value!);

                                    CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(
                                            _paymentCard.number.toString());
                                    setState(() {
                                      _card.name = cardType.toString();
                                      _paymentCard.type = cardType;
                                    });
                                  },
                                  onChanged: (val) {
                                    CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(val);
                                    setState(() {
                                      _card.name = cardType.toString();
                                      _paymentCard.type = cardType;
                                    });
                                  },
                                  validator: CardUtils.validateCardNum,
                                  decoration: InputDecoration(
                                    prefixIcon: SizedBox(
                                      height: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 6,
                                        ),
                                        child: CardUtils.getCardIcon(
                                          _paymentCard.type,
                                        ),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: buttonColor,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: buttonColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: buttonColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: buttonColor,
                                      ),
                                    ),
                                    hintText:
                                        "What number is written on card?".tr,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    labelText: "Number".tr,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 4,
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.grey),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                        ],
                                        decoration: InputDecoration(
                                            prefixIcon: SizedBox(
                                              height: 10,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                child: Image.asset(
                                                  'assets/images/card_cvv.png',
                                                  width: 6,
                                                  color: buttonColor,
                                                ),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: buttonColor,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: buttonColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: buttonColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: buttonColor)),
                                            hintText:
                                                "Number behind the card".tr,
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            labelText: 'CVV'),
                                        validator: CardUtils.validateCVV,
                                        keyboardType: TextInputType.number,
                                        onSaved: (value) {
                                          _paymentCard.cvv = int.parse(value!);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: Get.width * 0.03),
                                    Flexible(
                                      flex: 4,
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.black),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                          CardMonthInputFormatter()
                                        ],
                                        decoration: InputDecoration(
                                          prefixIcon: SizedBox(
                                            height: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              child: Image.asset(
                                                'assets/images/calender.png',
                                                width: 10,
                                                color: buttonColor,
                                              ),
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: buttonColor,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: buttonColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: buttonColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: buttonColor,
                                            ),
                                          ),
                                          hintText: 'MM/YY',
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          labelText: "Expiry Date".tr,
                                        ),
                                        validator: CardUtils.validateDate,
                                        keyboardType: TextInputType.number,
                                        onSaved: (value) {
                                          List<int> expiryDate =
                                              CardUtils.getExpiryDate(value!);
                                          _paymentCard.month = expiryDate[0];
                                          _paymentCard.year = expiryDate[1];
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: Get.height * 0.055),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: Get.width,
                                    child: CupertinoButton(
                                      onPressed: () {
                                        _validateInputs();
                                      },
                                      color: buttonColor,
                                      child: Text(
                                        "Pay ${currency}${(price * bookrealEstateController.days.length + tex)}",
                                        style: TextStyle(fontSize: 17.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.065),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }


  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
      showToastMessage("Please fix the errors in red before submitting.".tr);
    } else {
      var username = getData.read("UserLogin")["name"] ?? "";
      var email = getData.read("UserLogin")["email"] ?? "";
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount = currentTotalprice.toString();
      form.save();

      Get.to(() => StripePaymentWeb(paymentCard: _paymentCard))!.then((otid) {
        Get.back();
        if (otid != null) {
          bookApiData(otid);
        }
      });

      showToastMessage("Payment card is valid".tr);
    }
  }
}
// ---------- RESPONSIVE HELPERS ----------
const double kTabletBreakpoint = 768;
const double kDesktopBreakpoint = 1024;

class _R {
  final double w;
  _R(this.w);

  bool get isPhone => w < kTabletBreakpoint;
  bool get isTablet => w >= kTabletBreakpoint && w < kDesktopBreakpoint;
  bool get isDesktop => w >= kDesktopBreakpoint;

  double maxContentWidth() => isDesktop ? 1000 : double.infinity;
  double spacing(double base) => isDesktop ? base * 1.3 : (isTablet ? base * 1.15 : base);
  double t(double mobile, {double? desktop}) => isDesktop ? (desktop ?? mobile * 1.15) : (isTablet ? mobile * 1.06 : mobile);
}

class _SummaryCard extends StatelessWidget {
  final ColorNotifire notifire;
  final ReviewSummaryController reviewSummaryController;
  final HomePageController homePageController;
  final double height;

  const _SummaryCard({
    required this.notifire,
    required this.reviewSummaryController,
    required this.homePageController,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // image
          Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Container(
                  height: height,
                  width: 130,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      image: "${Config.imageUrl}${reviewSummaryController.pImage}",
                      placeholder: "assets/images/ezgif.com-crop.gif",
                      imageErrorBuilder: (_, __, ___) => Center(
                        child: Image.asset("assets/images/emty.gif", fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFedeeef),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 4),
                        Text(
                          "${homePageController.rate}",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            color: blueColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // text info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title
                  Text(
                    reviewSummaryController.pTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontFamily: FontFamily.gilroyBold,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // city
                  Text(
                    reviewSummaryController.pCity,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: notifire.getgreycolor,
                      fontFamily: FontFamily.gilroyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // type
                  Text(
                    "${reviewSummaryController.pType}",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: FontFamily.gilroyBold,
                      color: blueColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingWhenCard extends StatelessWidget {
  final ColorNotifire notifire;
  final String dateText;
  final String timeText;

  const _BookingWhenCard({
    required this.notifire,
    required this.dateText,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            _kvRow(notifire, "Booking Date".tr, dateText),
            const SizedBox(height: 12),
            _kvRow(notifire, "Time".tr, timeText),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(ColorNotifire n, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            k,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 15,
              color: n.getwhiteblackcolor,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 15,
                color: n.getwhiteblackcolor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _PrimaryBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: WhiteColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SecondaryBtn({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFeef4ff),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: blueColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
