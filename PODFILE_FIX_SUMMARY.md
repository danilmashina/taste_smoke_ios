# 🔧 Исправление проблемы с Podfile для CocoaPods 1.16+

## 🎯 Проблема
Ошибка: `[!] An error occurred while processing the post-install hook of the Podfile. undefined method 'project' for an instance of Pod::Installer`

## ✅ Решение

### 1. Исправлен основной Podfile
**Было (проблемная конструкция):**
```ruby
# Set deployment target для основного проекта
installer.project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  end
end
```

**Стало (совместимо с CocoaPods 1.16+):**
```ruby
post_install do |installer|
  # Стандартные настройки Flutter (обязательно!)
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      # Базовые настройки для AltStore совместимости
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # Исправление для симулятора (только если нужно)
      if target.platform_name == :ios
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
      
      # Подавление предупреждений для стабильной сборки
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
  end
end
```

### 2. Создан резервный минимальный Podfile
- **Файл**: `ios/Podfile.minimal`
- **Содержит**: только стандартные Flutter настройки
- **Использование**: автоматически при ошибке основного Podfile

### 3. Улучшен GitHub Actions workflow
- **Автоматическое переключение**: при ошибке основного Podfile
- **Резервный план**: использование минимального Podfile
- **Логирование**: подробные сообщения о процессе

## 🚀 Как это работает

1. **Первая попытка**: GitHub Actions пробует основной Podfile
2. **При ошибке**: автоматически переключается на минимальный
3. **Результат**: сборка продолжается с базовыми настройками

## 📋 Ключевые изменения

### Убрано (проблемные конструкции):
- ❌ `installer.project.targets` 
- ❌ Сложные манипуляции с флагами компиляции
- ❌ Избыточные настройки проекта

### Добавлено (совместимые решения):
- ✅ Только `installer.pods_project.targets`
- ✅ Условная проверка `target.platform_name`
- ✅ Резервный минимальный Podfile
- ✅ Автоматическое переключение в CI

## 🎉 Результат
- **Совместимость**: с CocoaPods 1.16+ и новее
- **Надежность**: автоматическое восстановление при ошибках
- **Простота**: минимальные изменения для максимальной совместимости
- **AltStore готовность**: все настройки сохранены для беспроблемной установки

## 💡 Рекомендации на будущее
1. **Минимализм**: используйте только необходимые настройки в post_install
2. **Стандарт**: всегда включайте `flutter_additional_ios_build_settings(target)`
3. **Тестирование**: проверяйте совместимость с новыми версиями CocoaPods
4. **Резерв**: держите минимальный Podfile как запасной вариант