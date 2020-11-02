
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/shared/clip_shadow_path.dart';

class TopAppBar extends HookWidget {
  final String title;
  final double heightContainer = 120;

  TopAppBar(this.title);

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
                    getImageCamera(context);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    getImageGallery(context);
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
                    getImageCamera(context);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    getImageGallery(context);
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

  Future getImageGallery(BuildContext context) async {
    File imageProfil = await ImagePicker.pickImage(source: ImageSource.gallery);

    //création du path pour le flyer
    await uploadImageProfil(imageProfil,context);
  }

  Future getImageCamera(BuildContext context) async {
    File imageProfil = await ImagePicker.pickImage(source: ImageSource.camera);
    await uploadImageProfil(imageProfil,context);
  }

  Future uploadImageProfil(File imageProfil,BuildContext context) async {
    //création du path pour le flyer
    String pathprofil =
        imageProfil.path.substring(imageProfil.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTaskFlyer = FirebaseStorage.instance.ref()
        .child('imageProfil')
        .child(context.read(myUserProvider).id)
        .child("/$pathprofil")
        .putFile(imageProfil);

    String urlFlyer = await uploadImage(uploadTaskFlyer);

    await context.read(firestoreDatabaseProvider).updateMyUserImageProfil(urlFlyer);
  }

  @override
  Widget build(BuildContext context) {
    final double  d = 0.0;
    final animationControllerWave = useAnimationController(
        initialValue:  d,
        duration: const Duration(seconds: 4),
        upperBound: 1,
        lowerBound: -1
    )..repeat();
    final user = useProvider(myUserProvider);

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
            ),
            builder: (context, child) {
              return ClipShadowPath(
                shadow: BoxShadow(
                    color: Colors.black,
                    //offset: Offset(-5,3),
                    blurRadius: 5,
                    spreadRadius: 15),
                clipper: ClippingClass(animationControllerWave.value),
                child: child,
              );
            }),
        title == 'Profil'
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
                            backgroundImage: user.imageUrl != null
                                ? NetworkImage(user.imageUrl)
                                : AssetImage('assets/img/normal_user_icon.png'),
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
        size.width * 1.6 * math.sin(move * slice),
        size.height * 0.3 * math.cos(move * slice) + 60,
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
