import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vanevents/models/call.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/screens/call_screens/call_screens.dart';
import 'package:vanevents/shared/CallMethods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({User from, User to, context}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.nom,
      callerPic: from.imageUrl,
      receiverId: to.id,
      receiverName: to.nom,
      receiverPic: to.imageUrl,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}