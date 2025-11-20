// ignore_for_file: prefer_const_constructors, prefer_if_null_operators, sort_child_properties_last, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/Api/data_store.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late ColorNotifire notifire;

  // --- Responsive helpers (local) ---
  double _maxBodyWidth(double w) => w >= 1200 ? 900 : (w >= 900 ? 760 : w);
  EdgeInsets _screenPadding(double w) {
    if (w >= 1200) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    if (w >= 900) return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    return const EdgeInsets.symmetric(horizontal: 10, vertical: 8);
  }

  int? _value = 0;

  // Keep this typed for safety
  final List<Map<String, dynamic>> locale = [
    {'name': 'ENGLISH', 'locale': const Locale('en', 'US')},
    {'name': 'عربى', 'locale': const Locale('ar', 'SA')},
    {'name': 'हिंदी', 'locale': const Locale('hi', 'IN')},
    {'name': 'Spanish', 'locale': const Locale('es', 'ES')},
    {'name': 'French', 'locale': const Locale('fr', 'FR')},
    {'name': 'German', 'locale': const Locale('de', 'DE')},
    {'name': 'Indonesian', 'locale': const Locale('id', 'ID')},
    {'name': 'Turkish', 'locale': const Locale('tr', 'TR')},
    {'name': 'Portuguese', 'locale': const Locale('pt', 'PT')},
  ];

  Future<void> _restoreTheme() async {
    final prefs = await SharedPreferences.getInstance();
    notifire.setIsDark = (prefs.getBool("setIsDark")) ?? false;
  }

  Future<void> _restoreSelectedLanguage() async {
    // default to stored value if present
    final stored = getData.read("lanValue");
    setState(() => _value = stored is int ? stored : 0);
  }

  @override
  void initState() {
    super.initState();
    _restoreTheme();
    _restoreSelectedLanguage();
  }

  void updateLanguage(Locale l) {
    Get.updateLocale(l);
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
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: Text(
          "Language".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        centerTitle: w < 900,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxBodyWidth(w)),
          child: Padding(
            padding: _screenPadding(w),
            child: Scrollbar(
              thumbVisibility: kIsWeb,
              child: ListView.builder(
                itemCount: locale.length + 1, // + header
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
                      child: Text(
                        "Suggested".tr,
                        style: TextStyle(
                          fontSize: 17,
                          color: notifire.getwhiteblackcolor,
                          fontFamily: FontFamily.gilroyBold,
                        ),
                      ),
                    );
                  }

                  final i = index - 1;
                  final item = locale[i];
                  final isSelected = _value == i;

                  return InkWell(
                    onTap: () async {
                      setState(() => _value = i);
                      save("lanValue", _value);
                      save("lCode", item['locale'].toString());
                      updateLanguage(item['locale'] as Locale);
                    },
                    child: _languageTile(
                      name: item['name'] as String?,
                      selected: isSelected,
                      value: i,
                      groupValue: _value,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageTile({
    required String? name,
    required bool selected,
    required int value,
    required int? groupValue,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.only(left: 15),
      height: 56,
      decoration: BoxDecoration(
        color: notifire.getblackwhitecolor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? blueColor : Colors.transparent,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name ?? "",
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 16,
                color: notifire.getwhiteblackcolor,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.0,
            child: Radio<int>(
              value: value,
              groupValue: groupValue,
              activeColor: blueColor,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}


// // ignore_for_file: prefer_const_constructors, prefer_if_null_operators, sort_child_properties_last, prefer_interpolation_to_compose_strings, avoid_print
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gotocarefinder/Api/data_store.dart';
// import 'package:gotocarefinder/model/fontfamily_model.dart';
// import 'package:gotocarefinder/utils/Colors.dart';
// import 'package:gotocarefinder/utils/Dark_lightmode.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LanguageScreen extends StatefulWidget {
//   const LanguageScreen({super.key});
//
//   @override
//   State<LanguageScreen> createState() => _LanguageScreenState();
// }
//
// class _LanguageScreenState extends State<LanguageScreen> {
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
//   int? _value = 0;
//   int currentIndex = 0;
//
//   final List locale = [
//     {'name': 'ENGLISH', 'locale': const Locale('en', 'US')},
//     {'name': 'عربى', 'locale': const Locale('ar', 'IN')},
//     {'name': 'हिंदी', 'locale': const Locale('hi', 'IN')},
//     {'name': 'Spanish', 'locale': const Locale('es', 'ES')},
//     {'name': 'France', 'locale': const Locale('fr', 'ES')},
//     {'name': 'Germany', 'locale': const Locale('de', 'ES')},
//     {'name': 'Indonesia', 'locale': const Locale('in', 'ES')},
//     {'name': 'South Africa', 'locale': const Locale('ZA', 'ES')},
//     {'name': 'Turkish', 'locale': const Locale('tr', 'ES')},
//     {'name': 'Portuguese', 'locale': const Locale('pt', 'ES')},
//   ];
//   updateLanguage(Locale locale) {
//     Get.back();
//     Get.updateLocale(locale);
//   }
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
//           "Language".tr,
//           style: TextStyle(
//             fontSize: 17,
//             fontFamily: FontFamily.gilroyBold,
//             color: notifire.getwhiteblackcolor,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 15, top: 10),
//                 child: Text(
//                   "Suggested".tr,
//                   style: TextStyle(
//                     fontSize: 17,
//                     color: notifire.getwhiteblackcolor,
//                     fontFamily: FontFamily.gilroyBold,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: locale.length,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     return InkWell(
//                       onTap: () {
//                         setState(() {
//                           _value = index;
//                           save("lanValue", _value);
//                           updateLanguage(locale[index]['locale']);
//                           save("lCode", locale[index]['locale'].toString());
//                         });
//                       },
//                       child: languageWidget(
//                         name: locale[index]['name'],
//                         value: index,
//                         radio: Radio(
//                           value: index,
//                           groupValue: getData.read("lanValue") != null
//                               ? getData.read("lanValue")
//                               : _value,
//                           hoverColor: blueColor,
//                           onChanged: (value4) {
//                             setState(() {});
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget languageWidget(
//       {String? name, int? value, void Function(int?)? onChanged, radio}) {
//     return Container(
//       margin: EdgeInsets.all(10),
//       alignment: Alignment.center,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 15),
//         child: Row(
//           children: [
//             Text(
//               name ?? "",
//               style: TextStyle(
//                 fontFamily: FontFamily.gilroyMedium,
//                 fontSize: 16,
//                 color: notifire.getwhiteblackcolor,
//               ),
//             ),
//             Spacer(),
//             radio,
//             SizedBox(
//               width: 10,
//             ),
//           ],
//         ),
//       ),
//       decoration: BoxDecoration(
//         color: notifire.getblackwhitecolor,
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
// }
