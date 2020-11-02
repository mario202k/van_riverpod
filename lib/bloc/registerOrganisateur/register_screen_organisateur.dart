import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/bloc/registerOrganisateur/bloc/blocOrganisateur.dart';
import 'package:vanevents/bloc/registerOrganisateur/register_form_organisateur.dart';
import 'package:vanevents/screens/model_body_login.dart';
import 'package:vanevents/screens/model_screen.dart';

class RegisterScreenOrganisateur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Organisateur',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: ModelBodyLogin(
          child: BlocProvider<RegisterBlocOrganisateur>(
            create: (context) => RegisterBlocOrganisateur(context),
            child: RegisterFormOrganisateur(),
          ),
        ),
      ),
    );
  }
}
