# Скрипт для исправления проблем сборки iOS на Windows
# Запуск: powershell -ExecutionPolicy Bypass -File scripts\fix_ios_build.ps1

Write-Host "🔧 Исправление проблем сборки iOS для AltStore..." -ForegroundColor Green

# 1. Проверка Flutter и Dart версий
Write-Host "`n📋 Проверка Flutter и Dart версий..." -ForegroundColor Yellow
flutter --version
dart --version
flutter doctor -v

# 2. Очистка всех кэшей
Write-Host "`n🧹 Полная очистка проекта..." -ForegroundColor Yellow
flutter clean
flutter pub cache clean --force
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "build"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "ios\Pods"
Remove-Item -Force -ErrorAction SilentlyContinue "ios\Podfile.lock"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "ios\.symlinks"
Remove-Item -Force -ErrorAction SilentlyContinue "pubspec.lock"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue ".dart_tool"

# 3. Проверка совместимости версий
Write-Host "`n🔍 Проверка совместимости Dart SDK..." -ForegroundColor Yellow
$dartVersion = dart --version 2>&1 | Select-String -Pattern "(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches[0].Value }
Write-Host "Текущая версия Dart: $dartVersion" -ForegroundColor Cyan

# 4. Переустановка зависимостей
Write-Host "`n📦 Переустановка Flutter зависимостей..." -ForegroundColor Yellow
$pubGetResult = flutter pub get 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Зависимости установлены успешно!" -ForegroundColor Green
} else {
    Write-Host "❌ Ошибка установки зависимостей:" -ForegroundColor Red
    Write-Host $pubGetResult -ForegroundColor Red
    Write-Host "`n💡 Попробуйте обновить Flutter:" -ForegroundColor Yellow
    Write-Host "flutter upgrade" -ForegroundColor Cyan
    exit 1
}

# 5. Проверка на ошибки
Write-Host "`n🔍 Анализ кода..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos

# 6. Проверка совместимости зависимостей
Write-Host "`n📊 Проверка устаревших зависимостей..." -ForegroundColor Yellow
flutter pub outdated

Write-Host "`n✅ Локальная диагностика завершена!" -ForegroundColor Green
Write-Host "Теперь можно запустить GitHub Actions для сборки IPA" -ForegroundColor Cyan
Write-Host "`n🚀 Для запуска сборки:" -ForegroundColor Yellow
Write-Host "git add . && git commit -m 'fix: совместимость версий SDK' && git push" -ForegroundColor Cyan