import 'package:auto_route/auto_route.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/shared/card_form.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: AppBar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .secondary, // Here we create one to set status bar color
                brightness: Brightness
                    .dark, // Set any color of status bar you want; or it defaults to your theme's primary color
              )),
          backgroundColor: Theme.of(context).colorScheme.background,
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        height: viewportConstraints.maxHeight,
                        child: Opacity(
                          opacity: 0.4,
                          child: Align(
                            alignment: Alignment.center,
                            child: AspectRatio(
                                aspectRatio: 1.6,
                                child: FlareActor(
                                  'assets/animations/dance.flr',
                                  alignment: Alignment.center,
                                  animation: 'dance',
                                )),
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Hero(
                              tag: 'splash',
                              child: Image.asset('assets/images/icon.jpg'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 5,
                                ),
                                CardForm(
                                  formContent: ['Email', 'Mot de passe'],
                                  textButton: 'Se connecter',
                                  type: 'login',
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                        flex: 4,
                                        child: Divider(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          thickness: 2,
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          'ou',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .button,
                                        )),
                                    Expanded(
                                        flex: 4,
                                        child: Divider(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          thickness: 2,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      onPressed: () {
                                        print('facebook');
                                      },
                                      backgroundColor: Colors.blue.shade800,
                                      child: Icon(
                                        FontAwesomeIcons.facebookF,
                                        color: Colors.white,
                                      ),
                                      heroTag: null,
                                    ),
                                    FloatingActionButton(
                                        onPressed: () {
                                          //auth.googleSignIn(context);
                                        },
                                        backgroundColor: Colors.red.shade700,
                                        child: Icon(
                                          FontAwesomeIcons.google,
                                          color: Colors.white,
                                        ),
                                        heroTag: null),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                FlatButton(
                                  onPressed: () => ExtendedNavigator.of(context)
                                      .push(Routes.signUp),
                                  child: Text(
                                    'Pas de compte? S\'inscrire maintenant',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.button,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                FlatButton(
                                  onPressed: () => ExtendedNavigator.of(context)
                                      .push(Routes.resetPassword),
                                  child: Text(
                                    'Mot de passe oublié?',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.button,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
