import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/auth/google_auth_service.dart';
import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final AuthServiceInterface _googleAuthService;

  AuthBloc({FirebaseAuth? firebaseAuth}) 
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleAuthService = GoogleAuthServiceFactory.create(),
        super(AuthInitial()) {

    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<CheckGoogleSignInAvailability>(_onCheckGoogleSignInAvailability);
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // In a real app, you might want to check for email verification here
      if (user.emailVerified) {
        emit(Authenticated(user));
      } else {
        emit(AuthFailure('Please verify your email.'));
      }
    } else {
      emit(UnAuthenticated());
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      await userCredential.user?.sendEmailVerification();
      emit(AuthFailure('A verification email has been sent. Please check your inbox.'));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Sign up failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        if (userCredential.user!.emailVerified) {
          emit(Authenticated(userCredential.user!));
        } else {
          emit(AuthFailure('Please verify your email before signing in.'));
        }
      } else {
        emit(UnAuthenticated());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Sign in failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(UnAuthenticated());
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(PasswordResetEmailSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(e.message ?? 'Password reset failed'));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Обработчик Google Sign-In
  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isAvailable = await _googleAuthService.isAvailable;
      if (!isAvailable) {
        emit(GoogleSignInUnavailable('Войдите через электронную почту'));
        return;
      }
      
      final googleAuth = await _googleAuthService.signIn();
      if (googleAuth != null) {
        // При наличии ID токена - создаем Firebase credential
        if (googleAuth['idToken'] != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth['accessToken'],
            idToken: googleAuth['idToken'],
          );
          final userCredential = await _firebaseAuth.signInWithCredential(credential);
          if (userCredential.user != null) {
            emit(Authenticated(userCredential.user!));
          } else {
            emit(AuthFailure('Ошибка аутентификации'));
          }
        } else {
          emit(AuthFailure('Не удалось получить токен'));
        }
      } else {
        emit(UnAuthenticated());
      }
    } catch (e) {
      emit(AuthFailure('Ошибка Google Sign-In: ${e.toString()}'));
    }
  }

  // Проверка доступности Google Sign-In
  Future<void> _onCheckGoogleSignInAvailability(CheckGoogleSignInAvailability event, Emitter<AuthState> emit) async {
    try {
      final isAvailable = await _googleAuthService.isAvailable;
      emit(GoogleSignInAvailable(isAvailable));
    } catch (e) {
      emit(GoogleSignInUnavailable('Ошибка проверки: ${e.toString()}'));
    }
  }
}
