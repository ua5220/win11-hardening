<#
.SYNOPSIS
    MEDIUM PRIORITY: Autoplay and AutoRun
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Autoplay and AutoRun ===" -ForegroundColor Magenta

$apPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "NoAutoplayfornonVolume" -Value 1 `
    -Description "Disallow Autoplay for non-volume devices"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoAutorun" -Value 1 `
    -Description "Set default behavior for AutoRun: Do not execute"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoDriveTypeAutoRun" -Value 255 `
    -Description "Turn off Autoplay on: All drives"
