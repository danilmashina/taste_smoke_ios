// lib/core/auth/google_auth_conditional.dart
// Условная реализация в зависимости от платформы
import 'dart:io';
import 'auth_service_interface.dart';

AuthServiceInterface _createGoogleAuthService() {
  if (Platform.isIOS) {
    // Для iOS возвращаем заглушку
    return _GoogleAuthStub();
  } else {
    // Для Android/других платформ возвращаем реальную реализацию
    // НО! Поскольку google_sign_in недоступен, используем заглушку везде
    return _GoogleAuthStub();
  }
}

class GoogleAuthService implements AuthServiceInterface {
  static final AuthServiceInterface _instance = _createGoogleAuthService();
  
  @override
  Future<bool> get isAvailable => _instance.isAvailable;
  
  @override
  Future<Map<String, dynamic>?> signIn() => _instance.signIn();
  
  @override
  Future<void> signOut() => _instance.signOut();
  
  @override
  Future<bool> isSignedIn() => _instance.isSignedIn();
}

class _GoogleAuthStub implements AuthServiceInterface {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<Map<String, dynamic>?> signIn() async {
    throw UnsupportedError(
      'Google Sign-In временно недоступен. '
      'Используйте Email/пароль для входа.',
    );
  }

  @override
  Future<void> signOut() async {
    // Ничего не делаем
  }

  @override
  Future<bool> isSignedIn() async => false;
}