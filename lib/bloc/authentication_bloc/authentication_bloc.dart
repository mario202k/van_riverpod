import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/repository/user_repository.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(null);

  @override
  AuthenticationState get initialState => AuthenticationInitial();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStarted) {
      yield* _mapAuthenticationStartedToState();
    } else if (event is AuthenticationLoggedIn) {
      yield* _mapAuthenticationLoggedInToState();
    } else if (event is AuthenticationLoggedOut) {
      yield* _mapAuthenticationLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAuthenticationStartedToState() async* {


    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final firebaseUser = await _userRepository.getFireBaseUser();

      final user = await _userRepository.getMyUser(firebaseUser.uid);
      if (!user.isAcceptedCGUCGV ) {
        yield AuthenticationCGUCGV(firebaseUser);
      } else {
        yield AuthenticationSuccess(firebaseUser,user);
      }
    } else {
      yield AuthenticationFailure(
          (await SharedPreferences.getInstance()).getBool('seen') ?? false);
    }
  }

  Stream<AuthenticationState> _mapAuthenticationLoggedInToState() async* {
    try {
      final firebaseUser = await _userRepository.getFireBaseUser();

      final user = await _userRepository.getMyUser(firebaseUser.uid);

      if (!user.isAcceptedCGUCGV) {
        yield AuthenticationCGUCGV(firebaseUser);
      } else {
        yield AuthenticationSuccess(firebaseUser,user);
      }
    } catch (e) {

      yield AuthenticationFailure(
          (await SharedPreferences.getInstance()).getBool('seen') ?? false);
    }
  }

  Stream<AuthenticationState> _mapAuthenticationLoggedOutToState() async* {
    yield AuthenticationFailure(
        (await SharedPreferences.getInstance()).getBool('seen') ?? false);
    _userRepository.signOut();
  }
}
