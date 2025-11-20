import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/controller/reviewlist_controller.dart';
import 'package:provider/provider.dart';

import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../../utils/Dark_lightmode.dart';

class ReviewlistScreen extends StatefulWidget {
  const ReviewlistScreen({super.key});

  @override
  State<ReviewlistScreen> createState() => _ReviewlistScreenState();
}

class _ReviewlistScreenState extends State<ReviewlistScreen> {
  final ReviewlistController reviewlistController = Get.put(ReviewlistController());
  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: notifire.getwhiteblackcolor),
        ),
        title: LayoutBuilder(
          builder: (context, c) {
            final isWide = MediaQuery.of(context).size.width >= 900;
            return Text(
              "Review".tr,
              style: TextStyle(
                color: notifire.getwhiteblackcolor,
                fontFamily: FontFamily.gilroyBold,
                fontSize: isWide ? 18 : 16,
              ),
            );
          },
        ),
      ),
      body: reviewlistController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWidePage = width >= 900;
          final crossAxisCount = width >= 1200 ? 3 : (width >= 720 ? 2 : 1);
          final horizPad = isWidePage ? 24.0 : 16.0;

          final items = reviewlistController.reviewlistData?.reviewlist ?? [];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "No reviews yet".tr,
                  style: TextStyle(
                    color: notifire.getwhiteblackcolor,
                    fontFamily: FontFamily.gilroyMedium,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          // Center the content on very wide screens
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizPad, vertical: 8),
                child: Scrollbar(
                  thumbVisibility: isWidePage,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final review = items[index];
                              return _ReviewCard(
                                notifire: notifire,
                                text: review.rateText ?? "",
                                rating: review.totalRate ?? "",
                              );
                            },
                            childCount: items.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            // Card is row-like; make it wider than tall
                            childAspectRatio: crossAxisCount == 1 ? 3.8 : 3.6,
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
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.notifire,
    required this.text,
    required this.rating,
  });

  final ColorNotifire notifire;
  final String text;
  final String rating;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isTight = w < 360;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: notifire.getborderColor, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Review text
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: notifire.getwhiteblackcolor,
                fontFamily: FontFamily.gilroyRegular,
                fontSize: isTight ? 14 : 16,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 12),
          // Rating pill
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 68, maxWidth: 88, minHeight: 34),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: blueColor, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: blueColor, size: isTight ? 18 : 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      rating,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        color: blueColor,
                        fontSize: isTight ? 14 : 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
