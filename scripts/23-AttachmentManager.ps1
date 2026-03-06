<#
.SYNOPSIS
    MEDIUM PRIORITY: Attachment Manager
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Attachment Manager ===" -ForegroundColor Magenta

$amPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $amPath `
    -Name "SaveZoneInformation" -Value 2 `
    -Description "Do not preserve zone information: Disabled (preserve it)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $amPath `
    -Name "HideZoneInfoOnProperties" -Value 1 `
    -Description "Hide mechanisms to remove zone information: Enabled"
