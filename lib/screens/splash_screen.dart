import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vanevents/bloc/login/login_screen.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:after_layout/after_layout.dart';
import 'package:vanevents/shared/appPageRoute.dart';

class MySplashScreen extends StatefulWidget {
  MySplashScreen();

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  AnimationController _controller;
  Animation _animation;
  CurvedAnimation _curve;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000),
    );

    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_curve);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Hero(
            tag: 'logo',
            child: SplashScreen.callback(
              name: 'assets/animations/logo.flr',
              fit: BoxFit.contain,
              startAnimation: 'start',
              onSuccess: (va) async {

//                  Future.delayed(Duration(seconds: 3)).then((value) => Navigator.pop(context));
//                  Navigator.of(context).pushAndRemoveUntil(
//                      AppPageRoute(
//                          builder: (BuildContext context) => LoginScreen()),
//                      ModalRoute.withName(Routes.authentication));
              //Navigator.of(context).pushReplacementNamed(Routes.login);

              Navigator.of(context).pushReplacement(AppPageRoute(
                  builder: (BuildContext context) => LoginScreen()));

//                  Navigator.of(context).pushAndRemoveUntil(
//                      AppPageRoute(
//                          builder: (BuildContext context) => LoginScreen()),
//                      ModalRoute.withName(Routes.authentication));
               // Navigator.of(context).maybePop();
//                  Navigator.of(context).push(
//                    AppPageRoute(
//                        builder: (BuildContext context) => LoginScreen())
//                  );
              },
              onError: (error, stacktrace) => print(error),
              isLoading: false,
              //until: () => Future.delayed(Duration(seconds: 4)),
            ),
          ),
          Positioned(
            bottom: 90,
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                children: <Widget>[
                  Hero(
                    tag: 'vanevents',
                    child: Text(
                      'Van e.vents',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 45),
                    ),
                  ),
                  Text(
                    'Partager votre événement ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _controller.forward();
  }
}
