// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, must_be_immutable, unnecessary_brace_in_string_interps

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers (screen padding / max body width)
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final SignUpController signUpController = Get.find();
  final HomePageController homePageController = Get.find();

  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  @override
  void initState() {
    super.initState();
    homePageController.getFavouriteList(countryId: getData.read("countryId"));
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final padding = R.screenPadding(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: notifire.getcardcolor,
        appBar: AppBar(
          backgroundColor: notifire.getbgcolor,
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Favorites".tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 18,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
            child: Padding(
              padding: padding,
              child: GetBuilder<HomePageController>(builder: (_) {
                if (!homePageController.isfevorite) {
                  return Center(child: CircularProgressIndicator());
                }

                final items =
                    homePageController.favouriteInfo?.propetylist ?? [];
                if (items.isEmpty) return _emptyState();

                return _ResponsiveFavoritesList(
                  length: items.length,
                  itemBuilder: (i) => _FavoriteItem(
                    title: items[i].name ?? "",
                    city: items[i].city ?? "",
                    rate: items[i].rate?.toString() ?? "",
                    typeTitle: items[i].propertyTypeTitle ?? "",
                    imageUrl: "${Config.imageUrl}${items[i].image ?? ""}",
                    onTap: () async {
                      setState(() =>
                      homePageController.rate = items[i].rate ?? "");
                      await homePageController.getPropertyDetailsApi(
                        id: items[i].id ?? "",
                        ptype: items[i].propertyType,
                      );
                      Get.toNamed(Routes.viewDataScreen);
                    },
                    onFavTap: () {
                      homePageController.chnageObjectIndex(i);
                      bottomSheet();
                    },
                    notifire: notifire,
                  ),
                );
              }),
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
            height: 120,
            width: 120,
          ),
          SizedBox(height: 24),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560),
            child: Text(
              "Sorry, Favorite List Empty".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: notifire.getwhiteblackcolor,
                fontWeight: FontWeight.bold,
                fontFamily: FontFamily.gilroyBold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future bottomSheet() {
    return Get.bottomSheet(
      GetBuilder<HomePageController>(builder: (_) {
        final idx = homePageController.currentIndex;
        final item = homePageController.favouriteInfo?.propetylist?[idx];
        if (item == null) return SizedBox.shrink();

        return Container(
          height: 350,
          decoration: BoxDecoration(
            color: notifire.getblackwhitecolor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "Remove from Favorites?".tr,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: FontFamily.gilroyBold,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: notifire.getgreycolor),
              ),
              Container(
                height: 140,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notifire.getblackwhitecolor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          width: 130,
                          margin: EdgeInsets.all(10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              "${Config.imageUrl}${item.image ?? ""}",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          right: 20,
                          child: _ratingPill(item.rate?.toString() ?? ""),
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: FontFamily.gilroyBold,
                              color: notifire.getwhiteblackcolor,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            item.city ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: notifire.getgreycolor,
                              fontFamily: FontFamily.gilroyMedium,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            item.propertyTypeTitle ?? "",
                            style: TextStyle(
                              fontSize: 17,
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
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFeef4ff),
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Text(
                          "Cancle".tr,
                          style: TextStyle(
                            color: blueColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        homePageController.addFavouriteList(
                          pid: item.id ?? "",
                          propertyType: item.propertyType ?? "",
                        );
                        Get.back();
                      },
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: blueColor,
                          borderRadius: BorderRadius.circular(45),
                        ),
                        child: Text(
                          "Yes, Remove".tr,
                          style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
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

// ===================== Responsive list/grid =====================
class _ResponsiveFavoritesList extends StatelessWidget {
  final int length;
  final Widget Function(int index) itemBuilder;
  const _ResponsiveFavoritesList({
    required this.length,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isList = w < 700; // phones

    if (isList) {
      return Scrollbar(
        thumbVisibility: kIsWeb,
        child: ListView.builder(
          itemCount: length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: itemBuilder(i),
          ),
        ),
      );
    }

    // Desktop/tablet grid.
    // IMPORTANT: Give tiles a fixed height via mainAxisExtent to prevent vertical overflow.
    final cross = w >= 1500 ? 4 : w >= 1200 ? 3 : 2;
    final tileHeight = 200.0; // enough room for image + text

    return Scrollbar(
      thumbVisibility: kIsWeb,
      child: GridView.builder(
        itemCount: length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: tileHeight,
        ),
        itemBuilder: (context, i) => _CardWrapper(child: itemBuilder(i)),
      ),
    );
  }
}

class _CardWrapper extends StatelessWidget {
  final Widget child;
  const _CardWrapper({required this.child});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(padding: const EdgeInsets.all(6.0), child: child),
    );
  }
}

// ===================== Item (auto layout) =====================
class _FavoriteItem extends StatelessWidget {
  final String title;
  final String city;
  final String rate;
  final String typeTitle;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onFavTap;
  final ColorNotifire notifire;

  const _FavoriteItem({
    required this.title,
    required this.city,
    required this.rate,
    required this.typeTitle,
    required this.imageUrl,
    required this.onTap,
    required this.onFavTap,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final useHorizontal = w < 700;

    if (useHorizontal) {
      return _horizontalTile(context);
    }

    return _gridCard(context);
  }

  // Phone (list) layout — fixed 150 height works nicely.
  Widget _horizontalTile(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: notifire.getblackwhitecolor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: notifire.getborderColor),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: 140,
                  margin: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/images/ezgif.com-crop.gif",
                      image: imageUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (c, e, s) =>
                          Container(color: Colors.grey.shade200),
                    ),
                  ),
                ),
                Positioned(top: 12, right: 18, child: _ratingPill(rate)),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: onFavTap,
                        child: Image.asset(
                          "assets/images/Fev-Bold.png",
                          height: 20,
                          width: 20,
                          color: blueColor,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: notifire.getgreycolor,
                      fontFamily: FontFamily.gilroyMedium,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    typeTitle,
                    style: TextStyle(
                      fontSize: 16,
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
    );
  }

  // Desktop/tablet (grid) layout — no hard-coded image width; image expands to tile height.
  Widget _gridCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              color: notifire.getblackwhitecolor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getborderColor),
            ),
            child: Row(
              children: [
                // Image section fills available height
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FadeInImage.assetNetwork(
                            placeholder: "assets/images/ezgif.com-crop.gif",
                            image: imageUrl,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (c, e, s) =>
                                Container(color: Colors.grey.shade200),
                          ),
                          Positioned(top: 12, right: 12, child: _ratingPill(rate)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Text section
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onFavTap,
                              child: Image.asset(
                                "assets/images/Fev-Bold.png",
                                height: 20,
                                width: 20,
                                color: blueColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: notifire.getgreycolor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          typeTitle,
                          style: TextStyle(
                            fontSize: 16,
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
        },
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



// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, must_be_immutable, unnecessary_brace_in_string_interps
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/signup_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class FavoriteScreen extends StatefulWidget {
//   @override
//   State<FavoriteScreen> createState() => _FavoriteScreenState();
// }
//
// class _FavoriteScreenState extends State<FavoriteScreen> {
//   SignUpController signUpController = Get.find();
//
//   HomePageController homePageController = Get.find();
//
//   List<String> list = ["All", "House", "Villa", "Apartment"];
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
//   void initState() {
//     super.initState();
//     setState(() {
//       homePageController.getFavouriteList(countryId: getData.read("countryId"));
//     });
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
//         backgroundColor: notifire.getcardcolor,
//         appBar: AppBar(
//           backgroundColor: notifire.getbgcolor,
//           centerTitle: true,
//           elevation: 0,
//           title: Text(
//             "Favorites".tr,
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//               fontSize: 18,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             GetBuilder<HomePageController>(builder: (context) {
//               return homePageController.isfevorite
//                   ? homePageController.favouriteInfo!.propetylist!.isNotEmpty
//                       ? Expanded(
//                           flex: 1,
//                           child: ListView.builder(
//                             itemCount: homePageController
//                                 .favouriteInfo?.propetylist!.length,
//                             physics: BouncingScrollPhysics(),
//                             itemBuilder: (context, index) {
//                               return InkWell(
//                                 onTap: () async {
//                                   setState(() {
//                                     homePageController.rate = homePageController
//                                             .favouriteInfo
//                                             ?.propetylist![index]
//                                             .rate ??
//                                         "";
//                                   });
//                                   await homePageController
//                                       .getPropertyDetailsApi(
//                                           id: homePageController.favouriteInfo
//                                                   ?.propetylist![index].id ??
//                                               "",
//                                           ptype: homePageController
//                                               .favouriteInfo
//                                               ?.propetylist![index]
//                                               .propertyType);
//                                   Get.toNamed(
//                                     Routes.viewDataScreen,
//                                   );
//                                 },
//                                 child: Container(
//                                   height: 140,
//                                   margin: EdgeInsets.all(10),
//                                   child: Row(
//                                     children: [
//                                       Stack(
//                                         children: [
//                                           Container(
//                                             height: 140,
//                                             width: 130,
//                                             margin: EdgeInsets.all(10),
//                                             child: ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               child: FadeInImage.assetNetwork(
//                                                 fadeInCurve: Curves.easeInCirc,
//                                                 placeholder:
//                                                     "assets/images/ezgif.com-crop.gif",
//                                                 height: 140,
//                                                 imageErrorBuilder: (context,
//                                                     error, stackTrace) {
//                                                   return Center(
//                                                     child: Image.asset(
//                                                       "assets/images/emty.gif",
//                                                       fit: BoxFit.cover,
//                                                       height: Get.height,
//                                                     ),
//                                                   );
//                                                 },
//                                                 image:
//                                                     "${Config.imageUrl}${homePageController.favouriteInfo?.propetylist![index].image ?? ""}",
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                           ),
//                                           /*homePageController
//                                                       .favouriteInfo
//                                                       ?.propetylist![index]
//                                                       .buyorrent ==
//                                                   "1"
//                                               ? */
//                                           Positioned(
//                                             top: 15,
//                                             right: 20,
//                                             child: Container(
//                                               height: 30,
//                                               width: 45,
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Container(
//                                                     margin: const EdgeInsets
//                                                         .fromLTRB(0, 0, 3, 0),
//                                                     child: Image.asset(
//                                                       "assets/images/Rating.png",
//                                                       height: 12,
//                                                       width: 12,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     homePageController
//                                                             .homeDatatInfo
//                                                             ?.homeData!
//                                                             .featuredProperty![
//                                                                 index]
//                                                             .rate ??
//                                                         "",
//                                                     style: TextStyle(
//                                                       fontFamily: FontFamily
//                                                           .gilroyMedium,
//                                                       color: blueColor,
//                                                     ),
//                                                   )
//                                                 ],
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFedeeef),
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                               ),
//                                             ),
//                                           )
//                                           /*: Positioned(
//                                                   top: 15,
//                                                   right: 20,
//                                                   child: Container(
//                                                     height: 30,
//                                                     width: 60,
//                                                     alignment: Alignment.center,
//                                                     child: Text(
//                                                       "BUY".tr,
//                                                       style: TextStyle(
//                                                           color: blueColor,
//                                                           fontWeight:
//                                                               FontWeight.w600),
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xFFedeeef),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15),
//                                                     ),
//                                                   ),
//                                                 ),*/
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         width: 8,
//                                       ),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     homePageController
//                                                             .favouriteInfo
//                                                             ?.propetylist![
//                                                                 index]
//                                                             .name ??
//                                                         "",
//                                                     maxLines: 2,
//                                                     style: TextStyle(
//                                                       fontSize: 17,
//                                                       fontFamily:
//                                                           FontFamily.gilroyBold,
//                                                       color: notifire
//                                                           .getwhiteblackcolor,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 10,
//                                                 ),
//                                                 InkWell(
//                                                   onTap: () {
//                                                     homePageController
//                                                         .chnageObjectIndex(
//                                                             index);
//                                                     bottomSheet();
//                                                   },
//                                                   child: Image.asset(
//                                                     "assets/images/Fev-Bold.png",
//                                                     height: 20,
//                                                     width: 20,
//                                                     color: blueColor,
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 20,
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 8),
//                                             Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                     homePageController
//                                                             .favouriteInfo
//                                                             ?.propetylist![
//                                                                 index]
//                                                             .city ??
//                                                         "",
//                                                     maxLines: 1,
//                                                     style: TextStyle(
//                                                       color:
//                                                           notifire.getgreycolor,
//                                                       fontFamily: FontFamily
//                                                           .gilroyMedium,
//                                                       overflow:
//                                                           TextOverflow.ellipsis,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 10,
//                                                 ),
//                                               ],
//                                             ),
//                                             SizedBox(height: 10),
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   "${homePageController.favouriteInfo?.propetylist![index].propertyTypeTitle ?? ""}",
//                                                   style: TextStyle(
//                                                     fontSize: 17,
//                                                     fontFamily:
//                                                         FontFamily.gilroyBold,
//                                                     color: blueColor,
//                                                   ),
//                                                 ),
//                                                 /*homePageController
//                                                             .favouriteInfo
//                                                             ?.propetylist![
//                                                                 index]
//                                                             .buyorrent ==
//                                                         "1"
//                                                     ? Text(
//                                                         "/night".tr,
//                                                         style: TextStyle(
//                                                           color: notifire
//                                                               .getgreycolor,
//                                                           fontFamily: FontFamily
//                                                               .gilroyMedium,
//                                                         ),
//                                                       )
//                                                     : SizedBox(),*/
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: notifire.getblackwhitecolor,
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         )
//                       : Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 5),
//                             child: Column(
//                               children: [
//                                 SizedBox(height: Get.height * 0.10),
//                                 Image(
//                                   image: AssetImage(
//                                       "assets/images/searchDataEmpty.png"),
//                                   height: 120,
//                                   width: 120,
//                                 ),
//                                 SizedBox(height: Get.height * 0.04),
//                                 Center(
//                                   child: SizedBox(
//                                     width: Get.width * 0.80,
//                                     child: Text(
//                                       "Sorry, Favorite List Empty".tr,
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: notifire.getwhiteblackcolor,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                   : Expanded(
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future bottomSheet() {
//     return Get.bottomSheet(
//       GetBuilder<HomePageController>(builder: (context) {
//         return Container(
//           height: 350,
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 20,
//               ),
//               Text(
//                 "Remove from Favorites?".tr,
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
//               Container(
//                 height: 140,
//                 margin: EdgeInsets.all(10),
//                 child: Row(
//                   children: [
//                     Stack(
//                       children: [
//                         Container(
//                           height: 140,
//                           width: 130,
//                           margin: EdgeInsets.all(10),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(15),
//                             child: Image.network(
//                               "${Config.imageUrl}${homePageController.favouriteInfo?.propetylist![homePageController.currentIndex].image ?? ""}",
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         Positioned(
//                           top: 15,
//                           right: 20,
//                           child: Container(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 5, horizontal: 7),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     margin:
//                                         const EdgeInsets.fromLTRB(0, 0, 3, 0),
//                                     child: Icon(
//                                       Icons.star,
//                                       size: 18,
//                                       color: yelloColor,
//                                     ),
//                                   ),
//                                   Text(
//                                     homePageController
//                                             .favouriteInfo
//                                             ?.propetylist![
//                                                 homePageController.currentIndex]
//                                             .rate ??
//                                         "",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       color: blueColor,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFedeeef),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   homePageController
//                                           .favouriteInfo
//                                           ?.propetylist![
//                                               homePageController.currentIndex]
//                                           .name ??
//                                       "",
//                                   maxLines: 2,
//                                   style: TextStyle(
//                                     fontSize: 17,
//                                     fontFamily: FontFamily.gilroyBold,
//                                     color: notifire.getwhiteblackcolor,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 5,
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   homePageController
//                                           .favouriteInfo
//                                           ?.propetylist![
//                                               homePageController.currentIndex]
//                                           .city ??
//                                       "",
//                                   maxLines: 1,
//                                   style: TextStyle(
//                                     color: notifire.getgreycolor,
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 7),
//                           Row(
//                             children: [
//                               Text(
//                                 "${homePageController.favouriteInfo?.propetylist![homePageController.currentIndex].propertyTypeTitle ?? ""}",
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontFamily: FontFamily.gilroyBold,
//                                   color: blueColor,
//                                 ),
//                               ),
//                               /*homePageController
//                                           .favouriteInfo
//                                           ?.propetylist![
//                                               homePageController.currentIndex]
//                                           .buyorrent ==
//                                       "1"
//                                   ? Text(
//                                       "/night".tr,
//                                       style: TextStyle(
//                                         color: notifire.getgreycolor,
//                                         fontFamily: FontFamily.gilroyMedium,
//                                       ),
//                                     )
//                                   : SizedBox(),*/
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 decoration: BoxDecoration(
//                   color: notifire.getblackwhitecolor,
//                   borderRadius: BorderRadius.circular(15),
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
//                         height: 60,
//                         margin: EdgeInsets.all(15),
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Cancle".tr,
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
//                         homePageController.addFavouriteList(
//                           pid: homePageController
//                                   .favouriteInfo
//                                   ?.propetylist![
//                                       homePageController.currentIndex]
//                                   .id ??
//                               "",
//                           propertyType: homePageController
//                                   .favouriteInfo
//                                   ?.propetylist![
//                                       homePageController.currentIndex]
//                                   .propertyType ??
//                               "",
//                         );
//                         Get.back();
//                       },
//                       child: Container(
//                         height: 60,
//                         margin: EdgeInsets.all(15),
//                         alignment: Alignment.center,
//                         child: Text(
//                           "Yes, Remove".tr,
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
