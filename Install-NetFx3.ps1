<#
.SYNOPSIS
    Silently installs .NET Framework 3.5 on Windows 10/11.
.DESCRIPTION
    Installs .NET 3.5 using Windows Update (no local SXS folder required). 
    Logs installation steps to Intune logs folder.
#>

# Logging Setup
$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\NetFx3_Install.log"
function Write-Log { param($msg) Add-Content -Path $logPath -Value ("[{0}] {1}" -f (Get-Date), $msg) }

Write-Log "Checking if .NET Framework 3.5 is already installed..."

# Check existing feature
$feature = Get-WindowsOptionalFeature -Online -FeatureName NetFx3

if ($feature.State -eq "Enabled") {
    Write-Log ".NET Framework 3.5 is already installed."
    exit 0
}

# Install .NET 3.5 silently via Windows Update
Write-Log "Installing .NET Framework 3.5 via Windows Update..."
try {
    Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart -ErrorAction Stop
    Write-Log ".NET Framework 3.5 installation completed successfully."
    exit 0
}
catch {
    Write-Log "ERROR: .NET Framework 3.5 installation failed: $_"
    exit 1
}
