# Скрипт диагностики проблем с созданием IPA
# PowerShell скрипт для Windows

param(
    [switch]$Detailed,
    [switch]$FixIssues
)

Write-Host "🔍 Диагностика проблем с созданием IPA" -ForegroundColor Green

# Проверяем, что мы в правильной директории
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Ошибка: Запустите скрипт из корня Flutter проекта" -ForegroundColor Red
    exit 1
}

Write-Host "`n📋 Этап 1: Проверка окружения" -ForegroundColor Yellow

# Проверка Flutter
Write-Host "Flutter версия:" -ForegroundColor Cyan
flutter --version

# Проверка структуры проекта
Write-Host "`n📁 Этап 2: Проверка структуры проекта" -ForegroundColor Yellow

$checks = @(
    @{Path="ios/Runner.xcodeproj/project.pbxproj"; Name="Xcode проект"},
    @{Path="ios/Runner/Info.plist"; Name="Info.plist"},
    @{Path="ios/Podfile"; Name="Podfile"},
    @{Path="ios/Flutter/Debug.xcconfig"; Name="Debug.xcconfig"},
    @{Path="ios/Flutter/Release.xcconfig"; Name="Release.xcconfig"}
)

foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "✅ $($check.Name) найден" -ForegroundColor Green
    } else {
        Write-Host "❌ $($check.Name) отсутствует: $($check.Path)" -ForegroundColor Red
    }
}

# Проверка CocoaPods
Write-Host "`n🍎 Проверка CocoaPods:" -ForegroundColor Cyan
if (Test-Path "ios/Pods") {
    Write-Host "✅ CocoaPods установлены" -ForegroundColor Green
    $podCount = (Get-ChildItem "ios/Pods" -Directory).Count
    Write-Host "   Количество pods: $podCount" -ForegroundColor Cyan
} else {
    Write-Host "❌ CocoaPods не установлены" -ForegroundColor Red
}

# Проверка Flutter конфигурации
Write-Host "`n⚙️ Этап 3: Проверка Flutter конфигурации" -ForegroundColor Yellow

if (Test-Path "ios/Flutter/Generated.xcconfig") {
    Write-Host "✅ Generated.xcconfig найден" -ForegroundColor Green
    if ($Detailed) {
        Write-Host "Содержимое Generated.xcconfig:" -ForegroundColor Cyan
        Get-Content "ios/Flutter/Generated.xcconfig"
    }
} else {
    Write-Host "❌ Generated.xcconfig отсутствует" -ForegroundColor Red
}

# Проверка bundle identifier
Write-Host "`n📱 Этап 4: Проверка bundle identifier" -ForegroundColor Yellow

if (Test-Path "ios/Runner/Info.plist") {
    $infoPlist = Get-Content "ios/Runner/Info.plist" -Raw
    if ($infoPlist -match "PRODUCT_BUNDLE_IDENTIFIER") {
        Write-Host "✅ Bundle identifier настроен через переменную" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Bundle identifier может быть захардкожен" -ForegroundColor Yellow
    }
    
    # Проверяем на com.example
    if ($infoPlist -match "com\.example") {
        Write-Host "⚠️ Обнаружен тестовый bundle identifier (com.example.*)" -ForegroundColor Yellow
        Write-Host "   Рекомендуется изменить на уникальный identifier" -ForegroundColor Yellow
    }
}

# Проверка предыдущих сборок
Write-Host "`n🔍 Этап 5: Проверка предыдущих сборок" -ForegroundColor Yellow

