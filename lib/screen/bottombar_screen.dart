// ignore_for_file: prefer_const_constructors, unused_field, prefer_final_fields, prefer_typing_uninitialized_variables, sort_child_properties_last
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/controller/wallet_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/screen/add%20property/addintro_screen.dart';
import 'package:gotocarefinder/screen/add%20property/membarship_screen.dart';
import 'package:gotocarefinder/screen/favorite_screen.dart';
import 'package:gotocarefinder/screen/home_screen.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/screen/near%20by%20map/map_screen.dart';
import 'package:gotocarefinder/screen/profile_screen.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottoBarScreen extends StatefulWidget {
  const BottoBarScreen({super.key});

  @override
  State<BottoBarScreen> createState() => _BottoBarScreenState();
}

late TabController tabController;

class _BottoBarScreenState extends State<BottoBarScreen>
    with TickerProviderStateMixin {
  final WalletController walletController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final ListOfPropertiController listOfPropertiController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final HomePageController homePageController = Get.find();

  int _currentIndex = 0;
  var isLogin;

  final List<Widget> myChilders = [
    const HomeScreen(),
    const MapScreen(),
    FavoriteScreen(),
    const ProfileScreen(),
  ];

  late ColorNotifire notifire;

  // --------- Responsive helpers ----------
  bool _isWide(BuildContext context) => MediaQuery.of(context).size.width >= 1000;
  double _railWidth(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1400 ? 92 : 72;

  @override
  void initState() {
    super.initState();
    isLogin = getData.read("UserLogin");
    tabController = TabController(length: 4, vsync: this);

    // keep _currentIndex in sync with TabController (works for both nav UIs)
    tabController.addListener(() {
      if (!mounted) return;
      setState(() => _currentIndex = tabController.index);
    });
  }

  Future<void> _handleTabTap(int index) async {
    // If not logged in: allow Home (0) but redirect for others
    if (isLogin == null && index != 0) {
      Get.to(() => LoginScreen());
      return;
    }

    // Special handling for Nearby (index 1) location permissions
    if (index == 1) {
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        // If still denied on web, ignore gracefully (browser handles prompt)
      } catch (_) {
        // Silently ignore any web/permission exceptions
      }
    }

    if (mounted) {
      tabController.animateTo(index);
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final wide = _isWide(context);

    // ----- Desktop/Web (wide) uses NavigationRail; Mobile/Tablet uses Bottom TabBar -----
    if (wide) {
      return Scaffold(
        backgroundColor: notifire.getbgcolor,
        body: Row(
          children: [
            // Side Navigation
            Container(
              width: _railWidth(context),
              color: notifire.getbgcolor,
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (i) => _handleTabTap(i),
                extended: false,
                backgroundColor: notifire.getbgcolor,
                selectedIconTheme: IconThemeData(color: const Color(0xff3D5BF6)),
                unselectedIconTheme:
                IconThemeData(color: notifire.getwhiteblackcolor),
                selectedLabelTextStyle: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  color: const Color(0xff3D5BF6),
                ),
                unselectedLabelTextStyle: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  color: notifire.getwhiteblackcolor.withOpacity(0.7),
                ),
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  NavigationRailDestination(
                    icon: Image.asset(
                      "assets/images/${_currentIndex == 0 ? "HomeBold.png" : "Home.png"}",
                      scale: 20,
                      color: _currentIndex == 0
                          ? const Color(0xff3D5BF6)
                          : notifire.getwhiteblackcolor,
                    ),
                    label: Text("Home".tr),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      "assets/images/${_currentIndex == 1 ? "mapbold.png" : "map.png"}",
                      scale: 3.7,
                      color: _currentIndex == 1
                          ? const Color(0xff3D5BF6)
                          : notifire.getwhiteblackcolor,
                    ),
                    label: Text("Nearby".tr),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      "assets/images/${_currentIndex == 2 ? "heartBold.png" : "heartline.png"}",
                      scale: 20,
                      color: _currentIndex == 2
                          ? const Color(0xff3D5BF6)
                          : notifire.getwhiteblackcolor,
                    ),
                    label: Text("Favorite".tr),
                  ),
                  NavigationRailDestination(
                    icon: Image.asset(
                      "assets/images/${_currentIndex == 3 ? "userBold.png" : "userline.png"}",
                      scale: 20,
                      color: _currentIndex == 3
                          ? const Color(0xff3D5BF6)
                          : notifire.getwhiteblackcolor,
                    ),
                    label: Text("Account".tr),
                  ),
                ],
              ),
            ),

            VerticalDivider(width: 1, color: notifire.getbgcolor),

            // Content
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: tabController,
                    children: myChilders,
                  ),
                  if (homePageController.addProp == "Yes")
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xff3D5BF6),
                        onPressed: _onAddPressed,
                        elevation: 4.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/addIcon.png",
                            color: Colors.white,
                            height: 30,
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

    // ----- Mobile / Tablet -----
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: myChilders,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: homePageController.addProp == "Yes"
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xff3D5BF6),
          onPressed: _onAddPressed,
          elevation: 4.0,
          child: Container(
            margin: const EdgeInsets.all(10.0),
            child: Image.asset(
              "assets/images/addIcon.png",
              color: Colors.white,
              height: 35,
            ),
          ),
        ),
      )
          : const SizedBox(),
      bottomNavigationBar: BottomAppBar(
        color: notifire.getbgcolor,
        child: TabBar(
          onTap: (index) => _handleTabTap(index),
          indicator: UnderlineTabIndicator(
            insets: const EdgeInsets.only(bottom: 52),
            borderSide: BorderSide(color: notifire.getbgcolor, width: 2),
          ),
          labelColor: Colors.blueAccent,
          indicatorSize: TabBarIndicatorSize.label,
          unselectedLabelColor: Colors.grey,
          controller: tabController,
          padding: const EdgeInsets.symmetric(vertical: 6),
          tabs: [
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/${_currentIndex == 0 ? "HomeBold.png" : "Home.png"}",
                    scale: 21,
                    color: _currentIndex == 0
                        ? const Color(0xff3D5BF6)
                        : notifire.getwhiteblackcolor,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Home".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.gilroyMedium,
                      color: _currentIndex == 0
                          ? const Color(0xff3D5BF6)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              width: 80,
              margin: EdgeInsets.only(
                  left: homePageController.addProp == "Yes" ? 0 : 9),
              alignment: getData.read("lCode") == "ar_IN"
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: Tab(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/${_currentIndex == 1 ? "mapbold.png" : "map.png"}",
                      scale: 3.7,
                      color: _currentIndex == 1
                          ? const Color(0xff3D5BF6)
                          : notifire.getwhiteblackcolor,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Nearby".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontFamily.gilroyMedium,
                        color: _currentIndex == 1
                            ? const Color(0xff3D5BF6)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              width: 80,
              margin: EdgeInsets.only(
                  right: homePageController.addProp == "Yes" ? 0 : 9),
              alignment: getData.read("lCode") == "ar_IN"
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: Tab(
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    Image.asset(
                      "assets/images/${_currentIndex == 2 ? "heartBold.png" : "heartline.png"}",
                      scale: 21,
                      color: _currentIndex == 2
                          ? const Color(0xff3D5BF6)
                          : notifire.getwhiteblackcolor,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Favorite".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontFamily.gilroyMedium,
                        color: _currentIndex == 2
                            ? const Color(0xff3D5BF6)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/${_currentIndex == 3 ? "userBold.png" : "userline.png"}",
                    scale: 21,
                    color: _currentIndex == 3
                        ? const Color(0xff3D5BF6)
                        : notifire.getwhiteblackcolor,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Account".tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.gilroyMedium,
                      color: _currentIndex == 3
                          ? const Color(0xff3D5BF6)
                          : Colors.grey,
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

  void _onAddPressed() {

    print('helli');
    dashBoardController.getDashBoardData().then((value) {
      if (isLogin != null) {
        if (dashBoardController.dashBoardInfo?.isSubscribe == 1) {
          dashBoardController.getDashBoardData();
          listOfPropertiController.getPropertiList();
          selectCountryController.getCountryApi();
          Get.to(() => const MembershipScreen());
        } else {
          selectCountryController.getCountryApi();
          Get.to(() => BoardingPage());
        }
      } else {
        Get.to(() => LoginScreen());
      }
    });
  }
}



// // ignore_for_file: prefer_const_constructors, unused_field, prefer_final_fields, prefer_typing_uninitialized_variables, sort_child_properties_last
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/homepage_controller.dart';
// import 'package:gotocarefinder/controller/listofproperti_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/controller/wallet_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/screen/add%20property/addintro_screen.dart';
// import 'package:gotocarefinder/screen/add%20property/membarship_screen.dart';
// import 'package:gotocarefinder/screen/favorite_screen.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/screen/login_screen.dart';
// import 'package:gotocarefinder/screen/near%20by%20map/map_screen.dart';
// import 'package:gotocarefinder/screen/profile_screen.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BottoBarScreen extends StatefulWidget {
//   const BottoBarScreen({super.key});
//
//   @override
//   State<BottoBarScreen> createState() => _BottoBarScreenState();
// }
//
// late TabController tabController;
//
// class _BottoBarScreenState extends State<BottoBarScreen>
//     with TickerProviderStateMixin {
//   WalletController walletController = Get.find();
//   DashBoardController dashBoardController = Get.find();
//   ListOfPropertiController listOfPropertiController = Get.find();
//   SelectCountryController selectCountryController = Get.find();
//   HomePageController homePageController = Get.find();
//
//   int _currentIndex = 0;
//
//   var isLogin;
//
//   List<Widget> myChilders = [
//     HomeScreen(),
//     MapScreen(),
//     FavoriteScreen(),
//     ProfileScreen(),
//   ];
//
//   late ColorNotifire notifire;
//
//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//
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
//
//     isLogin = getData.read("UserLogin");
//     tabController = TabController(length: 4, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: TabBarView(
//         physics: const NeverScrollableScrollPhysics(),
//         controller: tabController,
//         children: myChilders,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: homePageController.addProp == "Yes"
//           ? Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: FloatingActionButton(
//                 backgroundColor: Color(0xff3D5BF6),
//                 onPressed: () {
//                   dashBoardController.getDashBoardData().then(
//                     (value) {
//                       if (isLogin != null) {
//                         if (dashBoardController.dashBoardInfo?.isSubscribe ==
//                             1) {
//                           dashBoardController.getDashBoardData();
//                           listOfPropertiController.getPropertiList();
//                           selectCountryController.getCountryApi();
//                           Get.to(MembershipScreen());
//                         } else {
//                           selectCountryController.getCountryApi();
//                           Get.to(BoardingPage());
//                         }
//                       } else {
//                         Get.to(() => LoginScreen());
//                       }
//                     },
//                   );
//                 },
//                 child: Container(
//                   margin: EdgeInsets.all(10.0),
//                   child: Image.asset(
//                     "assets/images/addIcon.png",
//                     color: Colors.white,
//                     height: 35,
//                   ),
//                 ),
//                 elevation: 4.0,
//               ),
//             )
//           : SizedBox(),
//       bottomNavigationBar: BottomAppBar(
//         color: notifire.getbgcolor,
//         child: TabBar(
//           onTap: (index) async {
//             setState(() {});
//
//             if (isLogin != null) {
//               _currentIndex = index;
//               if (index == 1) {
//                 LocationPermission permission;
//                 permission = await Geolocator.checkPermission();
//                 permission = await Geolocator.requestPermission();
//                 if (permission == LocationPermission.denied) {
//                   lat = 0.0;
//                   long = 0.0;
//                 }
//               }
//             } else {
//               index != 0 ? Get.to(() => LoginScreen()) : const SizedBox();
//             }
//           },
//           indicator: UnderlineTabIndicator(
//             insets: EdgeInsets.only(bottom: 52),
//             borderSide: BorderSide(color: notifire.getbgcolor, width: 2),
//           ),
//           labelColor: Colors.blueAccent,
//           indicatorSize: TabBarIndicatorSize.label,
//           unselectedLabelColor: Colors.grey,
//           controller: tabController,
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           tabs: [
//             Tab(
//               child: Column(
//                 children: [
//                   Image.asset(
//                     "assets/images/${_currentIndex == 0 ? "HomeBold.png" : "Home.png"}",
//                     scale: 21,
//                     color: _currentIndex == 0
//                         ? Color(0xff3D5BF6)
//                         : notifire.getwhiteblackcolor,
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     "Home".tr,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: FontFamily.gilroyMedium,
//                       color:
//                           _currentIndex == 0 ? Color(0xff3D5BF6) : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 50,
//               width: 80,
//               margin: EdgeInsets.only(
//                   left: homePageController.addProp == "Yes" ? 0 : 9),
//               alignment: getData.read("lCode") == "ar_IN"
//                   ? Alignment.topRight
//                   : Alignment.topLeft,
//               child: Tab(
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       "assets/images/${_currentIndex == 1 ? "mapbold.png" : "map.png"}",
//                       scale: 3.7,
//                       color: _currentIndex == 1
//                           ? Color(0xff3D5BF6)
//                           : notifire.getwhiteblackcolor,
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       "Nearby".tr,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: FontFamily.gilroyMedium,
//                         color: _currentIndex == 1
//                             ? Color(0xff3D5BF6)
//                             : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               width: 80,
//               margin: EdgeInsets.only(
//                   right: homePageController.addProp == "Yes" ? 0 : 9),
//               alignment: getData.read("lCode") == "ar_IN"
//                   ? Alignment.topLeft
//                   : Alignment.topRight,
//               child: Tab(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 2,
//                     ),
//                     Image.asset(
//                       "assets/images/${_currentIndex == 2 ? "heartBold.png" : "heartline.png"}",
//                       scale: 21,
//                       color: _currentIndex == 2
//                           ? Color(0xff3D5BF6)
//                           : notifire.getwhiteblackcolor,
//                     ),
//                     SizedBox(height: 3),
//                     Text(
//                       "Favorite".tr,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: FontFamily.gilroyMedium,
//                         color: _currentIndex == 2
//                             ? Color(0xff3D5BF6)
//                             : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Tab(
//               child: Column(
//                 children: [
//                   Image.asset(
//                     "assets/images/${_currentIndex == 3 ? "userBold.png" : "userline.png"}",
//                     scale: 21,
//                     color: _currentIndex == 3
//                         ? Color(0xff3D5BF6)
//                         : notifire.getwhiteblackcolor,
//                   ),
//                   SizedBox(height: 3),
//                   Text(
//                     "Account".tr,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: FontFamily.gilroyMedium,
//                       color:
//                           _currentIndex == 3 ? Color(0xff3D5BF6) : Colors.grey,
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
// }
