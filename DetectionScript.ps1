# Detection Script for Dell ControlVault Host Components Installer (64-bit)
$ErrorActionPreference = "SilentlyContinue"
$found = $false

# 1. Check Uninstall registry for matching display name
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $regPaths) {
    $apps = Get-ItemProperty $path | Where-Object {
        $_.DisplayName -match "Dell\s+ControlVault"
    }
    if ($apps) {
        Write-Output "Found in registry: $($apps.DisplayName) - Version: $($apps.DisplayVersion)"
        $found = $true
        break
    }
}

# 2. Check if the driver exists in the PnP signed drivers list
if (-not $found) {
    $drivers = Get-WmiObject Win32_PnPSignedDriver | Where-Object {
        $_.DeviceName -match "ControlVault"
    }
    if ($drivers) {
        Write-Output "Found ControlVault driver: $($drivers.DeviceName) - Version: $($drivers.DriverVersion)"
        $found = $true
    }
}

# Exit code for Intune
if ($found) {
    exit 0  # Installed
} else {
    Write-Output "Dell ControlVault Host Components Installer not found."
    exit 1  # Not installed
}
