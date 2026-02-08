# Caresoko (GotoCareFinder) - Complete Documentation

## Overview

**Caresoko** (package name: `gotocarefinder`) is a Flutter-based healthcare booking and property rental platform. It connects users with homecare services, properties, and healthcare facilities with full booking, payment, and wallet functionality.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      Flutter Frontend                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │ Mobile App  │  │   Web App   │  │    Desktop Apps         │  │
│  │ Android/iOS │  │   Chrome    │  │ Windows/macOS/Linux     │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬─────────────┘  │
└─────────┼────────────────┼─────────────────────┼────────────────┘
          │                │                     │
          └────────────────┼─────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              Backend API (PHP)                                   │
│         https://careinafh.caresoko.com/user_api/                │
└─────────────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          ▼                ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  Stripe  │    │ PayStack │    │  PayPal  │
    └──────────┘    └──────────┘    └──────────┘
          │                │                │
          ▼                ▼                ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │ Razorpay │    │Google Map│    │ OneSignal│
    └──────────┘    └──────────┘    └──────────┘
```

---

## Tech Stack

| Layer              | Technology                          |
|--------------------|-------------------------------------|
| **Frontend**       | Flutter 3.6.2+ (Dart)               |
| **State Mgmt**     | GetX + Provider                     |
| **Local Storage**  | GetStorage + SharedPreferences      |
| **Backend API**    | PHP (REST endpoints)                |
| **Payments**       | Stripe, PayStack, PayPal, Razorpay  |
| **Maps**           | Google Maps Flutter                 |
| **Push Notifs**    | OneSignal (mobile only)             |
| **SMS/OTP**        | Twilio                              |

---

## Project Structure

```
caresoko/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── Api/
│   │   └── config.dart           # API base URL & endpoint definitions
│   ├── controller/               # GetX controllers (31 files)
│   ├── model/                    # Data models (24 files)
│   ├── screen/                   # UI screens (35+ files)
│   ├── firebase/                 # Auth & chat services
│   ├── push/                     # Push notification service
│   ├── utils/                    # Theme, localization
│   └── helpar/
│       └── get_di.dart           # Dependency injection
├── android/                      # Android platform config
├── ios/                          # iOS platform config
├── web/                          # Web platform config
├── windows/                      # Windows desktop config
├── macos/                        # macOS desktop config
├── linux/                        # Linux desktop config
├── assets/images/                # App images
└── fonts/                        # Gilroy font family
```

---

## API Configuration

### Base URLs

```
Production: https://careinafh.caresoko.com/
API Path:   https://careinafh.caresoko.com/user_api/
```

### External Service Keys

| Service       | Config Variable | Notes                    |
|---------------|-----------------|--------------------------|
| OneSignal     | `oneSignel`     | Push notifications       |
| Google Maps   | `googleKey`     | Maps API key             |
| Firebase      | `projectID`     | Project: studio-67236    |
| Stripe        | Environment var | Set via --dart-define    |

---

## Complete API Endpoints List

**Base URL:** `https://careinafh.caresoko.com/user_api/`

### Authentication & User Management (11 endpoints)

| # | Endpoint                | Description                    | Config Variable    |
|---|-------------------------|--------------------------------|--------------------|
| 1 | `u_reg_user.php`        | User registration              | `registerUser`     |
| 2 | `u_login_user.php`      | User login                     | `loginApi`         |
| 3 | `mobile_check.php`      | Mobile number verification     | `mobileChack`      |
| 4 | `u_forget_password.php` | Password reset                 | `forgetPassword`   |
| 5 | `pro_image.php`         | Update profile picture         | `updateProfilePic` |
| 6 | `u_profile_edit.php`    | Edit user profile              | `editProfileApi`   |
| 7 | `u_getdata.php`         | Get referral data              | `referDataGetApi`  |
| 8 | `acc_delete.php`        | Delete account                 | `deletAccount`     |
| 9 | `msg_otp.php`           | SMS OTP                        | `msgotp`           |
| 10| `twilio_otp.php`        | Twilio OTP                     | `twillotp`         |
| 11| `sms_type.php`          | SMS type configuration         | `smstype`          |

