// ignore_for_file: unnecessary_brace_in_string_interps, sort_child_properties_last, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeaturedScreen extends StatefulWidget {
  const FeaturedScreen({super.key});

  @override
  State<FeaturedScreen> createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  final HomePageController homePageController = Get.find();
  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final padding = R.screenPadding(context);

    final featured = homePageController.homeDatatInfo?.homeData?.featuredProperty ?? [];

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
          "Featured".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
            child: Padding(
              padding: padding,
              child: featured.isNotEmpty
                  ? _ResponsiveFeaturedList(
                featuredLength: featured.length,
                itemBuilder: (idx) => _FeaturedItem(
                  name: featured[idx].name ?? "",
                  imageUrl: "${Config.imageUrl}${featured[idx].image ?? ""}",
                  zipcode: featured[idx].zipcode ?? "",
                  city: featured[idx].city ?? "",
                  rate: featured[idx].rate ?? "",
                  typeTitle: featured[idx].propertyTypeTitle ?? "",
                  onTap: () async {
                    setState(() => homePageController.rate = featured[idx].rate ?? "");
                    homePageController.chnageObjectIndex(idx);
                    await homePageController.getPropertyDetailsApi(
                      id: featured[idx].id,
                      ptype: featured[idx].propertyType,
                    );
                    Get.toNamed(Routes.viewDataScreen);
                  },
                  notifire: notifire,
                ),
              )
                  : _emptyState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        children: [
          SizedBox(height: 40),
          Image(
            image: AssetImage("assets/images/searchDataEmpty.png"),
            height: 110,
            width: 110,
          ),
          SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Text(
              "Sorry, there is no any nearby \n category or data not found".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notifire.getgreycolor,
                fontFamily: FontFamily.gilroyBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Responsive wrapper =====================
/// Owns ScrollControllers so Scrollbar always has a position.
class _ResponsiveFeaturedList extends StatefulWidget {
  final int featuredLength;
  final Widget Function(int index) itemBuilder;

  const _ResponsiveFeaturedList({
    required this.featuredLength,
    required this.itemBuilder,
  });

  @override
  State<_ResponsiveFeaturedList> createState() => _ResponsiveFeaturedListState();
}

class _ResponsiveFeaturedListState extends State<_ResponsiveFeaturedList> {
  final ScrollController _listCtrl = ScrollController();
  final ScrollController _gridCtrl = ScrollController();

  @override
  void dispose() {
    _listCtrl.dispose();
    _gridCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isList = w < 700; // <700px: vertical list using horizontal tiles

    if (isList) {
      return Scrollbar(
        controller: _listCtrl,
        thumbVisibility: kIsWeb,
        child: ListView.builder(
          controller: _listCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: widget.featuredLength,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: widget.itemBuilder(i),
          ),
        ),
      );
    }

    // Grid for tablet/desktop using a computed mainAxisExtent (fixed tile height)
    final cross = w >= 1500 ? 4 : (w >= 1200 ? 3 : 2);
    final spacing = 16.0;

    return Scrollbar(
      controller: _gridCtrl,
      thumbVisibility: kIsWeb,
      child: LayoutBuilder(
        builder: (context, c) {
          final mq = MediaQuery.of(context);
          final textScale = mq.textScaleFactor.clamp(1.0, 1.3);
          final gridWidth = c.maxWidth;
          final tileWidth = (gridWidth - spacing * (cross - 1)) / cross;

          // Image is 4:3 inside card → height = tileWidth * 3/4
          final imageHeight = tileWidth * 3 / 4;

          // Room for title/location/type + paddings inside card
          // Scale the text area with textScale to avoid overflow.
          final baseTextArea = 112.0; // ~ 3 lines + paddings
          final textArea = baseTextArea * textScale;

          // Card padding & borders add a bit; add slack for rating pill/rounding.
          final chrome = 24.0;

          final mainExtent = imageHeight + textArea + chrome;

          return GridView.builder(
            controller: _gridCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: widget.featuredLength,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: mainExtent, // <- prevents bottom overflow
            ),
            itemBuilder: (context, i) => _FeaturedCard(item: widget.itemBuilder(i)),
          );
        },
      ),
    );
  }
}

// Wraps a horizontal tile into a card for grid usage
class _FeaturedCard extends StatelessWidget {
  final Widget item;
  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: item,
      ),
    );
  }
}

