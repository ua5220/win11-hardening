<#
.SYNOPSIS
    MEDIUM PRIORITY: Drive Encryption (BitLocker) Configuration
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== BitLocker Drive Encryption ===" -ForegroundColor Magenta

$blBase = "HKLM:\SOFTWARE\Policies\Microsoft\FVE"

# Encryption method
Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "EncryptionMethodWithXtsOs" -Value 4 `
    -Description "OS drive encryption: XTS-AES 128-bit"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "EncryptionMethodWithXtsFdv" -Value 4 `
    -Description "Fixed data drive encryption: XTS-AES 128-bit"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "EncryptionMethodWithXtsRdv" -Value 4 `
    -Description "Removable data drive encryption: XTS-AES 128-bit"

# Disable new DMA devices when locked
Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "DisableExternalDMAUnderLock" -Value 1 `
    -Description "Disable new DMA devices when computer is locked"

# Prevent memory overwrite on restart
Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "MorBehavior" -Value 0 `
    -Description "Prevent memory overwrite on restart: Disabled (allow overwrite)"

# --- OS Drive settings ---
Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "OSRecovery" -Value 1 `
    -Description "OS Drive: Enable recovery"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "OSActiveDirectoryBackup" -Value 1 `
    -Description "OS Drive: Backup to AD DS"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "OSRequireActiveDirectoryBackup" -Value 1 `
    -Description "OS Drive: Do not enable BitLocker until recovery info stored to AD"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "OSEncryptionType" -Value 1 `
    -Description "OS Drive: Full encryption"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "OSMinimumPIN" -Value 15 `
    -Description "OS Drive: Minimum PIN length 15"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "UseEnhancedPin" -Value 1 `
    -Description "OS Drive: Allow enhanced PINs"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "OSAllowSecureBootForIntegrity" -Value 1 `
    -Description "OS Drive: Allow Secure Boot for integrity validation"

# --- Fixed Data Drive settings ---
Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "FDVRecovery" -Value 1 `
    -Description "Fixed Drive: Enable recovery"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "FDVActiveDirectoryBackup" -Value 1 `
    -Description "Fixed Drive: Backup to AD DS"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "FDVRequireActiveDirectoryBackup" -Value 1 `
    -Description "Fixed Drive: Require AD backup before enabling"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "FDVEncryptionType" -Value 1 `
    -Description "Fixed Drive: Full encryption"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "FDVDenyWriteAccess" -Value 1 `
    -Description "Fixed Drive: Deny write access if not protected"

# --- Removable Data Drive settings ---
Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "RDVRecovery" -Value 1 `
    -Description "Removable Drive: Enable recovery"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $blBase `
    -Name "RDVEncryptionType" -Value 1 `
    -Description "Removable Drive: Full encryption"

# Machine account lockout
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "MaxDevicePasswordFailedAttempts" -Value 10 `
    -Description "Interactive logon: Machine account lockout threshold: 10"