if (Test-Path "build") {
    Write-Host "📁 Папка build существует" -ForegroundColor Cyan
    
    if (Test-Path "build/ios") {
        Write-Host "📁 Папка build/ios существует" -ForegroundColor Cyan
        
        # Поиск IPA файлов
        $ipaFiles = Get-ChildItem -Path "build" -Recurse -Filter "*.ipa" -ErrorAction SilentlyContinue
        if ($ipaFiles) {
            Write-Host "✅ Найдены IPA файлы:" -ForegroundColor Green
            foreach ($ipa in $ipaFiles) {
                $sizeMB = [math]::Round($ipa.Length / 1MB, 2)
                Write-Host "   📱 $($ipa.FullName) - $sizeMB MB" -ForegroundColor Cyan
                
                if ($Detailed) {
                    # Проверяем содержимое IPA
                    Write-Host "   Содержимое IPA:" -ForegroundColor Gray
                    if (Get-Command "7z" -ErrorAction SilentlyContinue) {
                        7z l $ipa.FullName | Select-Object -First 15 | Select-Object -Last 10
                    } else {
                        Write-Host "   (Установите 7-zip для детального анализа)" -ForegroundColor Gray
                    }
                }
            }
        } else {
            Write-Host "❌ IPA файлы не найдены" -ForegroundColor Red
        }
        
        # Поиск app bundle
        $appBundles = Get-ChildItem -Path "build" -Recurse -Filter "*.app" -ErrorAction SilentlyContinue
        if ($appBundles) {
            Write-Host "✅ Найдены app bundle:" -ForegroundColor Green
            foreach ($app in $appBundles) {
                Write-Host "   📱 $($app.FullName)" -ForegroundColor Cyan
            }
        }
        
        # Поиск архивов Xcode
        $archives = Get-ChildItem -Path "build" -Recurse -Filter "*.xcarchive" -ErrorAction SilentlyContinue
        if ($archives) {
            Write-Host "✅ Найдены Xcode архивы:" -ForegroundColor Green
            foreach ($archive in $archives) {
                Write-Host "   📦 $($archive.FullName)" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "❌ Папка build/ios не существует" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Папка build не существует" -ForegroundColor Red
}

# Проверка логов
Write-Host "`n📄 Этап 6: Проверка логов" -ForegroundColor Yellow

if (Test-Path "flutter_logs") {
    Write-Host "✅ Папка flutter_logs найдена" -ForegroundColor Green
    $logFiles = Get-ChildItem "flutter_logs" -Filter "*.log" -ErrorAction SilentlyContinue
    
    if ($logFiles) {
        Write-Host "Найдены лог файлы:" -ForegroundColor Cyan
        foreach ($log in $logFiles) {
            Write-Host "   📄 $($log.Name)" -ForegroundColor Cyan
            
            if ($Detailed) {
                Write-Host "   Последние ошибки в $($log.Name):" -ForegroundColor Gray
                $content = Get-Content $log.FullName -ErrorAction SilentlyContinue
                $errors = $content | Select-String -Pattern "error|failed|exception" -CaseSensitive:$false
                if ($errors) {
                    $errors | Select-Object -Last 5 | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
                } else {
                    Write-Host "     Ошибки не найдены" -ForegroundColor Green
                }
            }
        }
    }
} else {
    Write-Host "❌ Папка flutter_logs не найдена" -ForegroundColor Red
}

# Рекомендации по исправлению
Write-Host "`n💡 Этап 7: Рекомендации" -ForegroundColor Yellow

$issues = @()

if (-not (Test-Path "ios/Pods")) {
    $issues += "CocoaPods не установлены - запустите 'cd ios && pod install'"
}

if (-not (Test-Path "ios/Flutter/Generated.xcconfig")) {
    $issues += "Generated.xcconfig отсутствует - запустите 'flutter pub get'"
}

$ipaExists = Get-ChildItem -Path "build" -Recurse -Filter "*.ipa" -ErrorAction SilentlyContinue
if (-not $ipaExists) {
    $issues += "IPA файлы не найдены - попробуйте запустить сборку заново"
}

if ($issues.Count -gt 0) {
    Write-Host "🔧 Обнаружены проблемы:" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "   • $issue" -ForegroundColor Yellow
    }
    
    if ($FixIssues) {
        Write-Host "`n🛠️ Попытка автоматического исправления..." -ForegroundColor Green
        
        # Исправление CocoaPods
        if (-not (Test-Path "ios/Pods")) {
            Write-Host "Установка CocoaPods..." -ForegroundColor Cyan
            Set-Location "ios"
            pod install --repo-update
            Set-Location ".."
        }
        
        # Исправление Flutter конфигурации
        if (-not (Test-Path "ios/Flutter/Generated.xcconfig")) {
            Write-Host "Генерация Flutter конфигурации..." -ForegroundColor Cyan
            flutter pub get
        }
        
        Write-Host "✅ Автоматическое исправление завершено" -ForegroundColor Green
    }
} else {
    Write-Host "✅ Серьезные проблемы не обнаружены" -ForegroundColor Green
}

# Следующие шаги
Write-Host "`n🎯 Следующие шаги:" -ForegroundColor Yellow
Write-Host "1. Если проблемы обнаружены, исправьте их или запустите с флагом -FixIssues" -ForegroundColor Cyan
Write-Host "2. Для полной сборки IPA запустите: .\scripts\build_ipa_local.ps1" -ForegroundColor Cyan
Write-Host "3. Для детальной диагностики запустите: .\scripts\diagnose_ipa_issues.ps1 -Detailed" -ForegroundColor Cyan
Write-Host "4. См. подробное руководство в IPA_TROUBLESHOOTING_CHECKLIST.md" -ForegroundColor Cyan

Write-Host "`n🏁 Диагностика завершена!" -ForegroundColor Green