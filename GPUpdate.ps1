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

Get-WindowsCapability -Name 'Rsat.GroupPolicy.*' -Online | Where-Object { $_.State -ne 'Installed' } | Add-WindowsCapability -Online

# Run gpupdate
Write-Host "Updating Group Policies..."
Invoke-GPUpdate -Force 
Write-Host "Group Policies Updated"
