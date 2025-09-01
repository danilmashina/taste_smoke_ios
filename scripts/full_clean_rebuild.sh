#!/bin/bash

# Полная очистка и пересборка iOS проекта
# Используется после удаления зависимостей типа google_sign_in

echo "🧹 Полная очистка проекта taste_smoke_ios..."

# Очистка Flutter
echo "📱 Очистка Flutter кэша..."
flutter clean
flutter pub cache clean

# Удаление автогенерированных файлов
echo "🗑️ Удаление автогенерированных файлов..."
rm -rf .dart_tool/
rm -rf build/
rm -f pubspec.lock

# Очистка iOS зависимостей
echo "🍎 Очистка iOS зависимостей..."
cd ios
rm -rf Pods/
rm -f Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
cd ..

# Переустановка зависимостей
echo "📦 Установка зависимостей..."
flutter pub get

# Очистка CocoaPods кэша
echo "☕ Очистка CocoaPods кэша..."
cd ios
pod cache clean --all
pod repo update
pod install --verbose --repo-update
cd ..

echo "✅ Полная очистка завершена! Теперь можно собирать проект."
echo "💡 Для сборки iOS: flutter build ios --no-codesign"