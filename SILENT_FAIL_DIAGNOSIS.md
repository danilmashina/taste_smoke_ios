# 🔍 Диагностика "Silent Fail" при сборке IPA

## 🎯 Проблема: IPA не создается без явных ошибок

### Симптомы:
- `flutter build ipa` завершается с кодом 0 (успех)
- В логах видны dSYM файлы
- Отсутствует строка "Built ... Runner.ipa"
- Папка `build/ios/ipa/` пуста или не существует
- Нет явных красных ошибок в логах

## 🔍 Где искать причины Silent Fail

### 1. 📊 Анализ exit кодов процессов
```bash
# Flutter может вернуть 0, но внутренние процессы могут падать
echo "Exit code flutter: $?"
echo "Exit code xcodebuild: $?"
```

### 2. 🔍 Скрытые ошибки в логах
Ищите эти паттерны в логах:
```
# Проблемы с архивацией
"Archive operation failed"
"Unable to archive"
"Export failed"

# Проблемы с подписью (даже с --no-codesign)
"Code signing is required"
"No signing certificate"
"Provisioning profile"

# Проблемы с bundle
"Bundle identifier"
"Info.plist"
"CFBundleIdentifier"

# Проблемы с Xcode
"xcodebuild: error"
"Build input file cannot be found"
"No such file or directory"

# Проблемы с правами доступа
"Permission denied"
"Operation not permitted"
"Read-only file system"
```

### 3. 🧩 Типовые причины Silent Fail

#### A. Проблемы с Xcode архивацией
- Архив создается, но не экспортируется в IPA
- Неправильные настройки SKIP_INSTALL
- Проблемы с ENABLE_BITCODE

#### B. Проблемы с файловой системой
- Недостаточно места на диске
- Проблемы с правами доступа
- Временные файлы блокируют создание IPA

#### C. Проблемы с bundle identifier
- Конфликт с существующими приложениями
- Неправильный формат bundle ID
- Отсутствие bundle ID в Info.plist

#### D. Проблемы с зависимостями
- Конфликты версий CocoaPods
- Отсутствующие frameworks
- Проблемы с Swift/Objective-C совместимостью

## 🛠️ Улучшенная диагностика в GitHub Actions

Давайте создадим максимально детальный workflow для выявления скрытых проблем:

### Этап 1: Pre-build диагностика
```yaml
- name: Pre-build system diagnosis
  run: |
    echo "=== SYSTEM DIAGNOSIS ==="
    
    # Проверка места на диске
    df -h
    echo "Available disk space: $(df -h . | tail -1 | awk '{print $4}')"
    
    # Проверка памяти
    vm_stat | head -5
    
    # Проверка Xcode
    xcode-select -p
    xcrun --show-sdk-path
    xcrun --show-sdk-version
    
    # Проверка версий инструментов
    echo "Flutter: $(flutter --version --machine | jq -r '.flutterVersion')"
    echo "Dart: $(flutter --version --machine | jq -r '.dartSdkVersion')"
    echo "Xcode: $(xcodebuild -version | head -1)"
    echo "CocoaPods: $(pod --version)"
```