/// ===================== Reusable item =====================
class _FeaturedItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String zipcode;
  final String city;
  final String rate;
  final String typeTitle;
  final VoidCallback onTap;
  final ColorNotifire notifire;

  const _FeaturedItem({
    required this.name,
    required this.imageUrl,
    required this.zipcode,
    required this.city,
    required this.rate,
    required this.typeTitle,
    required this.onTap,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final useHorizontalTile = w < 700; // list layout

    if (useHorizontalTile) {
      return _horizontalTile(context);
    }
    return _verticalCard(context);
  }

  Widget _horizontalTile(BuildContext context) {
    // Clamp text scale to avoid excessive vertical growth → bottom overflow
    final ts = MediaQuery.of(context)
        .textScaler
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: ts),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 132),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: notifire.getblackwhitecolor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: notifire.getborderColor),
            ),
            child: Row(
              // Prevent stretching children to full height → avoids tiny overflows
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image + badge
                Stack(
                  children: [
                    Container(
                      width: 136,
                      margin: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/images/ezgif.com-crop.gif",
                            image: imageUrl,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (c, e, s) =>
                                Container(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ),
                    Positioned(top: 14, right: 18, child: _ratingPill(rate)),
                  ],
                ),
                const SizedBox(width: 8),
                // Texts
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/location.svg",
                              height: 14,
                              colorFilter: ColorFilter.mode(
                                notifire.getwhiteblackcolor,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                zipcode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: notifire.getgreycolor,
                                  fontFamily: FontFamily.gilroyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          typeTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
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
          ),
        ),
      ),
    );
  }

  Widget _verticalCard(BuildContext context) {
    // Clamp scale a bit here too, to keep grid math predictable
    final ts = MediaQuery.of(context)
        .textScaler
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.25);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: ts),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: notifire.getblackwhitecolor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: notifire.getborderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3, // keep image stable
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/images/ezgif.com-crop.gif",
                        image: imageUrl,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (c, e, s) =>
                            Container(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  Positioned(top: 12, right: 12, child: _ratingPill(rate)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: FontFamily.gilroyBold,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/location.svg",
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            notifire.getwhiteblackcolor,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            zipcode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: notifire.getgreycolor,
                              fontFamily: FontFamily.gilroyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      typeTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontFamily.gilroyBold,
                        color: blueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ratingPill(String text) {
    return Container(
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(0xFFedeeef),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/Rating.png", height: 14, width: 14),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              color: blueColor,
            ),
          ),
        ],
      ),
    );
  }
}



