import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/services/firebase_auth_service.dart';

class CardForm extends StatefulWidget {
  final List<String> formContent;
  final String textButton;
  final String type;

  CardForm({Key key, this.formContent, this.textButton, this.type})
      : super(key: key);

  @override
  _CardFormState createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<FocusScopeNode> _nodes;
  List<TextEditingController> _textEdit;
  GlobalKey key = GlobalKey();
  bool isDispose = false;
  double width = double.maxFinite;
  bool startAnimation = false;
  //FirebaseAuthService auth;
  bool obscureTextSignupConfirm = true;

  File _image;

  _afterLayout(_) {
    if (!isDispose) {
      double width = _getSizes();
      if (width != this.width) {
        setState(() {
          this.width = width;
        });
      }
    }
  }

  void togglePassword() {
    setState(() {
      obscureTextSignupConfirm = !obscureTextSignupConfirm;
    });
  }

  double _getSizes() {
    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;
    return sizeRed.width;
  }

  @override
  void initState() {
    _nodes = List<FocusScopeNode>.generate(
      widget.formContent.length,
      (index) => FocusScopeNode(),
    );
    _textEdit = List<TextEditingController>.generate(
        widget.formContent.length, (index) => TextEditingController());

    super.initState();
//    SchedulerBinding.instance.addPostFrameCallback(_afterLayout());
  }

  @override
  void didUpdateWidget(CardForm oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    isDispose = true;
    _textEdit.forEach((textEdit) => textEdit.dispose());
    _nodes.forEach((node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //auth = Provider.of<FirebaseAuthService>(context, listen: false);
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Card(
                key: key,
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onBackground,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(24.0)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FormBuilder(
                    key: _fbKey,
                    autovalidate: false,
                    child: Column(
                        children: List<Widget>.generate(
                            widget.formContent.length,
                            (index) => buildFormBuilder(
                                index, obscureTextSignupConfirm))),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
          Positioned(
            bottom: 0,
            width: constraints.maxWidth,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: !startAnimation
                  ? RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          widget.textButton,
                        ),
                      ),
                      onPressed: () {
                        onSubmit();
                      })
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary)),
            ),
          ),
