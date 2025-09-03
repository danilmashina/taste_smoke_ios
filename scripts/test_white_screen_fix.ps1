# Скрипт для тестирования исправлений белого экрана
# PowerShell скрипт для Windows

Write-Host "🔧 Тестирование исправлений белого экрана" -ForegroundColor Green

# Проверяем, что мы в правильной директории
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Ошибка: Запустите скрипт из корня Flutter проекта" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Этап 1: Проверка исправленных файлов" -ForegroundColor Yellow

$fixedFiles = @(
    @{Path="lib/main.dart"; Description="Улучшенная инициализация"},
    @{Path="lib/ui/screens/simple_home_screen.dart"; Description="Простой главный экран"},
    @{Path="lib/ui/screens/simple_screens.dart"; Description="Простые экраны"},
    @{Path="lib/ui/main_scaffold.dart"; Description="Простая навигация"},
    @{Path="lib/app_router.dart"; Description="Обновленный роутер"}
)

foreach ($file in $fixedFiles) {
    if (Test-Path $file.Path) {
        Write-Host "✅ $($file.Description): $($file.Path)" -ForegroundColor Green
    } else {
        Write-Host "❌ Отсутствует: $($file.Path)" -ForegroundColor Red
    }
}

Write-Host "`n📱 Этап 2: Проверка Flutter конфигурации" -ForegroundColor Yellow

# Проверка Flutter
Write-Host "Flutter doctor:" -ForegroundColor Cyan
flutter doctor --no-version-check

Write-Host "`n🔍 Этап 3: Анализ кода" -ForegroundColor Yellow
Write-Host "Анализ Dart кода..." -ForegroundColor Cyan
$analyzeResult = flutter analyze --no-fatal-infos 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Анализ кода прошел успешно" -ForegroundColor Green
} else {
    Write-Host "⚠️ Есть предупреждения в коде:" -ForegroundColor Yellow
    Write-Host $analyzeResult -ForegroundColor Gray
}

Write-Host "`n🔧 Этап 4: Тестирование сборки" -ForegroundColor Yellow

# Очистка
Write-Host "Очистка проекта..." -ForegroundColor Cyan
flutter clean | Out-Null

# Получение зависимостей
Write-Host "Установка зависимостей..." -ForegroundColor Cyan
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Зависимости установлены успешно" -ForegroundColor Green
} else {
    Write-Host "❌ Ошибка установки зависимостей" -ForegroundColor Red
    exit 1
}

# Тестирование сборки для iOS
Write-Host "`nТестирование сборки iOS..." -ForegroundColor Cyan
$buildResult = flutter build ios --release --no-codesign --no-tree-shake-icons 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Сборка iOS прошла успешно" -ForegroundColor Green
} else {
    Write-Host "❌ Ошибка сборки iOS:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Gray
    
    Write-Host "`n🔍 Диагностика ошибки сборки..." -ForegroundColor Yellow
    
    # Проверяем CocoaPods
    if (Test-Path "ios/Pods") {
        Write-Host "✅ CocoaPods установлены" -ForegroundColor Green
    } else {
        Write-Host "❌ CocoaPods не установлены, устанавливаем..." -ForegroundColor Red
        Set-Location "ios"
        pod install --repo-update
        Set-Location ".."
    }
    
    exit 1
}

Write-Host "`n📊 Этап 5: Проверка результата сборки" -ForegroundColor Yellow

if (Test-Path "build/ios/iphoneos") {
    Write-Host "✅ iOS app bundle создан" -ForegroundColor Green
    
    # Поиск .app файла
    $appFiles = Get-ChildItem -Path "build/ios/iphoneos" -Filter "*.app" -Directory
    if ($appFiles) {
        foreach ($app in $appFiles) {
            Write-Host "📱 App bundle: $($app.Name)" -ForegroundColor Cyan
            
            # Проверяем размер
            $size = (Get-ChildItem -Path $app.FullName -Recurse | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [math]::Round($size / 1MB, 2)
            Write-Host "   Размер: $sizeMB MB" -ForegroundColor Cyan
            
            # Проверяем Info.plist
            $infoPlist = Join-Path $app.FullName "Info.plist"
            if (Test-Path $infoPlist) {
                Write-Host "   ✅ Info.plist найден" -ForegroundColor Green
            } else {
                Write-Host "   ❌ Info.plist отсутствует" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "❌ .app файлы не найдены" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Папка build/ios/iphoneos не создана" -ForegroundColor Red
}

Write-Host "`n🎯 Этап 6: Рекомендации" -ForegroundColor Yellow

Write-Host "Для тестирования на устройстве:" -ForegroundColor Cyan
Write-Host "1. Соберите IPA: .\scripts\build_ipa_local.ps1" -ForegroundColor White
Write-Host "2. Установите через AltStore" -ForegroundColor White
Write-Host "3. Запустите приложение" -ForegroundColor White
Write-Host "4. Ожидайте увидеть экран '🎉 Приложение работает!'" -ForegroundColor White

Write-Host "`nДля диагностики на устройстве:" -ForegroundColor Cyan
Write-Host "1. Подключите устройство к Mac с Xcode" -ForegroundColor White
Write-Host "2. Откройте Console в Xcode" -ForegroundColor White
Write-Host "3. Ищите логи: '✅ Firebase инициализирован успешно'" -ForegroundColor White
Write-Host "4. См. подробности в WHITE_SCREEN_FIX.md" -ForegroundColor White

Write-Host "`n🏁 Тестирование завершено!" -ForegroundColor Green

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Все проверки прошли успешно" -ForegroundColor Green
    Write-Host "Приложение готово к установке на устройство" -ForegroundColor Green
} else {
    Write-Host "⚠️ Есть проблемы, которые нужно исправить" -ForegroundColor Yellow
}