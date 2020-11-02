import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/bloc/login/bloc/login_bloc.dart';
import 'package:vanevents/bloc/login/bloc/login_event.dart';
import 'package:vanevents/bloc/login/bloc/login_state.dart';
import 'package:vanevents/bloc/login/create_account_button.dart';
import 'package:vanevents/bloc/login/google_login_button.dart';
import 'package:vanevents/bloc/login/login_button.dart';
import 'package:vanevents/bloc/registerOrganisateur/register_screen_organisateur.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/reset_password.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

class LoginForm extends HookWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nodesEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final boolToggle = context.read(boolToggleProvider);

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        print(state);
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.rep,
                      style: Theme.of(context).textTheme.button,
                    ),
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.onError,
                    )
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Connexion...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          Navigator.of(context).pushReplacementNamed(Routes.authentication);
          context.bloc<AuthenticationBloc>().add(AuthenticationLoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: SizedBox(
                    height: 220,
                    child: FlareActor(
                      'assets/animations/dance.flr',
                      alignment: Alignment.center,
                      animation: 'dance',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                FormBuilder(
                  key: _fbKey,
                  //autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          attribute: 'Email',
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            icon: Icon(
                              FontAwesomeIcons.at,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          focusNode: _nodesEmail,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Email'].currentState
                                .validate()) {
                              _nodesEmail.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_nodePassword);
                            }
                          },
                          controller: _emailController,
                          onChanged: (val) {
                            if (_emailController.text.length == 0) {
                              _emailController.clear();
                            }
                          },
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis'),
                            FormBuilderValidators.email(
                                errorText: 'Veuillez saisir un Email valide'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer(builder: (context, watch, child) {
                          return FormBuilderTextField(
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                            cursorColor:
                                Theme.of(context).colorScheme.onBackground,
                            attribute: 'Mot de passe',
                            maxLines: 1,
                            obscureText:
                                watch(boolToggleProvider).obscureTextLogin,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              icon: Icon(
                                FontAwesomeIcons.key,
                                size: 22.0,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    boolToggle.setObscureTextLogin(),
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                iconSize: 20,
                                icon: Icon(FontAwesomeIcons.eye),
                              ),
                            ),
                            focusNode: _nodePassword,
                            onEditingComplete: () {
                              if (_fbKey.currentState.validate()) {
                                _nodePassword.unfocus();
                                _onFormSubmitted(context);
                              }
                            },
                            controller: _passwordController,
                            onChanged: (val) {
                              if (_passwordController.text.length == 0) {
                                _passwordController.clear();
                              }
                            },
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: 'Champs requis'),
                              (val) {
                                RegExp regex = new RegExp(
                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$');
                                if (regex.allMatches(val).length == 0) {
                                  return 'Entre 8 et 15, 1 majuscule, 1 minuscule, 1 chiffre';
                                }
                                return null;
                              },
                            ],
                          );
                        }),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      LoginButton(
                        onPressed: () => _onFormSubmitted(context),
                      ),
                      GoogleLoginButton(),
                      CreateAccountButton(),
                      RaisedButton(
                        onPressed: () {
                          context.bloc<LoginBloc>().add(LoginWithAnonymous());
                        },
                        child: Text('Anonyme'),
                      ),
                      FlatButton(
                        child: Text(
                          'Mot de passe oublié',
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return ResetPassword();
                            }),
                          );
                        },
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return RegisterScreenOrganisateur();
                            }),
                          );
                        },
                        child: Text('J\'organise'),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 90,
                            width: 300,
                            child: Hero(
                              tag: 'logo',
                              child: FlareActor(
                                'assets/animations/logo.flr',
                                alignment: Alignment.center,
                                fit: BoxFit.fitHeight,
                                //animation: 's',
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: Hero(
                              tag: 'vanevents',
                              child: Text(
                                'Van e.vents',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                        color: Colors.black, fontSize: 15),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onFormSubmitted(BuildContext context) {
    if (_fbKey.currentState.validate()) {
      context.bloc<LoginBloc>().add(
            LoginWithCredentialsPressed(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }
}
