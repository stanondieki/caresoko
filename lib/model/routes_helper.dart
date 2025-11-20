// ignore_for_file: prefer_const_constructors

import 'package:get/route_manager.dart';
import 'package:gotocarefinder/screen/add%20proparty/listofproparty_screen.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/listofagencies_screen.dart';
import 'package:gotocarefinder/screen/add%20property/addextraimage_screen.dart';
import 'package:gotocarefinder/screen/add%20property/addgallerycategory_screen.dart';
import 'package:gotocarefinder/screen/add%20property/addgalleryimage_screen.dart';
import 'package:gotocarefinder/screen/add%20property/booking_screen.dart';
import 'package:gotocarefinder/screen/add%20property/e-receiptpro_screen.dart';
import 'package:gotocarefinder/screen/add%20property/enquiry_screen.dart';
import 'package:gotocarefinder/screen/add%20property/extraimage_screen.dart';
import 'package:gotocarefinder/screen/add%20property/gallerycategory_screen.dart';
import 'package:gotocarefinder/screen/add%20property/galleryimage_screen.dart';
import 'package:gotocarefinder/screen/add%20property/listofproperty_screen.dart';
import 'package:gotocarefinder/screen/add%20property/membarship_screen.dart';
import 'package:gotocarefinder/screen/add%20property/membarshipdetails_screen.dart';
import 'package:gotocarefinder/screen/add%20property/myearnings_screen.dart';
import 'package:gotocarefinder/screen/add%20property/mypayout_screen.dart';
import 'package:gotocarefinder/screen/add%20property/reviewlistscreen.dart';
import 'package:gotocarefinder/screen/add%20property/subscribe_screen.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen1.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen2.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen3.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen4.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen5.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen6.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen7.dart';
import 'package:gotocarefinder/screen/add%20property/addproperty_screen8.dart';
import 'package:gotocarefinder/screen/add%20proparty/addproperty_screen.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen1.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen2.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen3.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen4.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen5.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen6.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen7.dart';
import 'package:gotocarefinder/screen/add%20property/add_homecare/add_homecare_screen8.dart';
import 'package:gotocarefinder/screen/addwallet/addwallet_screen.dart';
import 'package:gotocarefinder/screen/addwallet/referfriend_screen.dart';
import 'package:gotocarefinder/screen/addwallet/wallet_screen.dart';
import 'package:gotocarefinder/screen/bookinformation_screen.dart';
import 'package:gotocarefinder/screen/bookrealestate_screen.dart';
import 'package:gotocarefinder/screen/bottombar_screen.dart';
import 'package:gotocarefinder/screen/contract_agreement.dart';
import 'package:gotocarefinder/screen/coupons_screen.dart';
import 'package:gotocarefinder/screen/e-receipt_screen.dart';
import 'package:gotocarefinder/screen/faq_screen.dart';
import 'package:gotocarefinder/screen/featured_screen.dart';
import 'package:gotocarefinder/screen/gallery_screen.dart';
import 'package:gotocarefinder/screen/home_profile.dart';
import 'package:gotocarefinder/screen/homesearch_screen.dart';
import 'package:gotocarefinder/screen/image360Viewer/image_viewer.dart';
import 'package:gotocarefinder/screen/language_screen.dart';
import 'package:gotocarefinder/screen/login_screen.dart';
import 'package:gotocarefinder/screen/loream_screen.dart';
import 'package:gotocarefinder/screen/message_screen.dart';
import 'package:gotocarefinder/screen/mybooking_screen.dart';
import 'package:gotocarefinder/screen/notification_screen.dart';
import 'package:gotocarefinder/screen/onbording_screen.dart';
import 'package:gotocarefinder/screen/otp_screen.dart';
import 'package:gotocarefinder/screen/our_recommendation_screen.dart';
import 'package:gotocarefinder/screen/profile_screen.dart';
import 'package:gotocarefinder/screen/proparty/view_proparty_screen.dart';
import 'package:gotocarefinder/screen/resetpassword_screen.dart';
import 'package:gotocarefinder/screen/review_screen.dart';
import 'package:gotocarefinder/screen/review_summary.dart';
import 'package:gotocarefinder/screen/select_country.dart';
import 'package:gotocarefinder/screen/signup_screen.dart';
import 'package:gotocarefinder/screen/splesh_screen.dart';
import 'package:gotocarefinder/screen/view_homecare_data_screen.dart';
import 'package:gotocarefinder/screen/viewdata_screen.dart';
import 'package:gotocarefinder/screen/viewprofile_screen.dart';

