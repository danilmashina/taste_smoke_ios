# 🚨 Быстрое руководство по Silent Fail

## ❓ Ответы на ключевые вопросы

### 1. Где искать причину сбоя без явных ошибок?

**🎯 Приоритетные места поиска:**

1. **Между архивацией и экспортом IPA**
   - Flutter создает .xcarchive, но не экспортирует в IPA
   - Ищите: `find build/ -name "*.xcarchive"`

2. **В stderr, даже если он кажется пустым**
   - Скрытые ошибки часто попадают в stderr
   - Команда: `flutter build ipa 2> stderr.log`

3. **В системных ресурсах**
   - Нехватка места на диске
   - Нехватка памяти
   - Проблемы с правами доступа

4. **В настройках подписи кода**
   - Даже с `--no-codesign` могут быть проблемы
   - Проверить: `grep -r "CODE_SIGN" ios/`

### 2. Типовые причины Silent Fail

**🔍 Самые частые проблемы:**

#### A. Проблемы с экспортом архива (70% случаев)
```bash
# Архив создается, но не экспортируется
# Индикаторы в логах:
"Archive succeeded" ✅
"Export failed" ❌ или отсутствует "Built ... .ipa"
```

#### B. Неправильные настройки SKIP_INSTALL (20% случаев)
```bash
# В xcconfig должно быть:
SKIP_INSTALL=NO  # НЕ YES!
```

#### C. Проблемы с bundle identifier (5% случаев)
```bash
# Проблемные bundle ID:
com.example.*  # Заблокированы Apple
пустой или некорректный формат
```

#### D. Системные проблемы (5% случаев)
```bash
# Нехватка ресурсов:
df -h  # < 1GB свободного места
vm_stat  # нехватка памяти
```

### 3. Настройка максимальной диагностики в CI

**🛠️ Улучшенный workflow включает:**

```yaml
# 1. Разделение stdout и stderr
flutter build ipa --verbose > stdout.log 2> stderr.log

# 2. Мониторинг системных ресурсов
(while true; do echo "$(date): $(df -h . | tail -1)"; sleep 10; done) &

# 3. Немедленная проверка результата
find build/ -name "*.ipa" -o -name "*.xcarchive" -o -name "*.app"

# 4. Альтернативные методы при сбое
xcodebuild archive + xcodebuild -exportArchive
flutter build ios + manual IPA creation
```

### 4. Ключевые строки и индикаторы в логах

**✅ Успешные индикаторы (должны быть):**
```
Built build/ios/ipa/Runner.ipa (XX.XMB)
Archive succeeded
Export succeeded
```

**❌ Проблемные индикаторы (ищите):**
```
# Скрытые ошибки экспорта:
"Unable to export archive"
"Export failed"
"No signing certificate" (даже с --no-codesign)

# Проблемы с bundle:
"Bundle identifier ... is not valid"
"CFBundleIdentifier not found"

# Системные проблемы:
"No space left on device"
"Permission denied"
"Operation not permitted"

# Проблемы с зависимостями:
"Framework not found"
"Library not loaded"
"Symbol not found"
```

**⚠️ Косвенные признаки проблем:**
```
# Подозрительно быстрая сборка (< 2 минут)
# Отсутствие строки "Running Xcode build"
# Много предупреждений о подписи кода
# Ошибки в CocoaPods post_install
```

### 5. Дополнительные проверки для полной диагностики

**🔍 Если бы я диагностировал:**

```bash
# 1. Проверка до сборки
df -h  # место на диске
xcode-select -p  # путь к Xcode
xcrun --show-sdk-version  # версия SDK

# 2. Детальная сборка
flutter build ipa --verbose --analyze-size 2>&1 | tee full.log

# 3. Проверка после сборки
find . -name "*.ipa" -exec ls -lh {} \;
find build/ -name "*.xcarchive" -exec ls -lh {} \;

# 4. Анализ архива (если есть)
ls -la build/ios/archive/*/Products/Applications/

# 5. Прямой xcodebuild для сравнения
cd ios
xcodebuild archive -workspace Runner.xcworkspace -scheme Runner \
  -configuration Release -archivePath build/test.xcarchive \
  CODE_SIGNING_REQUIRED=NO

# 6. Проверка настроек проекта
xcodebuild -showBuildSettings -project Runner.xcodeproj \
  -scheme Runner -configuration Release | grep -i "code_sign\|bundle"
```

## 🎯 Быстрый чек-лист диагностики

### При Silent Fail проверьте по порядку:

1. **[ ]** Есть ли строка "Built ... .ipa" в логах?
2. **[ ]** Создался ли .xcarchive в build/?
3. **[ ]** Достаточно ли места на диске (>1GB)?
4. **[ ]** Корректен ли bundle identifier?
5. **[ ]** Правильные ли настройки в xcconfig?
6. **[ ]** Есть ли ошибки в stderr?
7. **[ ]** Работает ли альтернативный метод?

### Команды для быстрой проверки:

```bash
# Поиск IPA
find . -name "*.ipa" -type f

# Поиск архивов
find build/ -name "*.xcarchive" -type d

# Проверка места
df -h .

# Проверка bundle ID
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/

# Последние строки лога
tail -20 flutter_build.log
```

## 🛠️ Инструменты для диагностики

### Локальные скрипты:
```powershell
# Полная диагностика Silent Fail
.\scripts\diagnose_silent_fail.ps1 -Verbose -AlternativeMethods

# Быстрая проверка
.\scripts\diagnose_ipa_issues.ps1
```

### GitHub Actions:
- Обновленный workflow с максимальной диагностикой
- Разделение stdout/stderr
- Мониторинг системных ресурсов
- Альтернативные методы сборки

## 🎉 Заключение

Silent Fail - это **проблема экспорта**, а не компиляции. Flutter успешно создает архив, но не может экспортировать его в IPA из-за:
- Неправильных настроек подписи
- Проблем с bundle identifier
- Системных ограничений

**Ключ к решению:** максимально детальное логирование + альтернативные методы сборки.