<#
.SYNOPSIS
    HIGH PRIORITY: Operating System Patching Configuration
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== OS Patching Configuration ===" -ForegroundColor Magenta

$wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wuPath `
    -Name "NoAutoUpdate" -Value 0 `
    -Description "Configure Automatic Updates: Enabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wuPath `
    -Name "AUOptions" -Value 4 `
    -Description "Auto download and schedule the install"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wuPath `
    -Name "ScheduledInstallDay" -Value 0 `
    -Description "Scheduled install day: Every day"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wuPath `
    -Name "AllowMUUpdateService" -Value 1 `
    -Description "Install updates for other Microsoft products"

# Remove access to Pause updates
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" `
    -Name "SetDisablePauseUXAccess" -Value 1 `
    -Description "Remove access to Pause updates feature"

# Allow Updates in OOBE
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" `
    -Name "AllowUpdatesInOOBE" -Value 1 `
    -Description "Allow Updates in OOBE"
