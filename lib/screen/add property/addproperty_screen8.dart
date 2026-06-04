// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field

import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/config.dart';
import 'package:gotocarefinder/controller/addproperties_controller.dart';
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

class AddPropertyScreen8 extends StatefulWidget {
  const AddPropertyScreen8({super.key});

  @override
  State<AddPropertyScreen8> createState() => _AddPropertyScreen8State();
}

/// Best-practice radio options for the "website" question
enum WebsiteOption { hasWebsite, buildNew, revamp }

class _AddPropertyScreen8State extends State<AddPropertyScreen8> {
  final AddPropertiesController addPropertiesController = Get.find();
  final DashBoardController dashBoardController = Get.find();
  final EnquiryController enquriryController = Get.find();
  final SelectCountryController selectCountryController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final String manegeRoute = Get.arguments != null ? Get.arguments["add"] ?? "Add" : "Add";

  late ColorNotifire notifire;

  WebsiteOption? websiteOption;

  Future<void> getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    notifire.setIsDark = previusstate ?? false;
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();

    // Pre-fill in edit mode.
    if (manegeRoute == "edit") {
      addPropertiesController.propertyAboutController.text =
          addPropertiesController.ePropertyAbout ?? "";
      addPropertiesController.propertyMissionController.text =
          addPropertiesController.ePropertyMission ?? "";
      addPropertiesController.propertyVisionController.text =
          addPropertiesController.ePropertyVision ?? "";
      addPropertiesController.propertyWebsiteController.text =
          addPropertiesController.ePropertyWebsite ?? "";
    }

    // Initialize radio selection from controller’s booleans/ints
    if (addPropertiesController.haveWebsite == true) {
      websiteOption = WebsiteOption.hasWebsite;
    } else {
      if (addPropertiesController.websiteIntention == 1) {
        websiteOption = WebsiteOption.buildNew;
      } else if (addPropertiesController.websiteIntention == 2) {
        websiteOption = WebsiteOption.revamp;
      } else {
        websiteOption = null;
      }
    }

