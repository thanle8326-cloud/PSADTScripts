<#
.SYNOPSIS
    Detection script for .NET Framework 3.5 for Intune.
.DESCRIPTION
    Checks the registry to verify if .NET 3.5 is installed.
#>

$regPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5"
$installValue = (Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue).Install

if ($installValue -eq 1) {
    Write-Output ".NET Framework 3.5 is installed."
    exit 0  # Detected
} else {
    Write-Output ".NET Framework 3.5 is NOT installed."
    exit 1  # Not Detected
}
