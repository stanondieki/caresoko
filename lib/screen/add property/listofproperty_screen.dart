// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/addproperties_controller.dart';
import 'package:gotocarefinder/controller/listofproperti_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListOfPropertyScreen extends StatefulWidget {
  const ListOfPropertyScreen({super.key});

  @override
  State<ListOfPropertyScreen> createState() => _ListOfPropertyScreenState();
}

class _ListOfPropertyScreenState extends State<ListOfPropertyScreen> {
  final ListOfPropertiController listOfPropertiController =
      Get.put(ListOfPropertiController());
  final AddPropertiesController addPropertiesController = Get.find();

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    final previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure Provider is ready
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getdarkmodepreviousstate());
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            // Simple breakpoints
            final isPhone = width < 700;
            final isTablet = width >= 700 && width < 1100;
            final isDesktop = width >= 1100;

            // Content max width for large screens
            final double maxContentWidth =
                isDesktop ? 1200 : (isTablet ? 900 : width);

            // Grid columns and item height scale
            final int gridCount = isPhone ? 1 : (isTablet ? 2 : 3);
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 10 : 20,
              vertical: isPhone ? 0 : 8,
            );

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: pagePadding,
                  child: GetBuilder<ListOfPropertiController>(builder: (_) {
                    if (!listOfPropertiController.isLodding) {
                      return _buildLoading(notifire);
                    }

                    final items =
                        listOfPropertiController.propListInfo?.proplist ?? [];
                    if (items.isEmpty) {
                      return _buildEmpty(notifire);
                    }

                    // Phone: use ListView; Bigger screens: GridView
                    if (isPhone) {
                      return ListView.builder(
                        padding: EdgeInsets.only(top: 10, bottom: 16),
                        itemCount: items.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _PropertyCard(
                            notifire: notifire,
                            item: item,
                            imageAspectRatio: 110 / 125, // original card ratio
                            onTap: () => _onEditTap(index),
                          );
                        },
                      );
                    }

                    // Grid layout for tablet/desktop
                    final double gutter = 16;
                    final double cardWidth =
                        (maxContentWidth - (gutter * (gridCount + 1))) /
                            gridCount;
                    // Keep roughly similar height/ratio but allow it to grow on wide screens
                    final double cardHeight = math.max(160, cardWidth * 0.5);

                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount,
                        crossAxisSpacing: gutter,
                        mainAxisSpacing: gutter,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _PropertyCard(
                          notifire: notifire,
                          item: item,
                          denseText: isTablet, // tighten text a touch on 2-col
                          expandLayout: true, // roomier layout for grid
                          imageAspectRatio: isDesktop ? 1.2 : 1.0,
                          onTap: () => _onEditTap(index),
                        );
                      },
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: _AddFab(notifire: notifire),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: notifire.getblackwhitecolor,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        tooltip: 'Back',
      ),
      centerTitle: true,
      title: Text(
        "My Homes & Facilities".tr,
        style: TextStyle(
          color: notifire.getwhiteblackcolor,
          fontFamily: FontFamily.gilroyBold,
          fontSize: 16,
        ),
      ),
      actions: const [],
    );
  }

  Widget _buildLoading(ColorNotifire n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: CircularProgressIndicator(color: n.getwhiteblackcolor),
      ),
    );
  }

  Widget _buildEmpty(ColorNotifire n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Get.height * 0.08),
            Image(
              image: AssetImage("assets/images/searchDataEmpty.png"),
              height: 110,
              width: 110,
            ),
            SizedBox(height: 12),
            SizedBox(
              width: math.min(Get.width * 0.80, 480),
              child: Text(
                "Sorry, there is no any nearby \n category or data not found"
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: n.getgreycolor, fontFamily: FontFamily.gilroyBold),
              ),
            ),
            SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Get.toNamed(Routes.addPropertyScreen1, arguments: {"add": "Add"});
              },
              child: Text("Add New Property".tr),
            ),
          ],
        ),
      ),
    );
  }

  void _onEditTap(int index) {
    final p = listOfPropertiController.propListInfo?.proplist![index];
    if (p == null) return;

    try {
      addPropertiesController.getEditDetails(
        ePropertyId1: p.id ?? "",
        eLogo1: p.logo,
        ePTypeId1: int.tryParse(p.propertyTypeId ?? "") ?? 0,
        ePropertyType1: p.propertyType,
        eStatus1: p.status,
        ePImage1: p.image,
        elat1: double.tryParse(p.latitude ?? "") ?? 0.0,
        elong1: double.tryParse(p.longtitude ?? "") ?? 0.0,
        ePropertyAddress1: p.address,
        ePropertyZipCode1: p.zipCode,
        ePropertyCountry1: p.countryTitle,
        ePropertyCountryId1: int.tryParse(p.countryId ?? "") ?? 0,
        ePropertyName1: p.name,
        ePropertyDescription1: p.description,
        ePropertyLicenseNo1: p.licenseNo,
        ePropertyTypicalDay1: p.typicalDay,
        ePropertyAbout1: p.about,
        ePropertyMission1: p.mission,
        ePropertyVision1: p.vision,
        ePropertyWebsite1: p.website,
        facility1: p.facilitySelect ?? "",
        ePropertyCapacity1: int.tryParse(p.capacity ?? "") ?? 0,
        ePropertyBeds1: p.beds,
        eNoOfPrivateRooms1: p.noOfPrivateRooms,
        eNoOfSharedRooms1: p.noOfSharedRooms,
        ePrivateRoomsHaveOwnBathroom1: p.privateRoomsHaveOwnBathroom,
        ePrivateRoomsAvailable1: p.privateRoomsAvailable,
        eSharedRoomsAvailable1: p.sharedRoomsAvailable,
        eAcceptMemoryCareClients1: p.acceptMemoryCareClients,
        eAcceptMedicaidClients1: p.acceptMedicaidClients,
        eAcceptHoyerClients1: p.acceptHoyerClients,
        eAcceptCorrectionalClients1: p.acceptCorrectionalClients,
        eProvideCuratedMenus1: p.provideCuratedMenus,
        eProvideMedicationReminders1: p.provideMedicationReminders,
        ePricingReady1: p.pricingReady,
        ePropertyPricing1: p.pricing,
        eRecreationalActivities1: p.recreationalActivities,
        eCertifications1: p.certifications ?? "",
        eSpecializedCertifications1: p.specializedCertifications ?? "",
        eAccreditations1: p.accreditations ?? "",
        eMemberships1: p.memberships ?? "",
        eBackgroundChecks1: (p.backgroundChecks == 1),
        eDrugTesting1: (p.drugTesting == 1),
        eReferenceVerification1: (p.referenceVerification == 1),
      );
    } catch (e, st) {
      // Keep quiet in release but helpful during dev
      // ignore: avoid_print
      print("Edit mapping error: $e\n$st");
    }

    Get.toNamed(Routes.addPropertyScreen1, arguments: {"add": "edit"});
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.notifire});
  final ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.toNamed(Routes.addPropertyScreen1, arguments: {"add": "Add"});
      },
      tooltip: 'Add property',
      backgroundColor: Color(0xff3D5BF6),
      child: Icon(Icons.add, color: WhiteColor),
    );
  }
}

