<#
.SYNOPSIS
    MEDIUM PRIORITY: Anonymous Connections & Antivirus Configuration
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Anonymous Connections ===" -ForegroundColor Magenta

$secOptPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" `
    -Name "AllowInsecureGuestAuth" -Value 0 `
    -Description "Enable insecure guest logons: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOptPath `
    -Name "AnonymousNameLookup" -Value 0 `
    -Description "Allow anonymous SID/Name translation: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOptPath `
    -Name "RestrictAnonymousSAM" -Value 1 `
    -Description "Do not allow anonymous enumeration of SAM accounts"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOptPath `
    -Name "RestrictAnonymous" -Value 1 `
    -Description "Do not allow anonymous enumeration of SAM accounts and shares"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOptPath `
    -Name "EveryoneIncludesAnonymous" -Value 0 `
    -Description "Let Everyone permissions apply to anonymous users: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOptPath `
    -Name "RestrictRemoteSAM" -Value "O:BAG:BAD:(A;;RC;;;BA)" -Type String `
    -Description "Restrict clients allowed to make remote calls to SAM"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "RestrictNullSessAccess" -Value 1 `
    -Description "Restrict anonymous access to Named Pipes and Shares"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $secOptPath `
    -Name "TurnOffAnonymousBlock" -Value 1 `
    -Description "Network security: Allow LocalSystem NULL session fallback: Disabled"
