# Define the version to be removed
$versionToRemove = "7.0.302"

# Define the paths for .NET Core SDK and Runtime installations
$sdkPath = "C:\Program Files\dotnet\sdk"
$runtimePath = "C:\Program Files\dotnet\shared\Microsoft.NETCore.App"

# Construct the paths for the specific version
$sdkVersionPath = Join-Path -Path $sdkPath -ChildPath $versionToRemove
$runtimeVersionPath = Join-Path -Path $runtimePath -ChildPath $versionToRemove

# Check and remove the SDK version
if (Test-Path -Path $sdkVersionPath) {
    Remove-Item -Path $sdkVersionPath -Recurse -Force
    Write-Output "SDK version $versionToRemove has been removed."
} else {
    Write-Output "SDK version $versionToRemove not found."
}

# Check and remove the Runtime version
if (Test-Path -Path $runtimeVersionPath) {
    Remove-Item -Path $runtimeVersionPath -Recurse -Force
    Write-Output "Runtime version $versionToRemove has been removed."
} else {
    Write-Output "Runtime version $versionToRemove not found."
}