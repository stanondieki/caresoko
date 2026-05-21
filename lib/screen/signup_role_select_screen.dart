// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/signup_controller.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';

/// Lets the user pick their role before filling the signup form.
/// Sets `SignUpController.userType` and routes to the matching signup screen.
class SignUpRoleSelectScreen extends StatelessWidget {
  const SignUpRoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    final SignUpController signUpController = Get.find();

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(18.0),
          child: InkWell(
            onTap: () => Get.back(),
            child: Image.asset(
              'assets/images/back.png',
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "How will you use Caresoko?".tr,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: FontFamily.gilroyBold,
                  color: notifire.getwhiteblackcolor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose the role that best describes you. You can have only one role per account.".tr,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  color: notifire.getgreycolor,
                ),
              ),
              const SizedBox(height: 28),
              _RoleCard(
                notifire: notifire,
                icon: Icons.favorite_border,
                title: "I need care".tr,
                subtitle: "Find trusted providers for yourself or a loved one.".tr,
                onTap: () {
                  signUpController.setUserType("recipient");
                  Get.toNamed(Routes.signUpRecipientScreen);
                },
              ),
              const SizedBox(height: 16),
              _RoleCard(
                notifire: notifire,
                icon: Icons.medical_services_outlined,
                title: "I provide care".tr,
                subtitle: "List your services and connect with families that need help.".tr,
                onTap: () {
                  signUpController.setUserType("provider");
                  Get.toNamed(Routes.signUpProviderScreen);
                },
              ),
              const SizedBox(height: 28),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: notifire.getgreycolor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => Get.toNamed(Routes.login),
                      child: Text(
                        "Login".tr,
                        style: TextStyle(
                          color: blueColor,
                          fontFamily: FontFamily.gilroyBold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final ColorNotifire notifire;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.notifire,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: notifire.getboxcolor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: notifire.getborderColor),
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: blueColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: blueColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      fontSize: 16,
                      color: notifire.getwhiteblackcolor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 12,
                      color: notifire.getgreycolor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: notifire.getgreycolor),
          ],
        ),
      ),
    );
  }
}
