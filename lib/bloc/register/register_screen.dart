import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/bloc/register/bloc/register_bloc.dart';
import 'package:vanevents/bloc/register/register_form.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';

class RegisterScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(title: Text('Inscription',style: Theme.of(context).textTheme.headline6,),),
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
