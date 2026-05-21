// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/model/fontfamily_model.dart';
import 'package:gotocarefinder/model/routes_helper.dart';
import 'package:gotocarefinder/utils/Colors.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';

/// Pre-login marketing/welcome screen.
///
/// Shown once the splash finishes for visitors who aren't remembered. It pitches
/// the value prop, lists three trust signals, and offers explicit CTAs to:
///   - sign up (routes through the role-select screen),
///   - sign in (login screen),
///   - or browse anonymously (existing logged-out behaviour on BottoBarScreen).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    final hero = _Hero(notifire: notifire);
    final content = _Content(notifire: notifire);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  Expanded(child: Center(child: hero)),
                  Container(
                    width: 1,
                    color: notifire.getborderColor,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: content,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.04),
                    SizedBox(
                      height: size.height * 0.32,
                      child: Center(child: hero),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: content,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final ColorNotifire notifire;
  const _Hero({required this.notifire});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Soft gradient backdrop behind the illustration.
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                blueColor.withValues(alpha: 0.18),
                blueColor.withValues(alpha: 0.0),
              ],
              radius: 0.7,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Image.asset(
            "assets/images/spleshimage.png",
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final ColorNotifire notifire;
  const _Content({required this.notifire});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/LogoMain.png", height: 56),
        const SizedBox(height: 24),
        Text(
          "Compassionate care,\nclose to home.".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 28,
            height: 1.2,
            color: notifire.getwhiteblackcolor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Discover trusted homecare agencies, adult family homes, and assisted living in one place — or list your own service and reach the families who need you.".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyMedium,
            fontSize: 14,
            height: 1.5,
            color: notifire.getgreycolor,
          ),
        ),
        const SizedBox(height: 24),

        // Trust signals
        _TrustRow(
          notifire: notifire,
          icon: Icons.verified_user_outlined,
          text: "Verified providers".tr,
        ),
        const SizedBox(height: 10),
        _TrustRow(
          notifire: notifire,
          icon: Icons.reviews_outlined,
          text: "Real reviews from real families".tr,
        ),
        const SizedBox(height: 10),
        _TrustRow(
          notifire: notifire,
          icon: Icons.location_on_outlined,
          text: "Local & nearby search".tr,
        ),
        const SizedBox(height: 32),

        // Primary CTA — Get started (routes through role-select)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Get.toNamed(Routes.signUpScreen),
            style: ElevatedButton.styleFrom(
              backgroundColor: blueColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "Get started".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary CTA — Sign in
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Get.toNamed(Routes.login),
            style: OutlinedButton.styleFrom(
              foregroundColor: notifire.getwhiteblackcolor,
              side: BorderSide(color: notifire.getborderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              "I already have an account".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tertiary — Continue without account
        Center(
          child: TextButton(
            onPressed: () => Get.offAllNamed(Routes.bottoBarScreen),
            style: TextButton.styleFrom(foregroundColor: notifire.getgreycolor),
            child: Text(
              "Browse as a guest".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustRow extends StatelessWidget {
  final ColorNotifire notifire;
  final IconData icon;
  final String text;

  const _TrustRow({
    required this.notifire,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 28,
          width: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: blueColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: blueColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 13,
              color: notifire.getwhiteblackcolor,
            ),
          ),
        ),
      ],
    );
  }
}
