#!/bin/bash

# Configuration
debugInfoDir="debug_info"
buildBaseDir="build"
buildNumber=1
apkName="TeacherApp"
versionName="1.0.$buildNumber"
environment="production"  # Change to "development" or "staging" as needed
platforms="android-arm,android-arm64"

# Cross-platform environment variable handling
if [ -n "$KEYSTORE_FOLDER" ]; then
  echo "Using provided KEYSTORE_FOLDER: $KEYSTORE_FOLDER"
else
  # Try to get Windows env var if running in WSL
  if command -v wslpath &> /dev/null && command -v cmd.exe &> /dev/null; then
    KEYSTORE_FOLDER=$(cmd.exe /C "echo %KEYSTORE_FOLDER%" 2>/dev/null | tr -d '\r')
    if [ -n "$KEYSTORE_FOLDER" ]; then
      KEYSTORE_FOLDER=$(wslpath "$KEYSTORE_FOLDER")
    fi
  fi

  # Fallback to default Linux path if still not set
  KEYSTORE_FOLDER="${KEYSTORE_FOLDER:-$HOME/keystores}"
fi

# Convert backslashes to forward slashes (Windows compatibility)
KEYSTORE_FOLDER="${KEYSTORE_FOLDER//\\//}"

# Verify path exists
if [ ! -d "$KEYSTORE_FOLDER" ]; then
  echo "ERROR: Keystore folder not found: $KEYSTORE_FOLDER"
  exit 1
fi

# Rest of your build script
echo "Building with keystore folder: $KEYSTORE_FOLDER"

# Setup
debugInfoPath="$buildBaseDir/$debugInfoDir"
mkdir -p "$debugInfoPath"

echo "Building APK for $environment environment..."

# Build command
buildCommand="flutter build apk \
--release \
--obfuscate \
--split-debug-info=\"$debugInfoPath\" \
--dart-define=ENV=$environment \
--build-name=\"$versionName\" \
--build-number=$buildNumber \
--target-platform=$platforms"

echo "Executing:"
echo "$buildCommand"

# Execute build
eval "$buildCommand"

# Handle result
if [ $? -eq 0 ]; then
    echo -e "\nAPK build successful!"
    echo "Version: $versionName"
    echo "Build: $buildNumber"
    echo "Environment: $environment"

    outputDir="build/app/outputs/flutter-apk"
    originalApk="$outputDir/app-release.apk"
    renamedApk="$outputDir/${apkName}-${versionName}-${environment}.apk"

    if [ -f "$originalApk" ]; then
        mv "$originalApk" "$renamedApk"
        echo "APK renamed to: $renamedApk"
    else
        echo "WARNING: APK not found at expected location: $originalApk"
    fi
else
    echo -e "\nAPK build failed!"
    exit 1
fi
