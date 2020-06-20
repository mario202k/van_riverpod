import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/models/call.dart';
import 'package:vanevents/screens/call_screens/call_screens.dart';
import 'package:vanevents/shared/CallMethods.dart';
import 'package:vanevents/shared/permissions.dart';

class PickupScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    @required this.call,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            SizedBox(height: 50),

          CachedNetworkImage(
            //gif
            imageUrl: call.callerPic,
            imageBuilder: (context, imageProvider) =>
                ClipRRect(borderRadius: BorderRadius.circular(180),
                    child: Image(image: imageProvider)),
            fit: BoxFit.fitHeight,
            placeholder: (context, url) =>
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor:
                  Theme.of(context).colorScheme.primary,
                  child: Container(
                      height: 200,
                      width: 200,
                      color: Colors.white),
                ),
            errorWidget: (context, url, error) =>
                Icon(Icons.error),
          ),
            SizedBox(height: 15),
            Text(
              call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async =>
                  await Permissions.cameraAndMicrophonePermissionsGranted()
                      ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallScreen(call: call),
                    ),
                  )
                      : {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}