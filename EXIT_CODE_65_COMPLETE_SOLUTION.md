# Полное решение проблемы iOS Exit Code 65 в Flutter

## 🎯 Краткое описание проблемы

Exit Code 65 в Xcode обычно указывает на:
- Конфликты зависимостей плагинов
- Неправильные ссылки в project.pbxproj
- Остаточные импорты удаленных плагинов
- Проблемы с Info.plist или автогенерированными файлами

## 🔍 1. Диагностика проблемы

### Шаг 1.1: Запустите полную диагностику
```powershell
# Windows
powershell -ExecutionPolicy Bypass -File scripts\diagnose_exit_code_65.ps1

# Альтернатива - глубокий поиск Google Sign-In
powershell -ExecutionPolicy Bypass -File scripts\deep_google_search.ps1
```

### Шаг 1.2: Проверьте GitHub Actions лог
Ищите в логах GitHub Actions:
- `ld: symbol(s) not found for architecture`
- `Undefined symbols for architecture`
- `GoogleSignIn` упоминания
- `MissingPluginException`

## 🧹 2. Радикальная очистка проекта

### Шаг 2.1: Запустите ядерную очистку
```powershell
# ВНИМАНИЕ: Это удалит ВСЕ build артефакты
powershell -ExecutionPolicy Bypass -File scripts\nuclear_clean_ios.ps1
```

### Шаг 2.2: Ручная очистка (если скрипт не помог)
```bash
# 1. Flutter cleanup
flutter clean
flutter pub cache clean --force
rm -rf .dart_tool build pubspec.lock

# 2. iOS cleanup  
rm -rf ios/Pods ios/build ios/.symlinks
rm -f ios/Podfile.lock
rm -f ios/Flutter/Generated.xcconfig
rm -f ios/Flutter/flutter_export_environment.sh
rm -f ios/Runner/GeneratedPluginRegistrant.*

# 3. System cleanup (macOS)
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/CocoaPods
```

## 🔧 3. Устранение остаточных ссылок

### Шаг 3.1: Проверьте pubspec.yaml
```yaml
dependencies:
  # ✅ ПРАВИЛЬНО - закомментировано
  # google_sign_in: ^6.2.1
  
  # ❌ НЕПРАВИЛЬНО - активно
  # google_sign_in: ^6.2.1
```

### Шаг 3.2: Проверьте Info.plist
```xml
<!-- ❌ УДАЛИТЕ ВСЕ ТАКИЕ БЛОКИ -->
<!-- 
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>REVERSED_CLIENT_ID</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.XXXXXXXXX</string>
    </array>
  </dict>
</array>
-->
```

### Шаг 3.3: Проверьте Dart код на прямые импорты
```dart
// ❌ ТАКОГО НЕ ДОЛЖНО БЫТЬ:
// import 'package:google_sign_in/google_sign_in.dart';

// ✅ ПРАВИЛЬНО - условные импорты:
import 'dart:io' show Platform;
import '../auth/platform_auth_example.dart';
```

## 📱 4. Правильная Platform-aware реализация

### Шаг 4.1: Создайте интерфейс
```dart
// lib/core/auth/auth_interface.dart
abstract class AuthInterface {
  Future<bool> get isAvailable;
  Future<Map<String, dynamic>?> signIn();
  Future<void> signOut();
}
```

### Шаг 4.2: Создайте платформо-специфичные заглушки
```dart
// lib/core/auth/platform_auth.dart
import 'dart:io';

class PlatformAuth implements AuthInterface {
  @override
  Future<bool> get isAvailable async {
    // Google Sign-In недоступен на всех платформах
    return false;
  }

  @override
  Future<Map<String, dynamic>?> signIn() async {
    if (Platform.isIOS) {
      throw UnsupportedError('Google Sign-In недоступен на iOS');
    } else {
      throw UnsupportedError('Google Sign-In временно отключен');
    }
  }

  @override
  Future<void> signOut() async {
    // Заглушка
  }
}
```

