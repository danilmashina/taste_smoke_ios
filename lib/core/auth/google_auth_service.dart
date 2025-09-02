// lib/core/auth/google_auth_service.dart
// Условный импорт в зависимости от платформы
import 'auth_service_interface.dart';

// Условные импорты
import 'google_auth_stub.dart' if (dart.library.io) 'google_auth_conditional.dart';

class GoogleAuthServiceFactory {
  static AuthServiceInterface create() {
    return GoogleAuthService();
  }
}