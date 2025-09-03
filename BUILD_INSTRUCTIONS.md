# 📱 Инструкции по сборке iOS приложения для AltStore

## 🎯 Цель
Собрать IPA файл через GitHub Actions для установки через AltStore без аккаунта разработчика Apple.

## 🔧 Что исправлено

### 1. Совместимость версий SDK и пакетов
- **Flutter версия**: обновлена до 3.35.2 (последняя стабильная)
- **Dart SDK**: `>=3.5.0 <4.0.0` (совместимо с Flutter 3.35.2)
- **Firebase SDK**: обновлены до последних стабильных версий
  - `firebase_core: ^3.8.0`
  - `firebase_auth: ^5.3.3`
  - `cloud_firestore: ^5.5.0`
  - `firebase_storage: ^12.3.6`
  - `firebase_remote_config: ^5.1.8`
- **Другие пакеты**: используются последние совместимые версии

### 2. Flutter версия в GitHub Actions
- Обновлена до `3.35.2` (соответствует вашей локальной версии)

### 3. Podfile конфигурация (исправлена для CocoaPods 1.16+)
- **Совместимость**: убрана проблемная конструкция `installer.project.targets`
- **iOS deployment target**: 13.0 (для лучшей совместимости с AltStore)
- **Резервный Podfile**: создан минимальный вариант для автоматического переключения
- **Bitcode**: отключен (не нужен для AltStore)
- **Автоматическое восстановление**: GitHub Actions переключится на минимальный Podfile при ошибке

### 4. GitHub Actions workflow
- Добавлена возможность ручного запуска
- Улучшена очистка кэшей
- Добавлены проверки и диагностика
- Увеличен timeout до 60 минут
- Добавлено сохранение логов при ошибках

## 🚀 Как запустить сборку

### Вариант 1: Автоматически при push
```bash
git add .
git commit -m "fix: исправлены проблемы сборки iOS"
git push origin main
```

### Вариант 2: Ручной запуск
1. Зайдите в GitHub → Actions
2. Выберите "Flutter iOS Build for AltStore"
3. Нажмите "Run workflow"
4. Выберите ветку и нажмите "Run workflow"

## 🔍 Локальная диагностика и сборка (Windows)

### Полная локальная сборка IPA
```powershell
# Полная сборка IPA для AltStore
powershell -ExecutionPolicy Bypass -File scripts\build_ipa_local.ps1
```

### Диагностические скрипты
```powershell
# Диагностика Silent Fail (новый!)
powershell -ExecutionPolicy Bypass -File scripts\diagnose_silent_fail.ps1

# С альтернативными методами сборки
powershell -ExecutionPolicy Bypass -File scripts\diagnose_silent_fail.ps1 -AlternativeMethods -Verbose

# Тестирование исправлений белого экрана
powershell -ExecutionPolicy Bypass -File scripts\test_white_screen_fix.ps1

# Диагностика проблем с IPA
powershell -ExecutionPolicy Bypass -File scripts\diagnose_ipa_issues.ps1

# Детальная диагностика с исправлениями
powershell -ExecutionPolicy Bypass -File scripts\diagnose_ipa_issues.ps1 -Detailed -FixIssues

# Общая диагностика
powershell -ExecutionPolicy Bypass -File scripts\fix_ios_build.ps1

# Проверка готовности к сборке
powershell -ExecutionPolicy Bypass -File scripts\check_build_readiness.ps1

# Тестирование Podfile
powershell -ExecutionPolicy Bypass -File scripts\test_podfile.ps1

# Проверка iOS конфигурации
powershell -ExecutionPolicy Bypass -File scripts\check_ios_readiness.ps1
```

## 📦 Результат сборки

После успешной сборки:
1. Зайдите в GitHub → Actions → последний запуск
2. Скачайте артефакт `taste-smoke-ios-altstore`
3. Внутри будет IPA файл для установки через AltStore

## 🛠️ Установка через AltStore

1. Установите AltStore на iPhone
2. Подключите iPhone к компьютеру
3. Откройте AltServer на компьютере
4. Перетащите IPA файл в AltStore на iPhone
5. Приложение установится без аккаунта разработчика

## ❗ Важные моменты

