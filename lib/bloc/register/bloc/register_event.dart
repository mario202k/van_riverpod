import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String nomPrenom;
  final String email;
  final String password;

  const RegisterSubmitted({
    @required this.nomPrenom,
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [nomPrenom,email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}
