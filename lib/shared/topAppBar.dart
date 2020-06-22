import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/custom_drawer.dart';
import 'dart:math' as math;

class TopAppBar extends StatefulWidget {
  final String title;
  final bool isMenu;
  final double widthContainer;
  final double heightContainer = 120;

  TopAppBar(this.title, this.isMenu, this.widthContainer);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> with TickerProviderStateMixin {
  bool startAnimation = false;
  AnimationController animationController;
  AnimationController animationControllerWave;
  bool disposed = false;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  User user;

  _afterLayout(_) {
    setState(() {
      startAnimation = !startAnimation;
    });
  }

  @override
  void initState() {
    if (widget.isMenu) {
      animationControllerWave = AnimationController(
          value: 0.0,
          duration: Duration(seconds: 4),
          upperBound: 1,
          lowerBound: -1,
          vsync: this)
        ..repeat();

      animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 400));
    }
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isMenu) {
      disposed = true;
      if (animationController != null) animationController.dispose();
    }

    super.dispose();
  }

  void showDialogSource(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Text(
                'Source?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () {
                    getImageCamera();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    getImageGallery();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text(
                'Source?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () {
                    getImageCamera();
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    getImageGallery();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
    );
  }

  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }

  Future getImageGallery() async {
    File imageProfil = await ImagePicker.pickImage(source: ImageSource.gallery);

    //création du path pour le flyer
    await uploadImageProfil(imageProfil);
  }

  Future getImageCamera() async {
    File imageProfil = await ImagePicker.pickImage(source: ImageSource.camera);
    await uploadImageProfil(imageProfil);
  }

  Future uploadImageProfil(File imageProfil) async {
    //création du path pour le flyer
    String pathprofil =
        imageProfil.path.substring(imageProfil.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTaskFlyer = _storageReference
        .child('imageProfil')
        .child(context.read<User>().id)
        .child("/$pathprofil")
        .putFile(imageProfil);

    String urlFlyer = await uploadImage(uploadTaskFlyer);

    await context.read<FirestoreDatabase>().updateUserImageProfil(urlFlyer);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMenu) {
      user = Provider.of<User>(context, listen: false);
      final toggle = Provider.of<ValueNotifier<bool>>(context, listen: false);

      toggle.addListener(() {
        if (!disposed) {
          if (toggle.value) {
            animationController.forward();
          } else {
            animationController.reverse();
          }
        }
      });
    }

    return Stack(
      alignment: Alignment.center,
      overflow: Overflow.visible,
      children: <Widget>[
        AnimatedBuilder(
            animation: animationControllerWave,
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              width: double.infinity,
              height: 120,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    icon: widget.isMenu
                        ? SizedBox()
//                  AnimatedIcon(
//                          icon: AnimatedIcons.menu_arrow,
//                          progress: animationController,
//                          color: Theme.of(context).colorScheme.onSecondary,
//                        )
                        : Icon(
                      Platform.isAndroid
                          ? Icons.arrow_back
                          : Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      widget.isMenu
                          ? CustomDrawer.of(context).open()
                          : Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            builder: (context, child) {
              return ClipPath(
                clipper: ClippingClass(animationControllerWave.value),
                child: child,
              );
            }),
        widget.title == 'Profil'
            ? Positioned(
                top: 22,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => showDialogSource(context),
                  child: SizedBox(
                    width: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      overflow: Overflow.visible,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 52,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(user.imageUrl),
                          ),
                        ),
                        Positioned(
                          top: 60,
                          right: 0,
                          child: Icon(
                            FontAwesomeIcons.pencilAlt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ],
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
  double move = 0;
  double slice = math.pi;

  ClippingClass(this.move);

  @override
  Path getClip(Size size) {

    Path path = Path();
    path.lineTo(0, size.height * 0.6);

    path.quadraticBezierTo(
        size.width*1.6   * math.sin(move * slice),
        size.height*0.3  * math.cos(move * slice)+60,
        size.width,
        size.height * 0.6);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class ClippingChatClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.97, size.height * 0.95, size.width, size.height * .6);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
