import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/bloc/register/bloc/register_bloc.dart';
import 'package:vanevents/bloc/register/bloc/register_event.dart';
import 'package:vanevents/bloc/register/bloc/register_state.dart';
import 'package:vanevents/bloc/register/register_button.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:provider/provider.dart';

class RegisterForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nodeNomPrenom = FocusScopeNode();
  final FocusScopeNode _nodesEmail = FocusScopeNode();
  final FocusScopeNode _nodePassword = FocusScopeNode();
  final FocusScopeNode _nodeConfirmation = FocusScopeNode();
  final TextEditingController _nomPrenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.isSubmitting) {
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
        }
        if (state.isSuccess) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.rep),
                  ],
                ),
              ),
            );
        }
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state.rep),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                    backgroundImage: context.watch<BoolToggle>().imageProfil != null
                        ? FileImage(context.watch<BoolToggle>().imageProfil)
                        : AssetImage('assets/img/normal_user_icon.png'),
                    radius: 50,
                    child: RawMaterialButton(
                      shape: const CircleBorder(),
                      splashColor: Colors.black45,
                      onPressed: () => _onPressImage(context),
                      padding: const EdgeInsets.all(50.0),
                    )),
                FormBuilder(
                  key: _fbKey,
                  autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          attribute: 'Nom et prénom',
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: 'Nom et prénom',
                            icon: Icon(
                              FontAwesomeIcons.user,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          focusNode: _nodeNomPrenom,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Nom et prénom']
                                .currentState
                                .validate()) {
                              _nodeNomPrenom.unfocus();
                              FocusScope.of(context).requestFocus(_nodesEmail);
                            }
                          },
                          controller: _nomPrenomController,
                          onChanged: (val) {
                            if (_nomPrenomController.text.length == 0) {
                              _nomPrenomController.clear();
                            }
                          },
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis'),
                            (val) {
                              RegExp regex = RegExp(
                                  r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,15}$');

                              if (regex.allMatches(val).length == 0) {
                                return 'Entre 2 et 15, ';
                              }
                              return null;
                            },
                          ],
                        ),
                      ),
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
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          attribute: 'Mot de passe',
                          maxLines: 1,
                          obscureText:
                              context.watch<BoolToggle>().obscureTextLogin,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            icon: Icon(
                              FontAwesomeIcons.key,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => context
                                  .read<BoolToggle>()
                                  .setObscureTextLogin(),
                              color: Theme.of(context).colorScheme.onBackground,
                              iconSize: 20,
                              icon: Icon(FontAwesomeIcons.eye),
                            ),
                          ),
                          focusNode: _nodePassword,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Mot de passe']
                                .currentState
                                .validate()) {
                              _nodePassword.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(_nodeConfirmation);
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
                            },
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onBackground),
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          attribute: 'Confirmation',
                          maxLines: 1,
                          obscureText:
                              context.watch<BoolToggle>().obscuretextRegister,
                          decoration: InputDecoration(
                            labelText: 'Confirmation',
                            icon: Icon(
                              FontAwesomeIcons.key,
                              size: 22.0,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => context
                                  .read<BoolToggle>()
                                  .setObscureTextRegister(),
                              color: Theme.of(context).colorScheme.onBackground,
                              iconSize: 20,
                              icon: Icon(FontAwesomeIcons.eye),
                            ),
                          ),
                          focusNode: _nodeConfirmation,
                          onEditingComplete: () {
                            if (_fbKey.currentState.fields['Confirmation']
                                .currentState
                                .validate()) {
                              _nodeConfirmation.unfocus();
                              _onFormSubmitted(context);
                            }
                          },
                          controller: _confirmationController,
                          onChanged: (val) {
                            if (_confirmationController.text.length == 0) {
                              _confirmationController.clear();
                            }
                          },
                          validators: [
                            FormBuilderValidators.required(
                                errorText: 'Champs requis'),
                            (val) {
                              if (_passwordController.text != val)
                                return 'Pas identique';
                            },
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                RegisterButton(
                  onPressed: () => _onFormSubmitted(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onPressImage(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (_) => Platform.isAndroid
            ? AlertDialog(
                title: Text('Source?'),
                content: Text('Veuillez choisir une source'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Caméra'),
                    onPressed: () {
                      context.read<BoolToggle>().getImageCamera('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Galerie'),
                    onPressed: () {
                      context.read<BoolToggle>().getImageGallery('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            : CupertinoAlertDialog(
                title: Text('Source?'),
                content: Text('Veuillez choisir une source'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Caméra'),
                    onPressed: () {
                      context.read<BoolToggle>().getImageCamera('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Galerie'),
                    onPressed: () {
                      context.read<BoolToggle>().getImageGallery('Profil');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
  }

  void _onFormSubmitted(BuildContext context) {
    if(_fbKey.currentState.validate()){
      context.bloc<RegisterBloc>().add(
        RegisterSubmitted(
          email: _emailController.text,
          password: _passwordController.text, nomPrenom: _nomPrenomController.text,
        ),
      );
    }

  }
}