// // ignore_for_file: unnecessary_brace_in_string_interps, sort_child_properties_last, prefer_const_constructors
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FeaturedScreen extends StatefulWidget {
//   const FeaturedScreen({super.key});
//
//   @override
//   State<FeaturedScreen> createState() => _FeaturedScreenState();
// }
//
// class _FeaturedScreenState extends State<FeaturedScreen> {
//   final HomePageController homePageController = Get.find();
//   late ColorNotifire notifire;
//
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     notifire.setIsDark = previusstate ?? false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     final padding = R.screenPadding(context);
//
//     final featured = homePageController.homeDatatInfo?.homeData?.featuredProperty ?? [];
//
//     return Scaffold(
//       backgroundColor: notifire.getbgcolor,
//       appBar: AppBar(
//         backgroundColor: notifire.getbgcolor,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
//         ),
//         title: Text(
//           "Featured".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
//             child: Padding(
//               padding: padding,
//               child: featured.isNotEmpty
//                   ? _ResponsiveFeaturedList(
//                 featuredLength: featured.length,
//                 itemBuilder: (idx) => _FeaturedItem(
//                   name: featured[idx].name ?? "",
//                   imageUrl: "${Config.imageUrl}${featured[idx].image ?? ""}",
//                   zipcode: featured[idx].zipcode ?? "",
//                   city: featured[idx].city ?? "",
//                   rate: featured[idx].rate ?? "",
//                   typeTitle: featured[idx].propertyTypeTitle ?? "",
//                   onTap: () async {
//                     setState(() => homePageController.rate = featured[idx].rate ?? "");
//                     homePageController.chnageObjectIndex(idx);
//                     await homePageController.getPropertyDetailsApi(
//                       id: featured[idx].id,
//                       ptype: featured[idx].propertyType,
//                     );
//                     Get.toNamed(Routes.viewDataScreen);
//                   },
//                   notifire: notifire,
//                 ),
//               )
//                   : _emptyState(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _emptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
//       child: Column(
//         children: [
//           SizedBox(height: 40),
//           Image(
//             image: AssetImage("assets/images/searchDataEmpty.png"),
//             height: 110,
//             width: 110,
//           ),
//           SizedBox(height: 12),
//           ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: 480),
//             child: Text(
//               "Sorry, there is no any nearby \n category or data not found".tr,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: notifire.getgreycolor,
//                 fontFamily: FontFamily.gilroyBold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// ===================== Responsive wrapper =====================
// /// Owns ScrollControllers so Scrollbar always has a position.
// class _ResponsiveFeaturedList extends StatefulWidget {
//   final int featuredLength;
//   final Widget Function(int index) itemBuilder;
//
//   const _ResponsiveFeaturedList({
//     required this.featuredLength,
//     required this.itemBuilder,
//   });
//
//   @override
//   State<_ResponsiveFeaturedList> createState() => _ResponsiveFeaturedListState();
// }
//
// class _ResponsiveFeaturedListState extends State<_ResponsiveFeaturedList> {
//   final ScrollController _listCtrl = ScrollController();
//   final ScrollController _gridCtrl = ScrollController();
//
//   @override
//   void dispose() {
//     _listCtrl.dispose();
//     _gridCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final isList = w < 700; // <700px: vertical list using horizontal tiles
//
//     if (isList) {
//       return Scrollbar(
//         controller: _listCtrl,
//         thumbVisibility: kIsWeb,
//         child: ListView.builder(
//           controller: _listCtrl,
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.only(bottom: 24),
//           itemCount: widget.featuredLength,
//           itemBuilder: (context, i) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: widget.itemBuilder(i),
//           ),
//         ),
//       );
//     }
//
//     // Grid for tablet/desktop, with a TALLER tile to avoid bottom overflow.
//     final cross = w >= 1500
//         ? 4
//         : w >= 1200
//         ? 3
//         : 2;
//
//     // Make tiles taller by lowering the aspect ratio (width/height).
//     // These values leave enough room for the image (4/3 inside the card) + three text lines.
//     final double ratio = cross >= 4
//         ? 0.95   // 4 columns → slightly taller than square
//         : cross == 3
//         ? 0.85
//         : 0.75; // 2 columns → tallest tiles
//
//     return Scrollbar(
//       controller: _gridCtrl,
//       thumbVisibility: kIsWeb,
//       child: GridView.builder(
//         controller: _gridCtrl,
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.only(bottom: 24),
//         itemCount: widget.featuredLength,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: cross,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: ratio, // ↓ smaller ratio = taller cell
//         ),
//         itemBuilder: (context, i) => _FeaturedCard(item: widget.itemBuilder(i)),
//       ),
//     );
//   }
// }
//
// // Wraps a horizontal tile into a card for grid usage
// class _FeaturedCard extends StatelessWidget {
//   final Widget item;
//   const _FeaturedCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Theme.of(context).dividerColor),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(6.0),
//         child: item,
//       ),
//     );
//   }
// }
//
// /// ===================== Reusable item =====================
// class _FeaturedItem extends StatelessWidget {
//   final String name;
//   final String imageUrl;
//   final String zipcode;
//   final String city;
//   final String rate;
//   final String typeTitle;
//   final VoidCallback onTap;
//   final ColorNotifire notifire;
//
//   const _FeaturedItem({
//     required this.name,
//     required this.imageUrl,
//     required this.zipcode,
//     required this.city,
//     required this.rate,
//     required this.typeTitle,
//     required this.onTap,
//     required this.notifire,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final useHorizontalTile = w < 700; // list layout
//
//     if (useHorizontalTile) {
//       return _horizontalTile(context);
//     }
//     return _verticalCard(context);
//   }
//
//   Widget _horizontalTile(BuildContext context) {
//     // Clamp text scale to avoid excessive vertical growth → bottom overflow
//     final ts = MediaQuery.of(context)
//         .textScaler
//         .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
//
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaler: ts),
//       child: InkWell(
//         onTap: onTap,
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(minHeight: 132),
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: notifire.getblackwhitecolor,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(color: notifire.getborderColor),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Image + badge
//                 Stack(
//                   children: [
//                     Container(
//                       width: 136,
//                       margin: const EdgeInsets.all(10),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(15),
//                         child: AspectRatio(
//                           aspectRatio: 1,
//                           child: FadeInImage.assetNetwork(
//                             placeholder: "assets/images/ezgif.com-crop.gif",
//                             image: imageUrl,
//                             fit: BoxFit.cover,
//                             imageErrorBuilder: (c, e, s) =>
//                                 Container(color: Colors.grey.shade200),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(top: 14, right: 18, child: _ratingPill(rate)),
//                   ],
//                 ),
//                 const SizedBox(width: 8),
//                 // Texts
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontFamily: FontFamily.gilroyBold,
//                             color: notifire.getwhiteblackcolor,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             SvgPicture.asset(
//                               "assets/images/location.svg",
//                               height: 14,
//                               colorFilter: ColorFilter.mode(
//                                 notifire.getwhiteblackcolor,
//                                 BlendMode.srcIn,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 zipcode,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: notifire.getgreycolor,
//                                   fontFamily: FontFamily.gilroyMedium,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           typeTitle,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontFamily: FontFamily.gilroyBold,
//                             color: blueColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _verticalCard(BuildContext context) {
//     // Keep a consistent image aspect and let the tile be tall enough (grid ratio handles height).
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: notifire.getblackwhitecolor,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: notifire.getborderColor),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // image
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     topRight: Radius.circular(16),
//                   ),
//                   child: AspectRatio(
//                     aspectRatio: 4 / 3, // keep image stable
//                     child: FadeInImage.assetNetwork(
//                       placeholder: "assets/images/ezgif.com-crop.gif",
//                       image: imageUrl,
//                       fit: BoxFit.cover,
//                       imageErrorBuilder: (c, e, s) =>
//                           Container(color: Colors.grey.shade200),
//                     ),
//                   ),
//                 ),
//                 Positioned(top: 12, right: 12, child: _ratingPill(rate)),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontFamily: FontFamily.gilroyBold,
//                       color: notifire.getwhiteblackcolor,
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Row(
//                     children: [
//                       SvgPicture.asset(
//                         "assets/images/location.svg",
//                         height: 14,
//                         colorFilter: ColorFilter.mode(
//                           notifire.getwhiteblackcolor,
//                           BlendMode.srcIn,
//                         ),
//                       ),
//                       SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           zipcode,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: notifire.getgreycolor,
//                             fontFamily: FontFamily.gilroyMedium,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     typeTitle,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: FontFamily.gilroyBold,
//                       color: blueColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _ratingPill(String text) {
//     return Container(
//       height: 28,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: Color(0xFFedeeef),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Image.asset("assets/images/Rating.png", height: 14, width: 14),
//           SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyMedium,
//               color: blueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// // ignore_for_file: unnecessary_brace_in_string_interps, sort_child_properties_last, prefer_const_constructors
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FeaturedScreen extends StatefulWidget {
//   const FeaturedScreen({super.key});
//
//   @override
//   State<FeaturedScreen> createState() => _FeaturedScreenState();
// }
//
// class _FeaturedScreenState extends State<FeaturedScreen> {
//   final HomePageController homePageController = Get.find();
//
//   late ColorNotifire notifire;
//
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     notifire.setIsDark = previusstate ?? false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     final padding = R.screenPadding(context);
//
//     final featured = homePageController.homeDatatInfo?.homeData?.featuredProperty ?? [];
//
//     return Scaffold(
//       backgroundColor: notifire.getbgcolor,
//       appBar: AppBar(
//         backgroundColor: notifire.getbgcolor,
//         elevation: 0,
//         leading: IconButton(
//           onPressed: () => Get.back(),
//           icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
//         ),
//         title: Text(
//           "Featured".tr,
//           style: TextStyle(fontSize: 17, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor),
//         ),
//       ),
//       body: Align(
//         alignment: Alignment.topCenter,
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
//           child: Padding(
//             padding: padding,
//             child: featured.isNotEmpty
//                 ? _ResponsiveFeaturedList(
//               featuredLength: featured.length,
//               itemBuilder: (idx) => _FeaturedItem(
//                 name: featured[idx].name ?? "",
//                 imageUrl: "${Config.imageUrl}${featured[idx].image ?? ""}",
//                 zipcode: featured[idx].zipcode ?? "",
//                 city: featured[idx].city ?? "",
//                 rate: featured[idx].rate ?? "",
//                 typeTitle: featured[idx].propertyTypeTitle ?? "",
//                 onTap: () async {
//                   setState(() => homePageController.rate = featured[idx].rate ?? "");
//                   homePageController.chnageObjectIndex(idx);
//                   await homePageController.getPropertyDetailsApi(
//                     id: featured[idx].id,
//                     ptype: featured[idx].propertyType,
//                   );
//                   Get.toNamed(Routes.viewDataScreen);
//                 },
//                 notifire: notifire,
//               ),
//             )
//                 : _emptyState(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _emptyState() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
//       child: Column(children: [
//         SizedBox(height: 40),
//         Image(image: AssetImage("assets/images/searchDataEmpty.png"), height: 110, width: 110),
//         SizedBox(height: 12),
//         ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: 480),
//           child: Text(
//             "Sorry, there is no any nearby \n category or data not found".tr,
//             textAlign: TextAlign.center,
//             style: TextStyle(color: notifire.getgreycolor, fontFamily: FontFamily.gilroyBold),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// // ===================== Responsive wrapper =====================
// class _ResponsiveFeaturedList extends StatelessWidget {
//   final int featuredLength;
//   final Widget Function(int index) itemBuilder;
//   const _ResponsiveFeaturedList({required this.featuredLength, required this.itemBuilder});
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final isList = w < 700; // <700px use vertical list with horizontal tiles
//
//     if (isList) {
//       return Scrollbar(
//         thumbVisibility: kIsWeb,
//         child: ListView.builder(
//           itemCount: featuredLength,
//           itemBuilder: (context, i) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: itemBuilder(i)),
//         ),
//       );
//     }
//
//     // grid for tablet/desktop
//     final cross = w >= 1500
//         ? 4
//         : w >= 1200
//         ? 3
//         : 2;
//
//     return Scrollbar(
//       thumbVisibility: kIsWeb,
//       child: GridView.builder(
//         itemCount: featuredLength,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: cross,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 4 / 3, // image card aspect
//         ),
//         itemBuilder: (context, i) {
//           return _FeaturedCard(item: itemBuilder(i));
//         },
//       ),
//     );
//   }
// }
//
// // Wraps a horizontal tile into a card for grid usage
// class _FeaturedCard extends StatelessWidget {
//   final Widget item;
//   const _FeaturedCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor)),
//       child: Padding(
//         padding: const EdgeInsets.all(6.0),
//         child: item,
//       ),
//     );
//   }
// }
//
// // ===================== Reusable item =====================
// class _FeaturedItem extends StatelessWidget {
//   final String name;
//   final String imageUrl;
//   final String zipcode;
//   final String city;
//   final String rate;
//   final String typeTitle;
//   final VoidCallback onTap;
//   final ColorNotifire notifire;
//
//   const _FeaturedItem({
//     required this.name,
//     required this.imageUrl,
//     required this.zipcode,
//     required this.city,
//     required this.rate,
//     required this.typeTitle,
//     required this.onTap,
//     required this.notifire,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final useHorizontalTile = w < 700; // list layout
//
//     if (useHorizontalTile) {
//       return _horizontalTile(context);
//     }
//
//     return _verticalCard(context);
//   }
//
//   Widget _horizontalTile(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         height: 150,
//         decoration: BoxDecoration(color: notifire.getblackwhitecolor, borderRadius: BorderRadius.circular(15), border: Border.all(color: notifire.getborderColor)),
//         child: Row(
//           children: [
//             // Image
//             Stack(children: [
//               Container(
//                 height: 150,
//                 width: 140,
//                 margin: EdgeInsets.all(10),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: FadeInImage.assetNetwork(
//                     placeholder: "assets/images/ezgif.com-crop.gif",
//                     image: imageUrl,
//                     fit: BoxFit.cover,
//                     imageErrorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: 15,
//                 right: 24,
//                 child: _ratingPill(rate),
//               ),
//             ]),
//             SizedBox(width: 8),
//             // Texts
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor)),
//                   SizedBox(height: 6),
//                   Row(children: [
//                     SvgPicture.asset("assets/images/location.svg", height: 14, colorFilter: ColorFilter.mode(notifire.getwhiteblackcolor, BlendMode.srcIn)),
//                     SizedBox(width: 4),
//                     Expanded(
//                       child: Text(zipcode, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: notifire.getgreycolor, fontFamily: FontFamily.gilroyMedium)),
//                     ),
//                   ]),
//                   SizedBox(height: 8),
//                   Text(typeTitle, style: TextStyle(fontSize: 14, fontFamily: FontFamily.gilroyBold, color: blueColor)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _verticalCard(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(color: notifire.getblackwhitecolor, borderRadius: BorderRadius.circular(16), border: Border.all(color: notifire.getborderColor)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           // image
//           Stack(children: [
//             ClipRRect(
//               borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
//               child: AspectRatio(
//                 aspectRatio: 4 / 3,
//                 child: FadeInImage.assetNetwork(
//                   placeholder: "assets/images/ezgif.com-crop.gif",
//                   image: imageUrl,
//                   fit: BoxFit.cover,
//                   imageErrorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
//                 ),
//               ),
//             ),
//             Positioned(top: 12, right: 12, child: _ratingPill(rate)),
//           ]),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor)),
//               SizedBox(height: 6),
//               Row(children: [
//                 SvgPicture.asset("assets/images/location.svg", height: 14, colorFilter: ColorFilter.mode(notifire.getwhiteblackcolor, BlendMode.srcIn)),
//                 SizedBox(width: 4),
//                 Expanded(child: Text(zipcode, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: notifire.getgreycolor, fontFamily: FontFamily.gilroyMedium))),
//               ]),
//               SizedBox(height: 8),
//               Text(typeTitle, style: TextStyle(fontSize: 14, fontFamily: FontFamily.gilroyBold, color: blueColor)),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   Widget _ratingPill(String text) {
//     return Container(
//       height: 28,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       alignment: Alignment.center,
//       decoration: BoxDecoration(color: Color(0xFFedeeef), borderRadius: BorderRadius.circular(14)),
//       child: Row(children: [
//         Image.asset("assets/images/Rating.png", height: 14, width: 14),
//         SizedBox(width: 4),
//         Text(text, style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: blueColor)),
//       ]),
//     );
//   }
// }
//

