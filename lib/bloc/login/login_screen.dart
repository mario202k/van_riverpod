import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/bloc/login/bloc/login_bloc.dart';
import 'package:vanevents/bloc/login/login_form.dart';
import 'package:vanevents/screens/model_body.dart';

class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {

        bool result = await _onPressBackButton(context);

        return Future.value(result);
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .background,
        body: ModelBody(
          child: BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(context),
            child: LoginForm(),
          ),
        ),
      ),
    );
  }


  Future<bool> _onPressBackButton(BuildContext context) async {

    return await showDialog(
        context: context,
        builder: (_) =>
        Platform.isAndroid
            ? AlertDialog(
          title: Text('Quitter?'),
          content: Text(
              'Etes vous sur de vouloir quitter'),
          actions: <Widget>[
            FlatButton(
              child: Text('Non'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text('Oui'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        )
            : CupertinoAlertDialog(
          title: Text('Quitter?'),
          content: Text(
              'Etes vous sur de vouloir quitter'),
          actions: <Widget>[
            FlatButton(
              child: Text('Non'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text('Oui'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        )) ?? false;

  }
}

