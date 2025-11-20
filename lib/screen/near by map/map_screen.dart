// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_unnecessary_containers, sized_box_for_whitespace, unused_field, prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, prefer_collection_literals, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, unused_local_variable

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/homepage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/screen/home_screen.dart'; // uses R helpers (grid, padding, max width)
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final HomePageController homePageController = Get.find();
  late GoogleMapController mapController;
  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  final Set<Marker> markers = <Marker>{};

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetHeight: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
    _initMarkers();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    // Responsive sizes
    final w = MediaQuery.of(context).size.width;
    final panelHeight = w >= 1400
        ? 240.0
        : w >= 1100
        ? 200.0
        : w >= 700
        ? 170.0
        : 150.0; // mobile
    final cardImageWidth = w >= 1100 ? 220.0 : w >= 700 ? 180.0 : 130.0;

    return Scaffold(
      backgroundColor: notifire.getblackwhitecolor,
      body: GetBuilder<HomePageController>(builder: (_) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: homePageController.kGoogle,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                  markers: markers,
                  mapType: MapType.normal,
                  myLocationEnabled: false,
                  compassEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (controller) => setState(() => mapController = controller),
                ),
              ),

              // Top search bar (centered + max width on web)
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: _SearchBar(notifire: notifire),
                  ),
                ),
              ),

              // Bottom cards panel (responsive)
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: R.maxBodyWidth(context)),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: SizedBox(
                      height: panelHeight,
                      child: _BottomCards(
                        imageWidth: cardImageWidth,
                        panelHeight: panelHeight,
                        onCardChanged: (index) {
                          final item = homePageController.homeDatatInfo?.homeData?.featuredProperty?[index];
                          if (item == null) return;
                          final lat = double.tryParse(item.latitude ?? "0") ?? 0;
                          final lng = double.tryParse(item.longtitude ?? "0") ?? 0;
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 12)),
                          );
                        },
                        onCardTap: (index) async {
                          final f = homePageController.homeDatatInfo?.homeData?.featuredProperty?[index];
                          if (f == null) return;
                          setState(() => homePageController.rate = f.rate ?? "");
                          homePageController.chnageObjectIndex(index);
                          await homePageController.getPropertyDetailsApi(id: f.id, ptype: f.propertyType);
                          Get.toNamed(Routes.viewDataScreen);
                        },
                        notifire: notifire,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _initMarkers() async {
    final iconBytes = await _getBytesFromAsset("assets/images/MapPin.png", 100);
    final items = homePageController.homeDatatInfo?.homeData?.featuredProperty ?? [];
    for (var i = 0; i < items.length; i++) {
      final lat = double.tryParse(items[i].latitude?.toString() ?? "0") ?? 0;
      final lng = double.tryParse(items[i].longtitude?.toString() ?? "0") ?? 0;
      markers.add(
        Marker(
          markerId: MarkerId("f-$i"),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.fromBytes(iconBytes),
          infoWindow: InfoWindow(
            title: items[i].name,
            snippet: items[i].city,
            onTap: () async {
              setState(() => homePageController.rate = items[i].rate ?? "");
              homePageController.chnageObjectIndex(i);
              await homePageController.getPropertyDetailsApi(id: items[i].id, ptype: items[i].propertyType);
              Get.toNamed(Routes.viewDataScreen);
            },
          ),
          onTap: () => homePageController.updateMapPosition(index: i),
        ),
      );
    }
    if (mounted) setState(() {});
  }
}

