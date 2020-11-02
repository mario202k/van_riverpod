import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vanevents/bloc/login/bloc/login_event.dart';
import 'package:vanevents/bloc/login/bloc/login_state.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/repository/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final BuildContext _context;

  LoginBloc(this._context) : super(null);

  @override
  LoginState get initialState => LoginState.initial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }else if(event is LoginWithAnonymous){
      yield* _mapLoginWithAnonymous();
    }
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    try {

      UserCredential authResult =
          await _context.read(userRepositoryProvider).signInWithGoogle();

      await _context.read(userRepositoryProvider)
          .createOrUpdateUserOnDatabase(authResult.user);

      yield LoginState.success();

    } catch (e) {

      yield LoginState.failure('Impossible de se connecter');
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      UserCredential authResult = await _context.read(userRepositoryProvider)
          .signInWithCredentials(email, password);

      if (authResult.user.emailVerified) {
        await _context.read(userRepositoryProvider)
            .createOrUpdateUserOnDatabase(authResult.user);

        yield LoginState.success();
      } else {
        yield LoginState.failure('Email non vérifié');
      }
    } catch (e) {
      print(e);
      yield LoginState.failure('Impossible de se connecter');
    }
  }

  Stream<LoginState> _mapLoginWithAnonymous() async* {
    yield LoginState.loading();
    try {
      print('///');
     // print(authResult.additionalUserInfo.toString());
      UserCredential authResult = await _context.read(userRepositoryProvider).loginAnonymous();

      await _context.read(userRepositoryProvider)
          .createOrUpdateUserOnDatabase(authResult.user);


      yield LoginState.success();
    } catch (e) {
      print(e);
      yield LoginState.failure('Impossible de se connecter');
    }
  }
}
