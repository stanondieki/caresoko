// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/booking_controller.dart';
import 'package:gotocarefinder/controller/myearning_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // for `currency`
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyEarningsScreen extends StatefulWidget {
  const MyEarningsScreen({super.key});

  @override
  State<MyEarningsScreen> createState() => _MyEarningsScreenState();
}

class _MyEarningsScreenState extends State<MyEarningsScreen> {
  final MyEarningController myEarningController = Get.find();
  final BookingController bookingController = Get.find();

  late ColorNotifire notifire;

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

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
        leading: BackButton(
          color: notifire.getwhiteblackcolor,
          onPressed: () => Get.back(),
        ),
        title: Text(
          "My Earnings..".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
      body: GetBuilder<MyEarningController>(builder: (context) {
        if (!myEarningController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final list = myEarningController.earningInfo?.statuswise ?? [];
        if (list.isEmpty) {
          return _EmptyState(notifire: notifire);
        }

        return LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;

            // Clamp huge system text scales (prevents overflows)
            final mq = MediaQuery.of(context);
            final clamped = mq.copyWith(
              textScaler: TextScaler.linear(mq.textScaleFactor.clamp(1.0, 1.2)),
            );

            // Breakpoints: phone = 1 col (list), tablet = 2, desktop = 3
            final crossAxisCount = width >= 1200 ? 3 : (width >= 800 ? 2 : 1);

            double gridAspectFor(int count) {
              // < 1 => taller than wide (prevents bottom overflow)
              if (count == 3) return 0.95; // desktop: a bit tall
              if (count == 2) return 0.90; // tablet: taller
              return 1.0; // unused in list mode
            }

            return MediaQuery(
              data: clamped,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width < 600 ? 10 : 16,
                      vertical: 10,
                    ),
                    sliver: crossAxisCount == 1
                        // ===== PHONE: NATURAL-HEIGHT LIST WITH HORIZONTAL TILE =====
                        ? SliverList.builder(
                            itemCount: list.length,
                            itemBuilder: (_, index) {
                              final item = list[index];
                              return _EarningTile(
                                notifire: notifire,
                                title: item.propTitle ?? "",
                                imageUrl:
                                    "${Config.imageUrl}${item.propImg ?? ""}",
                                ratingText: item.rate ?? "",
                                pricePerDay: item.propPrice,
                                totalDays: item.totalDay,
                                vertical: false, // Row layout on phones
                                onTapReceipt: () async {
                                  await bookingController.getBookingDetails(
                                    bookId: item.bookId ?? "",
                                  );
                                  // COMMENTED OUT: Advert functionality disabled
                                  // Get.toNamed(Routes.eReceiptProScreen);
                                },
                              );
                            },
                          )
                        // ===== TABLET/DESKTOP: GRID WITH VERTICAL CARD =====
                        : SliverGrid.builder(
                            itemCount: list.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: gridAspectFor(crossAxisCount),
                            ),
                            itemBuilder: (_, index) {
                              final item = list[index];
                              return _EarningTile(
                                notifire: notifire,
                                title: item.propTitle ?? "",
                                imageUrl:
                                    "${Config.imageUrl}${item.propImg ?? ""}",
                                ratingText: item.rate ?? "",
                                pricePerDay: item.propPrice,
                                totalDays: item.totalDay,
                                vertical: true, // Column layout in grid
                                onTapReceipt: () async {
                                  await bookingController.getBookingDetails(
                                    bookId: item.bookId ?? "",
                                  );
                                  // COMMENTED OUT: Advert functionality disabled
                                  // Get.toNamed(Routes.eReceiptProScreen);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class _EarningTile extends StatelessWidget {
  final ColorNotifire notifire;
  final String title;
  final String imageUrl;
  final String ratingText;
  final dynamic pricePerDay; // could be String/num/null in API
  final dynamic totalDays; // could be String/num/null in API
  final bool vertical; // true: Column layout (grid), false: Row layout (list)
  final VoidCallback onTapReceipt;

  const _EarningTile({
    required this.notifire,
    required this.title,
    required this.imageUrl,
    required this.ratingText,
    required this.pricePerDay,
    required this.totalDays,
    required this.vertical,
    required this.onTapReceipt,
  });

  // Safely parse any price/day input (strings like "1,200.00" or "  40 " or "")
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    final s = v.toString().trim();
    if (s.isEmpty) return 0.0;
    // Keep digits, dot and minus
    final cleaned = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final price = _toDouble(pricePerDay);
    final days = _toDouble(totalDays);
    final total = price * days;

    // Two adaptive layouts:
    // - vertical == false (Row): for phones (image left, content right)
    // - vertical == true  (Column): for tablets/desktop grid (image top, content bottom)

    return Card(
      color: notifire.getblackwhitecolor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: vertical
          ? _buildVertical(context, total, days)
          : _buildHorizontal(context, total, days),
    );
  }

  Widget _buildHorizontal(BuildContext context, double total, double days) {
    // Phone list item (Row) — natural height, no overflow risk
    final imageRadius = 12.0;
    final w = MediaQuery.of(context).size.width;
    final isCompact = w < 400;
    final leftImageWidth = isCompact ? 110.0 : 130.0;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(imageRadius),
            child: SizedBox(
              width: leftImageWidth,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/images/ezgif.com-crop.gif",
                        image: imageUrl,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (_, __, ___) => Image.asset(
                          "assets/images/ezgif.com-crop.gif",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    _RatingChip(ratingText: ratingText),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // let height be natural
              children: [
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),

                // Amount + days
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "${currency}${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 18,
                        color: blueColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "/${days.toStringAsFixed(days.truncateToDouble() == days ? 0 : 2)} ${"days".tr}",
                      style: TextStyle(
                        color: notifire.getgreycolor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // E-Receipt button
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: onTapReceipt,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: blueColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "E-Receipt".tr,
                        style: TextStyle(
                          color: blueColor,
                          fontFamily: FontFamily.gilroyMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVertical(BuildContext context, double total, double days) {
    // Grid tile (Column): make sure it NEVER overflows
    // Use Expanded for the bottom content so it flexes inside the fixed grid height.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image (fixed ratio)
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FadeInImage.assetNetwork(
                placeholder: "assets/images/ezgif.com-crop.gif",
                image: imageUrl,
                fit: BoxFit.cover,
                imageErrorBuilder: (_, __, ___) => Image.asset(
                  "assets/images/ezgif.com-crop.gif",
                  fit: BoxFit.cover,
                ),
              ),
              _RatingChip(ratingText: ratingText),
            ],
          ),
        ),

        // Bottom content takes remaining height and scrolls/ellipsizes as needed
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Amount + days
                Row(
                  children: [
                    Text(
                      "${currency}${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 16,
                        color: blueColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "/${days.toStringAsFixed(days.truncateToDouble() == days ? 0 : 2)} ${"days".tr}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: notifire.getgreycolor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // E-Receipt button (full width)
                SizedBox(
                  height: 36,
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: blueColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: onTapReceipt,
                    child: Text(
                      "E-Receipt".tr,
                      style: TextStyle(
                        color: blueColor,
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String ratingText;
  const _RatingChip({required this.ratingText});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFedeeef),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              "assets/images/Rating.png",
              height: 12,
              width: 12,
            ),
            const SizedBox(width: 4),
            Text(
              ratingText,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                color: blueColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorNotifire notifire;
  const _EmptyState({required this.notifire});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/bookingEmpty.png", height: 120),
            const SizedBox(height: 16),
            Text(
              "Go & Book your favorite service".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notifire.getgreycolor,
                fontFamily: FontFamily.gilroyBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, sort_child_properties_last
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/booking_controller.dart';
// import 'package:gotocarefinder/controller/myearning_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class MyEarningsScreen extends StatefulWidget {
//   const MyEarningsScreen({super.key});
//
//   @override
//   State<MyEarningsScreen> createState() => _MyEarningsScreenState();
// }
//
// class _MyEarningsScreenState extends State<MyEarningsScreen> {
//   MyEarningController myEarningController = Get.find();
//   BookingController bookingController = Get.find();
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
//       appBar: AppBar(
//         backgroundColor: notifire.getbgcolor,
//         elevation: 0,
//         leading: BackButton(
//           color: notifire.getwhiteblackcolor,
//           onPressed: () {
//             Get.back();
//           },
//         ),
//         title: Text(
//           "My Earnings".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//           ),
//         ),
//       ),
//       body: GetBuilder<MyEarningController>(builder: (context) {
//         return SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: myEarningController.isLoading
//               ? myEarningController.earningInfo!.statuswise!.isNotEmpty
//                   ? ListView.builder(
//                       itemCount:
//                           myEarningController.earningInfo?.statuswise!.length,
//                       physics: BouncingScrollPhysics(),
//                       itemBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             InkWell(
//                               onTap: () async {},
//                               child: Container(
//                                 height: 155,
//                                 margin: EdgeInsets.all(10),
//                                 child: Row(
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         Container(
//                                           height: 135,
//                                           width: 130,
//                                           margin: EdgeInsets.all(10),
//                                           child: ClipRRect(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                             child: FadeInImage.assetNetwork(
//                                               fadeInCurve: Curves.easeInCirc,
//                                               placeholder:
//                                                   "assets/images/ezgif.com-crop.gif",
//                                               height: 135,
//                                               imageErrorBuilder:
//                                                   (context, error, stackTrace) {
//                                                 return Image.asset(
//                                                   "assets/images/ezgif.com-crop.gif",
//                                                   height: 48,
//                                                   width: 48,
//                                                   fit: BoxFit.cover,
//                                                 );
//                                               },
//                                               image:
//                                                   "${Config.imageUrl}${myEarningController.earningInfo?.statuswise![index].propImg ?? ""}",
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                           ),
//                                         ),
//                                         Positioned(
//                                           top: 15,
//                                           right: 20,
//                                           child: Container(
//                                             height: 30,
//                                             width: 45,
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                   margin:
//                                                       const EdgeInsets.fromLTRB(
//                                                           0, 0, 3, 0),
//                                                   child: Image.asset(
//                                                     "assets/images/Rating.png",
//                                                     height: 12,
//                                                     width: 12,
//                                                   ),
//                                                 ),
//                                                 Text(
//                                                   myEarningController
//                                                           .earningInfo
//                                                           ?.statuswise![index]
//                                                           .rate ??
//                                                       "",
//                                                   style: TextStyle(
//                                                     fontFamily:
//                                                         FontFamily.gilroyMedium,
//                                                     color: blueColor,
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: Color(0xFFedeeef),
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       width: 8,
//                                     ),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             myEarningController
//                                                     .earningInfo
//                                                     ?.statuswise![index]
//                                                     .propTitle ??
//                                                 "",
//                                             maxLines: 2,
//                                             style: TextStyle(
//                                               fontSize: 17,
//                                               fontFamily: FontFamily.gilroyBold,
//                                               color:
//                                                   notifire.getwhiteblackcolor,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 15,
//                                           ),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 "${currency}${int.parse(myEarningController.earningInfo?.statuswise![index].propPrice ?? "") * int.parse(myEarningController.earningInfo?.statuswise![index].totalDay ?? "")}",
//                                                 style: TextStyle(
//                                                   fontFamily:
//                                                       FontFamily.gilroyBold,
//                                                   fontSize: 20,
//                                                   color: blueColor,
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                 width: 5,
//                                               ),
//                                               Text(
//                                                 "/${myEarningController.earningInfo?.statuswise![index].totalDay ?? ""} ${"days".tr}",
//                                                 style: TextStyle(
//                                                   color: notifire.getgreycolor,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(
//                                             height: 15,
//                                           ),
//                                           InkWell(
//                                             onTap: () async {
//                                               await bookingController
//                                                   .getBookingDetails(
//                                                 bookId: myEarningController
//                                                         .earningInfo
//                                                         ?.statuswise![index]
//                                                         .bookId ??
//                                                     "",
//                                               );
//                                               Get.toNamed(
//                                                 Routes.eReceiptProScreen,
//                                               );
//                                             },
//                                             child: Container(
//                                               height: 35,
//                                               width: 120,
//                                               alignment: Alignment.center,
//                                               padding: EdgeInsets.all(8),
//                                               child: Text(
//                                                 "E-Receipt".tr,
//                                                 style: TextStyle(
//                                                   color: blueColor,
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color: blueColor),
//                                                 borderRadius:
//                                                     BorderRadius.circular(5),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: notifire.getblackwhitecolor,
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(left: 30),
//                             child: Image.asset(
//                               "assets/images/bookingEmpty.png",
//                               height: 110,
//                               width: 100,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 20,
//                           ),
//                           Text(
//                             "Go & Book your favorite service".tr,
//                             style: TextStyle(
//                               color: notifire.getgreycolor,
//                               fontFamily: FontFamily.gilroyBold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//               : Center(
//                   child: CircularProgressIndicator(),
//                 ),
//         );
//       }),
//     );
//   }
// }
