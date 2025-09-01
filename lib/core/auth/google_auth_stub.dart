// lib/core/auth/google_auth_stub.dart
// Заглушка для iOS, когда google_sign_in недоступен
import 'auth_service_interface.dart';

class GoogleAuthService implements AuthServiceInterface {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<Map<String, dynamic>?> signIn() async {
    throw UnsupportedError(
      'Google Sign-In не поддерживается на данной платформе. '
      'Используйте альтернативные методы аутентификации.',
    );
  }

  @override
  Future<void> signOut() async {
    // Ничего не делаем, так как Google Sign-In недоступен
  }

  @override
  Future<bool> isSignedIn() async => false;
}