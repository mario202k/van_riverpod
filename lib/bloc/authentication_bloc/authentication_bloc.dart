import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:vanevents/repository/user_repository.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final bool _seenOnboarding;
  final UserRepository _userRepository;

  AuthenticationBloc(
      {@required UserRepository userRepository,
        @required bool seenOnboarding })
      : assert(userRepository != null),
        assert(seenOnboarding != null),
        _seenOnboarding = seenOnboarding,
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => AuthenticationInitial();


  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {

    //_userRepository.signOut();

    if (event is AuthenticationStarted) {
      yield* _mapAuthenticationStartedToState();
    } else if (event is AuthenticationLoggedIn) {
      yield* _mapAuthenticationLoggedInToState();
    } else if (event is AuthenticationLoggedOut) {
      yield* _mapAuthenticationLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAuthenticationStartedToState() async* {

    print('_mapAuthenticationStartedToState');


    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final firebaseUser = await _userRepository.getUser();
      yield AuthenticationSuccess(firebaseUser);
    }else {
      print(_seenOnboarding);
      yield AuthenticationFailure(_seenOnboarding);
    }
  }

  Stream<AuthenticationState> _mapAuthenticationLoggedInToState() async* {

    try{
      final firebaseUser = await _userRepository.getUser();

      yield AuthenticationSuccess(firebaseUser);
    }catch(e){
      print(e);
      yield AuthenticationFailure(_seenOnboarding);
    }

  }

  Stream<AuthenticationState> _mapAuthenticationLoggedOutToState() async* {
    yield AuthenticationFailure(_seenOnboarding);
    _userRepository.signOut();
  }
}
