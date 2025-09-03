# Скрипт для диагностики Silent Fail при сборке IPA
# PowerShell скрипт для Windows

param(
    [switch]$Verbose,
    [switch]$AlternativeMethods
)

Write-Host "🔍 Диагностика Silent Fail при сборке IPA" -ForegroundColor Green

# Проверяем, что мы в правильной директории
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Ошибка: Запустите скрипт из корня Flutter проекта" -ForegroundColor Red
    exit 1
}

# Создаем директории для логов
New-Item -ItemType Directory -Force -Path "logs\flutter" | Out-Null
New-Item -ItemType Directory -Force -Path "logs\system" | Out-Null
New-Item -ItemType Directory -Force -Path "logs\analysis" | Out-Null

Write-Host "`n📊 Этап 1: Системная диагностика" -ForegroundColor Yellow

# Проверка системных ресурсов
Write-Host "Системные ресурсы:" -ForegroundColor Cyan
$disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
Write-Host "  Свободное место на диске: $freeSpaceGB GB" -ForegroundColor White

$memory = Get-WmiObject -Class Win32_ComputerSystem
$totalMemoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
Write-Host "  Общая память: $totalMemoryGB GB" -ForegroundColor White

# Проверка инструментов разработки
Write-Host "`nИнструменты разработки:" -ForegroundColor Cyan
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "  Flutter: $flutterVersion" -ForegroundColor White
} catch {
    Write-Host "  ❌ Flutter не найден" -ForegroundColor Red
}

try {
    $dartVersion = dart --version 2>&1
    Write-Host "  Dart: $dartVersion" -ForegroundColor White
} catch {
    Write-Host "  ❌ Dart не найден" -ForegroundColor Red
}

Write-Host "`n🔍 Этап 2: Проверка проекта" -ForegroundColor Yellow

# Проверка структуры iOS проекта
$iosChecks = @(
    @{Path="ios/Runner.xcodeproj/project.pbxproj"; Name="Xcode проект"},
    @{Path="ios/Runner/Info.plist"; Name="Info.plist"},
    @{Path="ios/Podfile"; Name="Podfile"},
    @{Path="ios/Pods"; Name="CocoaPods установлены"},
    @{Path="ios/Flutter/Generated.xcconfig"; Name="Generated.xcconfig"}
)

foreach ($check in $iosChecks) {
    if (Test-Path $check.Path) {
        Write-Host "✅ $($check.Name)" -ForegroundColor Green
    } else {
        Write-Host "❌ $($check.Name) отсутствует" -ForegroundColor Red
    }
}

# Проверка bundle identifier
Write-Host "`nПроверка bundle identifier:" -ForegroundColor Cyan
if (Test-Path "ios/Runner/Info.plist") {
    $infoPlist = Get-Content "ios/Runner/Info.plist" -Raw
    if ($infoPlist -match "PRODUCT_BUNDLE_IDENTIFIER") {
        Write-Host "✅ Bundle identifier настроен через переменную" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Bundle identifier может быть захардкожен" -ForegroundColor Yellow
    }
}

Write-Host "`n🔨 Этап 3: Тестовая сборка с диагностикой" -ForegroundColor Yellow

# Очистка проекта
Write-Host "Очистка проекта..." -ForegroundColor Cyan
flutter clean | Out-Null
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue

# Получение зависимостей
Write-Host "Установка зависимостей..." -ForegroundColor Cyan
flutter pub get | Out-Null

# Создание unsigned конфигурации
Write-Host "Создание unsigned конфигурации..." -ForegroundColor Cyan
$unsignedConfig = @"
#include "Generated.xcconfig"
CODE_SIGN_IDENTITY=
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
PROVISIONING_PROFILE_SPECIFIER=
DEVELOPMENT_TEAM=
ENABLE_BITCODE=NO
SKIP_INSTALL=NO
"@

$unsignedConfig | Out-File -FilePath "ios/Flutter/Unsigned.xcconfig" -Encoding UTF8

# Бэкап и замена Release.xcconfig
if (Test-Path "ios/Flutter/Release.xcconfig") {
    Copy-Item "ios/Flutter/Release.xcconfig" "ios/Flutter/Release.xcconfig.backup"
}
Copy-Item "ios/Flutter/Unsigned.xcconfig" "ios/Flutter/Release.xcconfig"

Write-Host "`n🚀 Запуск flutter build ipa с детальным логированием..." -ForegroundColor Yellow

# Запуск сборки с перенаправлением вывода
$buildStartTime = Get-Date
Write-Host "Время начала сборки: $buildStartTime" -ForegroundColor Cyan

