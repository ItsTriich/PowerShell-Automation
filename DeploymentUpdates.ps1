#Makes the program run as admin
param([switch]$Elevated)
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false) {
    if ($elevated) {
        # Tried to elevate, but it didn't work; aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}
'Running with full privileges'

# Install PSWindowsUpdate module if not already installed
if (-not (Get-Module -Name PSWindowsUpdate -ListAvailable)) {
    Write-Host "Installing PSWindowsUpdate module..."
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber
}

# Import the module
Import-Module PSWindowsUpdate

# Check for available updates including optional updates
Write-Host "Checking for available updates..."
$updates = Get-WindowsUpdate -MicrosoftUpdate -AcceptAll

# Display available updates
if ($updates.Count -gt 0) {
    Write-Host "Found $($updates.Count) update(s) available:"
    $updates | Format-Table -AutoSize

    # Install updates
    Write-Host "Installing updates..."
    Install-WindowsUpdate -AcceptAll -MicrosoftUpdate -Confirm:$false
    Write-Host "Updates installed successfully."

    # Check for pending restart
    $pendingRestart = Get-WindowsUpdate -InstallationResult PendingRestart
    if ($pendingRestart.Count -gt 0) {
        Write-Host "A restart is required to complete the update."
    } else {
        Write-Host "No restart required."
    }
} else {
    Write-Host "No updates available."
}

