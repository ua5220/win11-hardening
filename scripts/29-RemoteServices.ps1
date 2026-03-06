<#
.SYNOPSIS
    MEDIUM PRIORITY: Remote Services Hardening
    Remote Assistance, Remote Desktop, WinRM, Remote Shell
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Remote Services Hardening ===" -ForegroundColor Magenta

# --- Remote Assistance: Disable ---
Write-Host "  -- Remote Assistance --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "fAllowUnsolicited" -Value 0 `
    -Description "Configure Offer Remote Assistance: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "fAllowToGetHelp" -Value 0 `
    -Description "Configure Solicited Remote Assistance: Disabled"

# --- Remote Desktop Services ---
Write-Host "  -- Remote Desktop Services --" -ForegroundColor DarkCyan

# Credential Delegation
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" `
    -Name "AllowEncryptionOracle" -Value 0 `
    -Description "Encryption Oracle Remediation: Force Updated Clients"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation" `
    -Name "AllowProtectedCreds" -Value 1 `
    -Description "Remote host allows delegation of non-exportable credentials"

# RDP Client
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "AuthenticationLevel" -Value 1 `
    -Description "Server authentication for client: Do not connect if auth fails"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "DisablePasswordSaving" -Value 1 `
    -Description "Do not allow passwords to be saved"

# RDP Session Host - Security
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "fPromptForPassword" -Value 1 `
    -Description "Always prompt for password upon connection"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "fEncryptRPCTraffic" -Value 1 `
    -Description "Require secure RPC communication"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "SecurityLayer" -Value 2 `
    -Description "Security layer: SSL"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "UserAuthentication" -Value 1 `
    -Description "Require NLA for remote connections"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "MinEncryptionLevel" -Value 3 `
    -Description "Client connection encryption level: High"

# RDP Session Host - Device Redirection
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "fDisableClip" -Value 1 `
    -Description "Do not allow Clipboard redirection"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" `
    -Name "fDisableCdm" -Value 1 `
    -Description "Do not allow drive redirection"

# --- WinRM ---
Write-Host "  -- Windows Remote Management --" -ForegroundColor DarkCyan

# WinRM Client
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" `
    -Name "AllowBasic" -Value 0 `
    -Description "WinRM Client: Allow Basic auth: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" `
    -Name "AllowUnencryptedTraffic" -Value 0 `
    -Description "WinRM Client: Allow unencrypted traffic: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" `
    -Name "AllowDigest" -Value 0 `
    -Description "WinRM Client: Disallow Digest authentication"

# WinRM Service
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" `
    -Name "AllowBasic" -Value 0 `
    -Description "WinRM Service: Allow Basic auth: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" `
    -Name "AllowUnencryptedTraffic" -Value 0 `
    -Description "WinRM Service: Allow unencrypted traffic: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" `
    -Name "DisableRunAs" -Value 1 `
    -Description "WinRM Service: Disallow WinRM from storing RunAs credentials"

# --- Remote Shell ---
Write-Host "  -- Windows Remote Shell --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" `
    -Name "AllowRemoteShellAccess" -Value 0 `
    -Description "Allow Remote Shell Access: Disabled"
