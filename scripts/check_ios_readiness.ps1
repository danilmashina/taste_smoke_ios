# Проверка готовности iOS проекта к сборке
# Запуск: powershell -ExecutionPolicy Bypass -File scripts\check_ios_readiness.ps1

Write-Host "Checking iOS project readiness..." -ForegroundColor Green

$issues = @()

# 1. Проверка Flutter зависимостей
Write-Host "`nChecking Flutter dependencies..." -ForegroundColor Yellow
if (flutter pub get) {
    Write-Host "✅ Flutter dependencies OK" -ForegroundColor Green
} else {
    Write-Host "❌ Flutter dependencies failed" -ForegroundColor Red
    $issues += "Flutter dependencies"
}

# 2. Проверка iOS файлов
Write-Host "`nChecking iOS project files..." -ForegroundColor Yellow

$iosFiles = @{
    "ios\Runner.xcodeproj\project.pbxproj" = "Xcode project file"
    "ios\Runner\Info.plist" = "iOS Info.plist"
    "ios\Podfile" = "Main Podfile"
    "ios\Podfile.minimal" = "Backup Podfile"
}

foreach ($file in $iosFiles.Keys) {
    if (Test-Path $file) {
        Write-Host "✅ $($iosFiles[$file]) found" -ForegroundColor Green
    } else {
        Write-Host "❌ $($iosFiles[$file]) missing: $file" -ForegroundColor Red
        $issues += $iosFiles[$file]
    }
}

# 3. Проверка Flutter конфигурации
Write-Host "`nChecking Flutter iOS configuration..." -ForegroundColor Yellow

if (Test-Path "ios\Flutter\Generated.xcconfig") {
    Write-Host "✅ Flutter Generated.xcconfig found" -ForegroundColor Green
} else {
    Write-Host "⚠️ Generated.xcconfig missing (will be created during build)" -ForegroundColor Yellow
}

# 4. Проверка pubspec.yaml
Write-Host "`nChecking pubspec.yaml..." -ForegroundColor Yellow
$pubspecContent = Get-Content "pubspec.yaml" -Raw

if ($pubspecContent -match "flutter:") {
    Write-Host "✅ Flutter configuration found in pubspec.yaml" -ForegroundColor Green
} else {
    Write-Host "❌ Invalid pubspec.yaml" -ForegroundColor Red
    $issues += "pubspec.yaml configuration"
}

# 5. Проверка Firebase конфигурации (если используется)
if ($pubspecContent -match "firebase_") {
    Write-Host "`nChecking Firebase configuration..." -ForegroundColor Yellow
    
    if (Test-Path "ios\Runner\GoogleService-Info.plist") {
        Write-Host "✅ GoogleService-Info.plist found" -ForegroundColor Green
    } else {
        Write-Host "⚠️ GoogleService-Info.plist missing (may cause Firebase issues)" -ForegroundColor Yellow
    }
}

# 6. Проверка Podfile синтаксиса
Write-Host "`nChecking Podfile syntax..." -ForegroundColor Yellow
$podfileContent = Get-Content "ios\Podfile" -Raw

if ($podfileContent -match "flutter_additional_ios_build_settings") {
    Write-Host "✅ Standard Flutter function found in Podfile" -ForegroundColor Green
} else {
    Write-Host "❌ Missing standard Flutter function in Podfile" -ForegroundColor Red
    $issues += "Podfile Flutter function"
}

if ($podfileContent -match "installer\.project\.targets") {
    Write-Host "⚠️ Potentially problematic 'installer.project.targets' found" -ForegroundColor Yellow
    Write-Host "   This may cause issues with CocoaPods 1.16+" -ForegroundColor Yellow
}

# Итоговый результат
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "READINESS CHECK RESULTS" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan

if ($issues.Count -eq 0) {
    Write-Host "`n🎉 ALL CHECKS PASSED!" -ForegroundColor Green
    Write-Host "iOS project is ready for GitHub Actions build." -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. git add ." -ForegroundColor White
    Write-Host "2. git commit -m 'ready: iOS project ready for build'" -ForegroundColor White
    Write-Host "3. git push origin main" -ForegroundColor White
} else {
    Write-Host "`n⚠️ ISSUES FOUND:" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Red
    }
    Write-Host "`nPlease fix these issues before building." -ForegroundColor Yellow
}

Write-Host "`n" + "="*50 -ForegroundColor Cyan