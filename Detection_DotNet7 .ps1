# Detection Script for .NET Core Runtime 7.0.20

# Define the runtime to check for
$runtimeName = "Microsoft.NETCore.App 7.0.20"

# Get the list of installed runtimes
$runtimes = & dotnet --list-runtimes

# Check if the specific runtime is installed
if ($runtimes -match $runtimeName) {
    # If the runtime is installed, exit with code 0 (success)
    Write-Output "$runtimeName is installed."
    exit 0
} else {
    # If the runtime is not installed, exit with code 1 (indicating remediation is needed)
    Write-Output "$runtimeName is not installed."
    exit 1
}