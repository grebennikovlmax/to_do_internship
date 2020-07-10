import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthorizationState {}

class AuthorizationFailState implements AuthorizationState {}
class AuthorizationSuccessState implements AuthorizationState {}
class TryAuthorizationState implements AuthorizationState {}

abstract class AuthorizationEvent {

}

abstract class AuthWithCredentials {
  final String login;
  final String password;

  AuthWithCredentials(this.login,this.password);
}

class SignInEvent extends AuthWithCredentials implements AuthorizationEvent {

  SignInEvent(String login, String password) : super(login, password);

}

class SignUpEvent extends AuthWithCredentials implements AuthorizationEvent {

  SignUpEvent(String login, String password) : super(login, password);

}

class LogOutEvent extends AuthorizationEvent {}

class AuthorizationBloc extends Bloc<AuthorizationEvent, AuthorizationState> {

  final FirebaseAuth _firebaseAuth;

  AuthorizationBloc(this._firebaseAuth) : super(AuthorizationFailState());

  @override
  Stream<AuthorizationState> mapEventToState(AuthorizationEvent event) async* {
    if (event is SignInEvent) {
      yield* _tryAuth(event);
    } else if (event is SignUpEvent) {
      yield* _signUp(event);
    } else if (event is LogOutEvent) {
      yield* _logOut();
    }

  }

  Stream<AuthorizationState> _tryAuth(SignInEvent event) async* {
    yield TryAuthorizationState();
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: event.login, password: event.password.hashCode.toString());
      yield AuthorizationSuccessState();
    } catch (e) {
      print(e);
      yield AuthorizationFailState();
    }
  }

  Stream<AuthorizationState> _signUp(SignUpEvent event) async* {
    yield TryAuthorizationState();
    AuthResult a = await _firebaseAuth.createUserWithEmailAndPassword(email: event.login, password: event.password.hashCode.toString());
    yield AuthorizationFailState();
  }

  Stream<AuthorizationState> _logOut() async* {
    yield TryAuthorizationState();
    await _firebaseAuth.signOut();
    yield AuthorizationFailState();
  }

}