import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:gotocarefinder/utils/Dark_lightmode.dart';

class ChatPage extends StatefulWidget {
  final String resiverUserId;
  final String resiverUseremail;
  final String proPic;

  const ChatPage({
    super.key,
    required this.resiverUserId,
    required this.resiverUseremail,
    required this.proPic,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ColorNotifire notifire;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        leading: BackButton(
          color: notifire.getwhiteblackcolor,
          onPressed: () {
            Get.back();
          },
        ),
        title: Text("Chat Disabled", style: TextStyle(color: notifire.getwhiteblackcolor)),
      ),
      body: Center(
        child: Text("Chat functionality has been disabled.", style: TextStyle(color: notifire.getwhiteblackcolor)),
      ),
    );
  }
}
