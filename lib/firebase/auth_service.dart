// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

/// AuthService - Firebase has been removed
/// This service previously handled Firebase Authentication and Firestore operations.
/// If you need authentication, consider implementing a custom backend or using an alternative service.
class AuthService extends ChangeNotifier {
  
  singInAndStoreData({
    required String email,
    required String uid,
    required String proPicPath,
  }) async {
    // Firebase removed - implement alternative authentication if needed
    print("AuthService: Firebase removed. Implement alternative authentication.");
  }

  singUpAndStore({
    required String email,
    required String uid,
    required proPicPath,
  }) async {
    // Firebase removed - implement alternative authentication if needed
    print("AuthService: Firebase removed. Implement alternative authentication.");
  }
}
