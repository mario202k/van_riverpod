import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vanevents/bloc/login/bloc/login_event.dart';
import 'package:vanevents/bloc/login/bloc/login_state.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/repository/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final BuildContext _context;

  LoginBloc(this._context);

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
    }
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    try {
      AuthResult authResult =
          await _context.read<UserRepository>().signInWithGoogle();

      await _context
          .read<UserRepository>()
          .createOrUpdateUserOnDatabase(authResult.user);

      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure('Impossible de se connecter');
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      AuthResult authResult = await _context
          .read<UserRepository>()
          .signInWithCredentials(email, password);

      if (authResult.user.isEmailVerified) {
        await _context
            .read<UserRepository>()
            .createOrUpdateUserOnDatabase(authResult.user);
        yield LoginState.success();
      } else {
        yield LoginState.failure('Email non vérifié');
      }
    } catch (_) {
      yield LoginState.failure('Impossible de se connecter');
    }
  }
}
