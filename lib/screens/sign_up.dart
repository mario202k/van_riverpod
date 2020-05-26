import 'package:flutter/material.dart';
import 'package:vanevents/shared/card_form.dart';
import 'package:vanevents/shared/topAppBar.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final double _heightContainer = 120;

  bool startAnimation = false;


  GlobalKey key = GlobalKey();

  _afterLayout(_) {
    if (startAnimation == false) {
      setState(() {
        startAnimation = !startAnimation;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }



  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 100),
            child: TopAppBar(
                'SignUp',
                false,

                double.infinity),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Container(
            color: Theme.of(context).colorScheme.background,
            child: LayoutBuilder(builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                    minWidth: viewportConstraints.maxWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 60, 25, 25),
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          width: startAnimation
                              ? viewportConstraints.maxWidth - 50
                              : 0,
                          child: CardForm(
                            formContent: [
                              'Nom',
                              'Email',
                              'Mot de passe',
                              'Confirmation'
                            ],
                            textButton: 'S\'inscrire',
                            type: 'signup',
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: ClippingClassBottom(),
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          height: startAnimation ? _heightContainer : 0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
//              child: Column(
//
//                children: <Widget>[
//                  CircleAvatar(
//                      backgroundImage: _image != null
//                          ? FileImage(_image)
//                          : AssetImage('assets/img/normal_user_icon.png'),
////                      Icon(FontAwesomeIcons.userAlt)
//                      radius: 50,
//                      child: RawMaterialButton(
//                        shape: const CircleBorder(),
//                        splashColor: Colors.black45,
//                        onPressed: () {
//                          showDialog<void>(
//                            context: context,
//                            builder: (BuildContext context) {
//                              return PlatformAlertDialog(
//                                title: Text('Source?',style: Theme.of(context).textTheme.display1,),
//                                actions: <Widget>[
//                                  PlatformDialogAction(
//                                    child: Text('Caméra',style: Theme.of(context).textTheme.display1.copyWith(fontWeight: FontWeight.bold),),
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                      _getImageCamera();
//                                    },
//                                  ),
//                                  PlatformDialogAction(
//                                    child: Text('Galerie',style: Theme.of(context).textTheme.display1.copyWith(fontWeight: FontWeight.bold),),
//                                    //actionType: ActionType.,
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                      _getImageGallery();
//                                    },
//
//                                  ),
//                                ],
//                              );
//                            },
//                          );
//                        },
//                        padding: const EdgeInsets.all(50.0),
//                      )),
//                ],
//              ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ClippingClassBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.7);

    //path.lineTo(0.0, size.height);

    path.lineTo(size.width, 0);

    path.lineTo(size.width, size.height);

    path.lineTo(0.0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width, size.height * 0.3);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
