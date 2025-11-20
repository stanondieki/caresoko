// ignore_for_file: file_names, prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unused_local_variable

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/booking_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
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
  final BookingController bookingController = Get.find();

  late ColorNotifire notifire;
  var selectedRadioTile;
  final note = TextEditingController();
  String? rejectmsg = '';

  bool checkOut = false;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

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
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Details".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: GetBuilder<BookingController>(builder: (_) {
        if (!bookingController.isDetails) {
          return Center(child: CircularProgressIndicator());
        }

        final details = bookingController.proDetailsInfo?.bookdetails;
        final media = MediaQuery.of(context);
        final width = media.size.width;
        final isWide = width >= 900;
        final pagePad = EdgeInsets.symmetric(horizontal: isWide ? 24 : 10, vertical: 10);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: pagePad,
              child: Scrollbar(
                thumbVisibility: isWide,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Property Card
                      Container(
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
                              Text(
                                details?.propTitle ?? "",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 18,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                details?.propType ?? "",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 15,
                                  color: blueColor,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                details?.address ?? "",
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

                      SizedBox(height: 16),

                      // Date/Time Card
                      _InfoCard(
                        notifire: notifire,
                        rows: [
                          _KV("Date".tr, details?.date ?? "", notifire),
                          _KV("Time".tr, details?.time ?? "", notifire),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Guest Card
                      _InfoCard(
                        notifire: notifire,
                        rows: [
                          _KV(
                            'Name'.tr,
                            (details?.customerName == "" || details?.customerName == null)
                                ? (getData.read("UserLogin")["name"]?.toString() ?? "")
                                : (details?.customerName ?? ""),
                            notifire,
                          ),
                          _KV(
                            'Phone Number'.tr,
                            (details?.customerMobile == "" || details?.customerMobile == null)
                                ? "${getData.read("UserLogin")["ccode"]} ${getData.read("UserLogin")["mobile"]}"
                                : (details?.customerMobile ?? ""),
                            notifire,
                          ),
                          _KV(
                            'Booking Status'.tr,
                            details?.bookStatus ?? "",
                            notifire,
                            valueMaxLines: 1,
                          ),
                        ],
                      ),

                      if ((details?.message ?? "").isNotEmpty) ...[
                        SizedBox(height: 16),
                        // Note Card
                        Container(
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
                                Text(
                                  "Note:".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 18,
                                    color: notifire.getwhiteblackcolor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  details?.message ?? "",
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

                      SizedBox(height: 24),

                      // Actions (Uncomment if you want the action row back, now responsive)
                      /*
                      _ActionRow(
                        notifire: notifire,
                        detailsStatus: details?.bookStatus,
                        onCancel: () => _openCancelResponsive(details?.bookId),
                        onConfirm: () => bookingController.getBookingConfrimed(bookId: details?.bookId ?? ""),
                        onCheckIn: () => bookingController.getBookingCheckIn(bookId: details?.bookId ?? ""),
                        onCheckOut: () async {
                          final res = await bookingController.getBookingCheckOut(bookId: details?.bookId ?? "");
                          setState(() => checkOut = (res["Result"] == "true"));
                        },
                      ),
                      */
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ----------------- Responsive Cancel (BottomSheet on mobile, Dialog on web/desktop) -----------------
  void _openCancelResponsive(String? ticketid) {
    if (ticketid == null) return;

    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          backgroundColor: notifire.getbgcolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: _CancelContent(
                notifire: notifire,
                cancelList: cancelList,
                selectedRadioTile: selectedRadioTile,
                note: note,
                onChanged: (i, title) {
                  setState(() {
                    selectedRadioTile = i;
                    rejectmsg = title;
                  });
                },
                onCancel: () => Navigator.of(ctx).pop(),
                onConfirm: () {
                  Navigator.of(ctx).pop();
                  bookingController.getBookingCancle(
                    bookId: ticketid,
                    reason: rejectmsg == "Others".tr ? note.text : rejectmsg,
                  );
                },
              ),
            ),
          ),
        ),
      );
    } else {
      ticketCancell(ticketid); // reuse your original mobile sheet
    }
  }

  // original mobile bottom sheet (kept, just used by _openCancelResponsive on mobile)
  ticketCancell(ticketid) {
    showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: notifire.getbgcolor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    Container(
                      height: 6, width: 80,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(25)),
                    ),
                    SizedBox(height: 16),
                    Text("Select Reason".tr,
                      style: TextStyle(fontSize: 20, fontFamily: 'Gilroy Bold', color: notifire.getwhiteblackcolor),
                    ),
                    SizedBox(height: 12),
                    Text("Please select the reason for cancellation:".tr,
                      style: TextStyle(fontSize: 16, fontFamily: 'Gilroy Medium', color: notifire.getwhiteblackcolor),
                    ),
                    SizedBox(height: 12),
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
                            style: TextStyle(fontSize: 16, fontFamily: 'Gilroy Medium', color: notifire.getwhiteblackcolor),
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
                        ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 50,
                        child: TextField(
                          controller: note,
                          decoration: InputDecoration(
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Color(0xFF246BFD), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(color: Color(0xFF246BFD), width: 1),
                            ),
                            hintText: 'Enter reason'.tr,
                            hintStyle: TextStyle(
                              fontFamily: 'Gilroy Medium',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )
                        : const SizedBox(),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ticketbutton(
                              title: "Cancel".tr,
                              bgColor: Color(0xFF246BFD),
                              titleColor: Colors.white,
                              ontap: () => Get.back(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ticketbutton(
                              title: "Confirm".tr,
                              bgColor: Color(0xFF246BFD),
                              titleColor: Colors.white,
                              ontap: () {
                                Get.back();
                                bookingController.getBookingCancle(
                                  bookId: ticketid,
                                  reason: rejectmsg == "Others".tr ? note.text : rejectmsg,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ----------------- Review Sheet (responsive) -----------------
  Future reviewSheet() async {
    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      // Dialog on web/desktop
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Dialog(
          backgroundColor: notifire.getblackwhitecolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: _ReviewContent(
                notifire: notifire,
                bookingController: bookingController,
                onClose: () => Navigator.of(ctx).pop(),
              ),
            ),
          ),
        ),
      );
    } else {
      // Bottom sheet on mobile
      return Get.bottomSheet(
        isScrollControlled: true,
        _ReviewContent(
          notifire: notifire,
          bookingController: bookingController,
          onClose: () => Get.back(),
        ),
      );
    }
  }

  // ----------------- Widgets & helpers -----------------

  Widget ticketbutton({Function()? ontap, String? title, Color? bgColor, titleColor}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: bgColor!, width: 1),
        ),
        child: Center(
          child: Text(
            title!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontFamily: 'Gilroy Medium',
            ),
          ),
        ),
      ),
    );
  }

  // rows for info card
  _KV(String k, String v, ColorNotifire notifire, {int valueMaxLines = 2}) {
    return _KeyValueRow(title: k, value: v, notifire: notifire, valueMaxLines: valueMaxLines);
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
}

