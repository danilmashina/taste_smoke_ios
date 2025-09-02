# Simple build readiness check
Write-Host "Checking build readiness..." -ForegroundColor Green

# Check Flutter version
Write-Host "`nChecking Flutter version..." -ForegroundColor Yellow
flutter --version

# Check dependencies
Write-Host "`nInstalling dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to install dependencies!" -ForegroundColor Red
    exit 1
}

# Check code analysis
Write-Host "`nAnalyzing code..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos

Write-Host "`nBuild readiness check completed!" -ForegroundColor Green
Write-Host "You can now run the GitHub Actions build." -ForegroundColor Cyan