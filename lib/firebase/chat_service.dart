// import 'package:cloud_firestore/cloud_firestore.dart';
// Actually, since we removed the package, we can't import it.
// We need to remove the import and stub the types or remove the methods.

import 'package:flutter/material.dart';

class ChatServices extends ChangeNotifier {
  // Firebase removed.
  
  Future<void> sendMessage(
      {required String receiverId, required String messeage}) async {
    print("ChatServices: Firebase removed. Message not sent.");
  }

  // Stream<QuerySnapshot> getMessage... 
  // Since QuerySnapshot is from cloud_firestore, we can't return it.
  // We'll return a Stream<List> instead or just dynamic.
  Stream<dynamic> getMessage(
      {required String userId, required String otherUserId}) {
    return Stream.empty();
  }
}
