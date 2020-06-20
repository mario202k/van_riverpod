import 'package:flutter/material.dart';
import 'package:vanevents/main.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/splash_screen.dart';
import 'package:vanevents/screens/walkthrough.dart';
import 'package:vanevents/shared/custom_drawer.dart';


/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
/// Note: this class used to be called [LandingPage].
class AuthWidget extends StatefulWidget {

  final bool seenOnboarding;
  const AuthWidget({Key key, this.seenOnboarding})
      : super(key: key);


  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {

  @override
  Widget build(BuildContext context) {

    if (userSnapshotStatic.connectionState == ConnectionState.active &&

        !userSnapshotStatic.hasError) {
      return userSnapshotStatic.data != null
          ? CustomDrawer(child: BaseScreens())

          : widget.seenOnboarding ? MySplashScreen():Walkthrough();
    }

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
