# Create a base directory for debug info
$debugInfoDir = "debug_info"
$buildBaseDir = "build"

# Function to build AAB for a specific user type
function Build-AAB {
    param (
        [string]$userType,
        [string]$appName
    )
    $buildNumber = 3  # Starting build number

    # Create a directory for user-specific debug info if it doesn't exist
    $debugInfoBaseDir = Join-Path -Path $buildBaseDir -ChildPath $debugInfoDir
    $userDebugInfoDir = Join-Path -Path $debugInfoBaseDir -ChildPath $userType

    Write-Host "Building AAB for $userType..."

    # Build the AAB with the specified flavor, debug info, and dart define for user type and environment
    $buildCommand = "flutter build appbundle --flavor $userType --release --obfuscate --split-debug-info=`"$userDebugInfoDir`" --dart-define=`"USER_TYPE=$userType`" --dart-define=`"ENV=production`" --build-name=`"1.0.0`" --build-number=`"$buildNumber`""
    Write-Host "Running command: $buildCommand"

    Invoke-Expression $buildCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "AAB for $userType built successfully!"
    } else {
        Write-Host "Failed to build AAB for $userType. Last exit code: $LASTEXITCODE"
        exit 1
    }
}

# Define properties for each user type
$bundleProperties = @{
    "admin" = "AdminApp"
    "teacher" = "TeacherApp"
    "student" = "StudentApp"
}

# Build AABs for admin, teacher, and student
foreach ($userType in $bundleProperties.Keys) {
    $appName = $bundleProperties[$userType]
    Build-AAB $userType $appName
}

Write-Host "All AABs built successfully!"