/// A responsive card that adapts layout density and spacing.
/// Works both in a list (phone) and in a grid (tablet/desktop).
class _PropertyCard extends StatefulWidget {
  const _PropertyCard({
    required this.notifire,
    required this.item,
    required this.onTap,
    this.denseText = false,
    this.expandLayout = false,
    this.imageAspectRatio = 1.0,
  });

  final ColorNotifire notifire;
  final dynamic item; // your model type
  final VoidCallback onTap;
  final bool denseText;
  final bool expandLayout;
  final double imageAspectRatio;

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.notifire;
    final item = widget.item;

    final EdgeInsets cardMargin = EdgeInsets.all(10);
    final double imgWidth = 110;
    final double imgHeight = 125;

    final radius = BorderRadius.circular(16);

    Widget image = ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        // Preserve a nice ratio on grids; fallback to fixed size on phones
        aspectRatio: widget.expandLayout
            ? (widget.imageAspectRatio <= 0 ? 1 : widget.imageAspectRatio)
            : (imgWidth / imgHeight),
        child: FadeInImage.assetNetwork(
          fadeInCurve: Curves.easeInCirc,
          placeholder: "assets/images/ezgif.com-crop.gif",
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/images/ezgif.com-crop.gif",
              fit: BoxFit.cover,
            );
          },
          image: "${Config.imageUrl}${item.image ?? ""}",
          fit: BoxFit.cover,
        ),
      ),
    );

    // Rating chip
    Widget ratingChip = Positioned(
      top: 12,
      right: 12,
      child: Container(
        height: 30,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Color(0xFFedeeef),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/Rating.png", height: 14, width: 14),
            SizedBox(width: 4),
            Text(
              "${item.rate ?? ""}",
              style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium, color: blueColor),
            ),
          ],
        ),
      ),
    );

    // Title, city, type
    final title = Text(
      item.name ?? "",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: widget.denseText ? 16 : 17,
        fontFamily: FontFamily.gilroyBold,
        color: n.getwhiteblackcolor,
      ),
    );

    final city = Text(
      item.city ?? "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: n.getgreycolor,
        fontFamily: FontFamily.gilroyMedium,
        fontSize: widget.denseText ? 13 : 14,
      ),
    );

    final type = Text(
      "${item.propertyType ?? ""}",
      style: TextStyle(
        fontSize: widget.denseText ? 15 : 17,
        fontFamily: FontFamily.gilroyBold,
        color: blueColor,
      ),
    );

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image (fixed size on phone list; flexible on grid)
        if (!widget.expandLayout)
          Container(
            height: imgHeight,
            width: imgWidth,
            margin: EdgeInsets.all(10),
            child: image,
          )
        else
          // In a grid card, place image at left with a comfortable width
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Stack(children: [image, ratingChip]),
            ),
          ),

        SizedBox(width: 8),

        // Textual info
        Expanded(
          flex: widget.expandLayout ? 6 : 1,
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title,
                SizedBox(height: 6),
                city,
                SizedBox(height: 8),
                type,
              ],
            ),
          ),
        ),
      ],
    );

    final card = AnimatedContainer(
      duration: Duration(milliseconds: 140),
      curve: Curves.easeOut,
      height: widget.expandLayout ? null : 125,
      margin: cardMargin,
      decoration: BoxDecoration(
        color: widget.notifire.getblackwhitecolor,
        border: Border.all(color: widget.notifire.getborderColor),
        borderRadius: radius,
        boxShadow: _hover
            ? [
                BoxShadow(
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: Offset(0, 8),
                    color: Colors.black.withOpacity(0.08))
              ]
            : [],
      ),
      child: Stack(
        children: [
          if (!widget.expandLayout)
            // Phone/list: place rating on top of thumbnail
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  children: [
                    // image with rating overlay
                    Stack(
                      children: [
                        Container(
                          height: 125,
                          width: 110,
                          margin: EdgeInsets.all(10),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: image),
                        ),
                        Positioned(
                            top: 15,
                            right: 20,
                            child:
                                _PhoneRatingBadge(value: "${item.rate ?? ""}")),
                      ],
                    ),
                    Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),

          // Main content (handles both layouts)
          Positioned.fill(child: content),

          // Tap affordance in the corner for web hover users (optional)
          if (kIsWeb)
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: "Edit",
                child: Icon(Icons.edit, size: 18, color: blueColor),
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class _PhoneRatingBadge extends StatelessWidget {
  const _PhoneRatingBadge({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      constraints: BoxConstraints(minWidth: 45),
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFFedeeef),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/Rating.png", height: 12, width: 12),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
                fontFamily: FontFamily.gilroyMedium, color: blueColor),
          ),
        ],
      ),
    );
  }
}

// // ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/listofproperti_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ListOfPropertyScreen extends StatefulWidget {
//   const ListOfPropertyScreen({super.key});
//
//   @override
//   State<ListOfPropertyScreen> createState() => _ListOfPropertyScreenState();
// }
//
// class _ListOfPropertyScreenState extends State<ListOfPropertyScreen> {
//   ListOfPropertiController listOfPropertiController =
//       Get.put(ListOfPropertiController());
//   AddPropertiesController addPropertiesController = Get.find();
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
//         centerTitle: true,
//         title: Text(
//           "My Homes & Facilities".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(5),
//             child: InkWell(
//               onTap: () {
//                 Get.toNamed(
//                   Routes.addPropertyScreen1,
//                   arguments: {"add": "Add"},
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
//               child: GetBuilder<ListOfPropertiController>(builder: (context) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: listOfPropertiController.isLodding
//                       ? listOfPropertiController
//                               .propListInfo!.proplist!.isNotEmpty
//                           ? ListView.builder(
//                               padding: EdgeInsets.only(top: 10),
//                               itemCount: listOfPropertiController
//                                   .propListInfo?.proplist!.length,
//                               physics: BouncingScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 print("++++++++++++++>>" +
//                                     listOfPropertiController.propListInfo!
//                                         .proplist![index].facilitySelect
//                                         .toString());
//
//                                 return InkWell(
//                                   onTap: () {
//                                     try {
//                                       addPropertiesController.getEditDetails(
//                                         ePropertyId1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .id ??
//                                             "",
//                                         eLogo1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .logo,
//                                         ePTypeId1: int.parse(
//                                             listOfPropertiController
//                                                     .propListInfo
//                                                     ?.proplist![index]
//                                                     .propertyTypeId ??
//                                                 ""),
//                                         ePropertyType1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .propertyType,
//                                         eStatus1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .status,
//                                         ePImage1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .image,
//                                         elat1: double.parse(
//                                             listOfPropertiController
//                                                     .propListInfo
//                                                     ?.proplist![index]
//                                                     .latitude ??
//                                                 ""),
//                                         elong1: double.parse(
//                                             listOfPropertiController
//                                                     .propListInfo
//                                                     ?.proplist![index]
//                                                     .longtitude ??
//                                                 ""),
//                                         ePropertyAddress1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .address,
//                                         ePropertyZipCode1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .zipCode,
//                                         ePropertyCountry1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .countryTitle,
//                                         ePropertyCountryId1: int.parse(
//                                             listOfPropertiController
//                                                     .propListInfo
//                                                     ?.proplist![index]
//                                                     .countryId ??
//                                                 ""),
//                                         ePropertyName1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .name,
//                                         ePropertyDescription1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .description,
//                                         ePropertyLicenseNo1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .licenseNo,
//                                         ePropertyTypicalDay1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .typicalDay,
//                                         ePropertyAbout1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .about,
//                                         ePropertyMission1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .mission,
//                                         ePropertyVision1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .vision,
//                                         ePropertyWebsite1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .website,
//                                         facility1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .facilitySelect ??
//                                             "",
//                                         ePropertyCapacity1: int.parse(
//                                             listOfPropertiController
//                                                     .propListInfo
//                                                     ?.proplist![index]
//                                                     .capacity ??
//                                                 ""),
//                                         ePropertyBeds1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .beds,
//                                         eNoOfPrivateRooms1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .noOfPrivateRooms,
//                                         eNoOfSharedRooms1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .noOfSharedRooms,
//                                         ePrivateRoomsHaveOwnBathroom1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .privateRoomsHaveOwnBathroom,
//                                         ePrivateRoomsAvailable1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .privateRoomsAvailable,
//                                         eSharedRoomsAvailable1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .sharedRoomsAvailable,
//                                         eAcceptMemoryCareClients1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .acceptMemoryCareClients,
//                                         eAcceptMedicaidClients1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .acceptMedicaidClients,
//                                         eAcceptHoyerClients1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .acceptHoyerClients,
//                                         eAcceptCorrectionalClients1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .acceptCorrectionalClients,
//                                         eProvideCuratedMenus1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .provideCuratedMenus,
//                                         eProvideMedicationReminders1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .provideMedicationReminders,
//                                         ePricingReady1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .pricingReady,
//                                         ePropertyPricing1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .pricing,
//                                         eRecreationalActivities1:
//                                             listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .recreationalActivities,
//                                         eCertifications1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .certifications ??
//                                             "",
//                                         eSpecializedCertifications1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .specializedCertifications ??
//                                             "",
//                                         eAccreditations1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .accreditations ??
//                                             "",
//                                         eMemberships1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .memberships ??
//                                             "",
//                                         eBackgroundChecks1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .backgroundChecks ==
//                                             1,
//                                         eDrugTesting1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .drugTesting ==
//                                             1,
//                                         eReferenceVerification1: listOfPropertiController
//                                                 .propListInfo
//                                                 ?.proplist![index]
//                                                 .referenceVerification ==
//                                             1,
//                                       );
//                                     } catch (e, stackTrace) {
//                                       print("Error: $e");
//                                       print("Stack trace: $stackTrace");
//                                     }
//
//                                     /*addPropertiesController.getEditDetails(
//                                       ePropertyId1: listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .id ??
//                                           "",
//                                       eLogo1: listOfPropertiController
//                                           .propListInfo?.proplist![index].logo,
//                                       ePTypeId1: int.parse(
//                                           listOfPropertiController
//                                                   .propListInfo
//                                                   ?.proplist![index]
//                                                   .propertyTypeId ??
//                                               ""),
//                                       ePropertyType1: listOfPropertiController
//                                           .propListInfo
//                                           ?.proplist![index]
//                                           .propertyType,
//                                       eStatus1: listOfPropertiController
//                                           .propListInfo
//                                           ?.proplist![index]
//                                           .status,
//                                       ePImage1: listOfPropertiController
//                                           .propListInfo?.proplist![index].image,
//                                       elat1: listOfPropertiController
//                                           .propListInfo
//                                           ?.proplist![index]
//                                           .latitude,
//                                       elong1: listOfPropertiController
//                                           .propListInfo
//                                           ?.proplist![index]
//                                           .longtitude,
//                                       ePropertyAddress1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].address,
//                                       ePropertyZipCode1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].zipCode,
//                                       ePropertyCountry1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].countryTitle,
//                                       ePropertyCountryId1: int.parse(
//                                           listOfPropertiController
//                                                   .propListInfo
//                                                   ?.proplist![index]
//                                                   .countryId ??
//                                               ""),
//                                       ePropertyName1: listOfPropertiController
//                                           .propListInfo?.proplist![index].name,
//                                       ePropertyDescription1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].description,
//                                       ePropertyLicenseNo1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].licenseNo,
//                                       ePropertyTypicalDay1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].typicalDay,
//                                       ePropertyAbout1: listOfPropertiController
//                                           .propListInfo?.proplist![index].about,
//                                       ePropertyMission1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].mission,
//                                       ePropertyVision1: listOfPropertiController
//                                           .propListInfo
//                                           ?.proplist![index]
//                                           .vision,
//                                       ePropertyWebsite1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].website,
//                                       ePropertyLicenseExpiry1: DateTime.parse(
//                                           listOfPropertiController
//                                                   .propListInfo
//                                                   ?.proplist![index]
//                                                   .licenseExpiry ??
//                                               ""),
//                                       ePropertyCapacity1: int.parse(
//                                           listOfPropertiController.propListInfo
//                                                   ?.proplist![index].capacity ??
//                                               ""),
//                                       ePropertyBeds1: listOfPropertiController
//                                           .propListInfo?.proplist![index].beds,
//                                       eNoOfPrivateRooms1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .noOfPrivateRooms,
//                                       eNoOfSharedRooms1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .noOfSharedRooms,
//                                       ePrivateRoomsHaveOwnBathroom1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .privateRoomsHaveOwnBathroom,
//                                       ePrivateRoomsAvailable1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .privateRoomsAvailable,
//                                       eSharedRoomsAvailable1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .sharedRoomsAvailable,
//                                       eAcceptMemoryCareClients1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .acceptMemoryCareClients,
//                                       eAcceptMedicaidClients1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .acceptMedicaidClients,
//                                       eAcceptHoyerClients1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .acceptHoyerClients,
//                                       eAcceptCorrectionalClients1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .acceptCorrectionalClients,
//                                       eProvideCuratedMenus1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .provideCuratedMenus,
//                                       eProvideMedicationReminders1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .provideMedicationReminders,
//                                       ePricingReady1: listOfPropertiController
//                                           .propListInfo
//                                           ?.proplist![index]
//                                           .pricingReady,
//                                       ePropertyPricing1:
//                                           listOfPropertiController.propListInfo
//                                               ?.proplist![index].pricing,
//                                       eRecreationalActivities1:
//                                           listOfPropertiController
//                                               .propListInfo
//                                               ?.proplist![index]
//                                               .recreationalActivities,
//                                     );*/
//
//                                     Get.toNamed(
//                                       Routes.addPropertyScreen1,
//                                       arguments: {"add": "edit"},
//                                     );
//                                   },
//                                   child: Stack(
//                                     children: [
//                                       Container(
//                                         height: 125,
//                                         width: Get.size.width,
//                                         margin: EdgeInsets.all(10),
//                                         child: Row(
//                                           children: [
//                                             Stack(
//                                               children: [
//                                                 Container(
//                                                   height: 125,
//                                                   width: 110,
//                                                   margin: EdgeInsets.all(10),
//                                                   child: ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15),
//                                                     child: FadeInImage
//                                                         .assetNetwork(
//                                                       fadeInCurve:
//                                                           Curves.easeInCirc,
//                                                       placeholder:
//                                                           "assets/images/ezgif.com-crop.gif",
//                                                       height: 140,
//                                                       imageErrorBuilder:
//                                                           (context, error,
//                                                               stackTrace) {
//                                                         return Image.asset(
//                                                           "assets/images/ezgif.com-crop.gif",
//                                                           height: 48,
//                                                           width: 48,
//                                                           fit: BoxFit.cover,
//                                                         );
//                                                       },
//                                                       image:
//                                                           "${Config.imageUrl}${listOfPropertiController.propListInfo?.proplist![index].image ?? ""}",
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15),
//                                                   ),
//                                                 ),
//                                                 /*listOfPropertiController
//                                                             .propListInfo
//                                                             ?.proplist![index]
//                                                             .buyorrent ==
//                                                         "1"
//                                                     ? */
//                                                 Positioned(
//                                                   top: 15,
//                                                   right: 20,
//                                                   child: Container(
//                                                     height: 30,
//                                                     width: 45,
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                       children: [
//                                                         Container(
//                                                           margin:
//                                                               const EdgeInsets
//                                                                   .fromLTRB(
//                                                                   0, 0, 3, 0),
//                                                           child: Image.asset(
//                                                             "assets/images/Rating.png",
//                                                             height: 12,
//                                                             width: 12,
//                                                           ),
//                                                         ),
//                                                         Text(
//                                                           "${listOfPropertiController.propListInfo?.proplist![index].rate}",
//                                                           style: TextStyle(
//                                                             fontFamily: FontFamily
//                                                                 .gilroyMedium,
//                                                             color: blueColor,
//                                                           ),
//                                                         )
//                                                       ],
//                                                     ),
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xFFedeeef),
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               15),
//                                                     ),
//                                                   ),
//                                                 )
//                                                 /*: listOfPropertiController
//                                                                 .propListInfo
//                                                                 ?.proplist![
//                                                                     index]
//                                                                 .isSell ==
//                                                             "0"
//                                                         ? Positioned(
//                                                             top: 15,
//                                                             right: 20,
//                                                             child: Container(
//                                                               height: 27,
//                                                               width: 45,
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               child: Text(
//                                                                 "BUY".tr,
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color:
//                                                                       blueColor,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: Color(
//                                                                     0xFFedeeef),
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             15),
//                                                               ),
//                                                             ),
//                                                           )
//                                                         : Positioned(
//                                                             top: 15,
//                                                             right: 20,
//                                                             child: Container(
//                                                               height: 27,
//                                                               width: 45,
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               child: Text(
//                                                                 "SOLD".tr,
//                                                                 maxLines: 1,
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Color(
//                                                                       0xFFEA1E61),
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                               ),
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                 color: Color(
//                                                                     0xFFedeeef),
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             15),
//                                                               ),
//                                                             ),
//                                                           )*/
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               width: 8,
//                                             ),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Expanded(
//                                                         child: Text(
//                                                           listOfPropertiController
//                                                                   .propListInfo
//                                                                   ?.proplist![
//                                                                       index]
//                                                                   .name ??
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
//                                                     ],
//                                                   ),
//                                                   SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Row(
//                                                     children: [
//                                                       Expanded(
//                                                         child: Text(
//                                                           listOfPropertiController
//                                                                   .propListInfo
//                                                                   ?.proplist![
//                                                                       index]
//                                                                   .city ??
//                                                               "",
//                                                           maxLines: 1,
//                                                           style: TextStyle(
//                                                             color: notifire
//                                                                 .getgreycolor,
//                                                             fontFamily: FontFamily
//                                                                 .gilroyMedium,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: 10,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Row(
//                                                     children: [
//                                                       Text(
//                                                         "${listOfPropertiController.propListInfo?.proplist![index].propertyType ?? ""}",
//                                                         style: TextStyle(
//                                                           fontSize: 17,
//                                                           fontFamily: FontFamily
//                                                               .gilroyBold,
//                                                           color: blueColor,
//                                                         ),
//                                                       ),
//                                                       /*listOfPropertiController
//                                                                   .propListInfo
//                                                                   ?.proplist![
//                                                                       index]
//                                                                   .buyorrent ==
//                                                               "1"
//                                                           ? Text(
//                                                               "/night".tr,
//                                                               style: TextStyle(
//                                                                 color: notifire
//                                                                     .getgreycolor,
//                                                                 fontFamily:
//                                                                     FontFamily
//                                                                         .gilroyMedium,
//                                                               ),
//                                                             )
//                                                           : Text(""),*/
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                               color: notifire.getborderColor),
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                         ),
//                                       ),
//                                       /*listOfPropertiController.propListInfo
//                                                   ?.proplist![index].isSell ==
//                                               "0"
//                                           ? Positioned(
//                                               top: 0,
//                                               right: 0,
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   addPropertiesController.getEditDetails(
//                                                       eTitle1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .title,
//                                                       eNumber1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .mobile,
//                                                       eAddress1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .address,
//                                                       ePrice1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .price,
//                                                       ePropertyAddress1:
//                                                           listOfPropertiController
//                                                               .propListInfo
//                                                               ?.proplist![index]
//                                                               .description,
//                                                       eTotalBeds1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .beds,
//                                                       eTotalBathroom1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .bathroom,
//                                                       eSqft1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .sqrft,
//                                                       eRating1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .rate,
//                                                       eCityAndCountry1:
//                                                           listOfPropertiController
//                                                               .propListInfo
//                                                               ?.proplist![index]
//                                                               .city,
//                                                       lat1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .latitude,
//                                                       long1: listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![index]
//                                                           .longtitude,
//                                                       propId1: listOfPropertiController.propListInfo?.proplist![index].id,
//                                                       eImage1: listOfPropertiController.propListInfo?.proplist![index].image,
//                                                       eGest1: listOfPropertiController.propListInfo?.proplist![index].plimit ?? "",
//                                                       ebuyorRent: listOfPropertiController.propListInfo?.proplist![index].buyorrent ?? "",
//                                                       isShell: listOfPropertiController.propListInfo?.proplist![index].isSell ?? "0",
//                                                       id: listOfPropertiController.propListInfo?.proplist![index].id ?? "",
//                                                       facelity1: listOfPropertiController.propListInfo?.proplist![index].facilitySelect ?? "",
//                                                       pID: listOfPropertiController.propListInfo?.proplist![index].propertyTypeId ?? "",
//                                                       proName1: listOfPropertiController.propListInfo?.proplist![index].propertyType ?? "",
//                                                       countryId1: listOfPropertiController.propListInfo?.proplist![index].countryId ?? "",
//                                                       countryName1: listOfPropertiController.propListInfo?.proplist![index].countryTitle ?? "");
//                                                   Get.toNamed(
//                                                     Routes.addPropertyScreen,
//                                                     arguments: {"add": "edit"},
//                                                   );
//                                                 },
//                                                 child: Container(
//                                                   height: 35,
//                                                   width: 35,
//                                                   padding: EdgeInsets.all(9),
//                                                   alignment: Alignment.center,
//                                                   child: Image.asset(
//                                                       "assets/images/Pen (1).png"),
//                                                   decoration: BoxDecoration(
//                                                     shape: BoxShape.circle,
//                                                     color: Color(0xff3D5BF6),
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           : SizedBox(),*/
//                                     ],
//                                   ),
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
