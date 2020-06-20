import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firebase_auth_service.dart';
import 'package:vanevents/shared/topAppBar.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final double _heightContainer = 120;

  bool startAnimation = false;
  bool startAnimation2 = false;

  final TextEditingController _email = TextEditingController();

  double _height = 6.275;
  GlobalKey key = GlobalKey();

  _afterLayout(_) {
    if (startAnimation == false) {
      startAnimation = !startAnimation;
    }

    setState(() {
      //print(_getSizes());
      _height = _getSizes() / 53.5;
//      print(_height);
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  double _getSizes() {
    //WidgetsBinding.instance.addPostFrameCallback();

    final RenderBox renderBoxRed = key.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;

    return sizeRed.height;
    //print("SIZE of Red: $sizeRed");
  }

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
//    _auth = ModalRoute.of(context).settings.arguments;

   WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    return ModelScreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: TopAppBar('Reset', false, double.infinity),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ModelBody(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25),
                child: Stack(
                  children: <Widget>[
                    Card(
                      key: key,

                      elevation: 10,
//                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Container(
                        padding:
                        EdgeInsets.only(left: 20.0, right: 20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary
                          ]),
//                          color: Colors.blueAccent
                        ),
                        child: FormBuilder(
                          key: _fbKey,
                          autovalidate: false,
//                  readonly: true,
                          child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 70,
                                ),
                                Text(
                                  'Veuillez saisir votre adresse email',
                                  style: Theme.of(context)
                                      .textTheme
                                      .button,
                                ),
                                FormBuilderTextField(
                                  controller: _email,
                                  keyboardType:
                                  TextInputType.emailAddress,
                                  onEditingComplete: ()async{
                                    await submit( context);

                                  },
                                  style: TextStyle(
                                      color:
                                      Theme.of(context).colorScheme.onBackground),
                                  cursorColor: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  attribute: 'email',
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            width: 2),
                                        borderRadius:
                                        BorderRadius.circular(
                                            25.0)),
                                    labelText: 'Email',
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .button.copyWith(color: Theme.of(context).colorScheme.onBackground,),
                                    border: InputBorder.none,
                                    icon: Icon(
                                      FontAwesomeIcons.at,
                                      size: 22.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                    errorStyle: Theme.of(context)
                                        .textTheme
                                        .button,
                                  ),
                                  validators: [
                                    FormBuilderValidators.required(
                                        errorText: 'Champs requis'),
                                    FormBuilderValidators.email(
                                        errorText:
                                        'Veuillez saisir un Email valide'),
                                  ],
                                ),
                                SizedBox(
                                  height: 70,
                                ),
                              ]),
                        ),
                      ),
                    ),
                    FractionalTranslation(
                      translation: Offset(
                        0.0,
                        _height,
                      ),
                      child: Align(
                          alignment: FractionalOffset(0.5, 0.0),
                          child:  AnimatedSwitcher(
                            duration: Duration(milliseconds: 500),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: !startAnimation2? RaisedButton(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    'Envoyer l\'email',
                                  ),
                                ),
                                onPressed: () async {
                                  await submit(context);
                                }): CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    Theme.of(context)
                                        .colorScheme
                                        .primary)),
                          )
//                                    child: ProgressButton(
//                                        color: Theme.of(context)
//                                            .colorScheme
//                                            .surface,
//                                        borderRadius: 20,
//                                        width:
//                                            viewportConstraints.maxWidth * 0.6,
//                                        defaultWidget: Text(
//                                          'Envoyer l\'email',
//                                          style: Theme.of(context)
//                                              .textTheme
//                                              .button
//                                              .copyWith(
//                                                  fontWeight: FontWeight.w600,
//                                                  fontSize: 19),
//                                        ),
//                                        type: ProgressButtonType.Raised,
//                                        progressWidget:
//                                            CircularProgressIndicator(
//                                                valueColor:
//                                                    AlwaysStoppedAnimation<
//                                                            Color>(
//                                                        Theme.of(context)
//                                                            .colorScheme
//                                                            .primary)),
//                                        onPressed: () async {
//                                          _fbKey.currentState.save();
//                                          if (_fbKey.currentState.validate()) {
//                                            print(_fbKey.currentState.value);
//                                            await auth
//                                                .resetEmail(
//                                                    _email.text, context)
//                                                .then((str) {
//                                              auth.showSnackBar(
//                                                  "un email a été envoyé",
//                                                  context);
//                                            }).catchError((e) {
//                                              auth.showSnackBar(
//                                                  "email inconnu", context);
//                                            });
//                                          } else {
//                                            print(_fbKey.currentState.value);
//                                            auth.showSnackBar(
//                                                "formulaire non valide",
//                                                context);
//                                          }
//                                        })
                      ),
                    ),
                  ],
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
        ),
      ),
    );
  }

  Future submit(BuildContext context) async {
    _fbKey.currentState.save();
    if (_fbKey.currentState
        .validate()) {
      Scaffold.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('En cours...'),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      try{
        await context.read<UserRepository>()
            .resetEmail(
            _email.text);
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email envoyé'),

                ],
              ),
            ),
          );

      }catch(e){
        print(e);
        Scaffold.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email inconnu'),
                  Icon(Icons.error),

                ],

              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );

      }

    }

  }
}
