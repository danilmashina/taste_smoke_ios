# Скрипт для исправления проблем сборки iOS на Windows
# Запуск: powershell -ExecutionPolicy Bypass -File scripts\fix_ios_build.ps1

Write-Host "🔧 Исправление проблем сборки iOS для AltStore..." -ForegroundColor Green

# 1. Проверка Flutter
Write-Host "`n📋 Проверка Flutter..." -ForegroundColor Yellow
flutter doctor -v

# 2. Очистка всех кэшей
Write-Host "`n🧹 Полная очистка проекта..." -ForegroundColor Yellow
flutter clean
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "build"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "ios\Pods"
Remove-Item -Force -ErrorAction SilentlyContinue "ios\Podfile.lock"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "ios\.symlinks"
Remove-Item -Force -ErrorAction SilentlyContinue "pubspec.lock"

# 3. Переустановка зависимостей
Write-Host "`n📦 Переустановка Flutter зависимостей..." -ForegroundColor Yellow
flutter pub get

# 4. Проверка на ошибки
Write-Host "`n🔍 Анализ кода..." -ForegroundColor Yellow
flutter analyze

# 5. Проверка совместимости зависимостей
Write-Host "`n📊 Проверка устаревших зависимостей..." -ForegroundColor Yellow
flutter pub outdated

Write-Host "`n✅ Локальная диагностика завершена!" -ForegroundColor Green
Write-Host "Теперь можно запустить GitHub Actions для сборки IPA" -ForegroundColor Cyan