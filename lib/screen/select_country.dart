// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, prefer_adjacent_string_concatenation, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/search_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectCountryScreen extends StatefulWidget {
  const SelectCountryScreen({super.key});

  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {
  final SelectCountryController selectCountryController = Get.find();
  final HomePageController homePageController = Get.find();
  final SearchPropertyController searchController = Get.find();

  late ColorNotifire notifire;

  // --- Simple responsive helpers (local to this screen) ---
  bool _isDesktop(double w) => w >= 1200;
  bool _isTablet(double w) => w >= 900 && w < 1200;
  int _gridCount(double w) {
    if (w >= 1500) return 5;
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    return 2; // phones
  }

  EdgeInsets _screenPadding(double w) {
    if (_isDesktop(w)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    if (_isTablet(w)) return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    return const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
  }

  double _maxBodyWidth(double w) {
    if (_isDesktop(w)) return 1100;
    if (_isTablet(w)) return 980;
    return double.infinity;
  }

  int countrySelected = 0;

  Future<void> _restoreTheme() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = (prefs.getBool("setIsDark")) ?? false;
  }

  @override
  void initState() {
    super.initState();
    _restoreTheme();
    countrySelected = (getData.read("currentIndex") ?? 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: !_isDesktop(w),
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Select Country".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: GetBuilder<SelectCountryController>(builder: (_) {
        if (!selectCountryController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final items = selectCountryController.countryInfo?.countryData ?? [];
        if (items.isEmpty) {
          return Center(
            child: Text(
              "No countries found".tr,
              style: TextStyle(color: notifire.getgreycolor, fontFamily: FontFamily.gilroyBold),
            ),
          );
        }

        // Ensure selected index stays in range
        countrySelected = countrySelected.clamp(0, items.length - 1);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxBodyWidth(w)),
            child: Padding(
              padding: _screenPadding(w),
              child: Stack(
                children: [
                  // MAIN GRID
                  Scrollbar(
                    thumbVisibility: kIsWeb,
                    child: GridView.builder(
                      padding: EdgeInsets.only(bottom: 84), // leave room for the button
                      itemCount: items.length,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _gridCount(w),
                        mainAxisExtent: 240,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final c = items[index];
                        final isSelected = countrySelected == index;
                        return InkWell(
                          onTap: () => setState(() => countrySelected = index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: notifire.getblackwhitecolor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? blueColor : notifire.getborderColor, width: 1.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: "${Config.imageUrl}${c.img ?? ""}",
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        alignment: Alignment.center,
                                        child: Icon(Icons.public, color: Colors.grey.shade500),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "${c.title ?? ""}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: FontFamily.gilroyBold,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // BOTTOM ACTION
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Align(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 560),
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestButton(
                            Width: double.infinity,
                            height: 50,
                            buttoncolor: blueColor,
                            margin: EdgeInsets.symmetric(horizontal: _isDesktop(w) ? 0 : 8),
                            buttontext: "Continue".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: WhiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            onclick: () {
                              final idx = countrySelected.clamp(0, items.length - 1);
                              final sel = items[idx];

                              save("countryId", sel.id ?? "");
                              save("countryName", sel.title ?? "");
                              save("currentIndex", idx);

                              selectCountryController.changeCountryIndex(idx);

                              homePageController.getHomeDataApi(countryId: getData.read("countryId"));
                              homePageController.getCatWiseData(countryId: getData.read("countryId"), cId: "0");
                              searchController.getSearchData(countryId: getData.read("countryId"));

                              Get.offAndToNamed(Routes.bottoBarScreen);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}


// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, prefer_adjacent_string_concatenation, avoid_print
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/search_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SelectCountryScreen extends StatefulWidget {
//   const SelectCountryScreen({super.key});
//
//   @override
//   State<SelectCountryScreen> createState() => _SelectCountryScreenState();
// }
//
// class _SelectCountryScreenState extends State<SelectCountryScreen> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     countrySelected = getData.read("currentIndex");
//   }
//
//   SelectCountryController selectCountryController = Get.find();
//   HomePageController homePageController = Get.find();
//   SearchPropertyController searchController = Get.find();
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
//   int countrySelected = 0;
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
//           "Select Country".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: GetBuilder<SelectCountryController>(builder: (context) {
//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             selectCountryController.isLoading
//                 ? SingleChildScrollView(
//                     child: SizedBox(
//                       height: Get.size.height,
//                       width: Get.size.width,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: GridView.builder(
//                           itemCount: selectCountryController
//                               .countryInfo?.countryData!.length,
//                           shrinkWrap: true,
//                           physics: BouncingScrollPhysics(),
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             mainAxisExtent: 220,
//                             mainAxisSpacing: 8,
//                             crossAxisSpacing: 8,
//                           ),
//                           itemBuilder: (context, index) {
//                             return InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   countrySelected = index;
//
//                                   // save(
//                                   //     "countryId",
//                                   //     selectCountryController
//                                   //             .countryInfo?.countryData![index].id ??
//                                   //         "");
//                                   // print("££££££££££££${getData.read("countryId")}");
//                                   // save(
//                                   //     "countryName",
//                                   //     selectCountryController.countryInfo
//                                   //             ?.countryData![index].title ??
//                                   //         "");
//                                 });
//                               },
//                               child: Container(
//                                 height: 220,
//                                 margin: EdgeInsets.all(5),
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: 150,
//                                       width: 150,
//                                       margin: EdgeInsets.all(8),
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(15),
//                                         child: CachedNetworkImage(
//                                           imageUrl:
//                                               "${Config.imageUrl}${selectCountryController.countryInfo?.countryData![index].img ?? ""}",
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 8,
//                                     ),
//                                     Text(
//                                       "${selectCountryController.countryInfo?.countryData![index].title ?? ""}",
//                                       style: TextStyle(
//                                         fontSize: 17,
//                                         fontFamily: FontFamily.gilroyBold,
//                                         color: notifire.getwhiteblackcolor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15),
//                                   color: notifire.getblackwhitecolor,
//                                   border: countrySelected == index
//                                       ? Border.all(color: blueColor)
//                                       : Border.all(
//                                           color: notifire.getborderColor),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   )
//                 : Center(
//                     child: CircularProgressIndicator(),
//                   ),
//             Positioned(
//               bottom: 10,
//               child: Container(
//                 height: 50,
//                 width: Get.size.width,
//                 color: Colors.transparent,
//                 alignment: Alignment.center,
//                 child: GestButton(
//                   Width: Get.size.width,
//                   height: 50,
//                   buttoncolor: blueColor,
//                   margin: EdgeInsets.only(top: 5, left: 35, right: 35),
//                   buttontext: "Continue".tr,
//                   style: TextStyle(
//                     fontFamily: FontFamily.gilroyBold,
//                     color: WhiteColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   onclick: () {
//                     print(
//                         "££££££££££££>>>>>>>>>>>>>>>>${getData.read("countryId")}");
//                     save(
//                         "countryId",
//                         selectCountryController.countryInfo
//                                 ?.countryData![countrySelected].id ??
//                             "");
//                     save(
//                         "countryName",
//                         selectCountryController.countryInfo
//                                 ?.countryData![countrySelected].title ??
//                             "");
//                     selectCountryController.changeCountryIndex(countrySelected);
//                     homePageController.getHomeDataApi(
//                         countryId: getData.read("countryId"));
//                     homePageController.getCatWiseData(
//                         countryId: getData.read("countryId"), cId: "0");
//                     searchController.getSearchData(
//                         countryId: getData.read("countryId"));
//                     Get.offAndToNamed(Routes.bottoBarScreen);
//                   },
//                 ),
//               ),
//             )
//           ],
//         );
//       }),
//     );
//   }
// }