// ===================== Widgets =====================
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.notifire});
  final ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(children: [
        Expanded(
          child: InkWell(
            onTap: () => Get.toNamed(Routes.homeSearchScreen),
            child: Container(
              height: 46,
              decoration: BoxDecoration(color: notifire.getblackwhitecolor, borderRadius: BorderRadius.circular(40)),
              child: Row(children: [
                SizedBox(width: 14),
                Image.asset("assets/images/Search.png", height: 24, width: 24),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "Search by name or zipcode".tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: Colors.grey.shade500),
                  ),
                ),
                SizedBox(width: 14),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _BottomCards extends StatelessWidget {
  const _BottomCards({
    required this.imageWidth,
    required this.panelHeight,
    required this.onCardChanged,
    required this.onCardTap,
    required this.notifire,
  });

  final double imageWidth;
  final double panelHeight;
  final ValueChanged<int> onCardChanged;
  final ValueChanged<int> onCardTap;
  final ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomePageController>();
    final items = controller.homeDatatInfo?.homeData?.featuredProperty ?? [];

    if (items.isEmpty) return SizedBox.shrink();

    final useGrid = MediaQuery.of(context).size.width >= 1100; // desktop/tablet wide → show multiple cards

    if (!useGrid) {
      // Mobile / narrow: PageView (keeps camera sync behavior)
      return PageView.builder(
        controller: controller.pageController,
        itemCount: items.length,
        onPageChanged: onCardChanged,
        itemBuilder: (context, index) => _MapCard(
          item: _CardData(
            name: items[index].name ?? "",
            city: items[index].city ?? "",
            typeTitle: items[index].propertyTypeTitle ?? "",
            rate: items[index].rate?.toString() ?? "",
            imageUrl: "${Config.imageUrl}${items[index].image}",
          ),
          imageWidth: imageWidth,
          notifire: notifire,
          onTap: () => onCardTap(index),
        ),
      );
    }

    // Wide screens: show a horizontal list with multiple visible cards
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(width: 8),
      itemBuilder: (context, index) => SizedBox(
        width: 520,
        child: _MapCard(
          item: _CardData(
            name: items[index].name ?? "",
            city: items[index].city ?? "",
            typeTitle: items[index].propertyTypeTitle ?? "",
            rate: items[index].rate?.toString() ?? "",
            imageUrl: "${Config.imageUrl}${items[index].image}",
          ),
          imageWidth: imageWidth,
          notifire: notifire,
          onTap: () => onCardTap(index),
        ),
      ),
    );
  }
}

class _CardData {
  final String name;
  final String city;
  final String typeTitle;
  final String rate;
  final String imageUrl;
  _CardData({required this.name, required this.city, required this.typeTitle, required this.rate, required this.imageUrl});
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.item, required this.imageWidth, required this.notifire, required this.onTap});
  final _CardData item;
  final double imageWidth;
  final ColorNotifire notifire;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(color: notifire.getblackwhitecolor, borderRadius: BorderRadius.circular(15), border: Border.all(color: notifire.getborderColor)),
        child: Row(children: [
          // image
          Stack(children: [
            Container(
              height: double.infinity,
              width: imageWidth,
              margin: EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/images/ezgif.com-crop.gif",
                  image: item.imageUrl,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 18,
              child: _ratingPill(item.rate),
            ),
          ]),
          SizedBox(width: 8),
          // texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, fontFamily: FontFamily.gilroyBold, color: notifire.getwhiteblackcolor),
                ),
                SizedBox(height: 6),
                Text(
                  item.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: notifire.getgreycolor, fontFamily: FontFamily.gilroyMedium),
                ),
                SizedBox(height: 6),
                Text(item.typeTitle, style: TextStyle(fontSize: 16, fontFamily: FontFamily.gilroyBold, color: blueColor)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _ratingPill(String text) {
    return Container(
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Color(0xFFedeeef), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Image.asset("assets/images/Rating.png", height: 14, width: 14),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontFamily: FontFamily.gilroyMedium, color: blueColor)),
      ]),
    );
  }
}



// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_unnecessary_containers, sized_box_for_whitespace, unused_field, prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, prefer_collection_literals, unnecessary_brace_in_string_interps, unnecessary_string_interpolations, unused_local_variable
//
// import 'dart:ui' as ui;
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
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
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   HomePageController homePageController = Get.find();
//   late GoogleMapController mapController;
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
//   CameraPosition kGoogle = CameraPosition(
//     target: LatLng(47.751076, -120.740135),
//     zoom: 5,
//   );
//
//   final Set<Marker> markers = Set();
//
//   Future<Uint8List> getImages(String path, int width) async {
//     ByteData data = await rootBundle.load(path);
//     ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//         targetHeight: width);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//         .buffer
//         .asUint8List();
//   }
//
//   @override
//   void initState() {
//     getdarkmodepreviousstate();
//     super.initState();
//     getmarkers();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getblackwhitecolor,
//       body: GetBuilder<HomePageController>(builder: (context) {
//         return SafeArea(
//           child: Stack(
//             children: [
//               Container(
//                 height: Get.size.height,
//                 child: GoogleMap(
//                   initialCameraPosition: homePageController.kGoogle,
//                   gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
//                     Factory<OneSequenceGestureRecognizer>(
//                       () => EagerGestureRecognizer(),
//                     ),
//                   ].toSet(),
//                   markers: Set<Marker>.of(markers),
//                   mapType: MapType.normal,
//                   myLocationEnabled: false,
//                   compassEnabled: true,
//                   zoomGesturesEnabled: true,
//                   tiltGesturesEnabled: true,
//                   zoomControlsEnabled: true,
//                   onMapCreated: (controller) {
//                     setState(() {
//                       mapController = controller;
//                     });
//                   },
//                 ),
//               ),
//               Positioned(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 5, left: 5),
//                   child: SizedBox(
//                     height: 50,
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: InkWell(
//                             onTap: () {
//                               Get.toNamed(Routes.homeSearchScreen);
//                             },
//                             child: Container(
//                               height: 45,
//                               margin: EdgeInsets.only(right: 10),
//                               child: Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 15,
//                                   ),
//                                   Image.asset(
//                                     "assets/images/Search.png",
//                                     height: 25,
//                                     width: 25,
//                                   ),
//                                   SizedBox(
//                                     width: 8,
//                                   ),
//                                   Text(
//                                     "Search by name or zipcode".tr,
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       color: Colors.grey.shade500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               decoration: BoxDecoration(
//                                 color: notifire.getblackwhitecolor,
//                                 borderRadius: BorderRadius.circular(40),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 10,
//                 right: 0,
//                 left: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 5),
//                   child: SizedBox(
//                     height: 140,
//                     width: Get.size.width,
//                     child: PageView.builder(
//                       controller: homePageController.pageController,
//                       itemCount: homePageController
//                           .homeDatatInfo?.homeData!.featuredProperty!.length,
//                       onPageChanged: (int index) {
//                         mapController
//                             .animateCamera(
//                           CameraUpdate.newCameraPosition(
//                             CameraPosition(
//                               target: LatLng(
//                                 double.parse(homePageController
//                                         .homeDatatInfo
//                                         ?.homeData!
//                                         .featuredProperty![index]
//                                         .latitude ??
//                                     "0"),
//                                 double.parse(homePageController
//                                         .homeDatatInfo
//                                         ?.homeData!
//                                         .featuredProperty![index]
//                                         .longtitude ??
//                                     ""),
//                               ),
//                               zoom: 12,
//                             ),
//                           ),
//                         )
//                             .then((val) {
//                           setState(() {});
//                         });
//                       },
//                       itemBuilder: (context, index) {
//                         return InkWell(
//                           onTap: () async {
//                             setState(() {
//                               homePageController.rate = homePageController
//                                       .homeDatatInfo
//                                       ?.homeData!
//                                       .featuredProperty![index]
//                                       .rate ??
//                                   "";
//                             });
//                             homePageController.chnageObjectIndex(index);
//                             await homePageController.getPropertyDetailsApi(
//                                 id: homePageController.homeDatatInfo?.homeData!
//                                     .featuredProperty![index].id,
//                                 ptype: homePageController
//                                     .homeDatatInfo!
//                                     .homeData!
//                                     .featuredProperty![index]
//                                     .propertyType);
//                             Get.toNamed(
//                               Routes.viewDataScreen,
//                             );
//                           },
//                           child: Container(
//                             height: 140,
//                             margin: EdgeInsets.all(10),
//                             child: Row(
//                               children: [
//                                 Stack(
//                                   children: [
//                                     Container(
//                                       height: 140,
//                                       width: 130,
//                                       margin: EdgeInsets.all(10),
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(15),
//                                         child: FadeInImage.assetNetwork(
//                                           fadeInCurve: Curves.easeInCirc,
//                                           placeholder:
//                                               "assets/images/ezgif.com-crop.gif",
//                                           height: 140,
//                                           image:
//                                               "${Config.imageUrl}${homePageController.homeDatatInfo?.homeData!.featuredProperty![index].image}",
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     ),
//                                     /*homePageController
//                                                 .homeDatatInfo
//                                                 ?.homeData
//                                                 !.featuredProperty![index]
//                                                 .buyorrent ==
//                                             "1"
//                                         ? */
//                                     Positioned(
//                                       top: 15,
//                                       right: 20,
//                                       child: Container(
//                                         height: 30,
//                                         width: 45,
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Container(
//                                               margin: const EdgeInsets.fromLTRB(
//                                                   0, 0, 3, 0),
//                                               child: Image.asset(
//                                                 "assets/images/Rating.png",
//                                                 height: 12,
//                                                 width: 12,
//                                               ),
//                                             ),
//                                             Text(
//                                               homePageController
//                                                       .homeDatatInfo
//                                                       ?.homeData!
//                                                       .featuredProperty![index]
//                                                       .rate
//                                                       .toString() ??
//                                                   "",
//                                               style: TextStyle(
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 color: blueColor,
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Color(0xFFedeeef),
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                         ),
//                                       ),
//                                     )
//                                     /*: Positioned(
//                                             top: 15,
//                                             right: 20,
//                                             child: Container(
//                                               height: 30,
//                                               width: 60,
//                                               alignment: Alignment.center,
//                                               child: Text(
//                                                 "BUY".tr,
//                                                 style: TextStyle(
//                                                   color: blueColor,
//                                                 ),
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFedeeef),
//                                                 borderRadius:
//                                                     BorderRadius.circular(15),
//                                               ),
//                                             ),
//                                           ),*/
//                                   ],
//                                 ),
//                                 SizedBox(
//                                   width: 8,
//                                 ),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               homePageController
//                                                       .homeDatatInfo
//                                                       ?.homeData!
//                                                       .featuredProperty![index]
//                                                       .name ??
//                                                   "",
//                                               maxLines: 2,
//                                               style: TextStyle(
//                                                 fontSize: 17,
//                                                 fontFamily:
//                                                     FontFamily.gilroyBold,
//                                                 color:
//                                                     notifire.getwhiteblackcolor,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         height: 5,
//                                       ),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               homePageController
//                                                       .homeDatatInfo
//                                                       ?.homeData!
//                                                       .featuredProperty![index]
//                                                       .city ??
//                                                   "",
//                                               maxLines: 1,
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 color: notifire.getgreycolor,
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 10,
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         height: 6,
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             "${homePageController.homeDatatInfo?.homeData!.featuredProperty![index].propertyTypeTitle}",
//                                             style: TextStyle(
//                                               fontSize: 17,
//                                               fontFamily: FontFamily.gilroyBold,
//                                               color: blueColor,
//                                             ),
//                                           ),
//                                           /*homePageController
//                                               .homeDatatInfo
//                                               ?.homeData
//                                           !.featuredProperty![
//                                           index]
//                                               .buyorrent ==
//                                               "1"
//                                               ? Text(
//                                             "/night".tr,
//                                             style: TextStyle(
//                                               color: notifire
//                                                   .getgreycolor,
//                                               fontFamily: FontFamily
//                                                   .gilroyMedium,
//                                             ),
//                                           )
//                                               : SizedBox(),*/
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             decoration: BoxDecoration(
//                               color: notifire.getblackwhitecolor,
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   getmarkers() async {
//     final Uint8List markIcon = await getImages("assets/images/MapPin.png", 100);
//     for (var i = 0;
//         i <
//             homePageController
//                 .homeDatatInfo!.homeData!.featuredProperty!.length;
//         i++) {
//       markers.add(Marker(
//         //add first marker
//         markerId: MarkerId(i.toString()),
//         position: LatLng(
//           double.parse(homePageController
//                   .homeDatatInfo?.homeData!.featuredProperty![i].latitude
//                   .toString() ??
//               "0"),
//           double.parse(homePageController
//                   .homeDatatInfo?.homeData!.featuredProperty![i].longtitude
//                   .toString() ??
//               "0"),
//         ),
//         icon: BitmapDescriptor.fromBytes(markIcon), //position of marker
//         infoWindow: InfoWindow(
//           title: homePageController
//               .homeDatatInfo?.homeData!.featuredProperty![i].name,
//           snippet: homePageController
//               .homeDatatInfo?.homeData!.featuredProperty![i].city,
//           onTap: () async {
//             setState(() {
//               homePageController.rate = homePageController
//                       .homeDatatInfo?.homeData!.featuredProperty![i].rate ??
//                   "";
//             });
//             homePageController.chnageObjectIndex(i);
//             await homePageController.getPropertyDetailsApi(
//                 id: homePageController
//                     .homeDatatInfo?.homeData!.featuredProperty![i].id,
//                 ptype: homePageController.homeDatatInfo!.homeData!
//                     .featuredProperty![i].propertyType);
//             Get.toNamed(
//               Routes.viewDataScreen,
//             );
//           },
//         ),
//         onTap: () {
//           print(i.toString());
//           homePageController.updateMapPosition(index: i);
//         },
//       ));
//     }
//   }
// }
