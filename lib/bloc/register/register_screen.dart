import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/bloc/register/bloc/register_bloc.dart';
import 'package:vanevents/bloc/register/register_form.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/shared/topAppBar.dart';

class RegisterScreen extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: TopAppBar('Inscription', false, double.infinity),
        ),
        body: ModelBody(
          child: BlocProvider<RegisterBloc>(
            create: (context) => RegisterBloc(context),
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }

}