### Этап 2: Детальная сборка с перехватом всех процессов
```yaml
- name: Enhanced IPA build with full diagnostics
  run: |
    echo "🔨 ENHANCED IPA BUILD WITH DIAGNOSTICS"
    
    # Создаем директории для логов
    mkdir -p logs/{flutter,xcode,system}
    
    # Мониторинг системных ресурсов в фоне
    (while true; do
      echo "$(date): Disk: $(df -h . | tail -1 | awk '{print $4}'), Memory: $(vm_stat | grep 'Pages free' | awk '{print $3}')" >> logs/system/resources.log
      sleep 10
    done) &
    MONITOR_PID=$!
    
    # Запуск сборки с максимальной детализацией
    echo "Starting flutter build ipa with enhanced logging..."
    
    # Перехватываем STDERR и STDOUT отдельно
    flutter build ipa --release --no-codesign --verbose \
      > logs/flutter/stdout.log 2> logs/flutter/stderr.log
    
    FLUTTER_EXIT_CODE=$?
    
    # Останавливаем мониторинг
    kill $MONITOR_PID 2>/dev/null || true
    
    echo "Flutter build exit code: $FLUTTER_EXIT_CODE"
    
    # Анализируем результат
    if [ $FLUTTER_EXIT_CODE -eq 0 ]; then
      echo "✅ Flutter build returned success code"
    else
      echo "❌ Flutter build failed with code: $FLUTTER_EXIT_CODE"
    fi
    
    # Немедленная проверка файловой системы
    echo "=== IMMEDIATE FILE SYSTEM CHECK ==="
    find build/ -type f -name "*.ipa" -o -name "*.app" -o -name "*.xcarchive" 2>/dev/null | sort
    
    # Проверка размеров директорий
    echo "Build directory sizes:"
    du -sh build/* 2>/dev/null || echo "No build subdirectories"
    
    # Поиск всех IPA файлов в проекте
    echo "All IPA files in project:"
    find . -name "*.ipa" -type f -exec ls -lh {} \; 2>/dev/null || echo "No IPA files found"
```

### Этап 3: Анализ логов на предмет скрытых ошибок
```yaml
- name: Analyze logs for hidden failures
  run: |
    echo "🔍 ANALYZING LOGS FOR HIDDEN FAILURES"
    
    # Анализ Flutter логов
    echo "=== FLUTTER STDOUT ANALYSIS ==="
    if [ -f logs/flutter/stdout.log ]; then
      echo "Last 50 lines of Flutter stdout:"
      tail -50 logs/flutter/stdout.log
      
      # Поиск ключевых индикаторов
      echo "Searching for success indicators:"
      grep -i "built.*ipa" logs/flutter/stdout.log || echo "❌ No IPA build success message found"
      grep -i "archive.*success" logs/flutter/stdout.log || echo "❌ No archive success message found"
      
      echo "Searching for warning indicators:"
      grep -i "warning\|caution" logs/flutter/stdout.log | head -10
    fi
    
    echo "=== FLUTTER STDERR ANALYSIS ==="
    if [ -f logs/flutter/stderr.log ]; then
      echo "Flutter stderr content:"
      cat logs/flutter/stderr.log
      
      # Поиск скрытых ошибок
      echo "Searching for hidden errors:"
      grep -i "error\|fail\|exception\|abort" logs/flutter/stderr.log || echo "No explicit errors in stderr"
    fi
    
    # Анализ системных логов
    echo "=== SYSTEM RESOURCE ANALYSIS ==="
    if [ -f logs/system/resources.log ]; then
      echo "Resource usage during build:"
      cat logs/system/resources.log
    fi
    
    # Поиск Xcode логов
    echo "=== XCODE LOGS SEARCH ==="
    find ~/Library/Developer/Xcode/DerivedData -name "*.log" -mtime -1 2>/dev/null | head -5 | while read log; do
      echo "Checking Xcode log: $log"
      tail -20 "$log" | grep -i "error\|fail" || echo "No errors in this log"
    done
```

