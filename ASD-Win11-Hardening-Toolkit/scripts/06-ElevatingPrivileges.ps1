<#
.SYNOPSIS
    HIGH PRIORITY: User Account Control (UAC) Configuration
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== UAC Configuration ===" -ForegroundColor Magenta

$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "FilterAdministratorToken" -Value 1 `
    -Description "Admin Approval Mode for Built-in Administrator"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "ConsentPromptBehaviorAdmin" -Value 1 `
    -Description "Elevation prompt for admins: Prompt for credentials on secure desktop"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "ConsentPromptBehaviorUser" -Value 0 `
    -Description "Elevation prompt for standard users: Automatically deny"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "EnableInstallerDetection" -Value 1 `
    -Description "Detect application installations and prompt for elevation"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "EnableSecureUIAPaths" -Value 1 `
    -Description "Only elevate UIAccess apps installed in secure locations"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "EnableLUA" -Value 1 `
    -Description "Run all administrators in Admin Approval Mode"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $uacPath `
    -Name "EnableVirtualization" -Value 1 `
    -Description "Virtualize file and registry write failures to per-user locations"
