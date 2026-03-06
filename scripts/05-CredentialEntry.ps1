<#
.SYNOPSIS
    HIGH PRIORITY: Credential Entry Hardening
    Secure Desktop, logon UI restrictions
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Credential Entry ===" -ForegroundColor Magenta

# Logon settings
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DontDisplayNetworkSelectionUI" -Value 1 `
    -Description "Do not display network selection UI"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "EnumerateLocalUsers" -Value 0 `
    -Description "Enumerate local users on domain-joined computers: Disabled"

# Credential User Interface
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" `
    -Name "DisablePasswordReveal" -Value 1 `
    -Description "Do not display the password reveal button"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" `
    -Name "EnumerateAdministrators" -Value 0 `
    -Description "Enumerate administrator accounts on elevation: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" `
    -Name "EnableSecureCredentialPrompting" -Value 1 `
    -Description "Require trusted path for credential entry"

# Windows Logon Options
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "SoftwareSASGeneration" -Value 0 `
    -Description "Disable software Secure Attention Sequence"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableMPR" -Value 0 `
    -Description "Enable MPR notifications for the system: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "DisableAutomaticRestartSignOn" -Value 1 `
    -Description "Sign-in and lock last interactive user after restart: Disabled"

# Require CTRL+ALT+DEL
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "DisableCAD" -Value 0 `
    -Description "Interactive logon: Do not require CTRL+ALT+DEL = Disabled (require it)"
