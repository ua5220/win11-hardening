<#
.SYNOPSIS
    HIGH PRIORITY: Early Launch Antimalware (ELAM)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Early Launch Antimalware ===" -ForegroundColor Magenta

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" `
    -Name "DriverLoadPolicy" -Value 3 `
    -Description "Boot-Start Driver Init: Good, unknown and bad but critical"
