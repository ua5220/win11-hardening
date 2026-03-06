<#
.SYNOPSIS
    MEDIUM PRIORITY: Power Management (disable sleep/hibernate)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Power Management ===" -ForegroundColor Magenta

$sleepPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"

# Disable standby states
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" `
    -Name "DCSettingIndex" -Value 0 `
    -Description "Disable standby S1-S3 (battery)"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab" `
    -Name "ACSettingIndex" -Value 0 `
    -Description "Disable standby S1-S3 (plugged in)"

# Require password on wake
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" `
    -Name "DCSettingIndex" -Value 1 `
    -Description "Require password on wake (battery)"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51" `
    -Name "ACSettingIndex" -Value 1 `
    -Description "Require password on wake (plugged in)"

# Disable hibernate/sleep/hybrid via powercfg
if (-not $AuditOnly) {
    powercfg /hibernate off 2>$null
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0
    Write-Host "  [SET] Sleep/Hibernate disabled via powercfg" -ForegroundColor Cyan
}

# Hide hibernate/sleep from power menu
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "ShowHibernateOption" -Value 0 `
    -Description "Show hibernate in power options menu: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "ShowSleepOption" -Value 0 `
    -Description "Show sleep in power options menu: Disabled"
