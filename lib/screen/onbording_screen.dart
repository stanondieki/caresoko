// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/appbaner_model.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/search_controller.dart';

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  final HomePageController homePageController = Get.find();
  final SearchPropertyController searchController = Get.find();
  final SelectCountryController selectCountryController = Get.find();

  late ColorNotifire notifire;

  int pageIndex = 0;
  int countrySelected = 0;
  final PageController _page = PageController();

  @override
  void initState() {
    super.initState();
    _prefAndPermInit();
    selectCountryController.getCountryApi().then((_) {
      for (int a = 0;
      a <
          (selectCountryController
              .countryInfo?.countryData?.length ??
              0);
      a++) {
        if (selectCountryController
            .countryInfo?.countryData![a].dCon ==
            "1") {
          setState(() => countrySelected = a);
        }
      }
    });
  }

  Future<void> _prefAndPermInit() async {
    await Permission.storage.request();

    // theme
    final prefs = await SharedPreferences.getInstance();
    final prev = prefs.getBool("setIsDark");
    // notifire is initialized in build via Provider
    // this will be picked up when build runs
    // ignore: invalid_use_of_protected_member
    notifire.setIsDark = prev ?? false;
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    // breakpoints
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 768 && width < 1024;

    // on mobile we want full width, on bigger screens we constrain
    final double bodyMaxWidth =
    isDesktop ? 1200.0 : (isTablet ? 860.0 : width);

    // clamp text scale to avoid overflow
    final clamped = media.copyWith(
      textScaler: TextScaler.linear(media.textScaleFactor.clamp(1.0, 1.2)),
    );

    return MediaQuery(
      data: clamped,
      child: Scaffold(
        backgroundColor: notifire.getbgcolor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bodyMaxWidth),
              child: Padding(
                // NO horizontal padding on mobile so content touches the edges
                padding: EdgeInsets.symmetric(
                  horizontal: (isDesktop || isTablet) ? 24 : 0,
                  vertical: (isDesktop || isTablet) ? 24 : 12,
                ),
                child: LayoutBuilder(
                  builder: (context, c) {
                    if (isDesktop) {
                      // ================== DESKTOP / LARGE ==================
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT: hero carousel
                          Expanded(
                            flex: 7,
                            child: _HeroCarousel(
                              page: _page,
                              pageIndex: pageIndex,
                              onChanged: (i) =>
                                  setState(() => pageIndex = i),
                              notifire: notifire,
                            ),
                          ),
                          SizedBox(width: 28),
                          // RIGHT: actions panel
                          Expanded(
                            flex: 5,
                            child: _ActionPanel(
                              notifire: notifire,
                              onLogin: () {
                                Get.to(() => LoginScreen());
                                save('isLoginBack', false);
                              },
                              onGuest: _continueAsGuest,
                            ),
                          ),
                        ],
                      );
                    }

                    // ================== TABLET / MOBILE ==================
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _HeroCarousel(
                            page: _page,
                            pageIndex: pageIndex,
                            onChanged: (i) =>
                                setState(() => pageIndex = i),
                            notifire: notifire,
                          ),
                          SizedBox(height: 16),
                          _ActionPanel(
                            notifire: notifire,
                            onLogin: () {
                              Get.to(() => LoginScreen());
                              save('isLoginBack', false);
                            },
                            onGuest: _continueAsGuest,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    // Set Firstuser flag so splash screen skips onboarding next time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('Firstuser', true);

    // persist country selection
    save(
      "countryId",
      selectCountryController
          .countryInfo?.countryData?[countrySelected].id ??
          "4",  // Default to United States if not set
    );
    save(
      "countryName",
      selectCountryController
          .countryInfo?.countryData?[countrySelected].title ??
          "United States",
    );

    selectCountryController.changeCountryIndex(countrySelected);

    await homePageController
        .getHomeDataApi(countryId: getData.read("countryId"));
    await searchController
        .getSearchData(countryId: getData.read("countryId"));
    await homePageController.getCatWiseData(
        countryId: getData.read("countryId"), cId: "0");

    save('isLoginBack', true);
    Get.offAllNamed(Routes.bottoBarScreen);
  }
}

// ================== PARTS ==================

class _HeroCarousel extends StatelessWidget {
  final PageController page;
  final int pageIndex;
  final ValueChanged<int> onChanged;
  final ColorNotifire notifire;

  const _HeroCarousel({
    required this.page,
    required this.pageIndex,
    required this.onChanged,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // wider on desktop, taller on mobile
    final ar = w >= 1024
        ? 16 / 8
        : (w >= 768)
        ? 16 / 9
        : 16 / 12;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: ar,
            child: PageView.builder(
              controller: page,
              itemCount: appbaner.length,
              onPageChanged: onChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) => Ink(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(appbaner[i].image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _Dots(
          length: appbaner.length,
          index: pageIndex,
          activeColor: const Color(0xFF2F5AF4),
          inactiveColor: Colors.grey.shade400,
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final ColorNotifire notifire;
  final VoidCallback onLogin;
  final VoidCallback onGuest;

  const _ActionPanel({
    required this.notifire,
    required this.onLogin,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w >= 1024;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero, // so edges line up with screen on mobile
      color: notifire.getblackwhitecolor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: notifire.getborderColor),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
          vertical: 22,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // headline
            Text(
              "Finding Care For Mom & Dad\nHas Never Been Easier".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontFamily: FontFamily.gilroyBold,
                height: 1.25,
                color: notifire.getwhiteblackcolor,
              ),
            ),
            const SizedBox(height: 20),

            // login
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onLogin,
                icon: Icon(Icons.call, size: 18),
                label: Text(
                  "Login With Phone Number".tr,
                  style: TextStyle(fontFamily: FontFamily.gilroyBold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5AF4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              "OR".tr,
              style: TextStyle(
                color: notifire.getgreycolor,
                fontFamily: FontFamily.gilroyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // guest
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onGuest,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: notifire.getborderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: notifire.getboxcolor,
                ),
                child: Text(
                  "Continue as a Guest".tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifire.getwhiteblackcolor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              children: [
                Text(
                  "Don't have an account?".tr,
                  style: TextStyle(
                    color: notifire.getgreycolor,
                    fontFamily: FontFamily.gilroyMedium,
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(Routes.signUpScreen),
                  child: Text(
                    "Sign Up".tr,
                    style: TextStyle(
                      color: const Color(0xFF2F5AF4),
                      fontFamily: FontFamily.gilroyBold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int length;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  const _Dots({
    required this.length,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(length, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 8,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}




// // ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/model/appbaner_model.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/login_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../controller/search_controller.dart';
//
// class OnBordingScreen extends StatefulWidget {
//   const OnBordingScreen({super.key});
//
//   @override
//   State<OnBordingScreen> createState() => _OnBordingScreenState();
// }
//
// class _OnBordingScreenState extends State<OnBordingScreen> {
//   final HomePageController homePageController = Get.find();
//   final SearchPropertyController searchController = Get.find();
//   final SelectCountryController selectCountryController = Get.find();
//
//   late ColorNotifire notifire;
//
//   int pageIndex = 0;
//   int countrySelected = 0;
//   final PageController _page = PageController();
//
//   @override
//   void initState() {
//     super.initState();
//     _prefAndPermInit();
//     selectCountryController.getCountryApi().then((_) {
//       for (int a = 0; a < (selectCountryController.countryInfo?.countryData?.length ?? 0); a++) {
//         if (selectCountryController.countryInfo?.countryData![a].dCon == "1") {
//           setState(() => countrySelected = a);
//         }
//       }
//     });
//   }
//
//   Future<void> _prefAndPermInit() async {
//     await Permission.storage.request();
//
//     // theme
//     final prefs = await SharedPreferences.getInstance();
//     final prev = prefs.getBool("setIsDark");
//     notifire.setIsDark = prev ?? false;
//   }
//
//   @override
//   void dispose() {
//     _page.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//
//     // desktop-first breakpoints
//     final width = MediaQuery.of(context).size.width;
//     final isDesktop = width >= 1024;
//     final isTablet = width >= 768 && width < 1024;
//     final bodyMaxWidth = isDesktop ? 1200.0 : (isTablet ? 860.0 : 560.0);
//
//     // clamp extreme text scales to prevent overflow
//     final mq = MediaQuery.of(context);
//     final clamped = mq.copyWith(textScaleFactor: mq.textScaleFactor.clamp(1.0, 1.2));
//
//     return MediaQuery(
//       data: clamped,
//       child: Scaffold(
//         backgroundColor: notifire.getbgcolor,
//         body: SafeArea(
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: bodyMaxWidth),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isDesktop ? 24 : 16,
//                   vertical: isDesktop ? 24 : 12,
//                 ),
//                 child: LayoutBuilder(
//                   builder: (context, c) {
//                     if (isDesktop) {
//                       // ================== DESKTOP / LARGE ==================
//                       return Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // LEFT: hero carousel
//                           Expanded(
//                             flex: 7,
//                             child: _HeroCarousel(
//                               page: _page,
//                               pageIndex: pageIndex,
//                               onChanged: (i) => setState(() => pageIndex = i),
//                               notifire: notifire,
//                             ),
//                           ),
//                           SizedBox(width: 28),
//                           // RIGHT: actions panel
//                           Expanded(
//                             flex: 5,
//                             child: _ActionPanel(
//                               notifire: notifire,
//                               onLogin: () {
//                                 Get.to(() => LoginScreen());
//                                 save('isLoginBack', false);
//                               },
//                               onGuest: _continueAsGuest,
//                             ),
//                           ),
//                         ],
//                       );
//                     }
//
//                     // ================== TABLET / MOBILE ==================
//                     return SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           _HeroCarousel(
//                             page: _page,
//                             pageIndex: pageIndex,
//                             onChanged: (i) => setState(() => pageIndex = i),
//                             notifire: notifire,
//                           ),
//                           SizedBox(height: 16),
//                           _ActionPanel(
//                             notifire: notifire,
//                             onLogin: () {
//                               Get.to(() => LoginScreen());
//                               save('isLoginBack', false);
//                             },
//                             onGuest: _continueAsGuest,
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _continueAsGuest() async {
//     // persist country selection
//     save(
//       "countryId",
//       selectCountryController.countryInfo?.countryData?[countrySelected].id ?? "",
//     );
//     save(
//       "countryName",
//       selectCountryController.countryInfo?.countryData?[countrySelected].title ?? "",
//     );
//
//     selectCountryController.changeCountryIndex(countrySelected);
//
//     await homePageController.getHomeDataApi(countryId: getData.read("countryId"));
//     await searchController.getSearchData(countryId: getData.read("countryId"));
//     await homePageController.getCatWiseData(countryId: getData.read("countryId"), cId: "0");
//
//     save('isLoginBack', true);
//     Get.offAllNamed(Routes.bottoBarScreen);
//   }
// }
//
// // ================== PARTS ==================
//
// class _HeroCarousel extends StatelessWidget {
//   final PageController page;
//   final int pageIndex;
//   final ValueChanged<int> onChanged;
//   final ColorNotifire notifire;
//
//   const _HeroCarousel({
//     required this.page,
//     required this.pageIndex,
//     required this.onChanged,
//     required this.notifire,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // nice wide aspect on desktop, taller on small screens
//     final w = MediaQuery.of(context).size.width;
//     final ar = w >= 1024 ? 16 / 8 : (w >= 768 ? 16 / 9 : 16 / 12);
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(18),
//           child: AspectRatio(
//             aspectRatio: ar,
//             child: PageView.builder(
//               controller: page,
//               itemCount: appbaner.length,
//               onPageChanged: onChanged,
//               physics: const BouncingScrollPhysics(),
//               itemBuilder: (_, i) => Ink(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(appbaner[i].image),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _Dots(
//           length: appbaner.length,
//           index: pageIndex,
//           activeColor: const Color(0xFF2F5AF4),
//           inactiveColor: Colors.grey.shade400,
//         ),
//       ],
//     );
//   }
// }
//
// class _ActionPanel extends StatelessWidget {
//   final ColorNotifire notifire;
//   final VoidCallback onLogin;
//   final VoidCallback onGuest;
//
//   const _ActionPanel({
//     required this.notifire,
//     required this.onLogin,
//     required this.onGuest,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final isDesktop = w >= 1024;
//
//     return Card(
//       elevation: 0,
//       color: notifire.getblackwhitecolor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//         side: BorderSide(color: notifire.getborderColor),
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16, vertical: 22),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // headline
//             Text(
//               "Finding Care For Mom & Dad\nHas Never Been Easier".tr,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: isDesktop ? 24 : 20,
//                 fontFamily: FontFamily.gilroyBold,
//                 height: 1.25,
//                 color: notifire.getwhiteblackcolor,
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // login
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton.icon(
//                 onPressed: onLogin,
//                 icon: Icon(Icons.call, size: 18),
//                 label: Text(
//                   "Login With Phone Number".tr,
//                   style: TextStyle(fontFamily: FontFamily.gilroyBold),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2F5AF4),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//             Text("OR".tr,
//                 style: TextStyle(
//                   color: notifire.getgreycolor,
//                   fontFamily: FontFamily.gilroyMedium,
//                 )),
//             const SizedBox(height: 16),
//
//             // guest
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: OutlinedButton(
//                 onPressed: onGuest,
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: notifire.getborderColor),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   backgroundColor: notifire.getboxcolor,
//                 ),
//                 child: Text(
//                   "Continue as a Guest".tr,
//                   style: TextStyle(
//                     fontFamily: FontFamily.gilroyBold,
//                     color: notifire.getwhiteblackcolor,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 14),
//             Wrap(
//               alignment: WrapAlignment.center,
//               crossAxisAlignment: WrapCrossAlignment.center,
//               spacing: 6,
//               children: [
//                 Text(
//                   "Don't have an account?".tr,
//                   style: TextStyle(
//                     color: notifire.getgreycolor,
//                     fontFamily: FontFamily.gilroyMedium,
//                   ),
//                 ),
//                 InkWell(
//                   onTap: () => Get.toNamed(Routes.signUpScreen),
//                   child: Text(
//                     "Sign Up".tr,
//                     style: TextStyle(
//                       color: const Color(0xFF2F5AF4),
//                       fontFamily: FontFamily.gilroyBold,
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _Dots extends StatelessWidget {
//   final int length;
//   final int index;
//   final Color activeColor;
//   final Color inactiveColor;
//
//   const _Dots({
//     required this.length,
//     required this.index,
//     required this.activeColor,
//     required this.inactiveColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       children: List.generate(length, (i) {
//         final isActive = i == index;
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           height: 8,
//           width: isActive ? 18 : 8,
//           decoration: BoxDecoration(
//             color: isActive ? activeColor : inactiveColor,
//             borderRadius: BorderRadius.circular(8),
//           ),
//         );
//       }),
//     );
//   }
// }
