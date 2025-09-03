# Исправление проблемы создания IPA для AltStore

## Проблема
При сборке iOS приложения для AltStore возникала ошибка на этапе "Verify IPA creation" - папка `build/ios/ipa` не создавалась, хотя команда `flutter build ipa` завершалась без ошибок.

## Причина
Основные причины проблемы:

1. **Отсутствие настроек подписи кода**: В проекте не были правильно настроены параметры для unsigned сборки
2. **Неправильная конфигурация xcconfig**: Flutter конфигурационные файлы не содержали необходимых настроек для создания IPA без подписи
3. **Проблемы с bundle identifier**: Использовался стандартный `com.example.tasteSmokeIos` без правильной настройки для AltStore

## Решение

### 1. Обновленный workflow
Добавлены следующие улучшения в `.github/workflows/main.yml`:

- **Создание временного xcconfig файла** для unsigned сборки с правильными настройками:
  ```
  CODE_SIGN_IDENTITY=
  CODE_SIGNING_REQUIRED=NO
  CODE_SIGNING_ALLOWED=NO
  PROVISIONING_PROFILE_SPECIFIER=
  DEVELOPMENT_TEAM=
  ```

- **Альтернативный метод сборки**: Если `flutter build ipa` не работает, используется `flutter build ios` с последующим созданием IPA вручную

- **Улучшенная диагностика**: Добавлены подробные проверки и логирование для отладки проблем

### 2. Двухэтапная стратегия сборки

#### Этап 1: Прямая сборка IPA
```bash
flutter build ipa --release --no-codesign --verbose
```

#### Этап 2: Альтернативная сборка (если первая не удалась)
```bash
flutter build ios --release --no-codesign --verbose
# Затем создание IPA вручную из .app bundle
```

### 3. Улучшенная проверка результата
- Поиск IPA файлов в различных локациях
- Проверка содержимого IPA файла
- Детальная диагностика в случае ошибок

## Настройки для AltStore

Для корректной работы с AltStore убедитесь, что:

1. **Bundle Identifier** уникален (не `com.example.*`)
2. **Минимальная версия iOS** установлена правильно (сейчас 13.0)
3. **Приложение собрано без подписи** (unsigned)

## Диагностика проблем

Если сборка все еще не работает, проверьте:

1. **Структуру проекта**:
   ```bash
   ls -la ios/Runner.xcodeproj/
   ls -la ios/Runner.xcworkspace/
   ```

2. **CocoaPods установку**:
   ```bash
   ls -la ios/Pods/
   cat ios/Podfile.lock
   ```

3. **Flutter конфигурацию**:
   ```bash
   ls -la ios/Flutter/
   cat ios/Flutter/Generated.xcconfig
   ```

## Следующие шаги

После успешной сборки IPA файл можно:
1. Скачать из GitHub Actions artifacts
2. Установить через AltStore на устройство iOS
3. Протестировать функциональность приложения

## Дополнительные ресурсы

- [Flutter iOS deployment guide](https://docs.flutter.dev/deployment/ios)
- [AltStore documentation](https://altstore.io/)
- [iOS code signing guide](https://developer.apple.com/documentation/xcode/code-signing)