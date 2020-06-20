import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/call.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/screens/call_screens/pickup/pickup_screen.dart';
import 'package:vanevents/shared/CallMethods.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    @required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callStream(uid: user.id),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.data != null) {
          Call call = Call.fromMap(snapshot.data.data);

          if (!call.hasDialled) {
            return PickupScreen(call: call);
          }
        }
        return scaffold;
      },
    );
  }
}