    getdarkmodepreviousstate();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: addPropertiesController.websiteCallDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != addPropertiesController.websiteCallDate) {
      setState(() {
        addPropertiesController.websiteCallDate = picked;
        addPropertiesController.websiteCallDateController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getfevAndSearch,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        backgroundColor: notifire.getblackwhitecolor,
        elevation: 0,
        title: Text(
          manegeRoute == "Add" ? "Add Home Or Facility".tr : "Edit Home Or Facility".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final bool isPhone = w < 700;
            final bool isTablet = w >= 700 && w < 1100;
            final bool isDesktop = w >= 1100;

            final double maxContentWidth = isDesktop ? 900 : (isTablet ? 800 : w);
            final EdgeInsets pagePadding = EdgeInsets.symmetric(
              horizontal: isPhone ? 12 : 20,
              vertical: isPhone ? 0 : 8,
            );

            // Wider screens get more comfortable text areas
            final int minLines = isDesktop ? 8 : (isTablet ? 7 : 5);

            final bool wantsWebsite = (websiteOption == WebsiteOption.hasWebsite);
            final bool needsTerms =
            (websiteOption == WebsiteOption.buildNew || websiteOption == WebsiteOption.revamp);
            final bool canProceed =
                wantsWebsite || (needsTerms && addPropertiesController.consentToWebsiteTerms);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: pagePadding,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Container(
                              decoration: BoxDecoration(color: notifire.getblackwhitecolor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  _h1("Finally"),
                                  const SizedBox(height: 25),
                                  _stepText(manegeRoute == "Add" ? "Step 8 of 8" : "Step 7 of 7"),
                                  const SizedBox(height: 10),
                                  _h2("Tell Us About Your Home"),
                                  const SizedBox(height: 10),
                                  Divider(height: 0.5, color: notifire.getgreycolor),
                                  const SizedBox(height: 20),

                                  _h2("About You"),
                                  const SizedBox(height: 8),
                                  _multilineBox(
                                    controller: addPropertiesController.propertyAboutController,
                                    minLines: minLines,
                                    hint: "About You".tr,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Share a brief introduction about yourself and your experience in senior care'
                                            .tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  _h2("Your Mission"),
                                  const SizedBox(height: 8),
                                  _multilineBox(
                                    controller: addPropertiesController.propertyMissionController,
                                    minLines: minLines,
                                    hint:
                                    "State the purpose and values that drive your care facility or home".tr,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Your Mission'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  _h2("Your Vision"),
                                  const SizedBox(height: 8),
                                  _multilineBox(
                                    controller: addPropertiesController.propertyVisionController,
                                    minLines: minLines,
                                    hint:
                                    "Describe your long-term goals and how you envision improving senior care"
                                        .tr,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Your Vision'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 15, right: 15),
                                    child: Text(
                                      "Do you have a professional website for your home or facility? (If not, you can book our professional team to build you one or revamp your existing one)"
                                          .tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        fontSize: 16,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                  ),

                                  // ---------- Radio options (fixes overflow) ----------
                                  RadioListTile<WebsiteOption>(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    value: WebsiteOption.hasWebsite,
                                    groupValue: websiteOption,
                                    onChanged: (v) {
                                      websiteOption = v;
                                      addPropertiesController.haveWebsite = true;
                                      addPropertiesController.websiteIntention = 0;
                                      setState(() {});
                                    },
                                    title: Text(
                                      "Yes",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 17,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    activeColor: blueColor,
                                  ),
                                  RadioListTile<WebsiteOption>(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    value: WebsiteOption.buildNew,
                                    groupValue: websiteOption,
                                    onChanged: (v) {
                                      websiteOption = v;
                                      addPropertiesController.haveWebsite = false;
                                      addPropertiesController.websiteIntention = 1;
                                      setState(() {});
                                    },
                                    title: Text(
                                      "No, and I would like a full website build by your professional team",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 17,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    activeColor: blueColor,
                                  ),
                                  RadioListTile<WebsiteOption>(
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    value: WebsiteOption.revamp,
                                    groupValue: websiteOption,
                                    onChanged: (v) {
                                      websiteOption = v;
                                      addPropertiesController.haveWebsite = false;
                                      addPropertiesController.websiteIntention = 2;
                                      setState(() {});
                                    },
                                    title: Text(
                                      "No, I would like a revamp of my current website by your professional team",
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 17,
                                        color: notifire.getwhiteblackcolor,
                                      ),
                                    ),
                                    activeColor: blueColor,
                                  ),
                                  const SizedBox(height: 8),

                                  // ---------- Booking flow when user has no website ----------
                                  if (needsTerms) ...[
                                    _h2("Book Our Website Development / Revamp Services"),
                                    const SizedBox(height: 12),
                                    _dateField(
                                      type:
                                      "When are you available to discuss your website requirements in depth?",
                                      labelText: "Select Date",
                                      controller: addPropertiesController.websiteCallDateController,
                                      onTap: () => _selectDate(context),
                                    ),
                                    const SizedBox(height: 10),
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
                                              final TimeOfDay? selectedTime = await Get.dialog(
                                                Theme(
                                                  data: Get.theme.copyWith(
                                                    timePickerTheme: TimePickerThemeData(
                                                      backgroundColor: notifire.getblackwhitecolor,
                                                      hourMinuteTextColor:
                                                      notifire.getwhiteblackcolor,
                                                      dialHandColor: blueColor,
                                                      dialBackgroundColor: notifire
                                                          .getblackwhitecolor
                                                          .withOpacity(0.1),
                                                      entryModeIconColor:
                                                      notifire.getwhiteblackcolor,
                                                    ),
                                                    textButtonTheme: TextButtonThemeData(
                                                      style: TextButton.styleFrom(
                                                          foregroundColor: blueColor),
                                                    ),
                                                  ),
                                                  child:
                                                  TimePickerDialog(initialTime: TimeOfDay.now()),
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
                                                addPropertiesController
                                                    .updateWebsiteTime(formattedTime);
                                                setState(() {});
                                              }
                                            },
                                            child: Container(
                                              height: 55,
                                              margin: EdgeInsets.all(8),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: notifire.getblackwhitecolor,
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(
                                                    color: notifire.getborderColor),
                                              ),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 15),
                                                  Text(
                                                    addPropertiesController.websiteCalTime
                                                        ?.isNotEmpty ==
                                                        true
                                                        ? addPropertiesController.websiteCalTime!
                                                        : "Pick time".tr,
                                                    style: TextStyle(
                                                      fontFamily: FontFamily.gilroyMedium,
                                                      color: addPropertiesController
                                                          .websiteCalTime
                                                          ?.isNotEmpty ==
                                                          true
                                                          ? notifire.getwhiteblackcolor
                                                          : notifire.getgreycolor,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Image.asset(
                                                    "assets/images/Calendar.png",
                                                    height: 25,
                                                    width: 25,
                                                    color: addPropertiesController.websiteCalTime
                                                        ?.isNotEmpty ==
                                                        true
                                                        ? notifire.getwhiteblackcolor
                                                        : notifire.getgreycolor,
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    _h2("Terms Of Service"),
                                    const SizedBox(height: 8),
                                    CheckboxListTile(
                                      contentPadding: const EdgeInsets.only(left: 6, right: 12),
                                      value: addPropertiesController.consentToWebsiteTerms,
                                      onChanged: (_) {
                                        addPropertiesController.consentToWebsiteTerms =
                                        !addPropertiesController
                                            .consentToWebsiteTerms; // toggle
                                        setState(() {});
                                      },
                                      activeColor: blueColor,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      title: Text(
                                        "I consent to GoToCareFinder's terms of service, including permission for your professional team to link or reference the website on the platform",
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyMedium,
                                          fontSize: 17,
                                          color: notifire.getwhiteblackcolor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // ---------- Website input (conditionally required) ----------
                                  _textField(
                                    type: "Your Website",
                                    controller:
                                    addPropertiesController.propertyWebsiteController,
                                    labelText: "Your Website (Optional)".tr,
                                    textInputType: TextInputType.url,
                                    validator: (value) {
                                      // Only require a value when "Yes" is selected
                                      if (wantsWebsite) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Your Website Link'.tr;
                                        }
                                        final uri = Uri.tryParse(value.trim());
                                        if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
                                          return 'Please enter a valid URL'.tr;
                                        }
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 15),

                                  _h2("Upload Your Logo"),
                                  const SizedBox(height: 10),

                                  DottedBorder(
                                    borderType: BorderType.RRect,
                                    color: Color(0xff3D5BF6),
                                    radius: Radius.circular(15),
                                    borderPadding: EdgeInsets.symmetric(horizontal: 20),
                                    child: InkWell(
                                      onTap: () => _openGallery(context),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: manegeRoute == "Add"
                                            ? Container(
                                          height: 90,
                                          margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                          alignment: Alignment.center,
                                          child: addPropertiesController.logoPath == null ||
                                              addPropertiesController.logoBase64Image == null ||
                                              addPropertiesController.logoBase64Image!.isEmpty
                                              ? Image.asset(
                                            "assets/images/image-upload.png",
                                            height: 40,
                                            width: 42,
                                          )
                                              : Image.memory(
                                            base64Decode(addPropertiesController
                                                .logoBase64Image!),
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Container(
                                          height: 90,
                                          margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                          alignment: Alignment.center,
                                          child: addPropertiesController.eLogo == ""
                                              ? Image.asset(
                                            "assets/images/image-upload.png",
                                            height: 40,
                                            width: 42,
                                          )
                                              : addPropertiesController.logoPath == null ||
                                                  addPropertiesController.logoBase64Image == null ||
                                                  addPropertiesController.logoBase64Image!.isEmpty
                                              ? Image.network(
                                            "${Config.imageUrl}${addPropertiesController.eLogo}",
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          )
                                              : Image.memory(
                                            base64Decode(addPropertiesController
                                                .logoBase64Image!),
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // ---------- Next / Submit ----------
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: isPhone ? 24 : 35),
                                    child: GestButton(
                                      Width: double.infinity,
                                      height: 55,
                                      buttoncolor: canProceed ? blueColor : greyColor,
                                      margin: EdgeInsets.zero,
                                      buttontext: "Next".tr,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyBold,
                                        color: WhiteColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      onclick: canProceed
                                          ? () {
                                        // Validate only the fields that matter:
                                        // - Always validate the big text areas (you already enforce them)
                                        // - Validate website only when user selected "Yes"
                                        if (_formKey.currentState?.validate() ?? false) {
                                          // Persist the haveWebsite flag in the controller
                                          addPropertiesController.haveWebsite =
                                          (websiteOption == WebsiteOption.hasWebsite);

                                          if (manegeRoute == "Add") {
                                            addPropertiesController.addPropertyApi();
                                          } else {
                                            addPropertiesController.editPropertyApi();
                                          }
                                        }
                                      }
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _h1(String text) => Padding(
    padding: const EdgeInsets.only(left: 15),
    child: Text(
      text.tr,
      style: TextStyle(
        fontFamily: FontFamily.gilroyBold,
        fontSize: 18,
        color: notifire.getwhiteblackcolor,
      ),
    ),
  );

  Widget _h2(String text) => Padding(
    padding: const EdgeInsets.only(left: 15),
    child: Text(
      text.tr,
      style: TextStyle(
        fontFamily: FontFamily.gilroyBold,
        fontSize: 16,
        color: notifire.getwhiteblackcolor,
      ),
    ),
  );

  Widget _stepText(String text) => Padding(
    padding: const EdgeInsets.only(left: 15),
    child: Text(
      text.tr,
      style: TextStyle(
        fontFamily: FontFamily.gilroyBold,
        fontSize: 14,
        color: notifire.getgreycolor,
      ),
    ),
  );

  Widget _multilineBox({
    required TextEditingController controller,
    required int minLines,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 15, right: 15),
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: notifire.getborderColor),
      ),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        cursorColor: notifire.getwhiteblackcolor,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: blueColor),
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(12),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 15,
          ),
        ),
        style: TextStyle(
          fontFamily: FontFamily.gilroyMedium,
          fontSize: 16,
          color: notifire.getwhiteblackcolor,
        ),
        validator: validator,
      ),
    );
  }

  Widget _textField({
    String? type,
    String? labelText,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType? textInputType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            (type ?? "").tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            cursorColor: notifire.getwhiteblackcolor,
            keyboardType: textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle:
              TextStyle(color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
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

  Widget _dateField({
    String? type,
    String? labelText,
    TextEditingController? controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            (type ?? "").tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          margin: EdgeInsets.only(top: 5, bottom: 5, left: 12, right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: notifire.getblackwhitecolor,
          ),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            cursorColor: notifire.getwhiteblackcolor,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: TextStyle(
              color: notifire.getwhiteblackcolor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle:
              TextStyle(color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
              suffixIcon: Icon(Icons.calendar_today, color: notifire.getwhiteblackcolor),
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
          ),
        ),
      ],
    );
  }

  // ---------- Actions ----------
  void _openGallery(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addPropertiesController.logoPath = pickedFile.path;
      addPropertiesController.eLogoUpdated = true;
      setState(() {});
      List<int> imageBytes = await pickedFile.readAsBytes();
      addPropertiesController.logoBase64Image = base64Encode(imageBytes);
      setState(() {});
    }
  }
}













// // ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/config.dart';
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
// import 'package:intl/intl.dart';
//
// class AddPropertyScreen8 extends StatefulWidget {
//   const AddPropertyScreen8({super.key});
//
//   @override
//   State<AddPropertyScreen8> createState() => _AddPropertyScreen8State();
// }
//
// List<String> list = ["Buy", "Rent"];
//
// List<String> propartyStatus = ["Publish", "UnPublish"];
//
// class _AddPropertyScreen8State extends State<AddPropertyScreen8> {
//   AddPropertiesController addPropertiesController = Get.find();
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
//     if (manegeRoute == "edit") {
//       addPropertiesController.propertyAboutController.text =
//           addPropertiesController.ePropertyAbout!;
//       addPropertiesController.propertyMissionController.text =
//           addPropertiesController.ePropertyMission!;
//       addPropertiesController.propertyVisionController.text =
//           addPropertiesController.ePropertyVision!;
//       addPropertiesController.propertyWebsiteController.text =
//           addPropertiesController.ePropertyWebsite!;
//
//       setState(() {});
//     }
//     getdarkmodepreviousstate();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: addPropertiesController.websiteCallDate ?? DateTime.now(),
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
//     if (picked != null && picked != addPropertiesController.websiteCallDate) {
//       setState(() {
//         addPropertiesController.websiteCallDate = picked;
//         addPropertiesController.websiteCallDateController.text =
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
//           manegeRoute == "Add"
//               ? "Add Home Or Facility".tr
//               : "Edit Home Or Facility",
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
//                             "Finally".tr,
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
//                             manegeRoute == "Add"
//                                 ? "Step 8 of 8".tr
//                                 : "Step 7 of 7",
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
//                             "Tell Us About Your Home".tr,
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
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "About You".tr,
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
//                         Container(
//                           margin: EdgeInsets.only(top: 5, left: 15, right: 15),
//                           child: TextFormField(
//                             controller:
//                                 addPropertiesController.propertyAboutController,
//                             minLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             cursorColor: notifire.getwhiteblackcolor,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             decoration: InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: blueColor),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               contentPadding: EdgeInsets.all(10),
//                               border: InputBorder.none,
//                               hintText: "About You".tr,
//                               hintStyle: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Share a brief introduction about yourself and your experience in senior care'
//                                     .tr;
//                               }
//                               return null;
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Your Mission".tr,
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
//                         Container(
//                           margin: EdgeInsets.only(top: 5, left: 15, right: 15),
//                           child: TextFormField(
//                             controller: addPropertiesController
//                                 .propertyMissionController,
//                             minLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             cursorColor: notifire.getwhiteblackcolor,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             decoration: InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: blueColor),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               contentPadding: EdgeInsets.all(10),
//                               border: InputBorder.none,
//                               hintText:
//                                   "State the purpose and values that drive your care facility or home"
//                                       .tr,
//                               hintStyle: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Your Mission'.tr;
//                               }
//                               return null;
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Your Vision".tr,
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
//                         Container(
//                           margin: EdgeInsets.only(top: 5, left: 15, right: 15),
//                           child: TextFormField(
//                             controller: addPropertiesController
//                                 .propertyVisionController,
//                             minLines: 5,
//                             keyboardType: TextInputType.multiline,
//                             maxLines: null,
//                             cursorColor: notifire.getwhiteblackcolor,
//                             autovalidateMode:
//                                 AutovalidateMode.onUserInteraction,
//                             decoration: InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(color: blueColor),
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               contentPadding: EdgeInsets.all(10),
//                               border: InputBorder.none,
//                               hintText:
//                                   "Describe your long-term goals and how you envision improving senior care"
//                                       .tr,
//                               hintStyle: TextStyle(
//                                 fontFamily: FontFamily.gilroyMedium,
//                                 fontSize: 15,
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: FontFamily.gilroyMedium,
//                               fontSize: 16,
//                               color: notifire.getwhiteblackcolor,
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please Enter Your Vision'.tr;
//                               }
//                               return null;
//                             },
//                           ),
//                           decoration: BoxDecoration(
//                             color: notifire.getblackwhitecolor,
//                             borderRadius: BorderRadius.circular(15),
//                             border: Border.all(color: notifire.getborderColor),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 8,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15, right: 15),
//                           child: Text(
//                             "Do you have a professional website for your home or facility? (If not, you can book our professional team to build you one or revamp your existing one)"
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
//                                     value: addPropertiesController.haveWebsite,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.haveWebsite = true;
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
//                                     value: !addPropertiesController.haveWebsite,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.haveWebsite =
//                                           false;
//
//                                       addPropertiesController.websiteIntention = 1;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 60,
//                                   child: Text(
//                                     "No, and I would like a full website build by your professional team",
//                                     style: TextStyle(
//                                       fontFamily: FontFamily.gilroyMedium,
//                                       fontSize: 17,
//                                       color: notifire.getwhiteblackcolor,
//                                     ),
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
//                                     value: !addPropertiesController.haveWebsite,
//                                     side: const BorderSide(
//                                         color: Color(0xffC5CAD4)),
//                                     activeColor: blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     onChanged: (_) {
//                                       addPropertiesController.haveWebsite =
//                                           false;
//
//                                       addPropertiesController.websiteIntention = 2;
//
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: Get.size.width - 60,
//                                   child: Text(
//                                     "No, I would like a revamp of my current website by your professional team",
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
//                         !addPropertiesController.haveWebsite
//                             ? SizedBox(
//                                 height: 25,
//                               )
//                             : SizedBox(
//                                 height: 15,
//                               ),
//                         !addPropertiesController.haveWebsite
//                             ? Padding(
//                                 padding: const EdgeInsets.only(left: 15),
//                                 child: Text(
//                                   "Book Our Website Development / Revamp Services".tr,
//                                   style: TextStyle(
//                                     fontFamily: FontFamily.gilroyBold,
//                                     fontSize: 17,
//                                     color: notifire.getwhiteblackcolor,
//                                   ),
//                                 ),
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.haveWebsite
//                             ? SizedBox(
//                                 height: 15,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.haveWebsite
//                             ? dateTextField(
//                                 type: "When are you available to discuss your website requirements in depth?",
//                                 labelText: "Select Date",
//                                 controller: addPropertiesController
//                                     .websiteCallDateController,
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
//                         !addPropertiesController.haveWebsite
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.haveWebsite
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
//                         !addPropertiesController.haveWebsite
//                             ? SizedBox(
//                                 height: 10,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.haveWebsite
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
//                                           addPropertiesController
//                                               .updateWebsiteTime(formattedTime);
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
//                                               addPropertiesController
//                                                           .websiteCalTime
//                                                           ?.isNotEmpty ==
//                                                       true
//                                                   ? addPropertiesController
//                                                       .websiteCalTime!
//                                                   : "Pick time".tr,
//                                               style: TextStyle(
//                                                 fontFamily:
//                                                     FontFamily.gilroyMedium,
//                                                 color: addPropertiesController
//                                                             .websiteCalTime
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
//                                               color: addPropertiesController
//                                                           .websiteCalTime
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
//                         !addPropertiesController.haveWebsite
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
//                         !addPropertiesController.haveWebsite
//                             ? SizedBox(
//                                 height: 8,
//                               )
//                             : const SizedBox(),
//                         !addPropertiesController.haveWebsite
//                             ? Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       SizedBox(width: 10),
//                                       Transform.scale(
//                                         scale: 1,
//                                         child: Checkbox(
//                                           value: addPropertiesController
//                                               .consentToWebsiteTerms,
//                                           side: const BorderSide(
//                                               color: Color(0xffC5CAD4)),
//                                           activeColor: blueColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(5),
//                                           ),
//                                           onChanged: (_) {
//                                             addPropertiesController
//                                                     .consentToWebsiteTerms =
//                                                 !addPropertiesController
//                                                     .consentToWebsiteTerms;
//
//                                             setState(() {});
//                                           },
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: Get.size.width - 60,
//                                         child: Text(
//                                           "I consent to GoToCareFinder's terms of service, including permission for your professional team to link or reference the website on the platform",
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
//                         textfield(
//                           type: "Your Website".tr,
//                           controller:
//                               addPropertiesController.propertyWebsiteController,
//                           labelText: "Your Website (Optional)".tr,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please Enter Your Website Link'.tr;
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Text(
//                             "Upload Your Logo".tr,
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
//                         DottedBorder(
//                           borderType: BorderType.RRect,
//                           color: Color(0xff3D5BF6),
//                           radius: Radius.circular(15),
//                           borderPadding: EdgeInsets.symmetric(horizontal: 20),
//                           child: InkWell(
//                             onTap: () {
//                               _openGallery(context);
//                             },
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: manegeRoute == "Add"
//                                   ? Container(
//                                       height: 80,
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 20),
//                                       width: Get.size.width,
//                                       alignment: Alignment.center,
//                                       child: addPropertiesController.logoPath ==
//                                               null
//                                           ? Image.asset(
//                                               "assets/images/image-upload.png",
//                                               height: 40,
//                                               width: 42,
//                                             )
//                                           : Image.file(
//                                               File(
//                                                 addPropertiesController.logoPath
//                                                     .toString(),
//                                               ),
//                                               height: 50,
//                                               width: 50,
//                                               fit: BoxFit.cover,
//                                             ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     )
//                                   : Container(
//                                       height: 80,
//                                       margin:
//                                           EdgeInsets.symmetric(horizontal: 20),
//                                       width: Get.size.width,
//                                       alignment: Alignment.center,
//                                       child: addPropertiesController.eLogo == ""
//                                           ? Image.asset(
//                                               "assets/images/image-upload.png",
//                                               height: 40,
//                                               width: 42,
//                                             )
//                                           : addPropertiesController.logoPath ==
//                                                   null
//                                               ? Image.network(
//                                                   "${Config.imageUrl}${addPropertiesController.eLogo}",
//                                                   height: 50,
//                                                   width: 50,
//                                                   fit: BoxFit.cover,
//                                                 )
//                                               : Image.file(
//                                                   File(
//                                                     addPropertiesController
//                                                         .logoPath
//                                                         .toString(),
//                                                   ),
//                                                   height: 50,
//                                                   width: 50,
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(15),
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         GestButton(
//                           Width: Get.size.width,
//                           height: 55,
//                           buttoncolor: blueColor,
//                           margin: EdgeInsets.only(top: 5, left: 35, right: 35),
//                           buttontext: "Next".tr,
//                           style: TextStyle(
//                             fontFamily: FontFamily.gilroyBold,
//                             color: WhiteColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           onclick: () {
//                             if (manegeRoute == "Add") {
//                               addPropertiesController.addPropertyApi();
//                             } else if (manegeRoute == "edit") {
//                               addPropertiesController.editPropertyApi();
//                             }
//                             /*if (_formKey.currentState?.validate() ??
//                                       false) {
//                                     if (selectCountry != null) {
//                                       if (selectProperty != null) {
//                                         if (addPropertiesController
//                                             .selectedIndexes.isNotEmpty) {
//                                           if (addPropertiesController.lat !=
//                                                   null &&
//                                               addPropertiesController.long !=
//                                                   null) {
//                                             if (addPropertiesController.path !=
//                                                     null ||
//                                                 addPropertiesController
//                                                         .pImage !=
//                                                     "") {
//                                               if (manegeRoute == "Add") {
//                                                 addPropertiesController
//                                                     .addPropertyApi();
//                                               } else if (manegeRoute ==
//                                                   "edit") {
//                                                 addPropertiesController
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
//                           },
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
//       addPropertiesController.logoPath = pickedFile.path;
//       addPropertiesController.eLogoUpdated = true;
//       setState(() {});
//       File imageFile = File(addPropertiesController.logoPath.toString());
//       List<int> imageBytes = imageFile.readAsBytesSync();
//       addPropertiesController.logoBase64Image = base64Encode(imageBytes);
//       print("!!!!!!!!!++++++++++++${addPropertiesController.logoBase64Image}");
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
