part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  final FirebaseUser firebaseUser;

  const AuthenticationSuccess(this.firebaseUser);

  @override
  List<Object> get props => [firebaseUser];

  @override
  String toString() => 'Authenticated { displayName: $firebaseUser }';
}

class AuthenticationFailure extends AuthenticationState {
  final bool seenOnboarding;


  const AuthenticationFailure(this.seenOnboarding);

  @override
  List<Object> get props => [seenOnboarding];

  @override
  String toString() {
    return 'AuthenticationFailure{seenOnboarding: $seenOnboarding}';
  }
}


