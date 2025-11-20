// ignore_for_file: avoid_print, unused_local_variable, prefer_typing_uninitialized_variables, must_be_immutable, prefer_const_constructors_in_immutables, unnecessary_null_comparison, prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loream extends StatefulWidget {
  Loream({super.key});
  @override
  State<Loream> createState() => _LoreamState();
}

class _LoreamState extends State<Loream> {
  late ColorNotifire notifire;

  String title = Get.arguments["title"];
  String discription = Get.arguments["discription"];
  @override
  void initState() {
    super.initState();
    getdarkmodepreviousstate();
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Gilroy Medium',
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Get.height / 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.size.width / 20),
                child: Column(children: [
                  (discription != null && discription.isNotEmpty)
                      ? HtmlWidget(
                          discription,
                          textStyle: TextStyle(
                              color: notifire.getdarkscolor,
                              fontSize: Get.height / 50,
                              fontFamily: 'Gilroy Normal'),
                        )
                      : Text(
                          "",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: Get.height / 50,
                              fontFamily: 'Gilroy Normal'),
                        ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
