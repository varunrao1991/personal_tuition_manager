# Create a base directory for debug info
$debugInfoDir = "debug_info"
$buildBaseDir = "build"

# Function to build APK for a specific user type
function Build-APK {
    param (
        [string]$userType,
        [string]$apkName
    )
    $buildNumber = 3  # Starting build number

    # Create a directory for user-specific debug info if it doesn't exist
    $debugInfoBaseDir = Join-Path -Path $buildBaseDir -ChildPath $debugInfoDir
    $userDebugInfoDir = Join-Path -Path $debugInfoBaseDir -ChildPath $userType

    Write-Host "Building APK for $userType..."

    # Build the APK with the specified flavor, debug info, and dart define for user type and environment
    $buildCommand = "flutter build apk --flavor $userType --release --obfuscate --split-debug-info=`"$userDebugInfoDir`" --dart-define=`"USER_TYPE=$userType`" --dart-define=`"ENV=production`" --build-name=`"1.0.0`" --build-number=`"$buildNumber`" --target-platform android-arm,android-arm64"
    Write-Host "Running command: $buildCommand"

    Invoke-Expression $buildCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "APK for $userType built successfully!"
    } else {
        Write-Host "Failed to build APK for $userType. Last exit code: $LASTEXITCODE"
        exit 1
    }
}

# Define properties for each user type
$apkProperties = @{
    "admin" = "AdminApp"
    "teacher" = "TeacherApp"
    "student" = "StudentApp"
}

# Build APKs for admin, teacher, and student
foreach ($userType in $apkProperties.Keys) {
    $apkName = $apkProperties[$userType]
    Build-APK $userType $apkName
}

Write-Host "All APKs built successfully!"