### Шаг 4.3: Используйте в UI безопасно
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = PlatformAuth();
    
    return FutureBuilder<bool>(
      future: auth.isAvailable,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return GoogleSignInButton(); // Показываем кнопку
        } else {
          return EmailSignInForm(); // Показываем альтернативу
        }
      },
    );
  }
}
```

## 🔄 5. Пересборка проекта

### Шаг 5.1: Последовательность команд
```bash
# 1. Установите зависимости
flutter pub get

# 2. На macOS - установите pods
cd ios
pod repo update
pod install --repo-update --verbose
cd ..

# 3. Попробуйте сборку с verbose
flutter build ios --no-codesign --verbose
```

### Шаг 5.2: Если все еще падает с exit code 65
```bash
# Дополнительная диагностика
flutter doctor -v
flutter analyze
flutter test

# Проверьте конкретные ошибки в Xcode
open ios/Runner.xcworkspace
# Попробуйте собрать в Xcode напрямую
```

## 🚨 6. Специфичные причины exit code 65

### Причина 1: Остаточные ссылки в project.pbxproj
**Симптом:** `ld: framework not found GoogleSignIn`
**Решение:** 
```bash
# Найдите и удалите вручную в project.pbxproj:
grep -n "GoogleSignIn\|google_sign_in" ios/Runner.xcodeproj/project.pbxproj
# Удалите найденные строки вручную
```

### Причина 2: Неправильная версия iOS Deployment Target
**Симптом:** `iOS deployment target '9.0' is less than minimum required`
**Решение:** Убедитесь что в project.pbxproj:
```
IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```

### Причина 3: Конфликт Firebase SDK версий
**Симптом:** `duplicate symbol` ошибки
**Решение:** Обновите Podfile:
```ruby
# ios/Podfile
platform :ios, '13.0'
source 'https://cdn.cocoapods.org/'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Принудительные версии для совместимости
  pod 'GoogleUtilities', '~> 7.8'
end
```

### Причина 4: Поврежденная автогенерация плагинов
**Симптом:** `GeneratedPluginRegistrant` ошибки
**Решение:**
```bash
# Удалите автогенерированные файлы
rm ios/Runner/GeneratedPluginRegistrant.*
rm ios/Flutter/Generated.xcconfig

# Регенерируйте
flutter clean
flutter pub get
```

## ✅ 7. Проверочный чек-лист

- [ ] ✅ `pubspec.yaml` - google_sign_in закомментирован
- [ ] ✅ `pubspec.lock` - нет упоминаний google_sign_in  
- [ ] ✅ `Info.plist` - нет Google URL schemes
- [ ] ✅ `project.pbxproj` - нет ссылок на GoogleSignIn
- [ ] ✅ `GeneratedPluginRegistrant.*` - нет google_sign_in импортов
- [ ] ✅ Dart код - только условные импорты
- [ ] ✅ Build folders очищены
- [ ] ✅ CocoaPods cache очищен
- [ ] ✅ `flutter analyze` проходит без ошибок
- [ ] ✅ `flutter doctor` показывает OK

## 🎯 8. Финальная проверка

```bash
# 1. Последняя проверка чистоты
flutter analyze
flutter test

# 2. Локальная сборка (если на macOS)
flutter build ios --no-codesign --verbose

# 3. Коммит изменений
git add .
git commit -m "fix: устранены все причины iOS exit code 65"
git push

# 4. Проверка GitHub Actions
# Зайдите в GitHub и проследите за сборкой
```

## 🆘 9. Если ничего не помогает

### Последние средства:
1. **Создайте новый Flutter проект** и перенесите код поэтапно
2. **Проверьте версии:**
   - Flutter SDK: должен быть latest stable
   - Xcode: должен быть совместим с Flutter версией
   - iOS Deployment Target: 13.0+
3. **Обратитесь к сообществу:**
   - Flutter GitHub Issues
   - Stack Overflow с полным логом ошибки
   - Flutter Discord/Slack

Помните: Exit code 65 почти всегда решается полной очисткой и правильным удалением всех ссылок на проблемный плагин.