class Routes {
  static String initial = "/";
  static String onBordingScreen = '/OnBordingScreen';
  static String login = "/Login";
  static String bottoBarScreen = "/BottoBarScreen";
  static String contractScreen = "/contractScreen";
  static String signUpScreen = "/signUpScreen";
  static String otpScreen = '/otpScreen';
  static String resetPassword = "/resetPassword";
  static String viewDataScreen = "/viewDataScreen";
  static String viewHomecareDataScreen = "/viewHomecareDataScreen";
  static String viewPropartyScreen = "/viewPropartyScreen";
  static String massageScreen = "/massageScren";
  static String profileScreen = "/profileScreen";
  static String galleryScreen = "/galleyScreen";
  static String reviewScreen = "/reviewScreen";
  static String ourRecommendationScreen = "/ourRecommendationScreen";
  static String notificationScreen = "/notificationScreen";
  static String homeSearchScreen = "/homeSearchScreen";
  static String mybookingScreen = "/mybookingScreen";
  static String languageScreen = "/languageScreen";
  static String viewProfileScreen = "/viewProfileScreen";
  static String bookRealEstate = "/bookRealEstate";
  static String bookInformetionScreen = "/bookInformetionScreen";
  static String reviewSummaryScreen = "/reviewSummaryScreen";
  static String couponsScreen = "/couponsScreen";
  static String eReceiptScreen = "/eReceiptScreen";
  static String loreamScreen = "/loreamScreen";
  static String faqScreen = "/faqScreen";
  static String walletScreen = "/walletScreen";
  static String addWalletScreen = "/addWalletScreen";
  static String referFriendScreen = "/referFriendScreen";
  static String featuredScreen = "/featuredScreen";
  static String membershipScreen = "/membershipScreen";
  static String selectCountryScreen = "/selectCountryScreen";
  static String listOfPropertyScreen = "/listOfPropertyScreen";
  static String listOfAgenciesScreen = "/listOfAgenciesScreen";
  static String listOfPropartyScreen = "/listOfPropartyScreen";
  static String addPropertyScreen1 = "/addPropertyScreen1";
  static String addPropertyScreen2 = "/addPropertyScreen2";
  static String addPropertyScreen3 = "/addPropertyScreen3";
  static String addPropertyScreen4 = "/addPropertyScreen4";
  static String addPropertyScreen5 = "/addPropertyScreen5";
  static String addPropertyScreen6 = "/addPropertyScreen6";
  static String addPropertyScreen7 = "/addPropertyScreen7";
  static String addPropertyScreen8 = "/addPropertyScreen8";
  static String addHomecareScreen1 = "/addHomecareScreen1";
  static String addHomecareScreen2 = "/addHomecareScreen2";
  static String addHomecareScreen3 = "/addHomecareScreen3";
  static String addHomecareScreen4 = "/addHomecareScreen4";
  static String addHomecareScreen5 = "/addHomecareScreen5";
  static String addHomecareScreen6 = "/addHomecareScreen6";
  static String addHomecareScreen7 = "/addHomecareScreen7";
  static String addHomecareScreen8 = "/addHomecareScreen8";
  static String addPropertyScreen = "/addPropertyScreen";
  static String homeProfileScreen = "/homeProfileScreen";
  static String extraImageScreen = "/extraImageScreen";
  static String addExtraImageScreen = "/addExtraImageScreen";
  static String galleryCategoryScreen = "/galleryCategoryScreen";
  static String addGalleryCategoryScreen = "/addGalleryCategoryScrren";
  static String galleryImageScreen = "/galleryImageScreen";
  static String addGalleryImageScreen = "/addGalleryImageScreen";
  static String subscribeScreen = "/subscribeScreen";
  static String bookingScreen = "/bookingScreen";
  static String memberShipDetails = "/memberShipDetails";
  static String myEarningsScreen = "/myEarningsScreen";
  static String eReceiptProScreen = "/eReceiptProScreen";
  static String myPayoutScreen = "/myPayoutScreen";
  static String enquiryScreen = "/enquiryScreen";
  static String reviewlistScreen = "/reviewlistScreen";
  static String imageViewerSreen = "/ImageViewerSreen";
}

