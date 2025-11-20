import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);

    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        centerTitle: true,
        elevation: 0,
        leading: BackButton(
          color: notifire.getwhiteblackcolor,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Chats",
          style: TextStyle(
            fontSize: 18,
            color: notifire.getwhiteblackcolor,
          ),
        ),
      ),
      body: Center(
        child: Text("Chat functionality has been disabled.", style: TextStyle(color: notifire.getwhiteblackcolor)),
      ),
    );
  }
}
