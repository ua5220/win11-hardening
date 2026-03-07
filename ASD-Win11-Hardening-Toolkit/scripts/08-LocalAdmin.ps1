<#
.SYNOPSIS
    HIGH PRIORITY: Local Administrator Accounts (LAPS + UAC restrictions)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Local Administrator Accounts ===" -ForegroundColor Magenta

# LAPS Configuration
$lapsPath = "HKLM:\SOFTWARE\Policies\Microsoft Services\AdmPwd"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $lapsPath `
    -Name "AdmPwdEnabled" -Value 1 `
    -Description "LAPS: Enabled"

# Windows LAPS (new built-in)
$wlapsPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\LAPS"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wlapsPath `
    -Name "BackupDirectory" -Value 1 `
    -Description "LAPS: Backup to Active Directory"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wlapsPath `
    -Name "PasswordComplexity" -Value 4 `
    -Description "LAPS: Large + small letters"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wlapsPath `
    -Name "PasswordLength" -Value 30 `
    -Description "LAPS: Password Length 30"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wlapsPath `
    -Name "PasswordAgeDays" -Value 365 `
    -Description "LAPS: Password Age 365 days"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $wlapsPath `
    -Name "ADPasswordEncryptionEnabled" -Value 1 `
    -Description "LAPS: Enable password encryption"

# Apply UAC restrictions to local accounts on network logons (MS Security Guide)
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "LocalAccountTokenFilterPolicy" -Value 0 `
    -Description "Apply UAC restrictions to local accounts on network logons"
