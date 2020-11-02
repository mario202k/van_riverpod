import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/bloc/register/bloc/register_event.dart';
import 'package:vanevents/bloc/register/bloc/register_state.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final BuildContext _context;

  RegisterBloc(this._context) : super(null);

  @override
  RegisterState get initialState => RegisterState.initial();

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is RegisterSubmitted) {
      yield* _mapRegisterSubmittedToState(
          event.nomPrenom, event.email, event.password);
    }
  }

  Stream<RegisterState> _mapRegisterSubmittedToState(
    String nomPrenom,
    String email,
    String password,
  ) async* {
    yield RegisterState.loading();
    String rep = await _context.read<UserRepository>().signUp(
      image: _context.read<BoolToggle>().imageProfil,
      email: email,
      password: password,nomPrenom: nomPrenom,typeDeCompte: 2
    );
    print(rep);
    print('//');

    if(rep == 'un email de validation a été envoyé'){
      yield RegisterState.success(rep);
    }else{
      yield RegisterState.failure(rep);
    }
  }
}
