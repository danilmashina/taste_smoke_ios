# 🔍 Чек-лист диагностики проблем с созданием IPA

## 📋 Основные причины отсутствия IPA файла

### 1. 🚫 Flutter build ipa "успешно" завершается, но IPA не создается

**Симптомы:**
- Команда `flutter build ipa` возвращает код 0
- В логах видны dSYM файлы для библиотек
- Папка `build/ios/ipa/` не создается или пуста

**Причины:**
- Неправильные настройки подписи кода
- Проблемы с bundle identifier
- Ошибки в Info.plist
- Недостаточные права доступа

**Что проверить в логах:**
```bash
# Ищите эти строки в логах flutter build ipa:
"Building for device"
"Running Xcode build"
"Build succeeded"
"Built build/ios/ipa/Runner.ipa"  # ← Эта строка должна быть!
```

### 2. 🔧 Проблемы с настройками Xcode

**Симптомы:**
- Архив создается, но не упаковывается в IPA
- Ошибки типа "Code signing is required"
- Проблемы с provisioning profile

**Что проверить:**
```bash
# В логах ищите:
"Code Sign error"
"Provisioning profile"
"DEVELOPMENT_TEAM"
"CODE_SIGN_IDENTITY"
```

### 3. 📱 Проблемы с bundle identifier

**Симптомы:**
- Ошибки валидации приложения
- Конфликты с существующими приложениями

**Проверка:**
- Bundle ID должен быть уникальным
- Не должен содержать `com.example.*`
- Должен соответствовать формату reverse DNS

## 🔍 Детальный чек-лист диагностики

### Этап 1: Проверка окружения

- [ ] **Flutter версия корректна**
  ```bash
  flutter --version  # Должна быть 3.35.2
  ```

- [ ] **Xcode установлен и настроен**
  ```bash
  xcode-select -p
  xcrun --show-sdk-path
  ```

- [ ] **CocoaPods установлен**
  ```bash
  pod --version  # Должна быть >= 1.10
  ```

### Этап 2: Проверка проекта

- [ ] **Структура iOS проекта**
  ```bash
  ls -la ios/Runner.xcodeproj/
  ls -la ios/Runner.xcworkspace/
  ls -la ios/Pods/
  ```

- [ ] **Flutter конфигурация**
  ```bash
  ls -la ios/Flutter/Generated.xcconfig
  cat ios/Flutter/Release.xcconfig
  ```

- [ ] **Info.plist корректен**
  ```bash
  cat ios/Runner/Info.plist | grep -A1 CFBundleIdentifier
  ```

### Этап 3: Анализ логов сборки

#### 🔍 Ключевые строки в логах flutter build ipa:

**Успешное начало:**
```
Building for device (ios-release)...
Running pod install...
Running Xcode build...
```

**Проблемы с подписью:**
```
Code Sign error: No code signing identities found
Provisioning profile "..." doesn't include signing certificate
```

**Проблемы с архивацией:**
```
Archive failed
Export failed
Unable to export archive
```

**Успешное завершение (должно быть!):**
```
Built build/ios/ipa/Runner.ipa (XX.XMB)
```

#### 🚨 Критические ошибки:

1. **"No such file or directory: build/ios/ipa"**
   - Папка не создалась = архивация не прошла

2. **"Archive does not contain a single bundle"**
   - Проблемы с bundle structure

3. **"Unable to validate your application"**
   - Проблемы с Info.plist или entitlements

### Этап 4: Проверка результата

- [ ] **Папка build/ios/ipa существует**
  ```bash
  ls -la build/ios/ipa/
  ```

- [ ] **IPA файл создан и корректен**
  ```bash
  file build/ios/ipa/*.ipa  # Должен быть "Zip archive"
  du -h build/ios/ipa/*.ipa  # Размер > 1MB
  ```

- [ ] **Содержимое IPA корректно**
  ```bash
  unzip -l build/ios/ipa/*.ipa | grep "Payload/.*\.app/"
  ```

## 🛠️ Методы исправления

### Метод 1: Исправление настроек подписи

```bash
# Создание правильного xcconfig для unsigned сборки
cat > ios/Flutter/Unsigned.xcconfig << 'EOF'
#include "Generated.xcconfig"
CODE_SIGN_IDENTITY=
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
PROVISIONING_PROFILE_SPECIFIER=
DEVELOPMENT_TEAM=
ENABLE_BITCODE=NO
SKIP_INSTALL=NO
EOF
```

### Метод 2: Альтернативная сборка через flutter build ios

```bash
# Если flutter build ipa не работает
flutter build ios --release --no-codesign

# Создание IPA вручную
cd build/ios/iphoneos
mkdir Payload
cp -r Runner.app Payload/
zip -r ../ipa/Runner.ipa Payload/
```

### Метод 3: Проверка и исправление bundle identifier

```bash
# В ios/Runner.xcodeproj/project.pbxproj найти и изменить:
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.yourapp;
```

## 📊 Диагностические команды

### Проверка состояния сборки:
```bash
# Полная структура build/
find build/ -type f | head -20

# Поиск всех IPA файлов
find . -name "*.ipa" -type f

# Поиск архивов Xcode
find build/ -name "*.xcarchive" -type d

# Проверка логов Flutter
grep -i "error\|failed\|exception" flutter_logs/*.log
```

### Проверка созданного IPA:
```bash
# Базовая проверка
file build/ios/ipa/*.ipa
unzip -l build/ios/ipa/*.ipa | head -10

# Детальная проверка содержимого
unzip -q build/ios/ipa/*.ipa -d temp_ipa/
ls -la temp_ipa/Payload/
```

## 🎯 Частые решения

### Проблема: "flutter build ipa завершается успешно, но IPA не создается"

**Решение:**
1. Проверить настройки подписи в xcconfig
2. Убедиться, что bundle identifier уникален
3. Проверить права доступа к папке build/
4. Использовать альтернативный метод через flutter build ios

### Проблема: "IPA создается, но слишком маленький размер"

**Решение:**
1. Проверить, что все ресурсы включены в сборку
2. Убедиться, что Flutter assets правильно настроены
3. Проверить, что все зависимости установлены

### Проблема: "IPA создается, но не устанавливается через AltStore"

**Решение:**
1. Проверить bundle identifier (не должен быть com.example.*)
2. Убедиться, что минимальная версия iOS корректна
3. Проверить Info.plist на наличие обязательных ключей

## 📞 Когда обращаться за помощью

Если после выполнения всех шагов проблема не решена, соберите следующую информацию:

1. **Логи Flutter build**: `flutter_logs/flutter_build_ipa.log`
2. **Структура build/**: `find build/ -type f`
3. **Настройки проекта**: содержимое `ios/Flutter/*.xcconfig`
4. **Версии инструментов**: `flutter doctor -v`
5. **Содержимое Info.plist**: `cat ios/Runner/Info.plist`

Эта информация поможет быстро диагностировать и решить проблему.