// ----------------- Small UI pieces -----------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.notifire, required this.rows});
  final ColorNotifire notifire;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(children: rows),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.title,
    required this.value,
    required this.notifire,
    this.valueMaxLines = 2,
  });

  final String title;
  final String value;
  final ColorNotifire notifire;
  final int valueMaxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 15,
              color: notifire.getwhiteblackcolor,
            ),
          ),
          Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: valueMaxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 15,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelContent extends StatelessWidget {
  const _CancelContent({
    required this.notifire,
    required this.cancelList,
    required this.selectedRadioTile,
    required this.note,
    required this.onChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  final ColorNotifire notifire;
  final List cancelList;
  final dynamic selectedRadioTile;
  final TextEditingController note;
  final void Function(int index, String title) onChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    String? localReject;
    return StatefulBuilder(builder: (ctx, setState) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Text(
                "Select Reason".tr,
                style: TextStyle(fontSize: 20, fontFamily: 'Gilroy Bold', color: notifire.getwhiteblackcolor),
              ),
              SizedBox(height: 12),
              Text(
                "Please select the reason for cancellation:".tr,
                style: TextStyle(fontSize: 16, fontFamily: 'Gilroy Medium', color: notifire.getwhiteblackcolor),
              ),
              SizedBox(height: 12),
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
                      style: TextStyle(fontSize: 16, fontFamily: 'Gilroy Medium', color: notifire.getwhiteblackcolor),
                    ),
                    onChanged: (val) {
                      setState(() {});
                      localReject = cancelList[i]["title"];
                      onChanged(i, localReject!);
                    },
                  );
                },
              ),
              (localReject == "Others".tr)
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: note,
                    decoration: InputDecoration(
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Color(0xFF246BFD), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Color(0xFF246BFD), width: 1),
                      ),
                      hintText: 'Enter reason'.tr,
                      hintStyle: TextStyle(
                        fontFamily: 'Gilroy Medium',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              )
                  : const SizedBox(),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _DialogActionButton(
                        title: "Cancel".tr,
                        onTap: onCancel,
                        bg: Color(0xFF246BFD),
                        fg: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _DialogActionButton(
                        title: "Confirm".tr,
                        onTap: onConfirm,
                        bg: Color(0xFF246BFD),
                        fg: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      );
    });
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.title,
    required this.onTap,
    required this.bg,
    required this.fg,
  });

  final String title;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: bg, width: 1),
        ),
        child: Center(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontFamily: 'Gilroy Medium',
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({
    required this.notifire,
    required this.bookingController,
    required this.onClose,
  });

  final ColorNotifire notifire;
  final BookingController bookingController;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 520,
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Leave a Review".tr,
            style: TextStyle(fontSize: 20, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: notifire.getgreycolor),
          ),
          SizedBox(height: 20),
          Text(
            "How was your experience".tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor),
          ),
          SizedBox(height: 20),
          RatingBar(
            initialRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            ratingWidget: RatingWidget(
              full: Image.asset('assets/images/starBold.png', color: blueColor),
              half: Image.asset('assets/images/star-half.png', color: blueColor),
              empty: Image.asset('assets/images/Star.png', color: blueColor),
            ),
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            onRatingUpdate: (rating) {
              bookingController.totalRateUpdate(rating);
            },
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: notifire.getgreycolor),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Write Your Review".tr,
                style: TextStyle(fontSize: 17, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: notifire.getblackwhitecolor,
              borderRadius: BorderRadius.circular(15),
            ),
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
                hintStyle: TextStyle(fontFamily: FontFamily.gilroyMedium, fontSize: 15),
              ),
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: notifire.getgreycolor),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onClose,
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFeef4ff),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Text(
                      "Maybe Later".tr,
                      style: TextStyle(color: blueColor, fontFamily: FontFamily.gilroyBold, fontSize: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    bookingController.reviewUpdateApi(
                      bookId: bookingController.proDetailsInfo?.bookdetails!.bookId,
                    );
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Text(
                      "Submit".tr,
                      style: TextStyle(color: WhiteColor, fontFamily: FontFamily.gilroyBold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* Optional: a responsive action row if you later re-enable the bottom bar
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.notifire,
    required this.detailsStatus,
    required this.onCancel,
    required this.onConfirm,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  final ColorNotifire notifire;
  final String? detailsStatus;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 120 : 0, vertical: 8),
      child: Row(
        children: [
          if (detailsStatus == "Booked" || detailsStatus == "Confirmed")
            _pill("CANCEL".tr, Color(0xFFFFC02D), onCancel),
          SizedBox(width: 8),
          if (detailsStatus == "Booked")
            Expanded(child: _pill("CONFIRM".tr, Color(0xFF246BFD), onConfirm))
          else if (detailsStatus == "Confirmed")
            Expanded(child: _pill("CHECK IN".tr, Color(0xFF246BFD), onCheckIn))
          else if (detailsStatus == "Check_in")
            Expanded(child: _pill("CHECK OUT".tr, Color(0xFF246BFD), onCheckOut)),
        ],
      ),
    );
  }

  Widget _pill(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: TextStyle(color: Colors.white, fontFamily: FontFamily.gilroyMedium, fontSize: 13)),
      ),
    );
  }
}
*/



