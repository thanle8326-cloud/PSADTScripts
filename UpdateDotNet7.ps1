<#
.SYNOPSIS
    This script checks if a specific version of the .NET Core runtime is installed on the system. 
    If detected, it installs the .NET Desktop Runtime 8 and uninstalls the .NET Core Runtime 7.0.20.

.DESCRIPTION
    It first verifies the presence of the target .NET Core runtime (version 7.0.20). Upon confirmation, 
    the script installs the .NET Desktop Runtime 8 using WingetT. 
    After installing the new runtime, the script uninstalls the older .NET Core Runtime version to maintain a clean system and avoid potential runtime conflicts. 
    .NET Core runtime (version 7.0.20) is a EOL application.

.DATE
    August 14, 2024

.AUTHOR
    Kenny Mathias
#>

# Define the runtime you are looking for
$runtimeName = "Microsoft.NETCore.App 7.0.20"
$newRuntimeName = "Microsoft.WindowsDesktop.App 8"

# Get the list of installed runtimes
$runtimes = & dotnet --list-runtimes

# Check if the specific runtime is installed
if ($runtimes -match $runtimeName) {
    Write-Host "$runtimeName is installed."

    # Install .NET Desktop Runtime 8 using winget
    Write-Host "Installing .NET Desktop Runtime 8..."
    $wingetInstallResult = & winget install Microsoft.DotNet.DesktopRuntime.8 --Silent

    if ($wingetInstallResult) {
        # Verify if .NET Desktop Runtime 8 was successfully installed
        $runtimesAfterInstall = & dotnet --list-runtimes

        if ($runtimesAfterInstall -match $newRuntimeName) {
            Write-Host ".NET Desktop Runtime 8 installed successfully."

            # Uninstall .NET Core Runtime 7.0.20 using winget
            Write-Host "Uninstalling $runtimeName..."
            $wingetUninstallResult = & winget uninstall Microsoft.DotNet.DesktopRuntime.7

            if ($wingetUninstallResult) {
                Write-Host "Exit 0: $runtimeName successfully uninstalled."
                exit 0  # Success
            } else {
                Write-Error "Exit 1: Failed to uninstall $runtimeName using winget."
                exit 1  # Failure in uninstalling
            }
        } else {
            Write-Error "Exit 2: .NET Desktop Runtime 8 installation verification failed."
            exit 2  # Failure in verifying the new runtime installation
        }
    } else {
        Write-Error "Exit 3: Failed to install .NET Desktop Runtime 8."
        exit 3  # Failure in installing the new runtime
    }
} else {
    Write-Host "Exit 0: $runtimeName is not installed."
    exit 0  # Success (no action needed since the runtime is not installed)
}

