// Пример идеального Platform-aware кода для Flutter
// Этот файл демонстрирует, как правильно изолировать платформо-зависимый код

import 'dart:io' show Platform;

/// Абстрактный интерфейс для аутентификации
abstract class PlatformAuthInterface {
  Future<bool> get isAvailable;
  Future<Map<String, dynamic>?> signIn();
  Future<void> signOut();
  Future<bool> get isSignedIn;
}

/// Фабрика для создания платформо-специфичных реализаций
class PlatformAuthFactory {
  static PlatformAuthInterface create() {
    if (Platform.isIOS) {
      return IOSAuthStub();
    } else if (Platform.isAndroid) {
      return AndroidAuthStub();
    } else {
      return WebAuthStub();
    }
  }
}

/// Заглушка для iOS (когда google_sign_in недоступен)
class IOSAuthStub implements PlatformAuthInterface {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<Map<String, dynamic>?> signIn() async {
    throw UnsupportedError(
      'Google Sign-In временно недоступен на iOS из-за конфликта зависимостей. '
      'Используйте Email/пароль для входа.'
    );
  }

  @override
  Future<void> signOut() async {
    // Ничего не делаем для iOS
  }

  @override
  Future<bool> get isSignedIn async => false;
}

/// Заглушка для Android (можно заменить на реальную реализацию)
class AndroidAuthStub implements PlatformAuthInterface {
  @override
  Future<bool> get isAvailable async => false; // Временно отключено

  @override
  Future<Map<String, dynamic>?> signIn() async {
    throw UnsupportedError(
      'Google Sign-In временно недоступен. '
      'Используйте Email/пароль для входа.'
    );
  }

  @override
  Future<void> signOut() async {
    // Заглушка для Android
  }

  @override
  Future<bool> get isSignedIn async => false;
}

/// Заглушка для Web
class WebAuthStub implements PlatformAuthInterface {
  @override
  Future<bool> get isAvailable async => false;

  @override
  Future<Map<String, dynamic>?> signIn() async {
    throw UnsupportedError(
      'Google Sign-In недоступен в веб-версии.'
    );
  }

  @override
  Future<void> signOut() async {
    // Заглушка для Web
  }

  @override
  Future<bool> get isSignedIn async => false;
}

// ПРИМЕР ИСПОЛЬЗОВАНИЯ В UI:
/*
class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = PlatformAuthFactory.create();
    
    return FutureBuilder<bool>(
      future: authService.isAvailable,
      builder: (context, snapshot) {
        final isAvailable = snapshot.data ?? false;
        
        if (isAvailable) {
          return ElevatedButton(
            onPressed: () async {
              try {
                await authService.signIn();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text('Войти через Google'),
          );
        } else {
          return Column(
            children: [
              Text('Google Sign-In недоступен'),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/email-login'),
                child: Text('Войти через Email'),
              ),
            ],
          );
        }
      },
    );
  }
}
*/