// // ignore_for_file: file_names, prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, unused_local_variable
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/booking_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class EReceiptProScreen extends StatefulWidget {
//   const EReceiptProScreen({super.key});
//
//   @override
//   State<EReceiptProScreen> createState() => _EReceiptProScreenState();
// }
//
// class _EReceiptProScreenState extends State<EReceiptProScreen> {
//   BookingController bookingController = Get.find();
//
//   late ColorNotifire notifire;
//   var selectedRadioTile;
//   final note = TextEditingController();
//   String? rejectmsg = '';
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
//   bool checkOut = false;
//   @override
//   void initState() {
//     super.initState();
//     getdarkmodepreviousstate();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getbgcolor,
//       /*bottomNavigationBar: Container(
//         // height: 80,
//         width: Get.size.width,
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             return checkOut
//                 ? SizedBox()
//                 : GetBuilder<BookingController>(builder: (context) {
//                     return Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Row(
//                         children: [
//                           bookingController.proDetailsInfo?.bookdetails!
//                                       .bookStatus ==
//                                   "Booked"
//                               ? InkWell(
//                                   onTap: () {
//                                     ticketCancell(
//                                       bookingController.proDetailsInfo
//                                               ?.bookdetails!.bookId ??
//                                           "",
//                                     );
//                                   },
//                                   child: Container(
//                                     height: 50,
//                                     width: 93,
//                                     alignment: Alignment.center,
//                                     child: Text(
//                                       "CANCEL".tr,
//                                       style: TextStyle(
//                                         color: WhiteColor,
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 13,
//                                       ),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(10),
//                                       color: Color(0xFFFFC02D),
//                                     ),
//                                   ),
//                                 )
//                               : bookingController.proDetailsInfo?.bookdetails!
//                                           .bookStatus ==
//                                       "Confirmed"
//                                   ? InkWell(
//                                       onTap: () {
//                                         ticketCancell(
//                                           bookingController.proDetailsInfo
//                                                   ?.bookdetails!.bookId ??
//                                               "",
//                                         );
//                                       },
//                                       child: Container(
//                                         height: 50,
//                                         width: 93,
//                                         alignment: Alignment.center,
//                                         child: Text(
//                                           "CANCEL".tr,
//                                           style: TextStyle(
//                                             color: WhiteColor,
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                           color: Color(0xFFFFC02D),
//                                         ),
//                                       ),
//                                     )
//                                   : SizedBox(),
//                           SizedBox(
//                             width: 5,
//                           ),
//                           bookingController.proDetailsInfo?.bookdetails!
//                                       .bookStatus ==
//                                   "Booked"
//                               ? Expanded(
//                                   child: InkWell(
//                                     onTap: () {
//                                       bookingController.getBookingConfrimed(
//                                           bookId: bookingController
//                                                   .proDetailsInfo
//                                                   ?.bookdetails!
//                                                   .bookId ??
//                                               "");
//                                     },
//                                     child: Container(
//                                       height: 50,
//                                       alignment: Alignment.center,
//                                       child: Text(
//                                         "CONFIRM".tr,
//                                         style: TextStyle(
//                                           color: WhiteColor,
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(10),
//                                         color: Color(0xFF246BFD),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : bookingController.proDetailsInfo?.bookdetails!
//                                           .bookStatus ==
//                                       "Confirmed"
//                                   ? Expanded(
//                                       child: InkWell(
//                                         onTap: () {
//                                           bookingController.getBookingCheckIn(
//                                             bookId: bookingController
//                                                     .proDetailsInfo
//                                                     ?.bookdetails!
//                                                     .bookId ??
//                                                 "",
//                                           );
//                                         },
//                                         child: Container(
//                                           height: 50,
//                                           alignment: Alignment.center,
//                                           child: Text(
//                                             "CHECK IN".tr,
//                                             style: TextStyle(
//                                               color: WhiteColor,
//                                               fontFamily:
//                                                   FontFamily.gilroyMedium,
//                                               fontSize: 13,
//                                             ),
//                                           ),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             color: Color(0xFF246BFD),
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   : bookingController.proDetailsInfo
//                                               ?.bookdetails!.bookStatus ==
//                                           "Check_in"
//                                       ? Expanded(
//                                           child: InkWell(
//                                             onTap: () {
//                                               bookingController
//                                                   .getBookingCheckOut(
//                                                 bookId: bookingController
//                                                         .proDetailsInfo
//                                                         ?.bookdetails!
//                                                         .bookId ??
//                                                     "",
//                                               )
//                                                   .then(
//                                                 (value) {
//                                                   if (value["Result"] ==
//                                                       "true") {
//                                                     setState(() {
//                                                       checkOut = true;
//                                                     });
//                                                   } else {
//                                                     setState(() {
//                                                       checkOut = false;
//                                                     });
//                                                   }
//                                                 },
//                                               );
//                                             },
//                                             child: Container(
//                                               height: 50,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 "CHECK OUT".tr,
//                                                 style: TextStyle(
//                                                   color: WhiteColor,
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                                 color: Color(0xFF246BFD),
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                       : SizedBox(),
//                         ],
//                       ),
//                     );
//                   });
//           },
//         ),
//         decoration: BoxDecoration(
//           color: notifire.getbgcolor,
//         ),
//       ),*/
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
//           "Details".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: GetBuilder<BookingController>(builder: (context) {
//         return bookingController.isDetails
//             ? SizedBox(
//                 width: Get.size.width,
//                 child: SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 10),
//                     child: Column(
//                       children: [
//                         Container(
//                           width: double.infinity,
//                           margin: EdgeInsets.symmetric(horizontal: 10),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   bookingController.proDetailsInfo?.bookdetails!
//                                           .propTitle ??
//                                       "",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 18,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                                 SizedBox(height: 3),
//                                 Text(
//                                   bookingController.proDetailsInfo?.bookdetails!
//                                           .propType ??
//                                       "",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 15,
//                                     color: blueColor,
//                                   ),
//                                 ),
//                                 SizedBox(height: 3),
//                                 Text(
//                                   bookingController.proDetailsInfo?.bookdetails!
//                                           .address ??
//                                       "",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 15,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Container(
//                           // height: 160,
//                           width: Get.size.width,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 20),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                     Text(
//                                       "Date".tr,
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 15,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     Text(
//                                       bookingController.proDetailsInfo
//                                               ?.bookdetails!.date! ??
//                                           "",
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyBold,
//                                         fontSize: 15,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   height: 20,
//                                 ),
//                                 Row(
//                                   children: [
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                     Text(
//                                       "Time".tr,
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyMedium,
//                                         fontSize: 15,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                     Spacer(),
//                                     Text(
//                                       bookingController
//                                           .proDetailsInfo!.bookdetails!.time!,
//                                       style: TextStyle(
//                                         fontFamily: FontFamily.gilroyBold,
//                                         fontSize: 15,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       width: 20,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 20),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                   Text(
//                                     'Name'.tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   bookingController.proDetailsInfo?.bookdetails!
//                                               .customerName ==
//                                           ""
//                                       ? Text(
//                                           getData
//                                               .read("UserLogin")["name"]
//                                               .toString(),
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyBold,
//                                             fontSize: 15,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         )
//                                       : Text(
//                                           bookingController.proDetailsInfo
//                                                   ?.bookdetails!.customerName ??
//                                               "",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyBold,
//                                             fontSize: 15,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                   Text(
//                                     'Phone Number'.tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   bookingController.proDetailsInfo?.bookdetails!
//                                               .customerMobile ==
//                                           ""
//                                       ? Text(
//                                           "${getData.read("UserLogin")["ccode"]} ${getData.read("UserLogin")["mobile"]}",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyBold,
//                                             fontSize: 15,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         )
//                                       : Text(
//                                           "${bookingController.proDetailsInfo?.bookdetails!.customerMobile ?? ""}",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyBold,
//                                             fontSize: 15,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(
//                                 height: 20,
//                               ),
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                   Text(
//                                     'Booking Status'.tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                   Spacer(),
//                                   Text(
//                                     bookingController.proDetailsInfo
//                                             ?.bookdetails!.bookStatus ??
//                                         "",
//                                     maxLines: 1,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyBold,
//                                       fontSize: 15,
//                                       color: notifire.getwhiteblackcolor,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     width: 20,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         SizedBox(
//                           height: bookingController
//                                       .proDetailsInfo?.bookdetails!.message ==
//                                   ""
//                               ? 0
//                               : 20,
//                         ),
//                         bookingController
//                                     .proDetailsInfo?.bookdetails!.message ==
//                                 ""
//                             ? SizedBox()
//                             : Container(
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: notifire.getblackwhitecolor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(20),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Note:",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 18,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "${bookingController.proDetailsInfo?.bookdetails!.message}",
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyMedium,
//                                           fontSize: 15,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             : Center(
//                 child: CircularProgressIndicator(),
//               );
//       }),
//     );
//   }
//
//   ticketCancell(ticketid) {
//     showModalBottomSheet(
//         isDismissible: false,
//         isScrollControlled: true,
//         backgroundColor: notifire.getbgcolor,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//             return SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.only(
//                     bottom: MediaQuery.of(context).viewInsets.bottom),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(height: Get.height * 0.02),
//                     Container(
//                         height: 6,
//                         width: 80,
//                         decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(25))),
//                     SizedBox(height: Get.height * 0.02),
//                     Text(
//                       "Select Reason".tr,
//                       style: TextStyle(
//                           fontSize: 20,
//                           fontFamily: 'Gilroy Bold',
//                           color: notifire.getwhiteblackcolor),
//                     ),
//                     SizedBox(height: Get.height * 0.02),
//                     Text(
//                       "Please select the reason for cancellation:".tr,
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontFamily: 'Gilroy Medium',
//                           color: notifire.getwhiteblackcolor),
//                     ),
//                     SizedBox(height: Get.height * 0.02),
//                     ListView.builder(
//                       itemCount: cancelList.length,
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemBuilder: (ctx, i) {
//                         return RadioListTile(
//                           dense: true,
//                           value: i,
//                           activeColor: Color(0xFF246BFD),
//                           tileColor: notifire.getdarkscolor,
//                           selected: true,
//                           groupValue: selectedRadioTile,
//                           title: Text(
//                             cancelList[i]["title"],
//                             style: TextStyle(
//                                 fontSize: 16,
//                                 fontFamily: 'Gilroy Medium',
//                                 color: notifire.getwhiteblackcolor),
//                           ),
//                           onChanged: (val) {
//                             setState(() {});
//                             selectedRadioTile = val;
//                             rejectmsg = cancelList[i]["title"];
//                           },
//                         );
//                       },
//                     ),
//                     rejectmsg == "Others".tr
//                         ? SizedBox(
//                             height: 50,
//                             width: Get.width * 0.85,
//                             child: TextField(
//                               controller: note,
//                               decoration: InputDecoration(
//                                   isDense: true,
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(10)),
//                                     borderSide: BorderSide(
//                                         color: Color(0xFF246BFD), width: 1),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(10)),
//                                     borderSide: BorderSide(
//                                         color: Color(0xFF246BFD), width: 1),
//                                   ),
//                                   hintText: 'Enter reason'.tr,
//                                   hintStyle: TextStyle(
//                                       fontFamily: 'Gilroy Medium',
//                                       fontSize: Get.size.height / 55,
//                                       color: Colors.grey)),
//                             ),
//                           )
//                         : const SizedBox(),
//                     SizedBox(height: Get.height * 0.02),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         SizedBox(
//                           width: Get.width * 0.35,
//                           height: Get.height * 0.05,
//                           child: ticketbutton(
//                             title: "Cancel".tr,
//                             bgColor: Color(0xFF246BFD),
//                             titleColor: Colors.white,
//                             ontap: () {
//                               Get.back();
//                             },
//                           ),
//                         ),
//                         SizedBox(
//                           width: Get.width * 0.35,
//                           height: Get.height * 0.05,
//                           child: ticketbutton(
//                             title: "Confirm".tr,
//                             bgColor: Color(0xFF246BFD),
//                             titleColor: Colors.white,
//                             ontap: () {
//                               Get.back();
//                               bookingController.getBookingCancle(
//                                 bookId: ticketid,
//                                 reason: rejectmsg == "Others".tr
//                                     ? note.text
//                                     : rejectmsg,
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: Get.height * 0.04),
//                   ],
//                 ),
//               ),
//             );
//           });
//         });
//   }
//
//   List cancelList = [
//     {"id": 1, "title": "Financing fell through".tr},
//     {"id": 2, "title": "Inspection issues".tr},
//     {"id": 3, "title": "Change in financial situation".tr},
//     {"id": 4, "title": "Title issues".tr},
//     {"id": 5, "title": "Seller changes their mind".tr},
//     {"id": 6, "title": "Competing offer".tr},
//     {"id": 7, "title": "Personal reasons".tr},
//     {"id": 8, "title": "Others".tr},
//   ];
//
//   ticketbutton({Function()? ontap, String? title, Color? bgColor, titleColor}) {
//     return InkWell(
//       onTap: ontap,
//       child: Container(
//         height: Get.height * 0.04,
//         width: Get.width * 0.40,
//         decoration: BoxDecoration(
//             color: bgColor,
//             borderRadius: (BorderRadius.circular(18)),
//             border: Border.all(color: bgColor!, width: 1)),
//         child: Center(
//           child: Text(title!,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                   color: titleColor,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.5,
//                   fontFamily: 'Gilroy Medium')),
//         ),
//       ),
//     );
//   }
//
//   Future reviewSheet() {
//     return Get.bottomSheet(
//       isScrollControlled: true,
//       GetBuilder<BookingController>(builder: (context) {
//         return Container(
//           height: 520,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "Leave a Review".tr,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontFamily: FontFamily.gilroyBold,
//                   color: notifire.getwhiteblackcolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                 ),
//                 child: Divider(
//                   color: notifire.getgreycolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "How was your experience".tr,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontFamily: FontFamily.gilroyBold,
//                   color: notifire.getwhiteblackcolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               RatingBar(
//                 initialRating: 1,
//                 direction: Axis.horizontal,
//                 allowHalfRating: true,
//                 itemCount: 5,
//                 ratingWidget: RatingWidget(
//                   full: Image.asset(
//                     'assets/images/starBold.png',
//                     color: blueColor,
//                   ),
//                   half: Image.asset(
//                     'assets/images/star-half.png',
//                     color: blueColor,
//                   ),
//                   empty: Image.asset(
//                     'assets/images/Star.png',
//                     color: blueColor,
//                   ),
//                 ),
//                 itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
//                 onRatingUpdate: (rating) {
//                   bookingController.totalRateUpdate(rating);
//                 },
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                 ),
//                 child: Divider(
//                   color: notifire.getgreycolor,
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, left: 15),
//                 child: Text(
//                   "Write Your Review".tr,
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontFamily: FontFamily.gilroyBold,
//                     color: notifire.getwhiteblackcolor,
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.all(15),
//                 child: TextFormField(
//                   controller: bookingController.ratingText,
//                   minLines: 4,
//                   keyboardType: TextInputType.multiline,
//                   maxLines: null,
//                   cursorColor: notifire.getwhiteblackcolor,
//                   decoration: InputDecoration(
//                     contentPadding: EdgeInsets.all(10),
//                     focusedBorder: InputBorder.none,
//                     border: InputBorder.none,
//                     hintText: "Your review here...".tr,
//                     hintStyle: TextStyle(
//                       fontFamily: FontFamily.gilroyMedium,
//                       fontSize: 15,
//                     ),
//                   ),
//                   style: TextStyle(
//                     fontFamily: FontFamily.gilroyMedium,
//                     fontSize: 16,
//                     color: notifire.getwhiteblackcolor,
//                   ),
//                 ),
//                 decoration: BoxDecoration(
//                   color: notifire.getblackwhitecolor,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                 ),
//                 child: Divider(
//                   color: notifire.getgreycolor,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         Get.back();
//                       },
//                       child: Container(
//                         height: 50,
//                         margin: EdgeInsets.all(15),
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Maybe Later".tr,
//                           style: TextStyle(
//                             color: blueColor,
//                             fontFamily: FontFamily.gilroyBold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFeef4ff),
//                           borderRadius: BorderRadius.circular(45),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         bookingController.reviewUpdateApi(
//                           bookId: bookingController
//                               .proDetailsInfo?.bookdetails!.bookId,
//                         );
//                       },
//                       child: Container(
//                         height: 50,
//                         margin: EdgeInsets.all(15),
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Submit".tr,
//                           style: TextStyle(
//                             color: WhiteColor,
//                             fontFamily: FontFamily.gilroyBold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                           color: blueColor,
//                           borderRadius: BorderRadius.circular(45),
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               )
//             ],
//           ),
//           decoration: BoxDecoration(
//             color: notifire.getblackwhitecolor,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
