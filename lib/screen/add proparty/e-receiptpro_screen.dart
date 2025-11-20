// ignore_for_file: file_names, prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/add_proparty/booking_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EReceiptProScreen extends StatefulWidget {
  const EReceiptProScreen({super.key});

  @override
  State<EReceiptProScreen> createState() => _EReceiptProScreenState();
}

class _EReceiptProScreenState extends State<EReceiptProScreen> {
  BookingController bookingController = Get.find();

  late ColorNotifire notifire;
  var selectedRadioTile;
  final note = TextEditingController();
  String? rejectmsg = '';
  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  bool checkOut = false;
  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      bottomNavigationBar: Container(
        // height: 80,
        width: Get.size.width,
        child: StatefulBuilder(
          builder: (context, setState) {
            return checkOut ? SizedBox() : GetBuilder<BookingController>(builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    bookingController.proDetailsInfo?.bookdetails!.bookStatus ==
                        "Booked"
                        ? InkWell(
                      onTap: () {
                        ticketCancell(
                          bookingController
                              .proDetailsInfo?.bookdetails!.bookId ??
                              "",
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 93,
                        alignment: Alignment.center,
                        child: Text(
                          "CANCEL".tr,
                          style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 13,
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFFFC02D),
                        ),
                      ),
                    )
                        : bookingController.proDetailsInfo?.bookdetails!.bookStatus ==
                        "Confirmed"
                        ? InkWell(
                      onTap: () {
                        ticketCancell(
                          bookingController
                              .proDetailsInfo?.bookdetails!.bookId ??
                              "",
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 93,
                        alignment: Alignment.center,
                        child: Text(
                          "CANCEL".tr,
                          style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 13,
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFFFFC02D),
                        ),
                      ),
                    )
                        : SizedBox(),
                    SizedBox(
                      width: 5,
                    ),
                    bookingController.proDetailsInfo?.bookdetails!.bookStatus ==
                        "Booked"
                        ? Expanded(
                      child: InkWell(
                        onTap: () {
                          bookingController.getBookingConfrimed(
                              bookId: bookingController
                                  .proDetailsInfo?.bookdetails!.bookId ??
                                  "");
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            "CONFIRM".tr,
                            style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 13,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFF246BFD),
                          ),
                        ),
                      ),
                    )
                        : bookingController.proDetailsInfo?.bookdetails!.bookStatus ==
                        "Confirmed"
                        ? Expanded(
                      child: InkWell(
                        onTap: () {
                          bookingController.getBookingCheckIn(
                            bookId: bookingController
                                .proDetailsInfo?.bookdetails!.bookId ??
                                "",
                          );
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            "CHECK IN".tr,
                            style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 13,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFF246BFD),
                          ),
                        ),
                      ),
                    )
                        : bookingController
                        .proDetailsInfo?.bookdetails!.bookStatus ==
                        "Check_in"
                        ? Expanded(
                      child: InkWell(
                        onTap: () {
                          bookingController.getBookingCheckOut(
                            bookId: bookingController.proDetailsInfo
                                ?.bookdetails!.bookId ??
                                "",).then((value) {
                            if(value["Result"] == "true"){
                              setState(() {
                                checkOut = true;
                              });
                            } else {
                              setState(() {
                                checkOut = false;
                              });
                            }
                          },);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            "CHECK OUT".tr,
                            style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 13,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFF246BFD),
                          ),
                        ),
                      ),
                    )
                        : SizedBox(),
                  ],
                ),
              );
            });
        },),
        decoration: BoxDecoration(
          color: notifire.getbgcolor,
        ),
      ),
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
          "E-Receipt".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: GetBuilder<BookingController>(builder: (context) {
        String bId = ("${bookingController.proDetailsInfo?.bookdetails!.bookId ?? ""}");
        String bDate =
            ("${bookingController.proDetailsInfo?.bookdetails!.bookDate ?? ""}")
                .split(" ")
                .first;
        String fDate =
            ("${bookingController.proDetailsInfo?.bookdetails!.checkIn ?? ""}")
                .split(" ")
                .first;
        String ldate =
            ("${bookingController.proDetailsInfo?.bookdetails!.checkOut ?? ""}")
                .split(" ")
                .first;
        return bookingController.isDetails
            ? SizedBox(
                width: Get.size.width,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          // height: 160,
                          width: Get.size.width,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Booking Id".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      bId,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Booking Date".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      bDate,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                bookingController.proDetailsInfo?.bookdetails!.checkIn.toString() == "" ? SizedBox() : Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Check in".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      bookingController.proDetailsInfo?.bookdetails
                                      !.checkIn
                                              .toString().split(" ").first ??
                                          "",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: bookingController.proDetailsInfo?.bookdetails!.checkIn.toString() == "" ? 0 : 20,
                                ),

                                bookingController.proDetailsInfo?.bookdetails!.checkOut.toString() == "" ? SizedBox() : Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Check out".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      bookingController.proDetailsInfo!.bookdetails
                                      !.checkOut.toString().split(" ").first,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                                // : SizedBox(),
                                SizedBox(
                                  height: bookingController.proDetailsInfo?.bookdetails!.checkOut.toString() == "" ? 0 : 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Number Of Guest".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "${bookingController.proDetailsInfo?.bookdetails!.noguest}",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: notifire.getblackwhitecolor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          // height: 172,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          width: Get.size.width,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "${"Amount".tr} (${bookingController.proDetailsInfo?.bookdetails!.totalDay ?? ""} ${"days".tr})",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${currency}${(int.parse(bookingController.proDetailsInfo?.bookdetails!.propPrice ?? "") * int.parse(bookingController.proDetailsInfo?.bookdetails!.totalDay ?? ""))}  ",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Tax".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${currency}${bookingController.proDetailsInfo?.bookdetails!.tax ?? ""}  ",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Visibility(
                                visible: bookingController
                                            .proDetailsInfo?.bookdetails!.couAmt ==
                                        "0"
                                    ? false
                                    : true,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Coupon".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "${currency}${bookingController.proDetailsInfo?.bookdetails!.couAmt ?? ""}  ",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: Color(0xFF08E761),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: bookingController
                                    .proDetailsInfo?.bookdetails!.couAmt ==
                                    "0"
                                    ? 0 : 15,
                              ),
                              Visibility(
                                visible: bookingController.proDetailsInfo
                                            ?.bookdetails!.wallAmt ==
                                        "0"
                                    ? false
                                    : true,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Wallet".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      "${currency}${bookingController.proDetailsInfo?.bookdetails!.wallAmt ?? ""}  ",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 15,
                                        color: Color(0xFF08E761),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(horizontal: 20),
                              //   child: Divider(color: notifire.getborderColor,thickness: 2,),
                              // ),
                              SizedBox(
                                height: bookingController.proDetailsInfo
                                    ?.bookdetails!.wallAmt ==
                                    "0"
                                    ? 0 : 15,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Total".tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${currency}${bookingController.proDetailsInfo?.bookdetails!.total ?? ""}  ",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: notifire.getblackwhitecolor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Name'.tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  bookingController.proDetailsInfo?.bookdetails
                                  !.customerName ==
                                          ""
                                      ? Text(
                                          getData
                                              .read("UserLogin")["name"]
                                              .toString(),
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 15,
                                            color: notifire.getwhiteblackcolor,
                                          ),
                                        )
                                      : Text(
                                          bookingController.proDetailsInfo
                                                  ?.bookdetails!.customerName ??
                                              "",
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 15,
                                            color: notifire.getwhiteblackcolor,
                                          ),
                                        ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Phone Number'.tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  bookingController.proDetailsInfo?.bookdetails
                                  !.customerMobile ==
                                          ""
                                      ? Text(
                                          "${getData.read("UserLogin")["ccode"]} ${getData.read("UserLogin")["mobile"]}",
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 15,
                                            color: notifire.getwhiteblackcolor,
                                          ),
                                        )
                                      : Text(
                                          "${bookingController.proDetailsInfo?.bookdetails!.customerMobile ?? ""}",
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 15,
                                            color: notifire.getwhiteblackcolor,
                                          ),
                                        ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Payment Title'.tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    bookingController.proDetailsInfo?.bookdetails
                                    !.paymentTitle ??
                                        "",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              bookingController.proDetailsInfo?.bookdetails
                              !.transactionId !=
                                      "0"
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Transaction ID'.tr,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyMedium,
                                              fontSize: 15,
                                              color: notifire.getwhiteblackcolor,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            bookingController.proDetailsInfo
                                                    ?.bookdetails!.transactionId ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              fontSize: 15,
                                              color: notifire.getwhiteblackcolor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(
                                              new ClipboardData(
                                                  text: bookingController
                                                          .proDetailsInfo
                                                          ?.bookdetails
                                                  !.transactionId ??
                                                      ""),
                                            );
                                            showToastMessage("Copy");
                                          },
                                          child: Image.asset(
                                            "assets/images/copy.png",
                                            height: 25,
                                            width: 25,
                                            color: blueColor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              SizedBox(
                                height: bookingController.proDetailsInfo?.bookdetails
                                !.transactionId !=
                                    "0" ? 20 : 0,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Payment Status'.tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  bookingController.statusWiseBook == "Completed"
                                      ? Container(
                                          height: 30,
                                          width: 85,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Paid'.tr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: FontFamily.gilroyMedium,
                                              color: blueColor,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: blueColor),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                        )
                                      : bookingController.proDetailsInfo
                                                      ?.bookdetails!.pMethodId !=
                                                  "2"
                                          ? Container(
                                              height: 30,
                                              width: 85,
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Paid'.tr,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  color: blueColor,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                border:
                                                    Border.all(color: blueColor),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            )
                                          : bookingController.proDetailsInfo
                                                      ?.bookdetails!.bookStatus ==
                                                  "Completed"
                                              ? Container(
                                                  height: 30,
                                                  width: 85,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Paid'.tr,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontFamily:
                                                          FontFamily.gilroyMedium,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: blueColor),
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                )
                                              : Container(
                                                  height: 30,
                                                  width: 85,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "UnPaid".tr,
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          FontFamily.gilroyMedium,
                                                    ),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'Booking Status'.tr,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    bookingController.proDetailsInfo?.bookdetails
                                    !.bookStatus ??
                                        "",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 15,
                                      color: notifire.getwhiteblackcolor,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),

                                 ],
                              ),
                              SizedBox(height: bookingController.proDetailsInfo?.bookdetails!.checkIntime != "" ? 20 : 0),
                              bookingController.proDetailsInfo?.bookdetails!.checkIntime != ""
                                  ? Row(
                                children: [
                                  SizedBox(width: 20),
                                  Text("Check In Time",style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    fontSize: 15,
                                    color: notifire.getwhiteblackcolor,
                                  ),
                                  ),
                                  Spacer(),
                                  Text( bookingController.proDetailsInfo
                                      ?.bookdetails!.checkIntime ??
                                      "",style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 15,
                                    color: notifire.getwhiteblackcolor,
                                    overflow: TextOverflow.ellipsis,
                                  ),),
                                  SizedBox(width: 20),
                                ],
                              )
                                  : SizedBox(),
                              SizedBox(
                                height: bookingController.proDetailsInfo?.bookdetails!.checkOuttime != "" ? 20 : 0,
                              ),
                              bookingController.proDetailsInfo?.bookdetails!.checkOuttime != ""
                                  ? Row(
                                children: [
                                  SizedBox(width: 20),
                                  Text("Check Out Time",style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    fontSize: 15,
                                    color: notifire.getwhiteblackcolor,
                                  ),
                                  ),
                                  Spacer(),
                                  Text( bookingController.proDetailsInfo
                                      ?.bookdetails!.checkOuttime ??
                                      "",style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 15,
                                    color: notifire.getwhiteblackcolor,
                                    overflow: TextOverflow.ellipsis,
                                  ),),
                                  SizedBox(width: 20),
                                ],
                              )
                                  : SizedBox(),
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: notifire.getblackwhitecolor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        SizedBox(
                          height: bookingController.proDetailsInfo?.bookdetails!.addNote == "" ? 0 : 20,
                        ),
                        bookingController.proDetailsInfo?.bookdetails!.addNote == "" ? SizedBox() : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: notifire.getblackwhitecolor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Note:",style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 18,
                                  color: notifire.getwhiteblackcolor,
                                ),),
                                SizedBox(height: 3),
                                Text("${bookingController.proDetailsInfo?.bookdetails!.addNote}",
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    fontSize: 15,
                                    color: notifire.getwhiteblackcolor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      }),
    );
  }

  ticketCancell(ticketid) {
    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: notifire.getbgcolor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: Get.height * 0.02),
                    Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(25))),
                    SizedBox(height: Get.height * 0.02),
                    Text(
                      "Select Reason".tr,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Gilroy Bold',
                          color: notifire.getwhiteblackcolor),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    Text(
                      "Please select the reason for cancellation:".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Gilroy Medium',
                          color: notifire.getwhiteblackcolor),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    ListView.builder(
                      itemCount: cancelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return RadioListTile(
                          dense: true,
                          value: i,
                          activeColor: Color(0xFF246BFD),
                          tileColor: notifire.getdarkscolor,
                          selected: true,
                          groupValue: selectedRadioTile,
                          title: Text(
                            cancelList[i]["title"],
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Gilroy Medium',
                                color: notifire.getwhiteblackcolor),
                          ),
                          onChanged: (val) {
                            setState(() {});
                            selectedRadioTile = val;
                            rejectmsg = cancelList[i]["title"];
                          },
                        );
                      },
                    ),
                    rejectmsg == "Others".tr
                        ? SizedBox(
                            height: 50,
                            width: Get.width * 0.85,
                            child: TextField(
                              controller: note,
                              decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF246BFD), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF246BFD), width: 1),
                                  ),
                                  hintText: 'Enter reason'.tr,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Gilroy Medium',
                                      fontSize: Get.size.height / 55,
                                      color: Colors.grey)),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(height: Get.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: Get.width * 0.35,
                          height: Get.height * 0.05,
                          child: ticketbutton(
                            title: "Cancel".tr,
                            bgColor: Color(0xFF246BFD),
                            titleColor: Colors.white,
                            ontap: () {
                              Get.back();
                            },
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.35,
                          height: Get.height * 0.05,
                          child: ticketbutton(
                            title: "Confirm".tr,
                            bgColor: Color(0xFF246BFD),
                            titleColor: Colors.white,
                            ontap: () {
                              Get.back();
                              bookingController.getBookingCancle(
                                bookId: ticketid,
                                reason: rejectmsg == "Others".tr
                                    ? note.text
                                    : rejectmsg,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.04),
                  ],
                ),
              ),
            );
          });
        });
  }

  List cancelList = [
    {"id": 1, "title": "Financing fell through".tr},
    {"id": 2, "title": "Inspection issues".tr},
    {"id": 3, "title": "Change in financial situation".tr},
    {"id": 4, "title": "Title issues".tr},
    {"id": 5, "title": "Seller changes their mind".tr},
    {"id": 6, "title": "Competing offer".tr},
    {"id": 7, "title": "Personal reasons".tr},
    {"id": 8, "title": "Others".tr},
  ];

  ticketbutton({Function()? ontap, String? title, Color? bgColor, titleColor}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: Get.height * 0.04,
        width: Get.width * 0.40,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: (BorderRadius.circular(18)),
            border: Border.all(color: bgColor!, width: 1)),
        child: Center(
          child: Text(title!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontFamily: 'Gilroy Medium')),
        ),
      ),
    );
  }

  Future reviewSheet() {
    return Get.bottomSheet(
      isScrollControlled: true,
      GetBuilder<BookingController>(builder: (context) {
        return Container(
          height: 520,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Leave a Review".tr,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: FontFamily.gilroyBold,
                  color: notifire.getwhiteblackcolor,
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
                  color: notifire.getgreycolor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "How was your experience".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: FontFamily.gilroyBold,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RatingBar(
                initialRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                ratingWidget: RatingWidget(
                  full: Image.asset(
                    'assets/images/starBold.png',
                    color: blueColor,
                  ),
                  half: Image.asset(
                    'assets/images/star-half.png',
                    color: blueColor,
                  ),
                  empty: Image.asset(
                    'assets/images/Star.png',
                    color: blueColor,
                  ),
                ),
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (rating) {
                  bookingController.totalRateUpdate(rating);
                },
              ),
              SizedBox(
                height: 20,
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
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 15),
                child: Text(
                  "Write Your Review".tr,
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(15),
                child: TextFormField(
                  controller: bookingController.ratingText,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  cursorColor: notifire.getwhiteblackcolor,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintText: "Your review here...".tr,
                    hintStyle: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 15,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 16,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
                decoration: BoxDecoration(
                  color: notifire.getblackwhitecolor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Divider(
                  color: notifire.getgreycolor,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: Text(
                          "Maybe Later".tr,
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
                      onTap: () {
                        bookingController.reviewUpdateApi(
                          bookId: bookingController
                              .proDetailsInfo?.bookdetails!.bookId,
                        );
                      },
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: Text(
                          "Submit".tr,
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
            color: notifire.getblackwhitecolor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
        );
      }),
    );
  }
}
