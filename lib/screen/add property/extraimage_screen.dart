// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/extraimage_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExtraImageScreen extends StatefulWidget {
  const ExtraImageScreen({super.key});

  @override
  State<ExtraImageScreen> createState() => _ExtraImageScreenState();
}

class _ExtraImageScreenState extends State<ExtraImageScreen> {
  ExtraImageController extraImageController = Get.find();
  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previousState;
    }
  }

  @override
  void initState() {
    super.initState();
    // fire and forget is fine here, provider will rebuild theming
    getdarkmodepreviousstate();
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifire.getblackwhitecolor,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Extra Images///".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                Get.toNamed(
                  Routes.addExtraImageScreen,
                  arguments: {"add": "Add"},
                );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: Color(0xff3D5BF6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: WhiteColor),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Breakpoints
            final double maxWidth = constraints.maxWidth;
            final bool isMobile = maxWidth < 600;
            final bool isTablet = maxWidth >= 600 && maxWidth < 1024;
            final bool isDesktop = maxWidth >= 1024;

            // Container paddings responsive
            final double horizontalPad = isMobile ? 10 : (isTablet ? 16 : 24);
            final double verticalPad = isMobile ? 8 : 12;

            // Center content on wide screens
            final double contentMaxWidth = isDesktop ? 1200 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPad,
                    vertical: verticalPad,
                  ),
                  child: GetBuilder<ExtraImageController>(
                    builder: (controller) {
                      // NOTE: original code used isLoading as "data loaded"
                      // Keeping the same semantics to avoid logic change.
                      if (!controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final items = controller.extraListInfo?.extralist ?? [];
                      if (items.isEmpty) {
                        return _EmptyState(notifire: notifire);
                      }

                      // Decide layout: List (mobile) vs Grid (tablet/desktop)
                      if (isMobile) {
                        return ListView.builder(
                          padding: EdgeInsets.only(top: isMobile ? 8 : 10),
                          itemCount: items.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return _ExtraImageTile(
                              notifire: notifire,
                              title: items[index].propertyTitle ?? "",
                              imageUrl:
                              "${Config.imageUrl}${items[index].image ?? ""}",
                              onEdit: () {
                                controller.getEditExtraImage(
                                  img: items[index].image ?? "",
                                  recordId: items[index].id ?? "",
                                  selectPro: items[index].propertyTitle ?? "",
                                  pId: items[index].propertyId ?? "",
                                );
                                Get.toNamed(Routes.addExtraImageScreen,
                                    arguments: {"add": "edit"});
                              },
                              // Sizes tuned for mobile
                              height: 90,
                              thumbWidth: 80,
                              thumbRadius: 15,
                              margin: const EdgeInsets.all(10),
                            );
                          },
                        );
                      } else {
                        // Grid config responsive
                        // Target card width ~ 360px
                        final int crossAxisCount =
                        (maxWidth / 360).floor().clamp(2, 6);
                        final double childAspectRatio = 3.6 / 1.2; // wide card

                        return GridView.builder(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
                          ),
                          itemCount: items.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            // Scale card sizes a bit for larger screens
                            final double cardHeight =
                            isDesktop ? 110 : (isTablet ? 100 : 90);
                            final double thumbW =
                            isDesktop ? 100 : (isTablet ? 90 : 80);

                            return _ExtraImageTile(
                              notifire: notifire,
                              title: items[index].propertyTitle ?? "",
                              imageUrl:
                              "${Config.imageUrl}${items[index].image ?? ""}",
                              onEdit: () {
                                controller.getEditExtraImage(
                                  img: items[index].image ?? "",
                                  recordId: items[index].id ?? "",
                                  selectPro: items[index].propertyTitle ?? "",
                                  pId: items[index].propertyId ?? "",
                                );
                                Get.toNamed(Routes.addExtraImageScreen,
                                    arguments: {"add": "edit"});
                              },
                              height: cardHeight,
                              thumbWidth: thumbW,
                              thumbRadius: 16,
                              margin: const EdgeInsets.all(0),
                              hoverable: kIsWeb || isDesktop,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Empty state preserved, centered and responsive
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.notifire});
  final ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bool isNarrow = size.width < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 14 : 24,
          vertical: isNarrow ? 5 : 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * (isNarrow ? 0.08 : 0.10)),
            const Image(
              image: AssetImage("assets/images/searchDataEmpty.png"),
              height: 120,
              width: 120,
            ),
            SizedBox(height: isNarrow ? 12 : 16),
            SizedBox(
              width: size.width * (isNarrow ? 0.85 : 0.60),
              child: Text(
                "Sorry, there is no any nearby \n category or data not found".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: notifire.getgreycolor,
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: isNarrow ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable tile/card that looks like your original row but adapts to grid/list.
/// Adds subtle hover elevation on web/desktop.
class _ExtraImageTile extends StatefulWidget {
  const _ExtraImageTile({
    super.key,
    required this.notifire,
    required this.title,
    required this.imageUrl,
    required this.onEdit,
    this.height = 90,
    this.thumbWidth = 80,
    this.thumbRadius = 15,
    this.margin = const EdgeInsets.all(10),
    this.hoverable = false,
  });

  final ColorNotifire notifire;
  final String title;
  final String imageUrl;
  final VoidCallback onEdit;

  final double height;
  final double thumbWidth;
  final double thumbRadius;
  final EdgeInsets margin;
  final bool hoverable;

  @override
  State<_ExtraImageTile> createState() => _ExtraImageTileState();
}

class _ExtraImageTileState extends State<_ExtraImageTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final double cardElevation = widget.hoverable && _hover ? 4 : 0;

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.notifire.getblackwhitecolor,
        border: Border.all(color: widget.notifire.getborderColor),
        borderRadius: BorderRadius.circular(15),
        boxShadow: cardElevation > 0
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            height: widget.height,
            width: widget.thumbWidth,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.thumbRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.thumbRadius),
              child: FadeInImage.assetNetwork(
                fadeInCurve: Curves.easeInCirc,
                placeholder: "assets/images/ezgif.com-crop.gif",
                height: widget.height,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/images/ezgif.com-crop.gif",
                    height: widget.height,
                    width: widget.thumbWidth,
                    fit: BoxFit.cover,
                  );
                },
                image: widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Text
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 54.0), // space for edit btn
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: FontFamily.gilroyBold,
                    color: widget.notifire.getwhiteblackcolor,
                  ),
                ),
              ),
            ),
          ),

          // Edit button (floating style similar to your Positioned)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: widget.onEdit,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.all(9),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff3D5BF6),
                ),
                child: Image.asset("assets/images/Pen (1).png"),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.hoverable) {
      card = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: card,
      );
    }

    return card;
  }
}


// // ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/extraimage_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ExtraImageScreen extends StatefulWidget {
//   const ExtraImageScreen({super.key});
//
//   @override
//   State<ExtraImageScreen> createState() => _ExtraImageScreenState();
// }
//
// class _ExtraImageScreenState extends State<ExtraImageScreen> {
//   ExtraImageController extraImageController = Get.find();
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
//       backgroundColor: notifire.getfevAndSearch,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: notifire.getblackwhitecolor,
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
//           "Extra Images///".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(5),
//             child: InkWell(
//               onTap: () {
//                 Get.toNamed(
//                   Routes.addExtraImageScreen,
//                   arguments: {
//                     "add": "Add",
//                   },
//                 );
//               },
//               child: Container(
//                 height: 50,
//                 width: 50,
//                 child: Icon(
//                   Icons.add,
//                   color: WhiteColor,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Color(0xff3D5BF6),
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: GetBuilder<ExtraImageController>(builder: (context) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: extraImageController.isLoading
//                       ? extraImageController
//                               .extraListInfo!.extralist!.isNotEmpty
//                           ? ListView.builder(
//                               padding: EdgeInsets.only(top: 10),
//                               itemCount: extraImageController
//                                   .extraListInfo?.extralist!.length,
//                               physics: BouncingScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return Stack(
//                                   children: [
//                                     Container(
//                                       height: 90,
//                                       width: Get.size.width,
//                                       margin: EdgeInsets.all(10),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             height: 90,
//                                             width: 80,
//                                             margin: EdgeInsets.all(10),
//                                             child: ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                               child: FadeInImage.assetNetwork(
//                                                 fadeInCurve: Curves.easeInCirc,
//                                                 placeholder:
//                                                     "assets/images/ezgif.com-crop.gif",
//                                                 height: 90,
//                                                 imageErrorBuilder: (context,
//                                                     error, stackTrace) {
//                                                   return Image.asset(
//                                                     "assets/images/ezgif.com-crop.gif",
//                                                     height: 48,
//                                                     width: 48,
//                                                     fit: BoxFit.cover,
//                                                   );
//                                                 },
//                                                 image:
//                                                     "${Config.imageUrl}${extraImageController.extraListInfo?.extralist![index].image ?? ""}",
//                                                 fit: BoxFit.cover,
//                                               ),
//                                             ),
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(15),
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             width: 8,
//                                           ),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: Padding(
//                                                         padding:
//                                                             EdgeInsets.only(
//                                                                 top: 30),
//                                                         child: Text(
//                                                           extraImageController
//                                                                   .extraListInfo
//                                                                   ?.extralist![
//                                                                       index]
//                                                                   .propertyTitle ??
//                                                               "",
//                                                           maxLines: 2,
//                                                           style: TextStyle(
//                                                             fontSize: 17,
//                                                             fontFamily:
//                                                                 FontFamily
//                                                                     .gilroyBold,
//                                                             color: notifire
//                                                                 .getwhiteblackcolor,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                       decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: notifire.getborderColor),
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       top: 0,
//                                       right: 0,
//                                       child: InkWell(
//                                         onTap: () {
//                                           extraImageController
//                                               .getEditExtraImage(
//                                                   img: extraImageController
//                                                           .extraListInfo
//                                                           ?.extralist![index]
//                                                           .image ??
//                                                       "",
//                                                   recordId: extraImageController
//                                                           .extraListInfo
//                                                           ?.extralist![index]
//                                                           .id ??
//                                                       "",
//                                                   selectPro:
//                                                       extraImageController
//                                                               .extraListInfo
//                                                               ?.extralist![
//                                                                   index]
//                                                               .propertyTitle ??
//                                                           "",
//                                                   pId: extraImageController
//                                                           .extraListInfo
//                                                           ?.extralist![index]
//                                                           .propertyId ??
//                                                       "");
//                                           Get.toNamed(
//                                               Routes.addExtraImageScreen,
//                                               arguments: {
//                                                 "add": "edit",
//                                               });
//                                         },
//                                         child: Container(
//                                           height: 40,
//                                           width: 40,
//                                           padding: EdgeInsets.all(9),
//                                           alignment: Alignment.center,
//                                           child: Image.asset(
//                                               "assets/images/Pen (1).png"),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Color(0xff3D5BF6),
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 );
//                               },
//                             )
//                           : Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 14, vertical: 5),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(height: Get.height * 0.10),
//                                     Image(
//                                       image: AssetImage(
//                                         "assets/images/searchDataEmpty.png",
//                                       ),
//                                       height: 110,
//                                       width: 110,
//                                     ),
//                                     Center(
//                                       child: SizedBox(
//                                         width: Get.width * 0.80,
//                                         child: Text(
//                                           "Sorry, there is no any nearby \n category or data not found"
//                                               .tr,
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             color: notifire.getgreycolor,
//                                             fontFamily: FontFamily.gilroyBold,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                       : Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                   decoration: BoxDecoration(
//                     color: notifire.getblackwhitecolor,
//                   ),
//                 );
//               }),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