- **Без аккаунта разработчика**: Приложение будет работать 7 дней, потом нужно переустановить
- **AltStore требует**: Компьютер с AltServer должен быть в той же сети Wi-Fi
- **Обновления**: Каждые 7 дней нужно обновлять через AltStore
- **Ограничения**: Максимум 3 приложения одновременно без платного аккаунта

## 🐛 Решение проблем

### ✅ Проблемы с созданием IPA - РЕШЕНО!
Если видите ошибку "Папка build/ios/ipa не существует":
- 📖 **Подробное руководство**: см. `IPA_BUILD_FIX.md`
- ✅ **Автоматическое исправление**: workflow теперь использует двухэтапную стратегию сборки
- ✅ **Альтернативный метод**: создание IPA вручную из app bundle
- ✅ **Улучшенная диагностика**: подробные логи и проверки

### 🔍 Проблемы с "Silent Fail" - НОВАЯ ДИАГНОСТИКА!
Если `flutter build ipa` завершается успешно, но IPA не создается:
- 📖 **Детальное руководство**: см. `SILENT_FAIL_DIAGNOSIS.md`
- 🔍 **Максимальная диагностика**: workflow теперь перехватывает все скрытые ошибки
- 🛠️ **Альтернативные методы**: прямой xcodebuild + ручное создание IPA
- 📊 **Системный мониторинг**: отслеживание ресурсов и процессов
- 🧪 **Локальная диагностика**: `.\scripts\diagnose_silent_fail.ps1`

### 🔧 Проблема с белым экраном - НОВОЕ РЕШЕНИЕ!
Если приложение установилось, но показывает белый экран:
- 📖 **Подробное руководство**: см. `WHITE_SCREEN_FIX.md`
- ✅ **Улучшенная инициализация**: обработка ошибок Firebase и BLoC
- ✅ **Простые экраны**: заменены сложные экраны на простые для диагностики
- ✅ **Экран ошибок**: показывает проблемы вместо белого экрана
- 🧪 **Тест исправлений**: `.\scripts\test_white_screen_fix.ps1`

### 🚨 Ошибка CocoaPods post_install - ЭКСТРЕННОЕ ИСПРАВЛЕНИЕ!
Если сборка продолжает падать на этапе `pod install`:
- 📖 **Экстренные меры**: см. `EMERGENCY_FIX.md`
- 🔧 **Временно активен простой workflow**: `simple.yml`
- 🔧 **Основной workflow отключен**: `main.yml` (только ручной запуск)
- 🔧 **Ультра-минимальный Podfile**: убрано все лишнее для диагностики
- ✅ **Цель**: определить базовую работоспособность, затем постепенно восстановить функциональность

### Проблемы с CocoaPods
Если видите ошибку `undefined method 'project' for Pod::Installer`:
- ✅ **Автоматическое исправление**: GitHub Actions переключится на минимальный Podfile
- ✅ **Резервный план**: создан совместимый Podfile.minimal
- ✅ **Логи**: проверьте, произошло ли переключение в логах Actions

### Общие проблемы
1. Проверьте логи в GitHub Actions
2. Скачайте артефакт `build-logs` при ошибке  
3. Запустите локальную диагностику: `scripts\test_podfile.ps1`
4. Проверьте совместимость версий зависимостей

## 📋 Чек-лист перед сборкой

- [ ] ✅ **Dart SDK**: `>=3.5.0 <4.0.0` (совместимо с Flutter 3.35.2)
- [ ] ✅ **Flutter версия**: 3.35.2 в workflow
- [ ] ✅ **Firebase SDK**: обновлены до последних стабильных версий (3.x.x, 5.x.x)
- [ ] ✅ **Другие пакеты**: понижены до совместимых версий
- [ ] ✅ **iOS deployment target**: 13.0
- [ ] ✅ **Podfile**: содержит принудительные версии Firebase
- [ ] ✅ **Google Sign-In**: закомментирован в pubspec.yaml
- [ ] ✅ **Info.plist**: не содержит Google URL schemes
- [ ] ✅ **Код**: не содержит прямых импортов google_sign_in

## 🔗 Полезные ссылки

- [AltStore официальный сайт](https://altstore.io/)
- [Flutter iOS deployment](https://docs.flutter.dev/deployment/ios)
- [Firebase Flutter setup](https://firebase.flutter.dev/docs/overview)