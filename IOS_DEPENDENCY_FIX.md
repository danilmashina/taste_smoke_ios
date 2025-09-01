# iOS CocoaPods Dependency Issues Fix Guide - TasteSmoke iOS

## Problem Description
The build fails with CocoaPods dependency resolution error:
```
[!] CocoaPods could not find compatible versions for pod "GoogleUtilities/Environment":
  In Podfile:
    firebase_auth (from `.symlinks/plugins/firebase_auth/ios`) was resolved to 4.20.0, which depends on
      Firebase/Auth (= 10.25.0) was resolved to 10.25.0, which depends on
        FirebaseAuth (~> 10.25.0) was resolved to 10.25.0, which depends on
          GoogleUtilities/Environment (~> 7.8)
```

## Root Cause
Version conflicts between Firebase SDK components and GoogleUtilities dependencies.

## Solutions Applied

### 1. Updated Firebase Dependencies in pubspec.yaml
- Updated `firebase_core` from `^2.32.0` to `^2.34.0`
- Updated `firebase_auth` from `^4.20.0` to `^4.21.0`
- Kept other Firebase packages at compatible versions

### 2. Enhanced Podfile Configuration (ios/Podfile)
- Added explicit CocoaPods source: `source 'https://cdn.cocoapods.org/'`
- Specified GoogleUtilities version explicitly: `pod 'GoogleUtilities', '~> 7.12.0'`
- Added compatible Firebase SDK versions
- Enhanced post_install script with better build settings

### 3. Improved GitHub Actions Workflow (.github/workflows/build_ios.yml)
- Added comprehensive dependency cleaning
- Enhanced CocoaPods installation process
- Added verbose output for debugging

### 4. Created Automated Fix Script
- `scripts/fix_ios_dependencies.sh` - Automates the