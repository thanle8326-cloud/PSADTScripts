<#
.SYNOPSIS
    Installs Dell ControlVault3 Plus Driver and Firmware silently if not already installed.
    Designed for Intune packaging with relative path detection.
.DESCRIPTION
    1. Checks if "Dell ControlVault Host Components Installer 64-bit" is installed.
    2. If not installed, runs the EXE silently with /S and suppresses reboot.
    3. Logs output to C:\ProgramData\IntuneLogs\DellControlVault_Install.log.
#>

$ErrorActionPreference = "Stop"

# ===== CONFIGURATION =====
$logDir = "C:\ProgramData\IntuneLogs"
$logFile = Join-Path $logDir "DellControlVault_Install.log"
$installerName = "Dell-ControlVault3-Plus-Driver-and-Firmware.EXE"

# Create log folder
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force | Out-Null }

# Logging function
function Log {
    param([string]$msg)
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg"
}

# Get script directory for relative path (works in Intune)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installerPath = Join-Path $scriptDir $installerName

Log "===== Dell ControlVault 3 Plus Installation Script Started ====="

# ===== DETECTION =====
$cvInstalled = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, 
                                HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*Dell ControlVault Host Components Installer 64-bit*" }

if ($cvInstalled) {
    Log "Dell ControlVault Host Components Installer 64-bit is already installed. Version: $($cvInstalled.DisplayVersion)"
    Log "===== Script completed - no action needed ====="
    exit 0
}

# ===== INSTALLATION =====
if (Test-Path $installerPath) {
    try {
        Log "Installer found at $installerPath. Starting silent installation..."
        Start-Process -FilePath $installerPath -ArgumentList "/S " -Wait -NoNewWindow
        Log "Installation completed."
    }
    catch {
        Log "ERROR during installation: $($_.Exception.Message)"
        exit 1
    }
} else {
    Log "ERROR: Installer file not found at $installerPath"
    exit 1
}

Log "===== Dell ControlVault 3 Plus Installation Script Finished ====="
exit 0
