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

  ReviewlistController reviewlistController = Get.put(ReviewlistController());
  late ColorNotifire notifire;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
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
          "Review".tr,
          style: TextStyle(
            color: notifire.getwhiteblackcolor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 16,
          ),
        ),
      ),
      backgroundColor: notifire.getbgcolor,
      body: reviewlistController.isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: reviewlistController.reviewlistData!.reviewlist!.length,
          itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: notifire.getborderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(reviewlistController.reviewlistData!.reviewlist![index].rateText ?? "",
                          style: TextStyle(
                            color: notifire.getwhiteblackcolor,
                            fontFamily: FontFamily.gilroyRegular,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Container(
                        height: 30,
                        width: 60,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: blueColor,
                            width: 2,
                          ),
                          borderRadius:
                          BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: blueColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              reviewlistController.reviewlistData!.reviewlist![index].totalRate ?? "",
                              style: TextStyle(
                                fontFamily:
                                FontFamily.gilroyBold,
                                color: blueColor,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },),
      ),
    );
  }
}
