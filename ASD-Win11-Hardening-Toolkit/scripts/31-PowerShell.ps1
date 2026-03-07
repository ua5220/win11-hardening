<#
.SYNOPSIS
    MEDIUM PRIORITY: PowerShell Hardening
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== PowerShell Hardening ===" -ForegroundColor Magenta

$psPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

Set-RegistryValue -AuditOnly:$AuditOnly -Path "$psPath\ModuleLogging" `
    -Name "EnableModuleLogging" -Value 1 `
    -Description "Turn on Module Logging"

Set-RegistryValue -AuditOnly:$AuditOnly -Path "$psPath\ModuleLogging\ModuleNames" `
    -Name "*" -Value "*" -Type String `
    -Description "Module Names: * (all modules)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path "$psPath\ScriptBlockLogging" `
    -Name "EnableScriptBlockLogging" -Value 1 `
    -Description "Turn on PowerShell Script Block Logging"

Set-RegistryValue -AuditOnly:$AuditOnly -Path "$psPath\Transcription" `
    -Name "EnableTranscripting" -Value 1 `
    -Description "Turn on PowerShell Transcription"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $psPath `
    -Name "EnableScripts" -Value 1 `
    -Description "Turn on Script Execution"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $psPath `
    -Name "ExecutionPolicy" -Value "AllSigned" -Type String `
    -Description "Execution Policy: Allow only signed scripts"
