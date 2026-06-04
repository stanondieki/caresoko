// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/add_homecare_controller.dart';
import 'package:gotocarefinder/controller/dashboard_controller.dart';
import 'package:gotocarefinder/controller/enquiry_controller.dart';
import 'package:gotocarefinder/controller/selectcountry_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Custom_widget.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AddHomeCareScreen5 extends StatefulWidget {
  const AddHomeCareScreen5({super.key});

  @override
  State<AddHomeCareScreen5> createState() => _AddHomeCareScreen5State();
}

const List<String> list = ["Buy", "Rent"];
const List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddHomeCareScreen5State extends State<AddHomeCareScreen5> {
  final AddHomecareController addHomecareController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments != null ? Get.arguments["add"] ?? "Add" : "Add";

  String selectValue = list.first;
  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  bool carCheck = false;
  bool sportCheck = false;
  bool laundaryCheck = false;

  late ColorNotifire notifire;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = prefs.getBool("setIsDark") ?? false;
  }

  Future<Position> locateUser() async =>
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: addHomecareController.agencyShootDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: notifire.getwhiteblackcolor,
            ),
            dialogBackgroundColor: notifire.getblackwhitecolor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: blueColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != addHomecareController.agencyShootDate) {
      setState(() {
        addHomecareController.agencyShootDate = picked;
        addHomecareController.propertyShootDateController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    // ------ Responsive knobs ------
    final media = MediaQuery.of(context);
    final isWide = media.size.width >= 900; // desktop/tablet breakpoint
    final sidePad = isWide ? 24.0 : 10.0;
    const contentMaxWidth = 1100.0;

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        backgroundColor: notifire.getblackwhitecolor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Add Homecare Agency".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: contentMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sidePad),
                child: Scrollbar(
                  thumbVisibility: isWide, // handy on web/desktop
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      color: notifire.getblackwhitecolor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          _title("Photos Of Your Agency".tr),
                          const SizedBox(height: 16),
                          _subtitle(manegeRoute == "Add"
                              ? "Step 5 of 8".tr
                              : "Step 5 of 7".tr),
                          const SizedBox(height: 10),
                          _sectionHeader("A Visual Preview Of Your Agency".tr),
                          const SizedBox(height: 10),
                          Divider(height: 0.5, color: notifire.getgreycolor),
                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Text(
                              "Do you have high quality photos of your homecare agency? (If not, you can book our professional photographers to take photos for you)"
                                  .tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifire.getwhiteblackcolor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Yes/No have photos
                          Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Checkbox(
                                    value: addHomecareController.havePhotos,
                                    side: const BorderSide(
                                        color: Color(0xffC5CAD4)),
                                    activeColor: blueColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    onChanged: (_) {
                                      setState(() => addHomecareController
                                          .havePhotos = true);
                                    },
                                  ),
                                  Text(
                                    "Yes",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 17,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(thickness: 1),
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Checkbox(
                                    value: !addHomecareController.havePhotos,
                                    side: const BorderSide(
                                        color: Color(0xffC5CAD4)),
                                    activeColor: blueColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    onChanged: (_) {
                                      setState(() => addHomecareController
                                          .havePhotos = false);
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      "No, and I would like to book your professional photographers",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 17,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(
                              height:
                                  addHomecareController.havePhotos ? 15 : 25),

                          // --------- Booking block (responsive) ---------
                          if (!addHomecareController.havePhotos) ...[
                            _sectionHeader(
                                "Book Our Professional Photographers".tr),
                            const SizedBox(height: 12),
                            dateTextField(
                              type: "When would you like to have the shoot?",
                              labelText: "Select Date",
                              controller: addHomecareController
                                  .propertyShootDateController,
                              isDatePicker: true,
                              onDateSelected: (DateTime? _) {},
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                "What time on that day works best for you?".tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: FontFamily.gilroyBold,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final TimeOfDay? selectedTime =
                                          await Get.dialog(
                                        Theme(
                                          data: Get.theme.copyWith(
                                            timePickerTheme:
                                                TimePickerThemeData(
                                              backgroundColor:
                                                  notifire.getblackwhitecolor,
                                              hourMinuteTextColor:
                                                  notifire.getwhiteblackcolor,
                                              dialHandColor: blueColor,
                                              dialBackgroundColor: notifire
                                                  .getblackwhitecolor
                                                  .withOpacity(0.1),
                                              entryModeIconColor:
                                                  notifire.getwhiteblackcolor,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor: blueColor,
                                              ),
                                            ),
                                          ),
                                          child: TimePickerDialog(
                                            initialTime: TimeOfDay.now(),
                                          ),
                                        ),
                                      );

                                      if (selectedTime != null) {
                                        final now = DateTime.now();
                                        final dt = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          selectedTime.hour,
                                          selectedTime.minute,
                                        );
                                        final formattedTime =
                                            DateFormat('hh:mm a').format(dt);
                                        addHomecareController
                                            .updateTime(formattedTime);
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      height: 55,
                                      margin: const EdgeInsets.all(8),
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: notifire.getblackwhitecolor,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color: notifire.getborderColor),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              (addHomecareController
                                                          .agencyShootTime
                                                          ?.isNotEmpty ??
                                                      false)
                                                  ? addHomecareController
                                                      .agencyShootTime!
                                                  : "Pick time".tr,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyMedium,
                                                color: (addHomecareController
                                                            .agencyShootTime
                                                            ?.isNotEmpty ??
                                                        false)
                                                    ? notifire
                                                        .getwhiteblackcolor
                                                    : notifire.getgreycolor,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            "assets/images/Calendar.png",
                                            height: 25,
                                            width: 25,
                                            color: (addHomecareController
                                                        .agencyShootTime
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? notifire.getwhiteblackcolor
                                                : notifire.getgreycolor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _sectionHeader("Terms Of Service".tr),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Checkbox(
                                  value: addHomecareController
                                      .consentToPhotographyTerms,
                                  side: const BorderSide(
                                      color: Color(0xffC5CAD4)),
                                  activeColor: blueColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  onChanged: (_) {
                                    setState(() {
                                      addHomecareController
                                              .consentToPhotographyTerms =
                                          !addHomecareController
                                              .consentToPhotographyTerms;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    "I consent to GoToCareFinder's terms of service, including permission for GoToCareFinder to use the images on the platform",
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 17,
                                      color: notifire.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // --------- Upload block (responsive) ---------
                          if (addHomecareController.havePhotos) ...[
                            _sectionHeader("Upload Photos".tr),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, bottom: 7, right: 15),
                              child: Text(
                                "Showcase photos of your caregivers / team together or in action. A welcoming and professional presentation can make a lasting impression"
                                    .tr,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 16,
                                  color: notifire.getwhiteblackcolor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => _openGallery(context),
                              child: Center(
                                child: Container(
                                  width: media.size.width - 20,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xff3D5BF6)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Photos (Upload Multiple)".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (addHomecareController
                                .agencyImagesPaths.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: SizedBox(
                                  height: 170,
                                  child: ListView.builder(
                                    clipBehavior: Clip.none,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(bottom: 10),
                                    itemCount: addHomecareController
                                        .agencyImagesPaths.length,
                                    itemBuilder: (context, index) {
                                      final path = addHomecareController
                                          .agencyImagesPaths[index];
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: 300,
                                            width: 150,
                                            margin: const EdgeInsets.only(
                                                right: 15),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: MemoryImage(base64Decode(addHomecareController.agencyImagesBase64[index])),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 5,
                                            top: -8,
                                            child: GestureDetector(
                                              onTap: () {
                                                addHomecareController
                                                    .agencyImagesBase64
                                                    .removeAt(index);
                                                addHomecareController
                                                    .agencyImagesPaths
                                                    .removeAt(index);
                                                setState(() {});
                                              },
                                              child: Container(
                                                height: 26,
                                                width: 26,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xff3D5BF6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],

                          const SizedBox(height: 20),

                          // --------- NEXT button (centered on wide) ---------
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 160 : 35),
                            child: GestButton(
                              Width: double.infinity,
                              height: 55,
                              buttoncolor: addHomecareController.havePhotos
                                  ? blueColor
                                  : (addHomecareController
                                          .consentToPhotographyTerms
                                      ? blueColor
                                      : greyColor),
                              margin: const EdgeInsets.only(top: 5),
                              buttontext: "Next".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                color: WhiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              onclick: addHomecareController.havePhotos
                                  ? () {
                                      // COMMENTED OUT: Advert functionality disabled
                                      // Get.toNamed(
                                      //   Routes.addHomecareScreen6,
                                      //   arguments: {"add": manegeRoute},
                                      // );
                                    }
                                  : (addHomecareController
                                          .consentToPhotographyTerms
                                      ? () {
                                          // COMMENTED OUT: Advert functionality disabled
                                          // Get.toNamed(
                                          //   Routes.addPropertyScreen5,
                                          //   arguments: {"add": "Add"},
                                          // );
                                        }
                                      : null),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 20,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  Widget _subtitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: notifire.getgreycolor,
          ),
        ),
      );

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      );

  // (unchanged) gallery helper
  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addHomecareController.path = pickedFile.path;
      addHomecareController.agencyImagesPaths.add(addHomecareController.path!);

      final imageBytes = await pickedFile.readAsBytes();
      addHomecareController.base64Image = base64Encode(imageBytes);
      addHomecareController.agencyImagesBase64
          .add(addHomecareController.base64Image!);
      setState(() {});
    }
  }

  // (unchanged) text field helper
  Widget textfield({
    String? type,
    String? labelText,
    String? prefixtext,
    Widget? suffix,
    Color? labelcolor,
    Color? prefixcolor,
    Color? floatingLabelColor,
    Color? focusedBorderColor,
    TextDecoration? decoration,
    bool? readOnly,
    double? Width,
    int? max,
    TextEditingController? controller,
    TextInputType? textInputType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    double? Height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            type ?? "",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: Height,
          width: Width,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: notifire.getwhiteblackcolor,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: max,
            readOnly: readOnly ?? false,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: "Gilroy Medium",
                fontSize: 16,
              ),
              suffixIcon: suffix,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: blueColor),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifire.getborderColor),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget dateTextField({
    String? type,
    String? labelText,
    String? prefixtext,
    Widget? suffix,
    Color? labelcolor,
    Color? prefixcolor,
    Color? floatingLabelColor,
    Color? focusedBorderColor,
    TextDecoration? decoration,
    bool? readOnly,
    double? Width,
    int? max,
    TextEditingController? controller,
    TextInputType? textInputType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool? isDatePicker,
    Function(DateTime?)? onDateSelected,
    double? Height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            type ?? "",
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: Height,
          width: Width,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            cursorColor: notifire.getwhiteblackcolor,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: max,
            readOnly: isDatePicker == true ? true : readOnly ?? false,
            onTap: isDatePicker == true ? () => _selectDate(context) : null,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontFamily: "Gilroy Medium",
                fontSize: 16,
              ),
              suffixIcon: isDatePicker == true
                  ? Icon(Icons.calendar_today,
                      color: notifire.getwhiteblackcolor)
                  : suffix,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: blueColor),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: notifire.getborderColor),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }
}

// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/controller/add_homecare_controller.dart';
// import 'package:gotocarefinder/controller/addproperties_controller.dart';
// import 'package:gotocarefinder/controller/dashboard_controller.dart';
// import 'package:gotocarefinder/controller/enquiry_controller.dart';
// import 'package:gotocarefinder/controller/selectcountry_controller.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Custom_widget.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:gotocarefinder/model/routes_helper.dart';
// import 'package:intl/intl.dart';
//
// class AddHomeCareScreen5 extends StatefulWidget {
//   const AddHomeCareScreen5({super.key});
//
//   @override
//   State<AddHomeCareScreen5> createState() => _AddHomeCareScreen5State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddHomeCareScreen5State extends State<AddHomeCareScreen5> {
//   AddHomecareController addHomecareController = Get.find();
//   DashBoardController dashBoardController = Get.find();
//   EnquiryController enquriryController = Get.find();
//   SelectCountryController selectCountryController = Get.find();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   String manegeRoute = Get.arguments["add"];
//
//   String selectValue = list.first;
//   String? selectProperty;
//   String? selectCountry;
//   String slectStatus = propartyStatus.first;
//
//   bool carCheck = false;
//   bool sportCheck = false;
//   bool laundaryCheck = false;
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
//   Future<Position> locateUser() async {
//     return Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     print(".....//.......//.....//" + manegeRoute);
//     getdarkmodepreviousstate();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: addHomecareController.agencyShootDate ?? DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Colors.black, // Header background
//               onPrimary: Colors.white, // Header text
//               onSurface: Colors.black, // Calendar text
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null && picked != addHomecareController.agencyShootDate) {
//       setState(() {
//         addHomecareController.agencyShootDate = picked;
//         addHomecareController.propertyShootDateController.text =
//             DateFormat('dd/MM/yyyy').format(picked);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       backgroundColor: notifire.getfevAndSearch,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(
//             Icons.arrow_back,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//         backgroundColor: notifire.getblackwhitecolor,
//         elevation: 0,
//         title: Text(
//           "Add Homecare Agency".tr,
//           style: TextStyle(
//             color: notifire.getwhiteblackcolor,
//             fontFamily: FontFamily.gilroyBold,
//             fontSize: 16,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: BouncingScrollPhysics(),
//                   child: Container(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Photos Of Your Agency".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 18,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 25,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Step 5 of 8".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 14,
//                               color: notifire.getgreycolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "A Visual Preview Of Your Agency".tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Divider(
//                           height: 0.5,
//                           color: notifire.getgreycolor,
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15, right: 15),
//                           child: Text(
//                             "Do you have high quality photos of your homecare agency? (If not, you can book our professional photographers to take photos for you)"
//                                 .tr,
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyBold,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Column(
//                           children: [
//                             Row(
//                               children: [
//                                 SizedBox(width: 10),
//                                 Transform.scale(
//                                   scale: 1,
//                                   child: Checkbox(
//                                     value: addHomecareController.havePhotos,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.havePhotos = true;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 Text(
//                                   "Yes",
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyMedium,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 20),
//                               child: Divider(thickness: 1),
//                             ),
//                             Row(
//                               children: [
//                                 SizedBox(width: 10),
//                                 Transform.scale(
//                                   scale: 1,
//                                   child: Checkbox(
//                                     value: !addHomecareController.havePhotos,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addHomecareController.havePhotos = false;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 60,
//                                   child: Text(
//                                     "No, and I would like to book your professional photographers",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 17,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         !addHomecareController.havePhotos
//                             ? SizedBox(
//                                 height: 25,
//                               )
//                             : SizedBox(
//                                 height: 15,
//                               ),
//                         !addHomecareController.havePhotos
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Book Our Professional Photographers".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? SizedBox(
//                                 height: 15,
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? dateTextField(
//                                 type: "When would you like to have the shoot?",
//                                 labelText: "Select Date",
//                                 controller: addHomecareController
//                                     .propertyShootDateController,
//                                 isDatePicker: true,
//                                 onDateSelected: (DateTime? date) {
//                                   // Handle the selected date
//                                   if (date != null) {
//                                     print(
//                                         'Selected shoot date: ${DateFormat('dd/MM/yyyy').format(date)}');
//                                   }
//                                 },
//                               )
//                             : SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? Row(
//                                 children: [
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(left: 15),
//                                       child: Text(
//                                         "What time on that day works best for you?"
//                                             .tr,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontFamily: FontFamily.gilroyBold,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? Row(
//                                 children: [
//                                   Expanded(
//                                     child: GestureDetector(
//                                       onTap: () async {
//                                         final TimeOfDay? selectedTime =
//                                             await Get.dialog(
//                                           Theme(
//                                             data: Get.theme.copyWith(
//                                               timePickerTheme:
//                                                   TimePickerThemeData(
//                                                 backgroundColor:
//                                                     notifire.getblackwhitecolor,
//                                                 hourMinuteTextColor:
//                                                     notifire.getwhiteblackcolor,
//                                                 dialHandColor: blueColor,
//                                                 dialBackgroundColor: notifire
//                                                     .getblackwhitecolor
//                                                     .withOpacity(0.1),
//                                                 entryModeIconColor:
//                                                     notifire.getwhiteblackcolor,
//                                               ),
//                                               textButtonTheme:
//                                                   TextButtonThemeData(
//                                                 style: TextButton.styleFrom(
//                                                   foregroundColor: blueColor,
//                                                 ),
//                                               ),
//                                             ),
//                                             child: TimePickerDialog(
//                                               initialTime: TimeOfDay.now(),
//                                             ),
//                                           ),
//                                         );
//
//                                         if (selectedTime != null) {
//                                           final now = DateTime.now();
//                                           final dt = DateTime(
//                                               now.year,
//                                               now.month,
//                                               now.day,
//                                               selectedTime.hour,
//                                               selectedTime.minute);
//                                           final formattedTime =
//                                               DateFormat('hh:mm a').format(dt);
//                                           addHomecareController
//                                               .updateTime(formattedTime);
//                                           setState(() {});
//                                         }
//                                       },
//                                       child: Container(
//                                         height: 55,
//                                         margin: EdgeInsets.all(8),
//                                         child: Row(
//                                           children: [
//                                             SizedBox(width: 15),
//                                             Text(
//                                               addHomecareController
//                                                           .agencyShootTime
//                                                           ?.isNotEmpty ==
//                                                       true
//                                                   ? addHomecareController
//                                                       .agencyShootTime!
//                                                   : "Pick time".tr,
//                                               style: TextStyle(
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 color: addHomecareController
//                                                             .agencyShootTime
//                                                             ?.isNotEmpty ==
//                                                         true
//                                                     ? notifire
//                                                         .getwhiteblackcolor
//                                                     : notifire.getgreycolor,
//                                               ),
//                                             ),
//                                             Spacer(),
//                                             Image.asset(
//                                               "assets/images/Calendar.png",
//                                               height: 25,
//                                               width: 25,
//                                               color: addHomecareController
//                                                           .agencyShootTime
//                                                           ?.isNotEmpty ==
//                                                       true
//                                                   ? notifire.getwhiteblackcolor
//                                                   : notifire.getgreycolor,
//                                             ),
//                                             SizedBox(width: 5),
//                                           ],
//                                         ),
//                                         alignment: Alignment.center,
//                                         decoration: BoxDecoration(
//                                           color: notifire.getblackwhitecolor,
//                                           borderRadius:
//                                               BorderRadius.circular(15),
//                                           border: Border.all(
//                                               color: notifire.getborderColor),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Terms Of Service".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : const SizedBox(),
//                         !addHomecareController.havePhotos
//                             ? Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       SizedBox(width: 10),
//                                       Transform.scale(
//                                         scale: 1,
//                                         child: Checkbox(
//                                           value: addHomecareController
//                                               .consentToPhotographyTerms,
//                                           side: const BorderSide(
//                                               color: Color(0xffC5CAD4)),
//                                           activeColor: blueColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                           ),
//                                           onChanged: (_) {
//                                             addHomecareController
//                                                     .consentToPhotographyTerms =
//                                                 !addHomecareController
//                                                     .consentToPhotographyTerms;
//
//                                             setState(() {});
//                                           },
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: Get.size.width - 60,
//                                         child: Text(
//                                           "I consent to GoToCareFinder's terms of service, including permission for GoToCareFinder to use the images on the platform",
//                                           style: TextStyle(
//                                             fontFamily: FontFamily.gilroyMedium,
//                                             fontSize: 17,
//                                             color: notifire.getwhiteblackcolor,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               )
//                             : const SizedBox(),
//                         addHomecareController.havePhotos
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Upload Photos".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addHomecareController.havePhotos
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : const SizedBox(),
//                         addHomecareController.havePhotos
//                             ? Padding(
//                                 padding:
//                                     const EdgeInsets.only(left: 15, bottom: 7),
//                                 child: Text(
//                                   "Showcase photos of your caregivers / team together or in action. A welcoming and professional presentation can make a lasting impression"
//                                       .tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 16,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addHomecareController.havePhotos
//                             ? InkWell(
//                                 onTap: () {
//                                   _openGallery(context);
//                                 },
//                                 child: Center(
//                                   child: Container(
//                                     width: Get.mediaQuery.size.width - 20,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         border: Border.all(
//                                             color: Color(0xff3D5BF6)),
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                     child: Center(
//                                       child: Text(
//                                         "Photos (Upload Multiple)".tr,
//                                         style: TextStyle(
//                                           fontFamily: FontFamily.gilroyBold,
//                                           fontSize: 16,
//                                           color: notifire.getwhiteblackcolor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         addHomecareController.havePhotos
//                             ? const SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         addHomecareController.agencyImagesPaths.isEmpty
//                             ? const SizedBox()
//                             : addHomecareController.havePhotos
//                                 ? Padding(
//                                     padding: const EdgeInsets.only(
//                                         left: 15.0, right: 15),
//                                     child: SizedBox(
//                                       height: 170,
//                                       child: ListView.builder(
//                                         clipBehavior: Clip.none,
//                                         shrinkWrap: true,
//                                         scrollDirection: Axis.horizontal,
//                                         padding: EdgeInsets.only(bottom: 10),
//                                         itemCount: addHomecareController
//                                             .agencyImagesPaths.length,
//                                         itemBuilder: (context, index) {
//                                           return Stack(
//                                             clipBehavior: Clip.none,
//                                             children: [
//                                               Container(
//                                                 height: 300,
//                                                 width: 150,
//                                                 margin:
//                                                     EdgeInsets.only(right: 15),
//                                                 decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                     image: DecorationImage(
//                                                         image: FileImage(File(
//                                                             addHomecareController
//                                                                     .agencyImagesPaths[
//                                                                 index])),
//                                                         fit: BoxFit.cover)),
//                                               ),
//                                               Positioned(
//                                                 right: 5,
//                                                 top: -8,
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     addHomecareController
//                                                         .agencyImagesBase64
//                                                         .removeAt(index);
//                                                     addHomecareController
//                                                         .agencyImagesPaths
//                                                         .removeAt(index);
//                                                     setState(() {});
//                                                   },
//                                                   child: Container(
//                                                     height: 26,
//                                                     width: 26,
//                                                     decoration: BoxDecoration(
//                                                       color: Color(0xff3D5BF6),
//                                                       shape: BoxShape.circle,
//                                                     ),
//                                                     child: const Center(
//                                                         child: Icon(
//                                                       Icons.close,
//                                                       color: Colors.white,
//                                                       size: 18,
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                   )
//                                 : const SizedBox(),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         GestButton(
//                           Width: Get.size.width,
//                           height: 55,
//                           buttoncolor: addHomecareController.havePhotos
//                               ? blueColor
//                               : (addHomecareController.consentToPhotographyTerms
//                                   ? blueColor
//                                   : greyColor),
//                           margin: EdgeInsets.only(top: 5, left: 35, right: 35),
//                           buttontext: "Next".tr,
//                           style: TextStyle(
//                             fontFamily: FontFamily.gilroyBold,
//                             color: WhiteColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           onclick: addHomecareController.havePhotos
//                               ? () {
//                                   Get.toNamed(
//                                     Routes.addHomecareScreen6,
//                                     arguments: {"add": "Add"},
//                                   );
//                                   /*if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     if (selectCountry != null) {
//                                       if (selectProperty != null) {
//                                         if (addHomecareController
//                                             .selectedIndexes.isNotEmpty) {
//                                           if (addHomecareController.lat !=
//                                                   null &&
//                                               addHomecareController.long !=
//                                                   null) {
//                                             if (addHomecareController.path !=
//                                                     null ||
//                                                 addHomecareController
//                                                         .pImage !=
//                                                     "") {
//                                               if (manegeRoute == "Add") {
//                                                 addHomecareController
//                                                     .addPropertyApi();
//                                               } else if (manegeRoute ==
//                                                   "edit") {
//                                                 addHomecareController
//                                                     .editPropertyApi();
//                                               }
//                                             } else {
//                                               showToastMessage(
//                                                   "Please Upload Image".tr);
//                                             }
//                                           } else {
//                                             showToastMessage(
//                                                 "Please Add Your Property Location"
//                                                     .tr);
//                                           }
//                                         } else {
//                                           showToastMessage(
//                                               "Please Select Property Facility"
//                                                   .tr);
//                                         }
//                                       } else {
//                                         showToastMessage(
//                                             "Please Select Property Type".tr);
//                                       }
//                                     } else {
//                                       showToastMessage(
//                                           "Please Select Country".tr);
//                                     }
//                                   }*/
//                                 }
//                               : (addHomecareController.consentToPhotographyTerms
//                                   ? () {
//                                       Get.toNamed(
//                                         Routes.addPropertyScreen5,
//                                         arguments: {"add": "Add"},
//                                       );
//                                       /*if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     if (selectCountry != null) {
//                                       if (selectProperty != null) {
//                                         if (addHomecareController
//                                             .selectedIndexes.isNotEmpty) {
//                                           if (addHomecareController.lat !=
//                                                   null &&
//                                               addHomecareController.long !=
//                                                   null) {
//                                             if (addHomecareController.path !=
//                                                     null ||
//                                                 addHomecareController
//                                                         .pImage !=
//                                                     "") {
//                                               if (manegeRoute == "Add") {
//                                                 addHomecareController
//                                                     .addPropertyApi();
//                                               } else if (manegeRoute ==
//                                                   "edit") {
//                                                 addHomecareController
//                                                     .editPropertyApi();
//                                               }
//                                             } else {
//                                               showToastMessage(
//                                                   "Please Upload Image".tr);
//                                             }
//                                           } else {
//                                             showToastMessage(
//                                                 "Please Add Your Property Location"
//                                                     .tr);
//                                           }
//                                         } else {
//                                           showToastMessage(
//                                               "Please Select Property Facility"
//                                                   .tr);
//                                         }
//                                       } else {
//                                         showToastMessage(
//                                             "Please Select Property Type".tr);
//                                       }
//                                     } else {
//                                       showToastMessage(
//                                           "Please Select Country".tr);
//                                     }
//                                   }*/
//                                     }
//                                   : null),
//                         ),
//                         SizedBox(
//                           height: 25,
//                         ),
//                       ],
//                     ),
//                     decoration: BoxDecoration(
//                       color: notifire.getblackwhitecolor,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _openGallery(BuildContext context) async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       addHomecareController.path = pickedFile.path;
//       addHomecareController.agencyImagesPaths.add(addHomecareController.path!);
//
//       File imageFile = File(addHomecareController.path.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       addHomecareController.base64Image = base64Encode(imageBytes);
//       addHomecareController.agencyImagesBase64
//           .add(addHomecareController.base64Image!);
//       setState(() {});
//     }
//   }
//
//   textfield(
//       {String? type,
//       labelText,
//       prefixtext,
//       suffix,
//       Color? labelcolor,
//       prefixcolor,
//       floatingLabelColor,
//       focusedBorderColor,
//       TextDecoration? decoration,
//       bool? readOnly,
//       double? Width,
//       int? max,
//       TextEditingController? controller,
//       TextInputType? textInputType,
//       Function(String)? onChanged,
//       String? Function(String?)? validator,
//       Height}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 10,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 15),
//           child: Text(
//             type ?? "",
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//               fontSize: 16,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 6,
//         ),
//         Container(
//           height: Height,
//           width: Width,
//           margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: notifire.getblackwhitecolor),
//           child: TextFormField(
//             controller: controller,
//             onChanged: onChanged,
//             cursorColor: notifire.getwhiteblackcolor,
//             keyboardType: textInputType,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             maxLength: max,
//             readOnly: readOnly ?? false,
//             style: TextStyle(
//                 color: notifire.getwhiteblackcolor,
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 18),
//             decoration: InputDecoration(
//               hintText: labelText,
//               hintStyle: TextStyle(
//                   color: Colors.grey,
//                   fontFamily: "Gilroy Medium",
//                   fontSize: 16),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: blueColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: notifire.getborderColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }
//
//   dateTextField(
//       {String? type,
//       String? labelText,
//       String? prefixtext,
//       Widget? suffix,
//       Color? labelcolor,
//       Color? prefixcolor,
//       Color? floatingLabelColor,
//       Color? focusedBorderColor,
//       TextDecoration? decoration,
//       bool? readOnly,
//       double? Width,
//       int? max,
//       TextEditingController? controller,
//       TextInputType? textInputType,
//       Function(String)? onChanged,
//       String? Function(String?)? validator,
//       bool? isDatePicker,
//       Function(DateTime?)? onDateSelected,
//       double? Height}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 10,
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 15),
//           child: Text(
//             type ?? "",
//             style: TextStyle(
//               fontFamily: FontFamily.gilroyBold,
//               fontSize: 16,
//               color: notifire.getwhiteblackcolor,
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 6,
//         ),
//         Container(
//           height: Height,
//           width: Width,
//           margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               color: notifire.getblackwhitecolor),
//           child: TextFormField(
//             controller: controller,
//             onChanged: onChanged,
//             cursorColor: notifire.getwhiteblackcolor,
//             keyboardType: textInputType,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             maxLength: max,
//             readOnly: isDatePicker == true ? true : readOnly ?? false,
//             onTap: isDatePicker == true ? () => _selectDate(context) : null,
//             style: TextStyle(
//                 color: notifire.getwhiteblackcolor,
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 18),
//             decoration: InputDecoration(
//               hintText: labelText,
//               hintStyle: TextStyle(
//                   color: Colors.grey,
//                   fontFamily: "Gilroy Medium",
//                   fontSize: 16),
//               suffixIcon: isDatePicker == true
//                   ? Icon(
//                       Icons.calendar_today,
//                       color: notifire.getwhiteblackcolor,
//                     )
//                   : suffix,
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: blueColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 borderSide: BorderSide(color: notifire.getborderColor),
//               ),
//               border: OutlineInputBorder(
//                 borderSide: BorderSide(color: notifire.getborderColor),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//             validator: validator,
//           ),
//         ),
//       ],
//     );
//   }
// }