try {
    # Запуск с захватом stdout и stderr
    $process = Start-Process -FilePath "flutter" -ArgumentList "build", "ipa", "--release", "--no-codesign", "--verbose" -RedirectStandardOutput "logs\flutter\stdout.log" -RedirectStandardError "logs\flutter\stderr.log" -Wait -PassThru -NoNewWindow
    
    $buildEndTime = Get-Date
    $buildDuration = $buildEndTime - $buildStartTime
    
    Write-Host "Время окончания сборки: $buildEndTime" -ForegroundColor Cyan
    Write-Host "Длительность сборки: $($buildDuration.TotalMinutes.ToString('F2')) минут" -ForegroundColor Cyan
    Write-Host "Exit code: $($process.ExitCode)" -ForegroundColor Cyan
    
    # Анализ результата
    Write-Host "`n🔍 Анализ результата сборки..." -ForegroundColor Yellow
    
    # Проверка файловой системы
    Write-Host "Поиск IPA файлов:" -ForegroundColor Cyan
    $ipaFiles = Get-ChildItem -Path "." -Recurse -Filter "*.ipa" -ErrorAction SilentlyContinue
    
    if ($ipaFiles) {
        Write-Host "✅ Найдены IPA файлы:" -ForegroundColor Green
        foreach ($ipa in $ipaFiles) {
            $sizeMB = [math]::Round($ipa.Length / 1MB, 2)
            Write-Host "  📱 $($ipa.FullName) - $sizeMB MB" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ IPA файлы не найдены" -ForegroundColor Red
    }
    
    # Проверка app bundle
    Write-Host "`nПоиск app bundle:" -ForegroundColor Cyan
    $appBundles = Get-ChildItem -Path "build" -Recurse -Filter "*.app" -ErrorAction SilentlyContinue
    
    if ($appBundles) {
        Write-Host "✅ Найдены app bundle:" -ForegroundColor Green
        foreach ($app in $appBundles) {
            Write-Host "  📱 $($app.FullName)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ App bundle не найдены" -ForegroundColor Red
    }
    
    # Анализ логов
    Write-Host "`n📄 Анализ логов..." -ForegroundColor Yellow
    
    if (Test-Path "logs\flutter\stdout.log") {
        $stdout = Get-Content "logs\flutter\stdout.log" -Raw
        
        # Поиск индикаторов успеха
        Write-Host "Поиск индикаторов успеха:" -ForegroundColor Cyan
        if ($stdout -match "Built.*\.ipa") {
            Write-Host "✅ Найден индикатор успешной сборки IPA" -ForegroundColor Green
        } else {
            Write-Host "❌ Индикатор успешной сборки IPA не найден" -ForegroundColor Red
        }
        
        # Поиск предупреждений
        $warnings = $stdout | Select-String -Pattern "warning|caution" -AllMatches
        if ($warnings) {
            Write-Host "⚠️ Найдено предупреждений: $($warnings.Count)" -ForegroundColor Yellow
            if ($Verbose) {
                $warnings | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            }
        }
        
        if ($Verbose) {
            Write-Host "`nПоследние 20 строк stdout:" -ForegroundColor Gray
            Get-Content "logs\flutter\stdout.log" | Select-Object -Last 20 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        }
    }
    
    if (Test-Path "logs\flutter\stderr.log") {
        $stderr = Get-Content "logs\flutter\stderr.log" -Raw
        
        if ($stderr.Trim()) {
            Write-Host "⚠️ Найдены сообщения в stderr:" -ForegroundColor Yellow
            if ($Verbose) {
                Write-Host $stderr -ForegroundColor Gray
            }
            
            # Поиск скрытых ошибок
            $errors = $stderr | Select-String -Pattern "error|fail|exception|abort" -AllMatches
            if ($errors) {
                Write-Host "❌ Найдены потенциальные ошибки в stderr: $($errors.Count)" -ForegroundColor Red
                $errors | Select-Object -First 3 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            }
        } else {
            Write-Host "✅ Stderr пуст" -ForegroundColor Green
        }
    }
    
} catch {
    Write-Host "❌ Ошибка при запуске сборки: $_" -ForegroundColor Red
}

# Альтернативные методы сборки
if ($AlternativeMethods -and -not $ipaFiles) {
    Write-Host "`n🔄 Пробуем альтернативные методы сборки..." -ForegroundColor Yellow
    
    # Восстанавливаем оригинальную конфигурацию
    if (Test-Path "ios/Flutter/Release.xcconfig.backup") {
        Copy-Item "ios/Flutter/Release.xcconfig.backup" "ios/Flutter/Release.xcconfig"
    }
    
    # Метод: flutter build ios + ручное создание IPA
    Write-Host "Метод: flutter build ios + ручное создание IPA" -ForegroundColor Cyan
    
    try {
        $process = Start-Process -FilePath "flutter" -ArgumentList "build", "ios", "--release", "--no-codesign" -RedirectStandardOutput "logs\flutter\build_ios_stdout.log" -RedirectStandardError "logs\flutter\build_ios_stderr.log" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0 -and (Test-Path "build/ios/iphoneos")) {
            Write-Host "✅ Flutter build ios успешен" -ForegroundColor Green
            
            # Поиск .app файла
            $appFile = Get-ChildItem -Path "build/ios/iphoneos" -Filter "*.app" -Directory | Select-Object -First 1
            
            if ($appFile) {
                Write-Host "Найден app bundle: $($appFile.Name)" -ForegroundColor Cyan
                
                # Создание IPA вручную
                New-Item -ItemType Directory -Force -Path "build/ios/ipa/Payload" | Out-Null
                Copy-Item -Recurse $appFile.FullName "build/ios/ipa/Payload/"
                
                # Создание ZIP архива
                Set-Location "build/ios/ipa"
                
                if (Get-Command "7z" -ErrorAction SilentlyContinue) {
                    7z a -tzip "taste_smoke_ios.ipa" "Payload/*" | Out-Null
                } else {
                    Compress-Archive -Path "Payload/*" -DestinationPath "taste_smoke_ios.ipa" -Force
                }
                
                Set-Location "../../.."
                
                if (Test-Path "build/ios/ipa/taste_smoke_ios.ipa") {
                    $ipaSize = [math]::Round((Get-Item "build/ios/ipa/taste_smoke_ios.ipa").Length / 1MB, 2)
                    Write-Host "✅ IPA создан вручную: $ipaSize MB" -ForegroundColor Green
                } else {
                    Write-Host "❌ Не удалось создать IPA вручную" -ForegroundColor Red
                }
            } else {
                Write-Host "❌ App bundle не найден" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Flutter build ios не удался" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Ошибка альтернативного метода: $_" -ForegroundColor Red
    }
}

# Восстановление оригинальной конфигурации
if (Test-Path "ios/Flutter/Release.xcconfig.backup") {
    Copy-Item "ios/Flutter/Release.xcconfig.backup" "ios/Flutter/Release.xcconfig"
    Remove-Item "ios/Flutter/Release.xcconfig.backup"
}

Write-Host "`n📊 Итоговая диагностика:" -ForegroundColor Yellow

# Финальная проверка IPA
$finalIpaCheck = Get-ChildItem -Path "." -Recurse -Filter "*.ipa" -ErrorAction SilentlyContinue

if ($finalIpaCheck) {
    Write-Host "✅ IPA файлы найдены:" -ForegroundColor Green
    foreach ($ipa in $finalIpaCheck) {
        $sizeMB = [math]::Round($ipa.Length / 1MB, 2)
        Write-Host "  📱 $($ipa.FullName) - $sizeMB MB" -ForegroundColor Cyan
        
        # Проверка содержимого IPA (если есть 7z)
        if (Get-Command "7z" -ErrorAction SilentlyContinue) {
            $content = 7z l $ipa.FullName 2>$null | Select-String "Payload"
            if ($content) {
                Write-Host "    ✅ Содержит корректную структуру Payload" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️ Структура IPA может быть некорректной" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "`n🎉 Диагностика завершена успешно!" -ForegroundColor Green
    Write-Host "IPA готов для установки через AltStore" -ForegroundColor Green
} else {
    Write-Host "❌ IPA файлы не найдены" -ForegroundColor Red
    Write-Host "`n🔍 Рекомендации для решения проблемы:" -ForegroundColor Yellow
    Write-Host "1. Проверьте логи в папке logs/" -ForegroundColor White
    Write-Host "2. Убедитесь, что bundle identifier уникален" -ForegroundColor White
    Write-Host "3. Проверьте настройки подписи кода" -ForegroundColor White
    Write-Host "4. Попробуйте запустить с флагом -AlternativeMethods" -ForegroundColor White
    Write-Host "5. См. подробное руководство в SILENT_FAIL_DIAGNOSIS.md" -ForegroundColor White
}

Write-Host "`n📁 Логи сохранены в папке logs/ для дальнейшего анализа" -ForegroundColor Cyan