//          FractionalTranslation(
//              translation: Offset(0.0, height),
//              child: Align(
//                alignment: FractionalOffset(0.5, 0.0),
//                child: AnimatedSwitcher(
//                  duration: Duration(milliseconds: 500),
//                  transitionBuilder:
//                      (Widget child, Animation<double> animation) {
//                    return ScaleTransition(
//                      scale: animation,
//                      child: child,
//                    );
//                  },
//                  child: !startAnimation
//                      ? RaisedButton(
//                          color: Theme.of(context).colorScheme.primary,
//                          child: Padding(
//                            padding: const EdgeInsets.all(12.0),
//                            child: Text(
//                              widget.textButton,
//                            ),
//                          ),
//                          onPressed: () {
//                            onSubmit();
//                          })
//                      : CircularProgressIndicator(
//                          valueColor: AlwaysStoppedAnimation<Color>(
//                              Theme.of(context).colorScheme.primary)),
//                ),
//              )),
          widget.type == 'signup'
              ? FractionalTranslation(
                  translation: Offset(0.0, -0.5),
                  child: Align(
                    alignment: FractionalOffset(0.5, 0.0),
//                    child: FloatingActionButton(
//                      child: Icon(FontAwesomeIcons.calendar),
//                      onPressed: () {},
//                    ),
                    child: CircleAvatar(
                        backgroundImage: _image != null
                            ? FileImage(_image)
                            : AssetImage('assets/img/normal_user_icon.png'),
                        radius: 50,
                        child: RawMaterialButton(
                          shape: const CircleBorder(),
                          splashColor: Colors.black45,
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return PlatformAlertDialog(
                                  title: Text(
                                    'Source?',
                                    style: Theme.of(context).textTheme.bodyText2.copyWith(color: Theme.of(context).colorScheme.primary),
                                  ),
                                  actions: <Widget>[
                                    PlatformDialogAction(
                                      child: Text(
                                        'Caméra',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1.copyWith(color: Theme.of(context).colorScheme.primary),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _getImageCamera();
                                      },
                                    ),
                                    PlatformDialogAction(
                                      child: Text(
                                        'Galerie',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1.copyWith(color: Theme.of(context).colorScheme.primary),
                                      ),
                                      //actionType: ActionType.,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _getImageGallery();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          padding: const EdgeInsets.all(50.0),
                        )),
                  ),
                )
              : SizedBox()
        ],
      );
    });
  }

  Future _getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  onSubmit() async {
//    if (!_fbKey.currentState.validate()) {
//      auth.showSnackBar('Formulaire invalide', context);
//      return;
//    }
//    setState(() {
//      startAnimation = true;
//    });
//
//    switch (widget.type) {
//      case 'login':
//        await auth
//            .signInWithEmailAndPassword(
//                _textEdit.elementAt(0).text, _textEdit.elementAt(1).text)
//            .catchError((e) {
//          setState(() {
//            startAnimation = false;
//          });
//          print(e);
//          auth.showSnackBar("email ou mot de passe invalide", context);
//        }).whenComplete(() {
//          setState(() {
//            startAnimation = false;
//          });
//        });
//        break;
//      case 'signup':
//        if (_image != null) {
//          await auth.register(
//              _textEdit.elementAt(1).text, //email
//              _textEdit.elementAt(2).text, //mdp
//              _textEdit.elementAt(0).text, //nom
//              _image,
//              context).catchError((){
//            auth.showSnackBar('Impossible de s\'inscrire', context);
//          }).whenComplete((){
//            auth.showSnackBar('Un email de vérification a été envoyé', context);
//            setState(() {
//              startAnimation = false;
//            });
//            //ExtendedNavigator.of(context).pop();
//          });
//        } else {
//          auth.showSnackBar('Il manque une photo', context);
//          setState(() {
//            startAnimation = false;
//          });
//        }
//        break;
//    }
//    setState(() {
//      startAnimation = false;
//    });

  }

  Widget buildFormBuilder(int index, bool obscureText) {

    TextInputType textInput;
    List<FormFieldValidator> validators = List<FormFieldValidator>();
    Icon icon;
    IconButton iconButton;

    switch (widget.formContent.elementAt(index)) {
      case 'Nom':
        textInput = TextInputType.text;
        validators = [
          FormBuilderValidators.required(errorText: 'Champs requis'),
          (val) {
            RegExp regex = RegExp(
                r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,15}$');

            if (regex.allMatches(val).length == 0) {
              return 'Entre 2 et 15, ';
            }
          },
        ];
        obscureText = false;
        icon = Icon(
          FontAwesomeIcons.user,
          size: 22.0,
          color: Theme.of(context).colorScheme.onBackground,
        );

        break;

      case 'Email':
        textInput = TextInputType.emailAddress;
        validators = [
          FormBuilderValidators.required(errorText: 'Champs requis'),
          FormBuilderValidators.email(
              errorText: 'Veuillez saisir un Email valide'),
        ];
        obscureText = false;
        icon = Icon(
          FontAwesomeIcons.at,
          size: 22.0,
          color: Theme.of(context).colorScheme.onBackground,
        );

        break;
      case 'Mot de passe':
        textInput = TextInputType.text;
        validators = [
          FormBuilderValidators.required(errorText: 'Champs requis'),
          (val) {
            RegExp regex = new RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$');
            if (regex.allMatches(val).length == 0) {
              return 'Entre 8 et 15, 1 majuscule, 1 minuscule, 1 chiffre';
            }
          },
        ];
        icon = Icon(
          FontAwesomeIcons.key,
          size: 22.0,
          color: Theme.of(context).colorScheme.onBackground,
        );

        iconButton = IconButton(
          onPressed: () {
            togglePassword();
          },
          color: Theme.of(context).colorScheme.onBackground,
          iconSize: 20,
          icon: Icon(FontAwesomeIcons.eye),
        );
        break;
      case 'Confirmation':
        textInput = TextInputType.text;
        validators = [
          FormBuilderValidators.required(errorText: 'Champs requis'),
          (val) {
            if (_textEdit.elementAt(index - 1).text != val)
              return 'Pas identique';
          },
        ];

        icon = Icon(
          FontAwesomeIcons.key,
          size: 22.0,
          color: Theme.of(context).colorScheme.onBackground,
        );

        iconButton = IconButton(
          onPressed: () {
            togglePassword();
          },
          color: Theme.of(context).colorScheme.onBackground,
          iconSize: 20,
          icon: Icon(FontAwesomeIcons.eye),
        );
        break;
      case 'Titre':
        textInput = TextInputType.text;
        validators = [
          FormBuilderValidators.required(errorText: 'Champs requis'),
          (val) {
            RegExp regex = RegExp(
                r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,15}$');

            if (regex.allMatches(val).length == 0) {
              return 'Entre 2 et 15, ';
            }
          },
        ];
        obscureText = false;
        icon = Icon(
          FontAwesomeIcons.user,
          size: 22.0,
          color: Theme.of(context).colorScheme.onBackground,
        );

        break;
    }

    return Padding(
        padding: EdgeInsets.fromLTRB(
            8,
            widget.type == 'signup' &&
                    widget.formContent.elementAt(index) == 'Nom'
                ? 60
                : 10,
            8,
            10),
        child: FormBuilderTextField(
          keyboardType: textInput,
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          cursorColor: Theme.of(context).colorScheme.onBackground,
          attribute: widget.formContent.elementAt(index),
          maxLines:
              widget.formContent.elementAt(index) != 'Description' ? 1 : 10,
          obscureText: widget.formContent.elementAt(index) == 'Mot de passe' ? obscureText:false,
          decoration: buildInputDecoration(
              context, widget.formContent.elementAt(index),icon,iconButton),
          focusNode: _nodes.elementAt(index),

          onEditingComplete: () {
            String field = widget.formContent.elementAt(index);
            if (_fbKey.currentState.fields[field].currentState.validate()) {
              _nodes.elementAt(index).unfocus();

              if (_nodes.length - 1 != index) {
                FocusScope.of(context)
                    .requestFocus(_nodes.elementAt(index + 1));
              } else {
                onSubmit();
              }
            }
          },
          controller: _textEdit.elementAt(index),
          onChanged: (val) {
            if (_textEdit.elementAt(index).text.length == 0) {
              _textEdit.elementAt(index).clear();
            }
          },
          validators: validators,
        )
    );
  }

  InputDecoration buildInputDecoration(BuildContext context, String labelText, Icon icon, IconButton iconButton) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onBackground, width: 2),
          borderRadius: BorderRadius.circular(25.0)),
      labelText: labelText,
      labelStyle: Theme.of(context).textTheme.button,
      border: InputBorder.none,
      errorStyle: Theme.of(context).textTheme.button,icon: icon,suffixIcon: iconButton
    );
  }
}
