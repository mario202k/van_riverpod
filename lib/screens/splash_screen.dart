import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/shared/appPageRoute.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double largeur = 0;
  double hauteur = 0;

  _afterLayout(_) {
    print(largeur);
    setState(() {
      largeur = MediaQuery.of(context).size.width * 0.8;
      hauteur = MediaQuery.of(context).size.width * 0.8;
    });
  }

  @override
  void initState() {

    //setStatusBarColor();

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//      statusBarColor: Theme.of(context).colorScheme.secondary,
//      statusBarIconBrightness: Theme.of(context).colorScheme.brightness,
//      systemNavigationBarColor: Theme.of(context).colorScheme.secondary,
//      systemNavigationBarIconBrightness:
//          Theme.of(context).colorScheme.brightness,
//    ));



    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
//      appBar: PreferredSize(
//          preferredSize: Size.fromHeight(0),
//          child: AppBar( // Here we create one to set status bar color
//            backgroundColor: Theme.of(context).colorScheme.secondary, // Set any color of status bar you want; or it defaults to your theme's primary color
//          )
//      ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
//            MaterialPageRoute(
//                builder: (context) =>
//                    Login());
                // ExtendedNavigator.of(context).pushNamed(Routes.login);
              },
              child: AnimatedContainer(
                width: largeur,
                height: hauteur,
                curve: Curves.easeOutBack,
                onEnd: () {
                  Navigator.of(context).push(
                      AppPageRoute(builder: (BuildContext context) => Login()));
                  //ExtendedNavigator.of(context).pushNamed(Routes.login);
                },
                duration: Duration(seconds: 2),
                child: Hero(
                  tag: 'splash',
                  child: Image.asset('assets/images/icon.jpg'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
