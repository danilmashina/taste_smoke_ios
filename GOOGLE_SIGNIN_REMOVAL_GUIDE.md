# Руководство по исключению Google Sign-In из iOS сборки

## Проблема
Конфликт зависимостей между firebase_core, firebase_remote_config и google_sign_in приводит к невозможности сборки iOS приложения.

## Решение
Временное исключение google_sign_in с сохранением функциональности для Android.

## Реализованные изменения

### 1. Условные импорты и заглушки
Созданы файлы:
- `lib/core/auth/auth_service_interface.dart` - интерфейс
- `lib/core/auth/google_auth_stub.dart` - заглушка для iOS
- `lib/core/auth/google_auth_real.dart` - реальная реализация для Android
- `lib/core/auth/google_auth_conditional.dart` - условная логика
- `lib/core/auth/google_auth_service.dart` - фабрика сервисов

### 2. Обновленные блоки
- Добавлены события: `GoogleSignInRequested`, `CheckGoogleSignInAvailability`
- Добавлены состояния: `GoogleSignInAvailable`, `GoogleSignInUnavailable`
- Обновлен `AuthBloc` с поддержкой условного Google Auth

### 3. Конфигурация зависимостей
```yaml
# pubspec.yaml - google_sign_in закомментирован
# google_sign_in: ^6.2.1
```

## Команды для применения изменений

### Автоматическая очистка
```bash
chmod +x scripts/full_clean_rebuild.sh
./scripts/full_clean_rebuild.sh
```

### Ручная очистка
```bash
# 1. Очистка Flutter
flutter clean
flutter pub cache clean
rm -rf .dart_tool/ build/ pubspec.lock

# 2. Очистка iOS
cd ios
rm -rf Pods/ Podfile.lock
pod cache clean --all
cd ..

# 3. Переустановка
flutter pub get
cd ios && pod install --repo-update
```

## Использование в коде

### Проверка доступности
```dart
// В UI коде
BlocProvider.of<AuthBloc>(context).add(CheckGoogleSignInAvailability());

// Обработка состояния
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is GoogleSignInAvailable && state.isAvailable) {
      return GoogleSignInButton(); // Показываем кнопку
    } else if (state is GoogleSignInUnavailable) {
      return Text(state.reason); // Показываем причину недоступности
    }
    return SizedBox.shrink(); // Скрываем кнопку
  },
)
```

### Выполнение входа
```dart
// Вместо прямого вызова google_sign_in
BlocProvider.of<AuthBloc>(context).add(GoogleSignInRequested());
```

## Что проверить после изменений

### 1. Файлы конфигурации
- [ ] `pubspec.yaml` - google_sign_in закомментирован
- [ ] `ios/Podfile` - нет упоминаний google_sign_in
- [ ] `android/app/build.gradle` - настройки без изменений

### 2. Автогенерированные файлы
```bash
# Проверить отсутствие google_sign_in импортов
grep -r "google_sign_in" .dart_tool/ || echo "✅ Автогенерированные файлы чисты"
```

### 3. Компиляция
```bash
# iOS сборка (должна пройти без ошибок)
flutter build ios --no-codesign

# Android сборка (должна работать)
flutter build apk --debug
```

## Мониторинг ошибок

### Типичные ошибки и решения

**Ошибка:** "MissingPluginException: No implementation found for method"
**Решение:** Выполнить полную очистку и пересборку

**Ошибка:** "Unhandled Exception: google_sign_in"
**Решение:** Найти и заменить прямые вызовы на условные через AuthBloc

**Ошибка:** Exit code 65 при iOS сборке
**Решение:** Проверить и удалить все ссылки на google_sign_in в native коде

## Возврат Google Sign-In

Когда конфликт зависимостей будет решен:

1. Раскомментировать в `pubspec.yaml`:
```yaml
google_sign_in: ^6.2.1
```

2. Обновить `google_auth_conditional.dart`:
```dart
// Заменить заглушку на реальную реализацию
import 'google_auth_real.dart';
```

3. Выполнить полную очистку и пересборку

## Дополнительные ресурсы
- [Flutter Conditional Imports](https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files)
- [Firebase Auth без Google Sign-In](https://firebase.flutter.dev/docs/auth/usage/)
- [CocoaPods Dependency Resolution](https://guides.cocoapods.org/using/the-podfile.html)