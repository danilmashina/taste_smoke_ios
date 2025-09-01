#!/bin/bash

# iOS Dependencies Fix Script for taste_smoke_ios
# This script resolves common CocoaPods dependency issues

echo "🔧 Fixing iOS dependencies for taste_smoke_ios..."

# Clean Flutter first
echo "🧹 Cleaning Flutter..."
flutter clean
flutter pub get

# Navigate to iOS directory
cd "$(dirname "$0")/../ios" || exit 1

echo "📁 Current directory: $(pwd)"

# Clean previous installations
echo "🧹 Cleaning previous installations..."
rm -rf Pods
rm -f Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Update CocoaPods repository
echo "📦 Updating CocoaPods repository..."
pod repo update

# Clean CocoaPods cache
echo "🗑️ Cleaning CocoaPods cache..."
pod cache clean --all

# Install dependencies with verbose output
echo "⚙️ Installing CocoaPods dependencies..."
pod install --verbose --repo-update

# Check if installation was successful
if [ $? -eq 0 ]; then
    echo "✅ iOS dependencies fixed successfully!"
    echo "🎉 You can now build the iOS app"
else
    echo "❌ Failed to fix iOS dependencies. Check the output above for errors."
    echo "💡 Try running: pod install --verbose --repo-update"
    exit 1
fi