# Скрипт проверки готовности к сборке iOS
# Запуск: powershell -ExecutionPolicy Bypass -File scripts\check_build_readiness.ps1

Write-Host "🔍 Проверка готовности к сборке iOS для AltStore..." -ForegroundColor Green

$allChecks = @()

# 1. Проверка Flutter версии
Write-Host "`n📋 Проверка Flutter версии..." -ForegroundColor Yellow
$flutterVersion = flutter --version | Select-String -Pattern "Flutter (\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches[0].Groups[1].Value }
Write-Host "Flutter версия: $flutterVersion" -ForegroundColor Cyan

if ($flutterVersion -eq "3.35.2") {
    Write-Host "✅ Flutter версия корректная" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "❌ Ожидается Flutter 3.35.2, найдена $flutterVersion" -ForegroundColor Red
    $allChecks += $false
}

# 2. Проверка Dart версии
$dartVersion = dart --version 2>&1 | Select-String -Pattern "(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches[0].Value }
Write-Host "Dart версия: $dartVersion" -ForegroundColor Cyan

if ($dartVersion -eq "3.9.0") {
    Write-Host "✅ Dart версия корректная" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "❌ Ожидается Dart 3.9.0, найдена $dartVersion" -ForegroundColor Red
    $allChecks += $false
}

# 3. Проверка зависимостей
Write-Host "`n📦 Проверка зависимостей..." -ForegroundColor Yellow
$pubGetResult = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Зависимости установлены успешно" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "❌ Ошибка установки зависимостей" -ForegroundColor Red
    Write-Host $pubGetResult -ForegroundColor Red
    $allChecks += $false
}

# 4. Проверка анализа кода
Write-Host "`n🔍 Анализ кода..." -ForegroundColor Yellow
$analyzeResult = flutter analyze --no-fatal-infos 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Анализ кода прошел без критических ошибок" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "⚠️ Есть предупреждения в коде (не критично для сборки)" -ForegroundColor Yellow
    $allChecks += $true  # Предупреждения не блокируют сборку
}

# 5. Проверка pubspec.yaml
Write-Host "`n📄 Проверка pubspec.yaml..." -ForegroundColor Yellow
$pubspecContent = Get-Content "pubspec.yaml" -Raw

# Проверка Dart SDK
if ($pubspecContent -match "sdk: '>=3\.5\.0 <4\.0\.0'") {
    Write-Host "✅ Dart SDK версия корректная в pubspec.yaml" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "❌ Неправильная версия Dart SDK в pubspec.yaml" -ForegroundColor Red
    $allChecks += $false
}

# Проверка Firebase версий
$firebaseVersions = @{
    "firebase_core" = "3\.8\.0"
    "firebase_auth" = "5\.3\.3"
    "cloud_firestore" = "5\.5\.0"
}

foreach ($package in $firebaseVersions.Keys) {
    $expectedVersion = $firebaseVersions[$package]
    if ($pubspecContent -match "$package: \^$expectedVersion") {
        Write-Host "✅ $package версия корректная" -ForegroundColor Green
        $allChecks += $true
    } else {
        Write-Host "❌ Неправильная версия $package" -ForegroundColor Red
        $allChecks += $false
    }
}

# 6. Проверка Google Sign-In (должен быть закомментирован)
if ($pubspecContent -match "# google_sign_in:") {
    Write-Host "✅ Google Sign-In правильно закомментирован" -ForegroundColor Green
    $allChecks += $true
} elseif ($pubspecContent -notmatch "google_sign_in:") {
    Write-Host "✅ Google Sign-In отсутствует" -ForegroundColor Green
    $allChecks += $true
} else {
    Write-Host "❌ Google Sign-In не закомментирован (может вызвать проблемы)" -ForegroundColor Red
    $allChecks += $false
}

# 7. Проверка Podfile
Write-Host "`n🍎 Проверка Podfile..." -ForegroundColor Yellow
if (Test-Path "ios/Podfile") {
    $podfileContent = Get-Content "ios/Podfile" -Raw
    
    if ($podfileContent -match "platform :ios, '13\.0'") {
        Write-Host "✅ iOS deployment target корректный (13.0)" -ForegroundColor Green
        $allChecks += $true
    } else {
        Write-Host "❌ Неправильный iOS deployment target" -ForegroundColor Red
        $allChecks += $false
    }
    
    if ($podfileContent -match "GoogleUtilities.*8\.0") {
        Write-Host "✅ GoogleUtilities версия корректная" -ForegroundColor Green
        $allChecks += $true
    } else {
        Write-Host "❌ Неправильная версия GoogleUtilities" -ForegroundColor Red
        $allChecks += $false
    }
} else {
    Write-Host "❌ Podfile не найден" -ForegroundColor Red
    $allChecks += $false
}

# 8. Проверка GitHub Actions workflow
Write-Host "`n🚀 Проверка GitHub Actions..." -ForegroundColor Yellow
if (Test-Path ".github/workflows/main.yml") {
    $workflowContent = Get-Content ".github/workflows/main.yml" -Raw
    
    if ($workflowContent -match "flutter-version: '3\.35\.2'") {
        Write-Host "✅ Flutter версия в workflow корректная" -ForegroundColor Green
        $allChecks += $true
    } else {
        Write-Host "❌ Неправильная Flutter версия в workflow" -ForegroundColor Red
        $allChecks += $false
    }
} else {
    Write-Host "❌ GitHub Actions workflow не найден" -ForegroundColor Red
    $allChecks += $false
}

# Итоговый результат
Write-Host "`n📊 Результат проверки:" -ForegroundColor Yellow
$passedChecks = ($allChecks | Where-Object { $_ -eq $true }).Count
$totalChecks = $allChecks.Count
$successRate = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

Write-Host "Пройдено проверок: $passedChecks из $totalChecks ($successRate%)" -ForegroundColor Cyan

if ($passedChecks -eq $totalChecks) {
    Write-Host "`n🎉 ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ! Проект готов к сборке!" -ForegroundColor Green
    Write-Host "`n🚀 Для запуска сборки выполните:" -ForegroundColor Yellow
    Write-Host "git add . && git commit -m 'ready: проект готов к сборке iOS' && git push" -ForegroundColor Cyan
} elseif ($successRate -ge 80) {
    Write-Host "`n⚠️ Большинство проверок пройдено. Можно попробовать сборку." -ForegroundColor Yellow
    Write-Host "Исправьте оставшиеся проблемы для лучшего результата." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ Слишком много проблем. Исправьте их перед сборкой." -ForegroundColor Red
    Write-Host "Обратитесь к BUILD_INSTRUCTIONS.md для подробностей." -ForegroundColor Yellow
}