---

### Home & Dashboard (4 endpoints)

| # | Endpoint                  | Description                    | Config Variable       |
|---|---------------------------|--------------------------------|-----------------------|
| 1 | `u_home_data.php`         | Home page data                 | `homeDataApi`         |
| 2 | `u_proparty_home_data.php`| Property home page data        | `propartyHomeDataApi` |
| 3 | `u_dashboard.php`         | User dashboard                 | `dashboardApi`        |
| 4 | `u_country.php`           | Get all countries              | `allCountry`          |

---

### Property Management (14 endpoints)

| # | Endpoint                       | Description                    | Config Variable         |
|---|--------------------------------|--------------------------------|-------------------------|
| 1 | `u_property_details.php`       | Get property details           | `propertyDetails`       |
| 2 | `u_proparty_details.php`       | Get proparty details           | `propartyDetails`       |
| 3 | `u_search_property.php`        | Search properties              | `searchApi`             |
| 4 | `u_cat_wise_property.php`      | Properties by category         | `catWiseData`           |
| 5 | `u_proparty_cat_wise_property.php`| Proparty by category        | `propartyCatWiseData`   |
| 6 | `u_property_list.php`          | List all properties            | `propertyList`          |
| 7 | `u_proparty_list.php`          | List all proparties            | `propartyList`          |
| 8 | `u_property_add.php`           | Add new property               | `addPropertyApi`        |
| 9 | `u_property_edit.php`          | Edit property                  | `editPropertyApi`       |
| 10| `u_proparty_add.php`           | Add new proparty               | `addPropartyApi`        |
| 11| `u_proparty_edit.php`          | Edit proparty                  | `editPropartyApi`       |
| 12| `u_proparty_details_edit.php`  | Edit proparty details          | `propartyDetailsEditApi`|
| 13| `u_property_type.php`          | Get property types             | `propertyType`          |
| 14| `u_proparty_type.php`          | Get proparty types             | `propartyType`          |

---

### Homecare/Agency Management (5 endpoints)

| # | Endpoint                | Description                    | Config Variable    |
|---|-------------------------|--------------------------------|--------------------|
| 1 | `u_homecare_details.php`| Get homecare details           | `homecareDetails`  |
| 2 | `u_homecare_list.php`   | List homecare agencies         | `agencyList`       |
| 3 | `u_homecare_add.php`    | Add homecare agency            | `addHomecareApi`   |
| 4 | `u_homecare_edit.php`   | Edit homecare agency           | `editAgencyApi`    |
| 5 | `u_homecare_book.php`   | Book homecare service          | `homecareBookApi`  |

---

### Booking Management (13 endpoints)

| # | Endpoint                | Description                    | Config Variable      |
|---|-------------------------|--------------------------------|----------------------|
| 1 | `u_book.php`            | Create booking                 | `bookApi`            |
| 2 | `u_proparty_book.php`   | Book proparty                  | `propartyBookApi`    |
| 3 | `u_book_status_wise.php`| Get bookings by status         | `statusWiseBook`     |
| 4 | `u_book_cancle.php`     | Cancel booking                 | `bookingCancle`      |
| 5 | `u_book_details.php`    | Get booking details            | `bookingDetails`     |
| 6 | `u_my_book.php`         | Get my bookings                | `proBookStatusWise`  |
| 7 | `my_book_details.php`   | My booking details             | `proBookingDetails`  |
| 8 | `u_my_book_cancle.php`  | Cancel my booking              | `proBookingCancle`   |
| 9 | `u_confim.php`          | Confirm booking                | `confirmedBooking`   |
| 10| `u_check_in.php`        | Check-in                       | `proCheckIN`         |
| 11| `u_check_out.php`       | Check-out                      | `proCheckOutConfirmed`|
| 12| `u_check.php`           | Check date availability        | `checDateApi`        |
| 13| `calendar.php`          | Calendar data                  | `calendar`           |

---

### Favorites & Reviews (4 endpoints)

