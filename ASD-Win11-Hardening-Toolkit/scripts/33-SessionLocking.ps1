<#
.SYNOPSIS
    MEDIUM PRIORITY: Session Locking (15 min inactivity timeout)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Session Locking ===" -ForegroundColor Magenta

# Machine inactivity limit: 900 seconds (15 minutes)
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "InactivityTimeoutSecs" -Value 900 `
    -Description "Interactive logon: Machine inactivity limit: 900 seconds"

# Lock screen restrictions
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
    -Name "NoLockScreenCamera" -Value 1 `
    -Description "Prevent enabling lock screen camera"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
    -Name "NoLockScreenSlideshow" -Value 1 `
    -Description "Prevent enabling lock screen slide show"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DisableLockScreenAppNotifications" -Value 1 `
    -Description "Turn off app notifications on the lock screen"

# Voice activation while locked
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" `
    -Name "LetAppsActivateWithVoiceAboveLock" -Value 2 `
    -Description "Voice activation while locked: Force Deny"

# Windows Ink Workspace
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" `
    -Name "AllowWindowsInkWorkspace" -Value 1 `
    -Description "Windows Ink Workspace: On, but disallow access above lock"

# Screen saver (user-level settings applied as machine defaults)
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -Name "ScreenSaveActive" -Value "1" -Type String `
    -Description "Enable screen saver"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -Name "ScreenSaverIsSecure" -Value "1" -Type String `
    -Description "Password protect the screen saver"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" `
    -Name "ScreenSaveTimeOut" -Value "900" -Type String `
    -Description "Screen saver timeout: 900 seconds"