// // ignore_for_file: unnecessary_brace_in_string_interps, sort_child_properties_last, prefer_const_constructors
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FeaturedScreen extends StatefulWidget {
//   const FeaturedScreen({super.key});
//
//   @override
//   State<FeaturedScreen> createState() => _FeaturedScreenState();
// }
//
// class _FeaturedScreenState extends State<FeaturedScreen> {
//   HomePageController homePageController = Get.find();
//
//   List facilities = [
//     "assets/images/beds.svg",
//     "assets/images/bath.svg",
//     "assets/images/sqft.svg",
//   ];
//
//   late ColorNotifire notifire;
//
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
//           "Featured".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: homePageController
//                     .homeDatatInfo!.homeData!.featuredProperty!.isNotEmpty
//                 ? ListView.builder(
//                     itemCount: homePageController
//                         .homeDatatInfo?.homeData!.featuredProperty!.length,
//                     itemBuilder: (context, index1) {
//                       return InkWell(
//                         onTap: () async {
//                           setState(() {
//                             homePageController.rate = homePageController
//                                     .homeDatatInfo
//                                     ?.homeData!
//                                     .featuredProperty![index1]
//                                     .rate ??
//                                 "";
//                           });
//                           homePageController.chnageObjectIndex(index1);
//                           await homePageController.getPropertyDetailsApi(
//                               id: homePageController.homeDatatInfo?.homeData!
//                                   .featuredProperty![index1].id,
//                               ptype: homePageController.homeDatatInfo?.homeData!
//                                   .featuredProperty![index1].propertyType);
//                           Get.toNamed(
//                             Routes.viewDataScreen,
//                           );
//                         },
//                         child: Container(
//                           height: 140,
//                           margin: EdgeInsets.all(10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Stack(
//                                 children: [
//                                   Container(
//                                     height: 140,
//                                     width: 130,
//                                     margin: EdgeInsets.all(10),
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(15),
//                                       child: FadeInImage.assetNetwork(
//                                         fadeInCurve: Curves.easeInCirc,
//                                         placeholder:
//                                             "assets/images/ezgif.com-crop.gif",
//                                         height: 140,
//                                         imageErrorBuilder:
//                                             (context, error, stackTrace) {
//                                           return Center(
//                                             child: Image.asset(
//                                               "assets/images/emty.gif",
//                                               fit: BoxFit.cover,
//                                               height: Get.height,
//                                             ),
//                                           );
//                                         },
//                                         image:
//                                             "${Config.imageUrl}${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].image ?? ""}",
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(15),
//                                     ),
//                                   ),
//                                   /*homePageController
//                                               .homeDatatInfo
//                                               ?.homeData
//                                               !.featuredProperty![index1]
//                                               .buyorrent ==
//                                           "1"
//                                       ? */
//                                   Positioned(
//                                     top: 15,
//                                     right: 20,
//                                     child: Container(
//                                       height: 30,
//                                       width: 45,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Container(
//                                             margin: const EdgeInsets.fromLTRB(
//                                                 0, 0, 3, 0),
//                                             child: Image.asset(
//                                               "assets/images/Rating.png",
//                                               height: 12,
//                                               width: 12,
//                                             ),
//                                           ),
//                                           Text(
//                                             homePageController
//                                                     .homeDatatInfo
//                                                     ?.homeData!
//                                                     .featuredProperty![index1]
//                                                     .rate ??
//                                                 "",
//                                             style: TextStyle(
//                                               fontFamily:
//                                                   FontFamily.gilroyMedium,
//                                               color: blueColor,
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Color(0xFFedeeef),
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     ),
//                                   )
//                                   /*: Positioned(
//                                           top: 15,
//                                           right: 20,
//                                           child: Container(
//                                             height: 20,
//                                             width: 45,
//                                             alignment: Alignment.center,
//                                             child: Text(
//                                               "BUY".tr,
//                                               style: TextStyle(
//                                                   color: blueColor,
//                                                   fontWeight: FontWeight.w600),
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: Color(0xFFedeeef),
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                           ),
//                                         ),*/
//                                 ],
//                               ),
//                               SizedBox(
//                                 width: 8,
//                               ),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             homePageController
//                                                     .homeDatatInfo
//                                                     ?.homeData!
//                                                     .featuredProperty![index1]
//                                                     .name ??
//                                                 "",
//                                             maxLines: 2,
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               fontFamily: FontFamily.gilroyBold,
//                                               color:
//                                                   notifire.getwhiteblackcolor,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 5,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Expanded(
//                                           child: Row(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             children: [
//                                               SvgPicture.asset(
//                                                 "assets/images/location.svg",
//                                                 height: 14,
//                                                 colorFilter: ColorFilter.mode(
//                                                     notifire.getwhiteblackcolor,
//                                                     BlendMode.srcIn),
//                                               ),
//                                               SizedBox(
//                                                 width: 2,
//                                               ),
//                                               Flexible(
//                                                 child: Text(
//                                                   homePageController
//                                                           .homeDatatInfo
//                                                           ?.homeData!
//                                                           .featuredProperty![
//                                                               index1]
//                                                           .zipcode ??
//                                                       "",
//                                                   maxLines: 1,
//                                                   style: TextStyle(
//                                                     fontSize: 16,
//                                                     color:
//                                                         notifire.getgreycolor,
//                                                     fontFamily:
//                                                         FontFamily.gilroyMedium,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         SizedBox(
//                                           width: 10,
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(
//                                       height: 7,
//                                     ),
//                                     Row(
//                                       children: [
//                                         Text(
//                                           "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index1].propertyTypeTitle ?? ""}",
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                             fontFamily: FontFamily.gilroyBold,
//                                             color: blueColor,
//                                           ),
//                                         ),
//                                         /*homePageController
//                                                     .homeDatatInfo
//                                                     ?.homeData!
//                                                     .featuredProperty![index1]
//                                                     .buyorrent ==
//                                                 "1"
//                                             ? Text(
//                                                 "/night".tr,
//                                                 style: TextStyle(
//                                                   color: notifire.getgreycolor,
//                                                   fontFamily:
//                                                       FontFamily.gilroyMedium,
//                                                 ),
//                                               )
//                                             : Text(""),*/
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                       );
//                     },
//                   )
//                 : Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//                     child: Column(
//                       children: [
//                         SizedBox(height: Get.height * 0.10),
//                         Image(
//                           image: AssetImage(
//                             "assets/images/searchDataEmpty.png",
//                           ),
//                           height: 110,
//                           width: 110,
//                         ),
//                         Center(
//                           child: SizedBox(
//                             width: Get.width * 0.80,
//                             child: Text(
//                               "Sorry, there is no any nearby \n category or data not found"
//                                   .tr,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: notifire.getgreycolor,
//                                 fontFamily: FontFamily.gilroyBold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
