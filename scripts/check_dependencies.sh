#!/bin/bash

# Скрипт для проверки зависимостей и поиска остаточных ссылок на google_sign_in

echo "🔍 Проверка зависимостей taste_smoke_ios..."

# Проверка pubspec.yaml
echo "📄 Проверка pubspec.yaml..."
if grep -q "^[[:space:]]*google_sign_in:" pubspec.yaml; then
    echo "❌ Найдена активная зависимость google_sign_in в pubspec.yaml"
    exit 1
else
    echo "✅ google_sign_in правильно закомментирован в pubspec.yaml"
fi

# Проверка импортов в Dart коде
echo "📱 Проверка импортов в Dart коде..."
GOOGLE_IMPORTS=$(find lib -name "*.dart" -exec grep -l "import.*google_sign_in" {} \; 2>/dev/null)
if [ -n "$GOOGLE_IMPORTS" ]; then
    echo "❌ Найдены прямые импорты google_sign_in:"
    echo "$GOOGLE_IMPORTS"
    exit 1
else
    echo "✅ Прямые импорты google_sign_in не найдены"
fi

# Проверка автогенерированных файлов
echo "🤖 Проверка автогенерированных файлов..."
if [ -d ".dart_tool" ]; then
    AUTOGEN_GOOGLE=$(find .dart_tool -name "*.dart" -exec grep -l "google_sign_in" {} \; 2>/dev/null)
    if [ -n "$AUTOGEN_GOOGLE" ]; then
        echo "⚠️ Найдены ссылки на google_sign_in в автогенерированных файлах"
        echo "💡 Рекомендация: выполните flutter clean"
    else
        echo "✅ Автогенерированные файлы чисты"
    fi
fi

# Проверка iOS конфигурации
echo "🍎 Проверка iOS конфигурации..."
if [ -f "ios/Podfile" ]; then
    if grep -q "google_sign_in" ios/Podfile; then
        echo "❌ Найдены ссылки на google_sign_in в Podfile"
        exit 1
    else
        echo "✅ Podfile чист от google_sign_in"
    fi
fi

# Проверка Info.plist
if [ -f "ios/Runner/Info.plist" ]; then
    if grep -q "REVERSED_CLIENT_ID\|google" ios/Runner/Info.plist; then
        echo "⚠️ Найдены возможные ссылки на Google в Info.plist"
        echo "💡 Проверьте URL schemes и удалите Google-специфичные настройки"
    else
        echo "✅ Info.plist чист от Google настроек"
    fi
fi

echo ""
echo "🎉 Проверка завершена! Проект готов к сборке без google_sign_in"
echo "🚀 Можно запускать: flutter build ios --no-codesign"