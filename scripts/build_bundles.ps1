# Create a directory for the output AABs if it doesn't exist
$outputDir = "output_aabs"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Create a base directory for debug info
$debugInfoBaseDir = "debug_info"
if (-not (Test-Path $debugInfoBaseDir)) {
    New-Item -ItemType Directory -Path $debugInfoBaseDir
}

# Function to build AAB for a specific user type
function Build-AAB {
    param (
        [string]$userType,
        [string]$appName
    )

    # Create a directory for user-specific debug info if it doesn't exist
    $userDebugInfoDir = Join-Path -Path $debugInfoBaseDir -ChildPath $userType
    if (-not (Test-Path $userDebugInfoDir)) {
        New-Item -ItemType Directory -Path $userDebugInfoDir
    }

    Write-Host "Building AAB for $userType..."

    # Build the AAB with the specified flavor, debug info, and dart define for user type and environment
    $buildCommand = "flutter build appbundle --flavor $userType --release --obfuscate --split-debug-info=`"$userDebugInfoDir`" --dart-define=`"USER_TYPE=$userType`" --dart-define=`"ENV=production`" --build-name=`"1.0.0`" --build-number=`"1`""
    Write-Host "Running command: $buildCommand"

    Invoke-Expression $buildCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "AAB for $userType built successfully!"
        Move-Item ".\build\app\outputs\bundle\release\app-release.aab" "$outputDir\$appName.aab"
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
