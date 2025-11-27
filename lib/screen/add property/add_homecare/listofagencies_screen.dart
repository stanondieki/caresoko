// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/add_homecare_controller.dart';
import 'package:gotocarefinder/controller/listofagencies_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListOfAgenciesScreen extends StatefulWidget {
  const ListOfAgenciesScreen({super.key});

  @override
  State<ListOfAgenciesScreen> createState() => _ListOfAgenciesScreenState();
}

class _ListOfAgenciesScreenState extends State<ListOfAgenciesScreen> {
  final ListOfAgenciesController listOfAgenciesController =
      Get.put(ListOfAgenciesController());
  final AddHomecareController addHomecareController = Get.find();

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

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final horizPad = isWide ? 24.0 : 10.0;

    // grid columns for wide screens
    final crossAxisCount = width >= 1400
        ? 3
        : width >= 1100
            ? 2
            : 1;

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
          "My Homecare Agencies".tr,
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
                // COMMENTED OUT: Advert functionality disabled
                // Get.toNamed(
                //   Routes.addHomecareScreen1,
                //   arguments: {"add": "Add"},
                // );
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: Color(0xff3D5BF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizPad),
              child: GetBuilder<ListOfAgenciesController>(builder: (context) {
                final isLoaded = listOfAgenciesController.isLodding;
                final list =
                    listOfAgenciesController.agencyListInfo?.agencylist ?? [];

                if (!isLoaded) {
                  return Container(
                    decoration:
                        BoxDecoration(color: notifire.getblackwhitecolor),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (list.isEmpty) {
                  return Container(
                    decoration:
                        BoxDecoration(color: notifire.getblackwhitecolor),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/searchDataEmpty.png",
                              height: 110,
                              width: 110,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: Get.width * 0.80,
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
                    ),
                  );
                }

                // Responsive: list on mobile, grid on wide
                return Container(
                  decoration: BoxDecoration(color: notifire.getblackwhitecolor),
                  child: crossAxisCount == 1
                      ? ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          itemCount: list.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (ctx, index) => _agencyCard(
                            context: ctx, // ✅ passes real BuildContext
                            index: index,
                            isWide: false,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.9,
                          ),
                          itemCount: list.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (ctx, index) => _agencyCard(
                            context: ctx, // ✅ passes real BuildContext
                            index: index,
                            isWide: true,
                          ),
                        ),
                );

                // return Container(
                //   decoration: BoxDecoration(color: notifire.getblackwhitecolor),
                //   child: crossAxisCount == 1
                //       ? ListView.builder(
                //     padding: const EdgeInsets.only(top: 10, bottom: 20),
                //     itemCount: list.length,
                //     physics: const BouncingScrollPhysics(),
                //     itemBuilder: (_, index) => _agencyCard(
                //       context: context,
                //       index: index,
                //       isWide: false,
                //     ),
                //   )
                //       : GridView.builder(
                //     padding: const EdgeInsets.only(top: 10, bottom: 20),
                //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: crossAxisCount,
                //       crossAxisSpacing: 16,
                //       mainAxisSpacing: 16,
                //       // card is a horizontal row; this ratio keeps it sleek
                //       childAspectRatio: 2.9,
                //     ),
                //     itemCount: list.length,
                //     physics: const BouncingScrollPhysics(),
                //     itemBuilder: (_, index) => _agencyCard(
                //       context: context,
                //       index: index,
                //       isWide: true,
                //     ),
                //   ),
                // );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// One reusable card used in both list & grid
  Widget _agencyCard({
    required BuildContext context,
    required int index,
    required bool isWide,
  }) {
    final agency = listOfAgenciesController.agencyListInfo!.agencylist![index];

    return InkWell(
      onTap: () {
        try {
          addHomecareController.getEditDetails(
            eAgencyId1: agency.id ?? "",
            eLogo1: agency.logo,
            ePTypeId1: int.tryParse(agency.propertyType ?? "") ?? 0,
            ePropertyType1: agency.propertyType,
            eStatus1: "1",
            elat1: double.tryParse(agency.latitude ?? "") ?? 0,
            elong1: double.tryParse(agency.longitude ?? "") ?? 0,
            ePropertyAddress1: agency.agencyAddress,
            ePropertyZipCode1: agency.agencyZipcode,
            ePropertyCountry1: agency.agencyCountry,
            ePropertyCountryId1: 4,
            ePropertyName1: agency.name,
            ePropertyDescription1: agency.about,
            ePropertyLicenseNo1: agency.licenseNumber,
            ePropertyAbout1: agency.about,
            ePropertyMission1: agency.mission,
            ePropertyVision1: agency.vision,
            ePropertyWebsite1: agency.website,
            ePropertyPricing1: agency.pricing,
            eActivitiesOfDailyLiving1: agency.activitiesOfDailyLiving == 1,
            eMealPreparation1: agency.mealPreparation == 1,
            eLaundry1: agency.laundry == 1,
            eLightHousekeeping1: agency.lightHouseKeeping == 1,
            eMobilityAssistance1: agency.mobilityAssistance == 1,
            eTransportation1: agency.transportation == 1,
            eMemoryCare1: agency.memoryCare == 1,
            ePalliativeCare1: agency.palliativeCare == 1,
            eChronicConditionManagement1:
                agency.chronicConditionManagement == 1,
            ePostHospitalizationCare1: agency.postHospitalizationCare == 1,
            eRespiteCare1: agency.respiteCare == 1,
            eStaffAvailability1: agency.staffAvailability ?? "",
            eWeekendCoverage1: agency.weekendCoverage == 1,
            eHolidayCoverage1: agency.holidayCoverage == 1,
            eCertifications1: agency.certifications ?? "",
            eSpecializedCertifications1: agency.specializedCertifications ?? "",
            eAccreditations1: agency.accreditations ?? "",
            eMemberships1: agency.memberships ?? "",
            eBackgroundChecks1: agency.backgroundChecks == 1,
            eDrugTesting1: agency.drugTesting == 1,
            eReferenceVerification1: agency.referenceVerification == 1,
            eReadyPricing1: agency.pricingReady == 1,
            ePricing1: agency.pricing ?? "",
            ePrivatePay1: agency.privatePay == 1,
            eInsurance1: agency.insurance == 1,
            eMedicaid1: agency.medicaid == 1,
            eAgencyLicenseNo1: agency.licenseNumber ?? "",
            eLanguages1: agency.languages ?? "",
            eWhyTheyStandOut1: agency.whyTheyStandOut ?? "",
            eAgencyAbout1: agency.about ?? "",
            eAgencyMission1: agency.mission ?? "",
            eAgencyVision1: agency.vision ?? "",
            eAgencyWebsite1: agency.website ?? "",
          );
        } catch (e, stackTrace) {
          // keep your debug logging
          print("Error: $e");
          print("Stack trace: $stackTrace");
        }

        // COMMENTED OUT: Advert functionality disabled
        // Get.toNamed(
        //   Routes.addHomecareScreen1,
        //   arguments: {"add": "edit"},
        // );
      },
      child: Container(
        height: 125,
        margin: EdgeInsets.all(isWide ? 0 : 10),
        decoration: BoxDecoration(
          border: Border.all(color: notifire.getborderColor),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  height: 125,
                  width: 110,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeInCirc,
                      placeholder: "assets/images/ezgif.com-crop.gif",
                      height: 140,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/ezgif.com-crop.gif",
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                        );
                      },
                      image: "${Config.imageUrl}${agency.image ?? ""}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Rating pill
                Positioned(
                  top: 15,
                  right: 20,
                  child: Container(
                    height: 30,
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFedeeef),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/Rating.png",
                            height: 12, width: 12),
                        const SizedBox(width: 4),
                        Text(
                          "${agency.rate}",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            color: blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      agency.name ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: FontFamily.gilroyBold,
                        color: notifire.getwhiteblackcolor,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // City
                    Text(
                      agency.city ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: notifire.getgreycolor,
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Property Type Title
                    Text(
                      agency.propertyTypeTitle ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
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
    );
  }
}

// // ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
// import 'package:gotocarefinder/controller/add_homecare_controller.dart';
// import 'package:gotocarefinder/controller/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/listofagencies_controller.dart';
// import 'package:gotocarefinder/controller/listofproperti_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ListOfAgenciesScreen extends StatefulWidget {
//   const ListOfAgenciesScreen({super.key});
//
//   @override
//   State<ListOfAgenciesScreen> createState() => _ListOfAgenciesScreenState();
// }
//
// class _ListOfAgenciesScreenState extends State<ListOfAgenciesScreen> {
//   ListOfAgenciesController listOfAgenciesController =
//       Get.put(ListOfAgenciesController());
//   AddHomecareController addHomecareController = Get.find();
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
//           "My Homecare Agencies".tr,
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
//                   Routes.addHomecareScreen1,
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
//               child: GetBuilder<ListOfAgenciesController>(builder: (context) {
//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: listOfAgenciesController.isLodding
//                       ? listOfAgenciesController
//                               .agencyListInfo!.agencylist!.isNotEmpty
//                           ? ListView.builder(
//                               padding: EdgeInsets.only(top: 10),
//                               itemCount: listOfAgenciesController
//                                   .agencyListInfo?.agencylist!.length,
//                               physics: BouncingScrollPhysics(),
//                               itemBuilder: (context, index) {
//
//                                 return InkWell(
//                                   onTap: () {
//                                     try {
//                                       addHomecareController.getEditDetails(
//                                         eAgencyId1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .id ??
//                                             "",
//                                         eLogo1: listOfAgenciesController
//                                             .agencyListInfo
//                                             ?.agencylist![index]
//                                             .logo,
//                                         ePTypeId1: int.parse(
//                                             listOfAgenciesController
//                                                     .agencyListInfo
//                                                     ?.agencylist![index]
//                                                     .propertyType ??
//                                                 ""),
//                                         ePropertyType1: listOfAgenciesController
//                                             .agencyListInfo
//                                             ?.agencylist![index]
//                                             .propertyType,
//                                         eStatus1: "1",
//                                         elat1: double.parse(
//                                             listOfAgenciesController
//                                                     .agencyListInfo
//                                                     ?.agencylist![index]
//                                                     .latitude ??
//                                                 ""),
//                                         elong1: double.parse(
//                                             listOfAgenciesController
//                                                     .agencyListInfo
//                                                     ?.agencylist![index]
//                                                     .longitude ??
//                                                 ""),
//                                         ePropertyAddress1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .agencyAddress,
//                                         ePropertyZipCode1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .agencyZipcode,
//                                         ePropertyCountry1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .agencyCountry,
//                                         ePropertyCountryId1: 4,
//                                         ePropertyName1: listOfAgenciesController
//                                             .agencyListInfo
//                                             ?.agencylist![index]
//                                             .name,
//                                         ePropertyDescription1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .about,
//                                         ePropertyLicenseNo1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .licenseNumber,
//                                         ePropertyAbout1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .about,
//                                         ePropertyMission1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .mission,
//                                         ePropertyVision1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .vision,
//                                         ePropertyWebsite1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .website,
//                                         ePropertyPricing1:
//                                             listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .pricing,
//                                         eActivitiesOfDailyLiving1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .activitiesOfDailyLiving ==
//                                             1,
//                                         eMealPreparation1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .mealPreparation ==
//                                             1,
//                                         eLaundry1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .laundry ==
//                                             1,
//                                         eLightHousekeeping1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .lightHouseKeeping ==
//                                             1,
//                                         eMobilityAssistance1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .mobilityAssistance ==
//                                             1,
//                                         eTransportation1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .transportation ==
//                                             1,
//                                         eMemoryCare1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .memoryCare ==
//                                             1,
//                                         ePalliativeCare1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .palliativeCare ==
//                                             1,
//                                         eChronicConditionManagement1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .chronicConditionManagement ==
//                                             1,
//                                         ePostHospitalizationCare1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .postHospitalizationCare ==
//                                             1,
//                                         eRespiteCare1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .respiteCare ==
//                                             1,
//                                         eStaffAvailability1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .staffAvailability ??
//                                             "",
//                                         eWeekendCoverage1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .weekendCoverage ==
//                                             1,
//                                         eHolidayCoverage1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .holidayCoverage ==
//                                             1,
//                                         eCertifications1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .certifications ??
//                                             "",
//                                         eSpecializedCertifications1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .specializedCertifications ??
//                                             "",
//                                         eAccreditations1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .accreditations ??
//                                             "",
//                                         eMemberships1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .memberships ??
//                                             "",
//                                         eBackgroundChecks1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .backgroundChecks ==
//                                             1,
//                                         eDrugTesting1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .drugTesting ==
//                                             1,
//                                         eReferenceVerification1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .referenceVerification ==
//                                             1,
//                                         eReadyPricing1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .pricingReady ==
//                                             1,
//                                         ePricing1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .pricing ??
//                                             "",
//                                         ePrivatePay1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .privatePay ==
//                                             1,
//                                         eInsurance1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .insurance ==
//                                             1,
//                                         eMedicaid1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .medicaid ==
//                                             1,
//                                         eAgencyLicenseNo1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .licenseNumber ??
//                                             "",
//                                         eLanguages1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .languages ?? "",
//                                         eWhyTheyStandOut1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .whyTheyStandOut ??
//                                             "",
//                                         eAgencyAbout1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .about ??
//                                             "",
//                                         eAgencyMission1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .mission ??
//                                             "",
//                                         eAgencyVision1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .vision ??
//                                             "",
//                                         eAgencyWebsite1: listOfAgenciesController
//                                                 .agencyListInfo
//                                                 ?.agencylist![index]
//                                                 .website ??
//                                             "",
//                                       );
//                                     } catch (e, stackTrace) {
//                                       print("Error: $e");
//                                       print("Stack trace: $stackTrace");
//                                     }
//
//                                     Get.toNamed(
//                                       Routes.addHomecareScreen1,
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
//                                                           "${Config.imageUrl}${listOfAgenciesController.agencyListInfo?.agencylist![index].image ?? ""}",
//                                                       fit: BoxFit.cover,
//                                                     ),
//                                                   ),
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15),
//                                                   ),
//                                                 ),
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
//                                                           "${listOfAgenciesController.agencyListInfo?.agencylist![index].rate}",
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
//                                                           listOfAgenciesController
//                                                                   .agencyListInfo
//                                                                   ?.agencylist![
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
//                                                           listOfAgenciesController
//                                                                   .agencyListInfo
//                                                                   ?.agencylist![
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
//                                                         listOfAgenciesController.agencyListInfo?.agencylist![index].propertyTypeTitle ?? "",
//                                                         style: TextStyle(
//                                                           fontSize: 17,
//                                                           fontFamily: FontFamily
//                                                               .gilroyBold,
//                                                           color: blueColor,
//                                                         ),
//                                                       ),
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
