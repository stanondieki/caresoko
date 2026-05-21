// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/add_proparty/addproperties_controller.dart';
import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen.dart';

class ListOfPropartyScreen extends StatefulWidget {
  const ListOfPropartyScreen({super.key});

  @override
  State<ListOfPropartyScreen> createState() => _ListOfPropartyScreenState();
}

class _ListOfPropartyScreenState extends State<ListOfPropartyScreen> {
  final ListOfPropertyController listOfPropertiController =
      Get.put(ListOfPropertyController());
  final AddPropartiesController addPropertiesController =
      Get.put(AddPropartiesController());
  late ColorNotifire notifire;

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
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifire.getblackwhitecolor,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        centerTitle: true,
        title: Text(
          "My Properties".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
              onTap: () {
                addPropertiesController.buyOrRent = "";
                // COMMENTED OUT: Advert functionality disabled
                // Get.toNamed(Routes.addPropertyScreen, arguments: {"add": "Add"});
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
            final width = constraints.maxWidth;
            final isGrid = width >= 700; // switch to grid on tablets/web
            final crossAxisCount = width >= 1200 ? 3 : (width >= 900 ? 2 : 1);
            final horizontalPadding = width >= 900 ? 24.0 : 10.0;
            final gridSpacing = width >= 900 ? 18.0 : 12.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GetBuilder<ListOfPropertyController>(
                      builder: (controller) {
                    final isLoaded = listOfPropertiController.isLodding;
                    final list =
                        listOfPropertiController.propListInfo?.proplist ?? [];

                    if (!isLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (list.isEmpty) {
                      return _emptyState(context);
                    }

                    return Scrollbar(
                      thumbVisibility: isGrid,
                      child: isGrid
                          ? GridView.builder(
                              padding:
                                  const EdgeInsets.only(top: 12, bottom: 12),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: gridSpacing,
                                crossAxisSpacing: gridSpacing,
                                childAspectRatio: 3.2, // wide tile
                              ),
                              itemCount: list.length,
                              itemBuilder: (_, index) => _PropertyTile(
                                notifire: notifire,
                                item: list[index],
                                onTap: () => _openEdit(index),
                                onEdit: () => _openEdit(index),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 12),
                              itemCount: list.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: gridSpacing),
                              itemBuilder: (_, index) => _PropertyTile(
                                notifire: notifire,
                                item: list[index],
                                onTap: () => _openEdit(index),
                                onEdit: () => _openEdit(index),
                              ),
                            ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: width >= 700 ? 40 : 20),
            const Image(
              image: AssetImage("assets/images/searchDataEmpty.png"),
              height: 110,
              width: 110,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 480,
              child: Text(
                "Sorry, there is no any nearby \n category or data not found"
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: notifire.getgreycolor,
                  fontFamily: FontFamily.gilroyBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(int index) {
    final p = listOfPropertiController.propListInfo!.proplist![index];

    addPropertiesController.getEditDetails(
      eTitle1: p.title,
      eNumber1: p.mobile,
      eAddress1: p.address,
      ePrice1: p.price,
      ePropertyAddress1: p.address, // real address
      eTotalBeds1: p.beds,
      eTotalBathroom1: p.bathroom,
      eSqft1: p.sqrft,
      eRating1: p.rate,
      eCityAndCountry1: p.city,
      eDescription1: p.description, // <-- description now mapped correctly
      lat1: p.latitude,
      long1: p.longtitude,
      propId1: p.id,
      eImage1: p.image,
      eGest1: p.plimit ?? "",
      ebuyorRent: p.buyorrent ?? "",
      isShell: p.isSell ?? "0",
      id: p.id ?? "",
      facelity1: p.facilitySelect ?? "",
      pID: p.propertyTypeId ?? "",
      proName1: p.propertyType ?? "",
      countryId1: p.countryId ?? "",
      countryName1: p.countryTitle ?? "",
    );

    // COMMENTED OUT: Advert functionality disabled
    // Get.toNamed(Routes.addPropertyScreen, arguments: {"add": "edit"});
  }
}

/// One responsive property tile/card used by both list & grid.
class _PropertyTile extends StatelessWidget {
  final dynamic item;
  final ColorNotifire notifire;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _PropertyTile({
    required this.item,
    required this.notifire,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final showSoldPill = (item.isSell ?? "0") != "0";
    final forSalePill =
        (item.isSell ?? "0") == "0" && (item.buyorrent ?? "") != "1";
    final showRate = (item.buyorrent ?? "") == "1";

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: notifire.getborderColor),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: 130,
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: FadeInImage.assetNetwork(
                        fadeInCurve: Curves.easeInCirc,
                        placeholder: "assets/images/ezgif.com-crop.gif",
                        image: "${Config.imageUrl}${item.image ?? ""}",
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stack) =>
                            Image.asset("assets/images/ezgif.com-crop.gif",
                                fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Texts
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: FontFamily.gilroyBold,
                            color: notifire.getwhiteblackcolor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.city ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: notifire.getgreycolor,
                            fontFamily: FontFamily.gilroyMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "${currency}${item.price ?? ""}",
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: FontFamily.gilroyBold,
                                color: blueColor,
                              ),
                            ),
                            if ((item.buyorrent ?? "") == "1") ...[
                              const SizedBox(width: 4),
                              Text(
                                "/night".tr,
                                style: TextStyle(
                                  color: notifire.getgreycolor,
                                  fontFamily: FontFamily.gilroyMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top-right pills (rating / FOR SALE / SOLD)
          Positioned(
            top: 8,
            left: 8 + 110 - 12, // visually aligns over image corner
            child: Row(
              children: [
                if (showRate)
                  _pill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/Rating.png",
                            height: 12, width: 12),
                        const SizedBox(width: 4),
                        Text(
                          "${item.rate ?? ''}",
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: blueColor),
                        ),
                      ],
                    ),
                  ),
                if (forSalePill)
                  _pill(
                    width: 78,
                    child: Text("FOR SALE".tr,
                        style: TextStyle(
                            color: blueColor, fontWeight: FontWeight.w500)),
                  ),
                if (showSoldPill)
                  _pill(
                    width: 54,
                    child: Text(
                      "SOLD".tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFEA1E61),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),

          // Edit button (if not sold)
          if (!showSoldPill)
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: onEdit,
                child: Container(
                  height: 35,
                  width: 35,
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
  }

  Widget _pill({required Widget child, double width = 60}) {
    return Container(
      height: 27,
      width: width,
      margin: const EdgeInsets.only(right: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFedeeef),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}

// // ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/add_proparty/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/add_proparty/listofproparti_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/screen/home_screen.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ListOfPropartyScreen extends StatefulWidget {
//   const ListOfPropartyScreen({super.key});
//
//   @override
//   State<ListOfPropartyScreen> createState() => _ListOfPropartyScreenState();
// }
//
// class _ListOfPropartyScreenState extends State<ListOfPropartyScreen> {
//   ListOfPropertyController listOfPropertiController = Get.put(ListOfPropertyController());
//   AddPropartiesController addPropertiesController = Get.put(AddPropartiesController());
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
//           "My Properties".tr,
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
//                 addPropertiesController.buyOrRent = "";
//                 Get.toNamed(
//                   Routes.addPropertyScreen,
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
//               child: GetBuilder<ListOfPropertyController>(builder: (context) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: listOfPropertiController.isLodding
//                       ? listOfPropertiController
//                               .propListInfo!.proplist!.isNotEmpty
//                           ? ListView.builder(
//                     padding: EdgeInsets.only(top: 10),
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
//                                     addPropertiesController.getEditDetails(
//                                         eTitle1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .title,
//                                         eNumber1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .mobile,
//                                         eAddress1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .address,
//                                         ePrice1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .price,
//                                         ePropertyAddress1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .description,
//                                         eTotalBeds1: listOfPropertiController
//                                             .propListInfo?.proplist![index].beds,
//                                         eTotalBathroom1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .bathroom,
//                                         eSqft1: listOfPropertiController
//                                             .propListInfo
//                                             ?.proplist![index]
//                                             .sqrft,
//                                         eRating1: listOfPropertiController.propListInfo?.proplist![index].rate,
//                                         eCityAndCountry1: listOfPropertiController.propListInfo?.proplist![index].city,
//                                         lat1: listOfPropertiController.propListInfo?.proplist![index].latitude,
//                                         long1: listOfPropertiController.propListInfo?.proplist![index].longtitude,
//                                         propId1: listOfPropertiController.propListInfo?.proplist![index].id,
//                                         eImage1: listOfPropertiController.propListInfo?.proplist![index].image,
//                                         eGest1: listOfPropertiController.propListInfo?.proplist![index].plimit ?? "",
//                                         ebuyorRent: listOfPropertiController.propListInfo?.proplist![index].buyorrent ?? "",
//                                         isShell: listOfPropertiController.propListInfo?.proplist![index].isSell ?? "0",
//                                         id: listOfPropertiController.propListInfo?.proplist![index].id ?? "",
//                                         facelity1: listOfPropertiController.propListInfo?.proplist![index].facilitySelect ?? "",
//                                         pID: listOfPropertiController.propListInfo?.proplist![index].propertyTypeId ?? "",
//                                         proName1: listOfPropertiController.propListInfo?.proplist![index].propertyType ?? "",
//                                         countryId1: listOfPropertiController.propListInfo?.proplist![index].countryId ?? "",
//                                         countryName1: listOfPropertiController.propListInfo?.proplist![index].countryTitle ?? "");
//                                     print("========------->> ${listOfPropertiController.propListInfo!.proplist![index].propertyType}");
//                                     print("========------->> ${listOfPropertiController.propListInfo!.proplist![index].propertyTypeId}");
//                                     Get.toNamed(
//                                       Routes.addPropertyScreen,
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
//                                                     child: FadeInImage.assetNetwork(
//                                                       fadeInCurve: Curves.easeInCirc,
//                                                       placeholder:
//                                                       "assets/images/ezgif.com-crop.gif",
//                                                       height: 140,
//                                                       imageErrorBuilder: (context, error, stackTrace) {
//                                                         return Image.asset("assets/images/ezgif.com-crop.gif",height: 48,width: 48,fit: BoxFit.cover,);
//                                                       },
//                                                       image:
//                                                       "${Config.imageUrl}${listOfPropertiController.propListInfo?.proplist![index].image ?? ""}",
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15),
//                                                   ),
//                                                 ),
//                                                 listOfPropertiController
//                                                             .propListInfo
//                                                             ?.proplist![index]
//                                                             .buyorrent ==
//                                                         "1"
//                                                     ? Positioned(
//                                                         top: 15,
//                                                         right: 20,
//                                                         child: Container(
//                                                           height: 30,
//                                                           width: 45,
//                                                           child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .center,
//                                                             children: [
//                                                               Container(
//                                                                 margin:
//                                                                     const EdgeInsets
//                                                                         .fromLTRB(
//                                                                         0,
//                                                                         0,
//                                                                         3,
//                                                                         0),
//                                                                 child:
//                                                                     Image.asset(
//                                                                   "assets/images/Rating.png",
//                                                                   height: 12,
//                                                                   width: 12,
//                                                                 ),
//                                                               ),
//                                                               Text(
//                                                                 "${listOfPropertiController.propListInfo?.proplist![index].rate}",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontFamily:
//                                                                       FontFamily
//                                                                           .gilroyMedium,
//                                                                   color:
//                                                                       blueColor,
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             color: Color(
//                                                                 0xFFedeeef),
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         15),
//                                                           ),
//                                                         ),
//                                                       )
//                                                     : listOfPropertiController
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
//                                                               width: 75,
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               child: Text(
//                                                                 "FOR SALE".tr,
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
//                                                           )
//                                               ],
//                                             ),
//                                             SizedBox(
//                                               width: 8,
//                                             ),
//                                             Expanded(
//                                               child: Column(
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: [
//                                                   Row(
//                                                     children: [
//                                                       Expanded(
//                                                         child: Text(
//                                                           listOfPropertiController
//                                                                   .propListInfo
//                                                                   ?.proplist![
//                                                                       index]
//                                                                   .title ??
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
//                                                         "${currency}${listOfPropertiController.propListInfo?.proplist![index].price ?? ""}",
//                                                         style: TextStyle(
//                                                           fontSize: 17,
//                                                           fontFamily:
//                                                           FontFamily
//                                                               .gilroyBold,
//                                                           color:
//                                                           blueColor,
//                                                         ),
//                                                       ),
//                                                       listOfPropertiController
//                                                           .propListInfo
//                                                           ?.proplist![
//                                                       index]
//                                                           .buyorrent ==
//                                                           "1"
//                                                           ? Text(
//                                                         "/night".tr,
//                                                         style:
//                                                         TextStyle(
//                                                           color: notifire
//                                                               .getgreycolor,
//                                                           fontFamily:
//                                                           FontFamily
//                                                               .gilroyMedium,
//                                                         ),
//                                                       )
//                                                           : Text(""),
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
//                                       listOfPropertiController.propListInfo
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
//                                           : SizedBox(),
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