### Этап 4: Альтернативные методы сборки
```yaml
- name: Alternative build methods diagnosis
  if: always()
  run: |
    echo "🔄 TRYING ALTERNATIVE BUILD METHODS"
    
    # Метод 1: Прямой xcodebuild
    echo "=== METHOD 1: Direct xcodebuild ==="
    cd ios
    
    # Очистка
    xcodebuild clean -workspace Runner.xcworkspace -scheme Runner -configuration Release
    
    # Сборка архива
    echo "Building archive with xcodebuild..."
    xcodebuild archive \
      -workspace Runner.xcworkspace \
      -scheme Runner \
      -configuration Release \
      -archivePath build/Runner.xcarchive \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      > ../logs/xcode/archive.log 2>&1
    
    ARCHIVE_EXIT_CODE=$?
    echo "Archive exit code: $ARCHIVE_EXIT_CODE"
    
    if [ $ARCHIVE_EXIT_CODE -eq 0 ] && [ -d "build/Runner.xcarchive" ]; then
      echo "✅ Archive created successfully"
      
      # Экспорт в IPA
      echo "Exporting to IPA..."
      
      # Создаем plist для экспорта
      cat > export_options.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <false/>
</dict>
</plist>
EOF
      
      xcodebuild -exportArchive \
        -archivePath build/Runner.xcarchive \
        -exportPath ../build/ios/ipa \
        -exportOptionsPlist export_options.plist \
        > ../logs/xcode/export.log 2>&1
      
      EXPORT_EXIT_CODE=$?
      echo "Export exit code: $EXPORT_EXIT_CODE"
      
    else
      echo "❌ Archive creation failed"
      echo "Archive log:"
      cat ../logs/xcode/archive.log | tail -50
    fi
    
    cd ..
    
    # Метод 2: Flutter build ios + manual IPA creation
    echo "=== METHOD 2: Flutter build ios + manual IPA ==="
    
    flutter build ios --release --no-codesign > logs/flutter/build_ios.log 2>&1
    IOS_BUILD_EXIT_CODE=$?
    
    echo "Flutter build ios exit code: $IOS_BUILD_EXIT_CODE"
    
    if [ $IOS_BUILD_EXIT_CODE -eq 0 ] && [ -d "build/ios/iphoneos" ]; then
      echo "✅ iOS build successful, creating IPA manually..."
      
      cd build/ios/iphoneos
      APP_NAME=$(find . -name "*.app" -type d | head -1)
      
      if [ -n "$APP_NAME" ]; then
        echo "Found app: $APP_NAME"
        
        # Создаем IPA структуру
        mkdir -p ../ipa/Payload
        cp -r "$APP_NAME" ../ipa/Payload/
        
        cd ../ipa
        zip -r "Runner.ipa" Payload/
        
        echo "✅ Manual IPA created: $(ls -lh Runner.ipa)"
        cd ../../..
      else
        echo "❌ No .app bundle found"
        ls -la build/ios/iphoneos/
        cd ../../..
      fi
    else
      echo "❌ Flutter build ios failed"
      cat logs/flutter/build_ios.log | tail -50
    fi
```

## 🎯 Ключевые индикаторы для поиска

### В логах Flutter ищите:
```
✅ Успешные индикаторы:
- "Built build/ios/ipa/Runner.ipa"
- "Archive succeeded"
- "Export succeeded"

❌ Проблемные индикаторы:
- "Archive failed"
- "Export failed" 
- "Code signing error"
- "Bundle identifier error"
- "Provisioning profile"
- "No space left on device"
- "Permission denied"
```

### В системных логах ищите:
```
❌ Критические проблемы:
- Нехватка места на диске
- Нехватка памяти
- Проблемы с правами доступа
- Блокировка файлов другими процессами
```

## 🔧 Дополнительные проверки

### Проверка целостности проекта:
```bash
# Проверка bundle identifier
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/
plutil -p ios/Runner/Info.plist | grep -i bundle

# Проверка подписи кода
grep -r "CODE_SIGN" ios/Runner.xcodeproj/
cat ios/Flutter/Release.xcconfig

# Проверка зависимостей
pod --version
pod outdated --project-directory=ios
```

### Проверка Xcode настроек:
```bash
# Проверка схемы
xcodebuild -list -project ios/Runner.xcodeproj
xcodebuild -showBuildSettings -project ios/Runner.xcodeproj -scheme Runner -configuration Release | grep -i "code_sign\|bundle"
```

## 🎯 Заключение

Silent Fail обычно происходит из-за:
1. **Проблем с экспортом архива** (не с созданием)
2. **Неправильных настроек подписи** (даже с --no-codesign)
3. **Проблем с файловой системой** (место, права)
4. **Конфликтов зависимостей** (CocoaPods, Swift)

Ключ к решению - **максимально детальное логирование** каждого этапа и **альтернативные методы сборки** для сравнения результатов.