<#
.SYNOPSIS
    HIGH PRIORITY: Multi-Factor Authentication (Windows Hello for Business)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Multi-Factor Authentication (WHfB) ===" -ForegroundColor Magenta

# PIN Complexity
$pinPath = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork\PINComplexity"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $pinPath `
    -Name "Expiration" -Value 365 `
    -Description "PIN Expiration: 365 days"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $pinPath `
    -Name "MinimumPINLength" -Value 6 `
    -Description "Minimum PIN length: 6"

# Biometrics - Enhanced anti-spoofing
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures" `
    -Name "EnhancedAntiSpoofing" -Value 1 `
    -Description "Configure enhanced anti-spoofing"

# Windows Hello for Business
$whfbPath = "HKLM:\SOFTWARE\Policies\Microsoft\PassportForWork"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $whfbPath `
    -Name "UsePassportForWork" -Value 1 `
    -Description "Use Windows Hello for Business"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $whfbPath `
    -Name "RequireSecurityDevice" -Value 1 `
    -Description "Use a hardware security device"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $whfbPath `
    -Name "UseBiometrics" -Value 1 `
    -Description "Use biometrics"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $whfbPath `
    -Name "ExcludeSecurityDevices\TPM12" -Value 1 `
    -Description "Do not use TPM 1.2"