| # | Endpoint                | Description                    | Config Variable        |
|---|-------------------------|--------------------------------|------------------------|
| 1 | `u_fav.php`             | Add/Remove favorite            | `addAndRemoveFavourite`|
| 2 | `u_favlist.php`         | Get favorites list             | `favouriteList`        |
| 3 | `u_rate_update.php`     | Submit review/rating           | `reviewApi`            |
| 4 | `review_list.php`       | Get reviews list               | `reviewlist`           |

---

### Payment & Wallet (7 endpoints)

| # | Endpoint                | Description                    | Config Variable      |
|---|-------------------------|--------------------------------|----------------------|
| 1 | `u_paymentgateway.php`  | Get payment gateway config     | `paymentgatewayApi`  |
| 2 | `paystack/index.php`    | PayStack payment               | `paystackpayment`    |
| 3 | `u_wallet_report.php`   | Wallet transaction report      | `walletReportApi`    |
| 4 | `u_wallet_up.php`       | Update wallet balance          | `walletUpdateApi`    |
| 5 | `request_withdraw.php`  | Request withdrawal             | `requestWithdraw`    |
| 6 | `payout_list.php`       | Get payout history             | `payOutList`         |
| 7 | `u_sale_prop.php`       | Property sale transaction      | `makeSellProperty`   |

---

### Subscription & Packages (3 endpoints)

| # | Endpoint                | Description                    | Config Variable    |
|---|-------------------------|--------------------------------|--------------------|
| 1 | `u_package.php`         | Get subscription packages      | `subScribeList`    |
| 2 | `u_package_purchase.php`| Purchase package               | `packagePurchase`  |
| 3 | `u_sub_details.php`     | Subscription details           | `subScribeDetails` |

---

### Gallery Management (9 endpoints)

| # | Endpoint                  | Description                    | Config Variable      |
|---|---------------------------|--------------------------------|----------------------|
| 1 | `view_gallery.php`        | View all gallery images        | `seeAllGalery`       |
| 2 | `u_gallery_cat_list.php`  | Gallery categories list        | `galleryCatList`     |
| 3 | `u_gal_cat_add.php`       | Add gallery category           | `addGalleryCat`      |
| 4 | `u_gal_cat_edit.php`      | Edit gallery category          | `upDateGalleryCat`   |
| 5 | `gallery_list.php`        | Get gallery list               | `galleryList`        |
| 6 | `add_gallery.php`         | Add gallery image              | `addGallery`         |
| 7 | `update_gallery.php`      | Update gallery image           | `editGallery`        |
| 8 | `property_wise_galcat.php`| Gallery by property            | `proWiseGalleryCat`  |
| 9 | `u_extra_list.php`        | Extra images list              | `extraImageList`     |

---

### Extra Images (2 endpoints)

| # | Endpoint                | Description                    | Config Variable    |
|---|-------------------------|--------------------------------|--------------------|
| 1 | `u_add_exra.php`        | Add extra image                | `addExtraImage`    |
| 2 | `u_extra_edit.php`      | Edit extra image               | `editExtraImage`   |

---

### Facilities (2 endpoints)

| # | Endpoint                  | Description                    | Config Variable        |
|---|---------------------------|--------------------------------|------------------------|
| 1 | `u_facility.php`          | Get facilities list            | `facilityList`         |
| 2 | `u_proparty_facility.php` | Get proparty facilities        | `propartyFacilityList` |

---

### Other Endpoints (5 endpoints)

| # | Endpoint                | Description                    | Config Variable    |
|---|-------------------------|--------------------------------|--------------------|
| 1 | `u_couponlist.php`      | Get coupons list               | `couponlist`       |
| 2 | `u_check_coupon.php`    | Validate coupon code           | `couponCheck`      |
| 3 | `u_pagelist.php`        | Get page list (CMS)            | `pageListApi`      |
| 4 | `u_faq.php`             | Get FAQ list                   | `faqApi`           |
| 5 | `notification.php`      | Get notifications              | `notification`     |
| 6 | `u_enquiry.php`         | Submit enquiry                 | `enquiry`          |
| 7 | `u_my_enquiry.php`      | Get my enquiries               | `enquiryListApi`   |

