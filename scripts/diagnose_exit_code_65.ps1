# Advanced diagnostics for iOS exit code 65 in Flutter projects

Write-Host "Diagnosing iOS exit code 65 issues..." -ForegroundColor Cyan

# Step 1: Check for common causes of exit code 65
Write-Host ""
Write-Host "1. Checking common causes of exit code 65..." -ForegroundColor Yellow

# Check for missing files
$criticalFiles = @(
    "ios/Runner/Info.plist",
    "ios/Runner.xcodeproj/project.pbxproj", 
    "ios/Flutter/Generated.xcconfig",
    "ios/Runner/GeneratedPluginRegistrant.m",
    "ios/Runner/GeneratedPluginRegistrant.h"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ Found: $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ MISSING: $file" -ForegroundColor Red
    }
}

# Step 2: Check Info.plist for problematic entries
Write-Host ""
Write-Host "2. Analyzing Info.plist..." -ForegroundColor Yellow

if (Test-Path "ios/Runner/Info.plist") {
    $infoPlistContent = Get-Content "ios/Runner/Info.plist" -Raw
    
    # Check for Google-related URL schemes
    if ($infoPlistContent -match "REVERSED_CLIENT_ID|google|gms") {
        Write-Host "  ❌ Found Google-related entries in Info.plist" -ForegroundColor Red
        Write-Host "     This can cause exit code 65 if google_sign_in is not available" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Info.plist is clean from Google entries" -ForegroundColor Green
    }
    
    # Check for malformed XML
    try {
        [xml]$xmlContent = $infoPlistContent
        Write-Host "  ✅ Info.plist XML is well-formed" -ForegroundColor Green
    }
    catch {
        Write-Host "  ❌ Info.plist XML is malformed" -ForegroundColor Red
        Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Step 3: Check project.pbxproj for issues
Write-Host ""
Write-Host "3. Analyzing project.pbxproj..." -ForegroundColor Yellow

if (Test-Path "ios/Runner.xcodeproj/project.pbxproj") {
    $pbxContent = Get-Content "ios/Runner.xcodeproj/project.pbxproj" -Raw
    
    # Check for Google Sign-In references
    if ($pbxContent -match "google_sign_in|GoogleSignIn|GoogleService") {
        Write-Host "  ❌ Found Google Sign-In references in project.pbxproj" -ForegroundColor Red
    } else {
        Write-Host "  ✅ No Google Sign-In references in project.pbxproj" -ForegroundColor Green
    }
    
    # Check for broken file references
    $brokenReferences = ($pbxContent -split "`n" | Where-Object { $_ -match "path.*GoogleSignIn|name.*GoogleSignIn" })
    if ($brokenReferences.Count -gt 0) {
        Write-Host "  ❌ Found broken Google Sign-In file references:" -ForegroundColor Red
        foreach ($ref in $brokenReferences) {
            Write-Host "     $($ref.Trim())" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ✅ No broken Google Sign-In file references" -ForegroundColor Green
    }
}

# Step 4: Check for problematic build settings
Write-Host ""
Write-Host "4. Checking Flutter generated files..." -ForegroundColor Yellow

if (Test-Path "ios/Flutter/Generated.xcconfig") {
    $xcconfigContent = Get-Content "ios/Flutter/Generated.xcconfig" -Raw
    
    if ($xcconfigContent -match "google_sign_in") {
        Write-Host "  ❌ Found google_sign_in in Generated.xcconfig" -ForegroundColor Red
        Write-Host "     This indicates Flutter still thinks the plugin is available" -ForegroundColor Yellow
    } else {
        Write-Host "  ✅ Generated.xcconfig is clean" -ForegroundColor Green
    }
}

# Step 5: Check for orphaned build files
Write-Host ""
Write-Host "5. Checking for orphaned build files..." -ForegroundColor Yellow

$buildFolders = @(
    "ios/build",
    "build/ios",
    "ios/DerivedData"
)

foreach ($folder in $buildFolders) {
    if (Test-Path $folder) {
        Write-Host "  ⚠️  Found build folder: $folder" -ForegroundColor Yellow
        Write-Host "     Consider deleting for clean build" -ForegroundColor Blue
    }
}

# Step 6: Simulate Flutter build diagnosis
Write-Host ""
Write-Host "6. Running Flutter diagnostics..." -ForegroundColor Yellow

try {
    $flutterDoctor = flutter doctor --verbose 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Flutter doctor passed" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Flutter doctor found issues" -ForegroundColor Red
    }
}
catch {
    Write-Host "  ⚠️  Could not run flutter doctor" -ForegroundColor Yellow
}

# Step 7: Check pubspec.lock
Write-Host ""
Write-Host "7. Checking dependency lock file..." -ForegroundColor Yellow

if (Test-Path "pubspec.lock") {
    $lockContent = Get-Content "pubspec.lock" -Raw
    if ($lockContent -match "google_sign_in") {
        Write-Host "  ❌ CRITICAL: google_sign_in found in pubspec.lock" -ForegroundColor Red
        Write-Host "     This will cause compilation errors in iOS" -ForegroundColor Yellow
        Write-Host "     FIX: Delete pubspec.lock and run 'flutter pub get'" -ForegroundColor Blue
    } else {
        Write-Host "  ✅ pubspec.lock is clean" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  pubspec.lock not found" -ForegroundColor Yellow
    Write-Host "     Run 'flutter pub get' to generate it" -ForegroundColor Blue
}

Write-Host ""
Write-Host "Exit Code 65 Diagnosis Summary:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Exit code 65 typically indicates:" -ForegroundColor White
Write-Host "- Xcode project configuration errors" -ForegroundColor Gray
Write-Host "- Missing or broken file references" -ForegroundColor Gray  
Write-Host "- Plugin registration mismatches" -ForegroundColor Gray
Write-Host "- Malformed Info.plist or project.pbxproj" -ForegroundColor Gray
Write-Host "- Orphaned Google Sign-In references" -ForegroundColor Gray
Write-Host ""
Write-Host "NEXT STEPS if issues found:" -ForegroundColor Green
Write-Host "1. Run: flutter clean" -ForegroundColor Blue
Write-Host "2. Delete: pubspec.lock" -ForegroundColor Blue
Write-Host "3. Run: flutter pub get" -ForegroundColor Blue
Write-Host "4. Delete iOS build folders" -ForegroundColor Blue
Write-Host "5. Try: flutter build ios --no-codesign --verbose" -ForegroundColor Blue