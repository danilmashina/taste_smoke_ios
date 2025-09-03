# Скрипт для локальной сборки IPA для AltStore
# PowerShell скрипт для Windows

Write-Host "🔨 Локальная сборка IPA для AltStore" -ForegroundColor Green

# Проверяем, что мы в правильной директории
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Ошибка: Запустите скрипт из корня Flutter проекта" -ForegroundColor Red
    exit 1
}

# Проверяем Flutter
Write-Host "📋 Проверка Flutter..." -ForegroundColor Yellow
flutter doctor -v

# Очистка проекта
Write-Host "🧹 Очистка проекта..." -ForegroundColor Yellow
flutter clean
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "ios/Pods" -ErrorAction SilentlyContinue
Remove-Item -Force "ios/Podfile.lock" -ErrorAction SilentlyContinue

# Получение зависимостей
Write-Host "📦 Установка Flutter зависимостей..." -ForegroundColor Yellow
flutter pub get

# Установка CocoaPods
Write-Host "🍎 Установка CocoaPods..." -ForegroundColor Yellow
Set-Location "ios"

# Проверяем версию CocoaPods
$podVersion = pod --version
Write-Host "Версия CocoaPods: $podVersion" -ForegroundColor Cyan

# Установка pods
if (pod install --repo-update --verbose) {
    Write-Host "✅ CocoaPods установлены успешно" -ForegroundColor Green
} else {
    Write-Host "⚠️ Ошибка с основным Podfile, пробуем минимальный..." -ForegroundColor Yellow
    
    # Бэкап и использование минимального Podfile
    Copy-Item "Podfile" "Podfile.backup"
    Copy-Item "Podfile.minimal" "Podfile"
    
    Remove-Item -Recurse -Force "Pods" -ErrorAction SilentlyContinue
    Remove-Item -Force "Podfile.lock" -ErrorAction SilentlyContinue
    
    if (pod install --repo-update --verbose) {
        Write-Host "✅ Минимальный Podfile установлен успешно" -ForegroundColor Green
    } else {
        Write-Host "❌ Ошибка даже с минимальным Podfile" -ForegroundColor Red
        Set-Location ".."
        exit 1
    }
}

Set-Location ".."

# Создание unsigned xcconfig
Write-Host "⚙️ Настройка для unsigned сборки..." -ForegroundColor Yellow
$unsignedConfig = @"
#include "Generated.xcconfig"
CODE_SIGN_IDENTITY=
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
PROVISIONING_PROFILE_SPECIFIER=
DEVELOPMENT_TEAM=
"@

$unsignedConfig | Out-File -FilePath "ios/Flutter/Unsigned.xcconfig" -Encoding UTF8

# Бэкап и замена Release.xcconfig
Copy-Item "ios/Flutter/Release.xcconfig" "ios/Flutter/Release.xcconfig.backup"
Copy-Item "ios/Flutter/Unsigned.xcconfig" "ios/Flutter/Release.xcconfig"

# Сборка IPA
Write-Host "🔨 Сборка IPA..." -ForegroundColor Yellow
if (flutter build ipa --release --no-codesign --verbose) {
    Write-Host "✅ Сборка IPA завершена успешно" -ForegroundColor Green
} else {
    Write-Host "⚠️ Ошибка сборки IPA, пробуем альтернативный метод..." -ForegroundColor Yellow
    
    # Восстанавливаем оригинальный файл
    Copy-Item "ios/Flutter/Release.xcconfig.backup" "ios/Flutter/Release.xcconfig"
    
    # Альтернативная сборка
    if (flutter build ios --release --no-codesign --verbose) {
        Write-Host "✅ Сборка iOS app завершена успешно" -ForegroundColor Green
        
        # Создание IPA вручную
        Write-Host "📦 Создание IPA из app bundle..." -ForegroundColor Yellow
        
        New-Item -ItemType Directory -Force -Path "build/ios/ipa" | Out-Null
        Set-Location "build/ios/iphoneos"
        
        # Находим .app файл
        $appFile = Get-ChildItem -Directory -Filter "*.app" | Select-Object -First 1
        
        if ($appFile) {
            Write-Host "Найден app bundle: $($appFile.Name)" -ForegroundColor Cyan
            
            # Создаем структуру для IPA
            New-Item -ItemType Directory -Force -Path "Payload" | Out-Null
            Copy-Item -Recurse $appFile.FullName "Payload/"
            
            # Создаем IPA файл (используем 7-zip если доступен, иначе Compress-Archive)
            $ipaPath = "../ipa/taste_smoke_ios.ipa"
            
            if (Get-Command "7z" -ErrorAction SilentlyContinue) {
                7z a -tzip $ipaPath "Payload/*"
            } else {
                Compress-Archive -Path "Payload/*" -DestinationPath $ipaPath -Force
            }
            
            Write-Host "✅ IPA создан: $ipaPath" -ForegroundColor Green
            Set-Location "../../.."
        } else {
            Write-Host "❌ App bundle не найден" -ForegroundColor Red
            Set-Location "../../.."
            exit 1
        }
    } else {
        Write-Host "❌ Ошибка сборки iOS app" -ForegroundColor Red
        exit 1
    }
}

# Восстанавливаем оригинальный Release.xcconfig
if (Test-Path "ios/Flutter/Release.xcconfig.backup") {
    Copy-Item "ios/Flutter/Release.xcconfig.backup" "ios/Flutter/Release.xcconfig"
    Remove-Item "ios/Flutter/Release.xcconfig.backup"
}

# Проверка результата
Write-Host "🔍 Проверка созданного IPA..." -ForegroundColor Yellow

if (Test-Path "build/ios/ipa") {
    $ipaFiles = Get-ChildItem "build/ios/ipa/*.ipa"
    
    if ($ipaFiles) {
        Write-Host "✅ IPA файлы найдены:" -ForegroundColor Green
        foreach ($ipa in $ipaFiles) {
            Write-Host "  📱 $($ipa.Name) - $([math]::Round($ipa.Length / 1MB, 2)) MB" -ForegroundColor Cyan
        }
        
        Write-Host "`n🎉 Сборка завершена успешно!" -ForegroundColor Green
        Write-Host "📁 IPA файлы находятся в: build/ios/ipa/" -ForegroundColor Cyan
        Write-Host "📲 Теперь вы можете установить IPA через AltStore" -ForegroundColor Cyan
    } else {
        Write-Host "❌ IPA файлы не найдены" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Папка build/ios/ipa не существует" -ForegroundColor Red
    exit 1
}