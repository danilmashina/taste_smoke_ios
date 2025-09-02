# Скрипт для тестирования Podfile на Windows (симуляция)
# Запуск: powershell -ExecutionPolicy Bypass -File scripts\test_podfile.ps1

Write-Host "🧪 Тестирование Podfile конфигурации..." -ForegroundColor Green

# Проверка наличия файлов
Write-Host "`n📋 Проверка файлов Podfile..." -ForegroundColor Yellow

if (Test-Path "ios\Podfile") {
    Write-Host "✅ Основной Podfile найден" -ForegroundColor Green
} else {
    Write-Host "❌ Основной Podfile не найден" -ForegroundColor Red
    exit 1
}

if (Test-Path "ios\Podfile.minimal") {
    Write-Host "✅ Минимальный Podfile найден" -ForegroundColor Green
} else {
    Write-Host "❌ Минимальный Podfile не найден" -ForegroundColor Red
    exit 1
}

# Проверка синтаксиса Podfile
Write-Host "`n🔍 Анализ содержимого Podfile..." -ForegroundColor Yellow

$podfileContent = Get-Content "ios\Podfile" -Raw

# Проверка на проблемные конструкции
$issues = @()

if ($podfileContent -match "installer\.project\.targets") {
    $issues += "❌ Найдена проблемная конструкция 'installer.project.targets'"
}

if ($podfileContent -match "flutter_additional_ios_build_settings") {
    Write-Host "✅ Стандартная Flutter функция найдена" -ForegroundColor Green
} else {
    $issues += "⚠️ Отсутствует стандартная Flutter функция"
}

if ($podfileContent -match "platform :ios, '13\.0'") {
    Write-Host "✅ iOS deployment target корректный (13.0)" -ForegroundColor Green
} else {
    $issues += "⚠️ Неправильный iOS deployment target"
}

# Проверка минимального Podfile
Write-Host "`n🔍 Анализ минимального Podfile..." -ForegroundColor Yellow

$minimalContent = Get-Content "ios\Podfile.minimal" -Raw

if ($minimalContent -notmatch "installer\.project\.targets") {
    Write-Host "✅ Минимальный Podfile не содержит проблемных конструкций" -ForegroundColor Green
} else {
    $issues += "❌ Минимальный Podfile содержит проблемные конструкции"
}

# Вывод результатов
Write-Host "`n📊 Результаты анализа:" -ForegroundColor Yellow

if ($issues.Count -eq 0) {
    Write-Host "🎉 Все проверки пройдены! Podfile готов к использованию." -ForegroundColor Green
    Write-Host "`n🚀 Можно запускать GitHub Actions сборку." -ForegroundColor Cyan
} else {
    Write-Host "⚠️ Найдены потенциальные проблемы:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host "  $issue" -ForegroundColor Red
    }
    Write-Host "`n💡 GitHub Actions автоматически переключится на минимальный Podfile при ошибке." -ForegroundColor Cyan
}

Write-Host "`n📝 Рекомендации:" -ForegroundColor Yellow
Write-Host "1. Основной Podfile содержит оптимизации для AltStore" -ForegroundColor White
Write-Host "2. Минимальный Podfile - запасной вариант для совместимости" -ForegroundColor White
Write-Host "3. GitHub Actions автоматически выберет рабочий вариант" -ForegroundColor White