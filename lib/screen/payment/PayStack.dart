// ignore_for_file: unused_element, prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, file_names, sort_child_properties_last

import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/utils/Colors.dart';

class PayStack extends StatefulWidget {
  final String? email;
  final String? totalAmount;
  final String? paystackId;

  const PayStack({this.email, this.totalAmount, this.paystackId});

  @override
  State<PayStack> createState() => _PayStackState();
}

class _PayStackState extends State<PayStack> {
  String publicKeyTest = 'pk_test_71d15313379591407f0bf9786e695c2616eece54';

  @override
  void initState() {
    super.initState();
  }

  String _getReference() {
    var platform = (Platform.isIOS) ? 'iOS' : 'Android';
    final thisDate = DateTime.now().millisecondsSinceEpoch;
    return 'ChargedFrom${platform}_$thisDate';
  }

  chargeCard() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            height: 50,
            width: Get.size.width,
            child: GestureDetector(
              onTap: () {
                chargeCard();
              },
              child: Container(
                height: 50,
                width: Get.size.width,
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text("Pay Now !!"),
                decoration: BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )),
      ),
    );
  }
}
