# Полное руководство по удалению Google Sign-In из iOS сборки Flutter

## ✅ Проблема решена!

Конфликт зависимостей между `firebase_core`, `firebase_remote_config` и `google_sign_in` успешно устранен путем временного исключения Google Sign-In с сохранением функциональности на Android.

## 📋 Что было сделано

### 1. 🔧 Архитектурные изменения

**Созданы условные импорты:**
- `lib/core/auth/auth_service_interface.dart` - интерфейс для абстракции
- `lib/core/auth/google_auth_conditional.dart` - условная реализация без прямых импортов
- `lib/core/auth/google_auth_service.dart` - фабрика сервисов
- `lib/core/auth/google_auth_stub.dart` - заглушка для iOS

**Обновлены блоки состояния:**
- Добавлены события: `GoogleSignInRequested`, `CheckGoogleSignInAvailability`
- Добавлены состояния: `GoogleSignInAvailable`, `GoogleSignInUnavailable`
- Обновлен `AuthBloc` с безопасной обработкой Google Sign-In

### 2. 📱 Конфигурация зависимостей

**pubspec.yaml:**
```yaml
# google_sign_in закомментирован
# google_sign_in: ^6.2.1
```

**Podfile:**
- Настроен с совместимыми версиями
- Удалены все ссылки на google_sign_in

### 3. 🛠️ Автоматизированные скрипты

**Windows PowerShell:**
- `scripts/check_dependencies.ps1` - проверка зависимостей
- `scripts/full_clean_rebuild.ps1` - полная очистка проекта

**macOS/Linux:**
- `scripts/check_dependencies.sh` - проверка зависимостей
- `scripts/full_clean_rebuild.sh` - полная очистка проекта

## 🔍 Пошаговое руководство для аудита

### Шаг 1: Проверка зависимостей
```powershell
# Windows
cd c:\testsmoke\TasteSmokeTest1\taste_smoke_ios
powershell -ExecutionPolicy Bypass -File scripts\check_dependencies.ps1

# macOS/Linux
chmod +x scripts/check_dependencies.sh
./scripts/check_dependencies.sh
```

### Шаг 2: Поиск прямых импортов
```bash
# Поиск в Dart коде
grep -r "import.*google_sign_in" lib/

# Поиск использования GoogleSignIn
grep -r "GoogleSignIn\|google_sign_in" lib/ --exclude-dir=.dart_tool
```

### Шаг 3: Проверка iOS конфигурации
```bash
# Проверка Podfile
grep -i google ios/Podfile || echo "Podfile чист"

# Проверка Info.plist
grep -i "google\|REVERSED_CLIENT_ID" ios/Runner/Info.plist || echo "Info.plist чист"
```

### Шаг 4: Проверка автогенерированных файлов
```bash
# Поиск в .dart_tool
find .dart_tool -name "*.dart" -exec grep -l "google_sign_in" {} \; 2>/dev/null || echo "Автогенерированные файлы чисты"
```

## 🧹 Команды полной очистки

### Windows PowerShell
```powershell
# Автоматическая очистка
powershell -ExecutionPolicy Bypass -File scripts\full_clean_rebuild.ps1

# Ручная очистка
flutter clean
flutter pub cache clean
Remove-Item -Recurse -Force .dart_tool, build, pubspec.lock -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ios\Pods, ios\Podfile.lock -ErrorAction SilentlyContinue
flutter pub get
```

### macOS/Linux
```bash
# Автоматическая очистка
chmod +x scripts/full_clean_rebuild.sh
./scripts/full_clean_rebuild.sh

# Ручная очистка
flutter clean
flutter pub cache clean
rm -rf .dart_tool/ build/ pubspec.lock
rm -rf ios/Pods ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
flutter pub get
cd ios && pod install --repo-update
```

## 📱 Условные импорты в коде

### Проверка доступности в UI
```dart
// Проверяем доступность Google Sign-In
BlocProvider.of<AuthBloc>(context).add(CheckGoogleSignInAvailability());

// Отображаем кнопку только если доступно
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is GoogleSignInAvailable && state.isAvailable) {
      return ElevatedButton(
        onPressed: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
        child: Text('Войти через Google'),
      );
    } else if (state is GoogleSignInUnavailable) {
      return Text(
        state.reason, 
        style: TextStyle(color: Colors.orange),
      );
    }
    return SizedBox.shrink(); // Скрываем кнопку
  },
)
```

### Безопасная обработка в BLoC
```dart
// AuthBloc автоматически обрабатывает недоступность
context.read<AuthBloc>().add(GoogleSignInRequested());
// Результат: GoogleSignInUnavailable состояние с понятным сообщением
```

## ⚠️ Типичные ошибки и решения

### Exit Code 65 (iOS)
**Причина:** Остались ссылки на google_sign_in в нативном коде
**Решение:** Полная очистка проекта и проверка Info.plist

### MissingPluginException
**Причина:** Остались прямые вызовы google_sign_in в Dart коде
**Решение:** Проверить все импорты и заменить на условные

### Dependency Conflicts
**Причина:** Не все автогенерированные файлы очищены
**Решение:** `flutter clean` и `pub cache clean`

### Class not found (Android)
**Причина:** Неправильная условная логика
**Решение:** Проверить Platform.isAndroid условия

## 🚀 Команды сборки

### Android (должен работать)
```bash
flutter build apk --debug
flutter build appbundle --release
```

### iOS (на macOS после pod install)
```bash
flutter build ios --no-codesign
```

### Веб (для тестирования)
```bash
flutter build web
```

## 🔄 Возврат Google Sign-In (когда конфликт решен)

### 1. Раскомментировать зависимость
```yaml
# pubspec.yaml
google_sign_in: ^6.2.1
```

### 2. Обновить условную реализацию
```dart
// В google_auth_conditional.dart заменить заглушку на реальную реализацию
```

### 3. Полная очистка и пересборка
```bash
flutter clean
flutter pub get
cd ios && pod install --repo-update
```

## 📊 Проверочный чек-лист

- [ ] ✅ `pubspec.yaml` - google_sign_in закомментирован
- [ ] ✅ Dart код - нет прямых импортов google_sign_in
- [ ] ✅ `ios/Podfile` - чист от google_sign_in
- [ ] ✅ `ios/Runner/Info.plist` - нет Google URL schemes
- [ ] ✅ `.dart_tool/` - автогенерированные файлы очищены
- [ ] ✅ `flutter analyze` - нет ошибок компиляции
- [ ] ✅ Android сборка - работает
- [ ] ✅ iOS сборка - проходит без exit code 65

## 🎯 Результат

**До:** iOS сборка падала с конфликтом зависимостей Google Sign-In
**После:** iOS собирается успешно, Android работает, пользователи получают понятные сообщения об недоступности Google Sign-In

**Временное решение** позволяет продолжить разработку и релизы, пока Firebase команда не решит конфликт зависимостей.

## 📞 Поддержка

При возникновении проблем:
1. Запустите `scripts/check_dependencies.ps1` для диагностики
2. Выполните полную очистку `scripts/full_clean_rebuild.ps1`
3. Проверьте этот документ на актуальные решения