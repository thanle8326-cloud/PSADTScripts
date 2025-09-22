<#
.SYNOPSIS

PSApppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION

- The script is provided as a template to perform an install or uninstall of an application(s).
- The script either performs an "Install" deployment type or an "Uninstall" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType

The type of deployment to perform. Default is: Install.

.PARAMETER DeployMode

Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru

Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode

Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging

Disables logging to file for the script. Default is: $false.

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"

.EXAMPLE

powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"

.EXAMPLE

Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
- 69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
- 70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [String]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    } Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = 'Apache Friends'
    [String]$appName = 'XAMPP'
    [String]$appVersion = '8.2.4-0'
    [String]$appArch = ''
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '23/07/2025'
    [String]$appScriptAuthor = 'Gangadharrao Thanle'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = ''
    [String]$installTitle = ''

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.10.1'
    [String]$deployAppScriptDate = '05/03/2024'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## <Perform Pre-Installation tasks here>


        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'
        
        
##*===============================================
##* INSTALLATION
##*===============================================
If ($DeploymentType -ine 'Uninstall') {
    ##* Installation logic
    Try {
        Show-InstallationProgress -StatusMessage "Installing XAMPP silently. Please wait..."

        $xamppInstaller = Join-Path -Path $dirFiles -ChildPath "xampp-windows-x64-8.2.4-0-VS16-installer.exe"

        If (Test-Path -Path $xamppInstaller) {
            Write-Log -Message "Found XAMPP installer at: $xamppInstaller. Starting silent installation..."

            Execute-Process -Path $xamppInstaller -Parameters "--mode unattended" -WindowStyle Hidden

            Write-Log -Message "XAMPP installation completed successfully."
        } else {
            Write-Log -Message "XAMPP installer not found at path: $xamppInstaller" -Severity 3
            Throw "Installer not found at: $xamppInstaller"
        }

        Close-InstallationProgress
        Exit-Script -ExitCode 0
    }
    Catch {
        Write-Log -Message "XAMPP installation failed: $_" -Severity 3
        Close-InstallationProgress
        Show-DialogBox -Text "XAMPP installation failed. Check logs." -Icon 'Error'
        Exit-Script -ExitCode 1
    }
}

        ## Display a message at the end of the install
        If (-not $useDefaultMsi) {
            Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait
        }
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        ##Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        ##Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Uninstallation'

        # <Perform Uninstallation tasks here>
        
##*=============================================== Uninstallation Section ===================================================##

If ($deploymentType -ieq 'Uninstall') {
    Try {
        ##Show-InstallationProgress -StatusMessage "Uninstalling XAMPP completely..."

        $installDir = "C:\xampp"
        $handlePath = Join-Path -Path $dirFiles -ChildPath "handle.exe"

        ## Step 1: Kill XAMPP processes
        $processes = @("httpd", "mysqld", "xampp-control", "filezilla", "mercury", "tomcat", "Apache")
        foreach ($proc in $processes) {
            Get-Process -Name $proc -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    Write-Log -Message "Stopping process: $($_.Name)"
                    Stop-Process -Id $_.Id -Force -ErrorAction Stop
                } catch {
                    Write-Log -Message "Process $($_.Name) could not be stopped: $_"
                }
            }
        }

        ## Step 2: Disable XAMPP-related services
        $services = @("Apache2.4", "mysql", "filezilla", "mercury", "tomcat7")
        foreach ($svc in $services) {
            if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
                try {
                    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Log -Message "Disabled service: $svc"
                } catch {
                    Write-Log -Message "Failed to disable service $svc $_" -Severity 2
                }
            }
        }

        ## Step 3: Use handle.exe to detect & kill locked processes
if (Test-Path $handlePath) {
    Write-Log -Message "Running handle.exe to detect locks on $installDir..."
    $handleOutput = & $handlePath $installDir -accepteula 2>&1

    $lockedPIDs = ($handleOutput | Where-Object { $_ -match 'pid: (\d+)' }) |
        ForEach-Object {
            $_ -match 'pid: (\d+)' | Out-Null
            $Matches[1]
        } | Select-Object -Unique

    foreach ($processId in $lockedPIDs) {
        try {
            Write-Log -Message "Killing locked process PID: $processId"
            Stop-Process -Id $processId -Force -ErrorAction Stop
        } catch {
            Write-Log -Message "Failed to kill PID $processId $_" -Severity 2
        }
    }
} else {
    Write-Log -Message "handle.exe not found. Skipping handle cleanup." -Severity 2
}

        ## Step 4: Remove Start Menu/Desktop Shortcuts
        $paths = @(
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\XAMPP",
            "$env:AppData\Microsoft\Windows\Start Menu\Programs\XAMPP",
            "$env:Public\Desktop\xampp-control.lnk"
        )
        foreach ($path in $paths) {
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log -Message "Removed: $path"
            }
        }

        ## Step 5: Remove Uninstall registry key
        $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        $xamppKey = Get-ChildItem $uninstallKey | Where-Object {
            (Get-ItemProperty $_.PSPath).DisplayName -like "*XAMPP*"
        }
        foreach ($key in $xamppKey) {
            try {
                Remove-Item -Path $key.PSPath -Recurse -Force
                Write-Log -Message "Removed uninstall registry key: $($key.PSChildName)"
            } catch {
                Write-Log -Message "Failed to remove uninstall key: $_" -Severity 2
            }
        }

        ## Step 6: Delete the C:\xampp folder
        if (Test-Path $installDir) {
            try {
                Write-Log -Message "Attempting to delete: $installDir"
                Remove-Item -Path $installDir -Recurse -Force -ErrorAction Stop
                Write-Log -Message "Successfully deleted $installDir"
            } catch {
                Write-Log -Message "Failed to delete $installDir $_" -Severity 3
                Throw "Folder deletion failed"
            }
        } else {
            Write-Log -Message "$installDir not found. Skipping folder deletion."
        }

        Close-InstallationProgress
        Exit-Script -ExitCode 0
    }
    Catch {
        Write-Log -Message "Uninstallation failed: $_" -Severity 3
        Close-InstallationProgress
        Exit-Script -ExitCode 1
    }
}



        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>


    }
    ElseIf ($deploymentType -ieq 'Repair') {
        ##*===============================================
        ##* PRE-REPAIR
        ##*===============================================
        [String]$installPhase = 'Pre-Repair'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        ##Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        ##Show-InstallationProgress

        ## <Perform Pre-Repair tasks here>

        ##*===============================================
        ##* REPAIR
        ##*===============================================
        [String]$installPhase = 'Repair'

        ## Handle Zero-Config MSI Repairs
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }
        ## <Perform Repair tasks here>

        ##*===============================================
        ##* POST-REPAIR
        ##*===============================================
        [String]$installPhase = 'Post-Repair'

        ## <Perform Post-Repair tasks here>


    }
    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
