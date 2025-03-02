#!/bin/bash
# Build Flutter apps for all platforms

# Build for Android
flutter build apk --release

# Build for iOS (requires macOS)
# flutter build ios --release

# Build for Windows
flutter build windows --release

# Build for macOS (requires macOS)
# flutter build macos --release

# Build for Linux
flutter build linux --release 