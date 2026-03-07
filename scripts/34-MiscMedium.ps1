<#
.SYNOPSIS
    MEDIUM PRIORITY: Miscellaneous Medium Priority Settings
    Command Prompt, Registry editing, Legacy/Run once lists, File sharing,
    Group Policy processing, Installing applications, Safe Mode
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Miscellaneous Medium Priority ===" -ForegroundColor Magenta

# --- Command Prompt ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DisableCMD" -Value 0 `
    -Description "Prevent access to command prompt (and script processing)"

# --- Registry editing tools ---
# NOTE: This applies to the CURRENT user (HKCU). When running as admin,
# this will prevent the admin from using regedit/reg.exe in this session.
# In domain environments, deploy this via GPO targeting standard users only.
# Set to 0 temporarily if you need to re-run scripts that use reg.exe.
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "DisableRegistryTools" -Value 0 `
    -Description "Prevent access to registry editing tools (silent mode too)"

# --- Legacy and run once lists ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "DisableLocalMachineRun" -Value 1 `
    -Description "Do not process the legacy run list"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "DisableLocalMachineRunOnce" -Value 1 `
    -Description "Do not process the run once list"

# --- File and print sharing ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\NetworkSharing" `
    -Name "NoInplaceSharing" -Value 1 `
    -Description "Prevent users from sharing files within their profile"

# --- Installing applications ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "EnableUserControl" -Value 0 `
    -Description "Allow user control over installs: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" -Value 0 `
    -Description "Always install with elevated privileges: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer" `
    -Name "AlwaysInstallElevated" -Value 0 `
    -Description "User: Always install with elevated privileges: Disabled"

# SmartScreen
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "EnableSmartScreen" -Value 0 `
    -Description "Configure Windows Defender SmartScreen: Enabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "ShellSmartScreenLevel" -Value "Allow" -Type String `
    -Description "SmartScreen: Warn and prevent bypass"

# --- Safe Mode ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "SafeModeBlockNonAdmins" -Value 1 `
    -Description "Block non-admins from using Safe Mode"

# --- Group Policy processing ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" `
    -Name "NoBackgroundPolicy" -Value 0 `
    -Description "Registry policy processing: Apply during periodic background"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}" `
    -Name "NoGPOListChanges" -Value 0 `
    -Description "Registry policy processing: Process even if unchanged"

# --- CD Burner ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoCDBurning" -Value 1 `
    -Description "Remove CD Burning features"

# --- Location services ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
    -Name "DisableLocation" -Value 1 `
    -Description "Turn off location"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" `
    -Name "DisableLocationScripting" -Value 1 `
    -Description "Turn off location scripting"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors\WindowsLocationProvider" `
    -Name "DisableWindowsLocationProvider" -Value 1 `
    -Description "Turn off Windows Location Provider"
