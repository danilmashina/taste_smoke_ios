import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class UnAuthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetEmailSent extends AuthState {}

// Добавляем состояния для Google Sign-In
class GoogleSignInAvailable extends AuthState {
  final bool isAvailable;

  const GoogleSignInAvailable(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

class GoogleSignInUnavailable extends AuthState {
  final String reason;

  const GoogleSignInUnavailable(this.reason);

  @override
  List<Object?> get props => [reason];
}