final getPages = [
  GetPage(
    name: Routes.initial,
    page: () => SpleshScreen(),
  ),
  GetPage(
    name: Routes.onBordingScreen,
    page: () => OnBordingScreen(),
  ),
  GetPage(
    name: Routes.login,
    page: () => LoginScreen(),
  ),
  GetPage(
    name: Routes.bottoBarScreen,
    page: () => BottoBarScreen(),
  ),
  GetPage(
    name: Routes.contractScreen,
    page: () => ContractAgreement(),
  ),
  GetPage(
    name: Routes.signUpScreen,
    page: () => SignUpScreen(),
  ),
  GetPage(
    name: Routes.otpScreen,
    page: () => OtpScreen(),
  ),
  GetPage(
    name: Routes.resetPassword,
    page: () => ResetPasswordScreen(),
  ),
  GetPage(
    name: Routes.viewDataScreen,
    page: () => ViewDataScreen(),
  ),
  GetPage(
    name: Routes.viewHomecareDataScreen,
    page: () => ViewHomecareDataScreen(),
  ),
  GetPage(
    name: Routes.viewPropartyScreen,
    page: () => ViewPropartyScreen(),
  ),
  GetPage(
    name: Routes.massageScreen,
    page: () => MassageScreen(),
  ),
  GetPage(
    name: Routes.profileScreen,
    page: () => ProfileScreen(),
  ),
  GetPage(
    name: Routes.galleryScreen,
    page: () => GalleryScreen(),
  ),
  GetPage(
    name: Routes.reviewScreen,
    page: () => ReviewScreen(),
  ),
  GetPage(
    name: Routes.ourRecommendationScreen,
    page: () => OurRecommendationScreen(),
  ),
  GetPage(
    name: Routes.notificationScreen,
    page: () => NotificationScreen(),
  ),
  GetPage(
    name: Routes.homeSearchScreen,
    page: () => HomeSearchScreen(),
  ),
  GetPage(
    name: Routes.mybookingScreen,
    page: () => MyBookingScreen(),
  ),
  GetPage(
    name: Routes.languageScreen,
    page: () => LanguageScreen(),
  ),
  GetPage(
    name: Routes.viewProfileScreen,
    page: () => ViewProfileScreen(),
  ),
  GetPage(
    name: Routes.bookRealEstate,
    page: () => BookRealEstate(),
  ),
  GetPage(
    name: Routes.bookInformetionScreen,
    page: () => BookInformetionScreen(),
  ),
  GetPage(
    name: Routes.reviewSummaryScreen,
    page: () => ReviewSummaryScreen(),
  ),
  GetPage(
    name: Routes.couponsScreen,
    page: () => CouponsScreen(),
  ),
  GetPage(
    name: Routes.eReceiptScreen,
    page: () => EReceiptScreen(),
  ),
  GetPage(
    name: Routes.loreamScreen,
    page: () => Loream(),
  ),
  GetPage(
    name: Routes.faqScreen,
    page: () => FaqScreen(),
  ),
  GetPage(
    name: Routes.walletScreen,
    page: () => WalletScreen(),
  ),
  GetPage(
    name: Routes.addWalletScreen,
    page: () => AddWalletScreen(),
  ),
  GetPage(
    name: Routes.referFriendScreen,
    page: () => ReferFriendScreen(),
  ),
  GetPage(
    name: Routes.featuredScreen,
    page: () => FeaturedScreen(),
  ),
  GetPage(
    name: Routes.membershipScreen,
    page: () => MembershipScreen(),
  ),
  GetPage(
    name: Routes.selectCountryScreen,
    page: () => SelectCountryScreen(),
  ),
  GetPage(
    name: Routes.listOfPropertyScreen,
    page: () => ListOfPropertyScreen(),
  ),
  GetPage(
    name: Routes.listOfAgenciesScreen,
    page: () => ListOfAgenciesScreen(),
  ),
  GetPage(
    name: Routes.listOfPropartyScreen,
    page: () => ListOfPropartyScreen(),
  ),
  GetPage(
    name: Routes.addPropertyScreen1,
    page: () => AddPropertyScreen1(),
  ),
  GetPage(
    name: Routes.addPropertyScreen2,
    page: () => AddPropertyScreen2(),
  ),
  GetPage(
    name: Routes.addPropertyScreen3,
    page: () => AddPropertyScreen3(),
  ),
  GetPage(
    name: Routes.addPropertyScreen4,
    page: () => AddPropertyScreen4(),
  ),
  GetPage(
    name: Routes.addPropertyScreen5,
    page: () => AddPropertyScreen5(),
  ),
  GetPage(
    name: Routes.addPropertyScreen6,
    page: () => AddPropertyScreen6(),
  ),
  GetPage(
    name: Routes.addPropertyScreen7,
    page: () => AddPropertyScreen7(),
  ),
  GetPage(
    name: Routes.addPropertyScreen8,
    page: () => AddPropertyScreen8(),
  ),
  GetPage(
    name: Routes.addHomecareScreen1,
    page: () => AddHomeCareScreen1(),
  ),
  GetPage(
    name: Routes.addHomecareScreen2,
    page: () => AddHomeCareScreen2(),
  ),
  GetPage(
    name: Routes.addHomecareScreen3,
    page: () => AddHomeCareScreen3(),
  ),
  GetPage(
    name: Routes.addHomecareScreen4,
    page: () => AddHomeCareScreen4(),
  ),
  GetPage(
    name: Routes.addHomecareScreen5,
    page: () => AddHomeCareScreen5(),
  ),
  GetPage(
    name: Routes.addHomecareScreen6,
    page: () => AddHomeCareScreen6(),
  ),
  GetPage(
    name: Routes.addHomecareScreen7,
    page: () => AddHomeCareScreen7(),
  ),
  GetPage(
    name: Routes.addHomecareScreen8,
    page: () => AddHomeCareScreen8(),
  ),
  GetPage(
    name: Routes.addPropertyScreen,
    page: () => AddPropertyScreen(),
  ),
  GetPage(
    name: Routes.homeProfileScreen,
    page: () => HomeProfileScreen(),
  ),
  GetPage(
    name: Routes.extraImageScreen,
    page: () => ExtraImageScreen(),
  ),
  GetPage(
    name: Routes.addExtraImageScreen,
    page: () => AddExtraImageScreen(),
  ),
  GetPage(
    name: Routes.galleryCategoryScreen,
    page: () => GalleryCategoryScreen(),
  ),
  GetPage(
    name: Routes.addGalleryCategoryScreen,
    page: () => AddGalleryCategoryScreen(),
  ),
  GetPage(
    name: Routes.galleryImageScreen,
    page: () => GallertImageScreen(),
  ),
  GetPage(
    name: Routes.addGalleryImageScreen,
    page: () => AddGalleryImageScreen(),
  ),
  GetPage(
    name: Routes.subscribeScreen,
    page: () => SubscribeScreen(),
  ),
  GetPage(
    name: Routes.bookingScreen,
    page: () => BookingScreen(),
  ),
  GetPage(
    name: Routes.memberShipDetails,
    page: () => MemberShipDetails(),
  ),
  GetPage(
    name: Routes.myEarningsScreen,
    page: () => MyEarningsScreen(),
  ),
  GetPage(
    name: Routes.eReceiptProScreen,
    page: () => EReceiptProScreen(),
  ),
  GetPage(
    name: Routes.myPayoutScreen,
    page: () => MyPayoutScreen(),
  ),
  GetPage(
    name: Routes.enquiryScreen,
    page: () => EnquiryScreen(),
  ),
  GetPage(
    name: Routes.reviewlistScreen,
    page: () => ReviewlistScreen(),
  ),
  GetPage(
    name: Routes.imageViewerSreen,
    page: () => ImageViewerSreen(),
  ),
];
