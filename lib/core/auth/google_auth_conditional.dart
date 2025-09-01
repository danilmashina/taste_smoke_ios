// lib/core/auth/google_auth_conditional.dart
// Условная реализация без прямых импортов google_sign_in
import 'dart:io';
import 'auth_service_interface.dart';

// Создаем сервис в зависимости от платформы
class GoogleAuthService implements AuthServiceInterface {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();
  
  @override
  Future<bool> get isAvailable async {
    // Google Sign-In временно недоступен на всех платформах
    // из-за конфликта зависимостей в iOS
    return false;
  }
  
  @override
  Future<Map<String, dynamic>?> signIn() async {
    if (Platform.isIOS) {
      throw UnsupportedError(
        'Google Sign-In временно недоступен на iOS из-за конфликта зависимостей. '
        'Используйте Email/пароль для входа.'
      );
    } else {
      // На Android тоже временно используем заглушку,
      // так как google_sign_in закомментирован в pubspec.yaml
      throw UnsupportedError(
        'Google Sign-In временно недоступен. '
        'Используйте Email/пароль для входа.'
      );
    }
  }
  
  @override
  Future<void> signOut() async {
    // Ничего не делаем, так как Google Sign-In недоступен
  }
  
  @override
  Future<bool> isSignedIn() async => false;
}