<#
.SYNOPSIS
    MEDIUM PRIORITY: Security Policies, System Cryptography, Password Policy
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Security Policies ===" -ForegroundColor Magenta

# DNS - Disable multicast name resolution (LLMNR)
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" `
    -Name "EnableMulticast" -Value 0 `
    -Description "Turn off multicast name resolution (LLMNR)"

# WLAN - Disable auto-connect to open hotspots
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" `
    -Name "AutoConnectAllowedOEM" -Value 0 `
    -Description "Disable auto-connect to suggested open hotspots"

# Disable consumer experiences
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableWindowsConsumerFeatures" -Value 1 `
    -Description "Turn off Microsoft consumer experiences"

# File Explorer security
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "NoHeapTerminationOnCorruption" -Value 0 `
    -Description "Turn off heap termination on corruption: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "PreXPSP2ShellProtocolBehavior" -Value 0 `
    -Description "Turn off shell protocol protected mode: Disabled"

# Prevent RSS enclosure downloads
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds" `
    -Name "DisableEnclosureDownload" -Value 1 `
    -Description "Prevent downloading of enclosures"

# Disable indexing of encrypted files
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name "AllowIndexingEncryptedStoresOrItems" -Value 0 `
    -Description "Allow indexing of encrypted files: Disabled"

# Disable Game Recording
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" `
    -Name "AllowGameDVR" -Value 0 `
    -Description "Windows Game Recording and Broadcasting: Disabled"

# Domain member settings
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "DisablePasswordChange" -Value 0 `
    -Description "Disable machine account password changes: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "MaximumPasswordAge" -Value 30 `
    -Description "Maximum machine account password age: 30 days"

# LDAP client signing
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Services\ldap" `
    -Name "LDAPClientIntegrity" -Value 1 `
    -Description "LDAP client signing requirements: Negotiate signing"

# Strengthen default permissions
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" `
    -Name "ProtectionMode" -Value 1 `
    -Description "Strengthen default permissions of internal system objects"

# --- System Cryptography ---
Write-Host "  -- System Cryptography --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography" `
    -Name "ForceKeyProtection" -Value 2 `
    -Description "Force strong key protection: Password required each use"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" `
    -Name "Enabled" -Value 1 `
    -Description "Use FIPS compliant algorithms"

# --- Password Policy ---
Write-Host "  -- Password Policy --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "BlockDomainPicturePassword" -Value 1 `
    -Description "Turn off picture password sign-in"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "AllowDomainPINLogon" -Value 0 `
    -Description "Turn on convenience PIN sign-in: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "LimitBlankPasswordUse" -Value 1 `
    -Description "Limit local account use of blank passwords to console logon only"

# Apply password policy via net accounts
if (-not $AuditOnly) {
    net accounts /minpwlen:15 2>$null
    net accounts /maxpwage:unlimited 2>$null
    Write-Host "  [SET] Min password length: 15, Max age: unlimited" -ForegroundColor Cyan
}

# --- Widgets / OS functionality ---
Write-Host "  -- OS Functionality --" -ForegroundColor DarkCyan

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Widgets" `
    -Name "DisableWidgetsOnLockScreen" -Value 1 `
    -Description "Disable Widgets On Lock Screen"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Widgets" `
    -Name "DisableWidgetsBoard" -Value 1 `
    -Description "Disable Widgets Board"

# Windows Search - no web results
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" `
    -Name "DisableWebSearch" -Value 1 `
    -Description "Don't search the web or display web results in Search"

# Microsoft accounts
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppRuntime" `
    -Name "AllowMicrosoftAccountsToBeOptional" -Value 1 `
    -Description "Allow Microsoft accounts to be optional"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount" `
    -Name "DisableUserAuth" -Value 1 `
    -Description "Block all consumer Microsoft account user authentication"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" `
    -Name "DisableFileSyncNGSC" -Value 1 `
    -Description "Prevent the usage of OneDrive for file storage"

# Telemetry
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name "AllowTelemetry" -Value 0 `
    -Description "Allow Diagnostic Data: Off"

# Inventory Collector
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" `
    -Name "DisableInventory" -Value 1 `
    -Description "Turn off Inventory Collector"

# Sound Recorder
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\SoundRecorder" `
    -Name "Soundrec" -Value 0 `
    -Description "Do not allow Sound Recorder to run"

# Microsoft Store
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" `
    -Name "RemoveWindowsStore" -Value 1 `
    -Description "Turn off the Store application"

# Guest account
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "EnableGuestAccount" -Value 0 `
    -Description "Accounts: Guest account status: Disabled"

# Print drivers
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers" `
    -Name "RestrictDriverInstallationToAdministrators" -Value 1 `
    -Description "Limits printer driver installation to Administrators"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DisableHTTPPrinting" -Value 1 `
    -Description "Turn off downloading of print drivers over HTTP"