---

## Total: 79 API Endpoints

| Category                 | Count |
|--------------------------|-------|
| Authentication & User    | 11    |
| Home & Dashboard         | 4     |
| Property Management      | 14    |
| Homecare/Agency          | 5     |
| Booking Management       | 13    |
| Favorites & Reviews      | 4     |
| Payment & Wallet         | 7     |
| Subscription & Packages  | 3     |
| Gallery Management       | 9     |
| Extra Images             | 2     |
| Facilities               | 2     |
| Other (Coupons, FAQ, etc)| 7     |
| **Total**                | **81**|

---

## Local Development Setup

### Prerequisites

1. **Flutter SDK** (version 3.6.2+)
   ```powershell
   flutter --version
   flutter doctor
   ```

2. **Android Studio** or **VS Code** with Flutter extensions

3. **For Android**: Android SDK 35, NDK 27.0.12077973

4. **For iOS**: Xcode (macOS only)

### Step-by-Step Setup

#### 1. Navigate to Project
```powershell
cd d:\Programming\IMEJE\Digisrupt\caresoko\caresoko
```

#### 2. Install Dependencies
```powershell
flutter pub get
```

#### 3. Configure API Keys
Edit `lib/Api/config.dart`:
```dart
static const String oneSignel = "YOUR_ONESIGNAL_APP_ID";
static const googleKey = "YOUR_GOOGLE_MAPS_API_KEY";
```

#### 4. Configure Backend URL (if using local backend)
```dart
// For local testing
static const String baseurl = 'http://localhost/caresoko/';
// For production
static const String baseurl = 'https://careinafh.caresoko.com/';
```

#### 5. Run the App
```powershell
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# Web (Chrome)
flutter run -d chrome

# Windows
flutter run -d windows

# Linux
flutter run -d linux

# List devices
flutter devices
```

---

## Deployment Guide

### Android Deployment

#### 1. Configure Signing
Create keystore:
```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Edit `android/app/build.gradle`:
```groovy
signingConfigs {
    release {
        storeFile file('path/to/upload-keystore.jks')
        storePassword 'YOUR_STORE_PASSWORD'
        keyAlias 'upload'
        keyPassword 'YOUR_KEY_PASSWORD'
    }
}
```

#### 2. Update Application ID
```groovy
applicationId = "com.yourcompany.caresoko"
```

#### 3. Build
```powershell
# APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# With Stripe key
flutter build appbundle --release --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx
```

### iOS Deployment (macOS only)
```powershell
flutter build ipa --release
```

### Web Deployment
```powershell
flutter build web --release
```
Output: `build/web/` - Deploy to Firebase Hosting, Netlify, Vercel, etc.

### Windows Deployment
```powershell
flutter build windows --release
```
Output: `build/windows/runner/Release/`

---

## Environment Variables

```powershell
flutter build apk --release \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx \
  --dart-define=GOOGLE_MAPS_KEY=xxx \
  --dart-define=ONESIGNAL_APP_ID=xxx
```

---

## Key Features

| Feature                     | Status |
|-----------------------------|--------|
| User Auth (Phone/Email)     | ✅     |
| Property Listings           | ✅     |
| Homecare Services           | ✅     |
| Real Estate Booking         | ✅     |
| Multiple Payment Gateways   | ✅     |
| Wallet System               | ✅     |
| Google Maps                 | ✅     |
| Push Notifications          | ✅     |
| Multi-language              | ✅     |
| Dark/Light Mode             | ✅     |
| 360° Image Viewer           | ✅     |
| Reviews & Ratings           | ✅     |
| Subscription Packages       | ✅     |
| Contract Agreements         | ✅     |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Could not find google-services.json" | Run `flutterfire configure` |
| Stripe fails on web | Add Stripe.js to `web/index.html` |
| OneSignal crashes on web/Linux | Expected - mobile only |
| Google Maps not showing | Add API key and enable Maps API |
| Android SDK version issues | Use `compileSdk = 35`, `targetSdk = 34` |

---

*Generated: 2026-02-07*
