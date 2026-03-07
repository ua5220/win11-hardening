<#
.SYNOPSIS
    HIGH PRIORITY: Credential Protection
    Configures credential caching, WDigest, Credential Guard, LSASS protection
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Credential Protection ===" -ForegroundColor Magenta

# --- Cached credentials: limit to 1 previous logon ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
    -Name "CachedLogonsCount" -Value "1" -Type String `
    -Description "Interactive logon: Number of previous logons to cache"

# --- Do not allow storage of passwords for network auth ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "DisableDomainCreds" -Value 1 `
    -Description "Do not allow storage of passwords for network authentication"

# --- Disable WDigest Authentication ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" `
    -Name "UseLogonCredential" -Value 0 `
    -Description "WDigest Authentication disabled"

# --- Virtualization Based Security (Credential Guard) ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "EnableVirtualizationBasedSecurity" -Value 1 `
    -Description "Turn On Virtualization Based Security"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "RequirePlatformSecurityFeatures" -Value 3 `
    -Description "Platform Security Level: Secure Boot and DMA Protection"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "HypervisorEnforcedCodeIntegrity" -Value 1 `
    -Description "VBS Protection of Code Integrity: Enabled with UEFI lock"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "HVCIMATRequired" -Value 1 `
    -Description "Require UEFI Memory Attributes Table"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "LsaCfgFlags" -Value 1 `
    -Description "Credential Guard: Enabled with UEFI lock"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "ConfigureSystemGuardLaunch" -Value 1 `
    -Description "Secure Launch Configuration: Enabled"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" `
    -Name "ConfigureKernelShadowStacksLaunch" -Value 1 `
    -Description "Kernel-mode Hardware-enforced Stack Protection: Enforcement mode"

# --- LSASS Protection ---
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "AllowCustomSSPsAPs" -Value 0 `
    -Description "Disallow Custom SSPs and APs loaded into LSASS"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "RunAsPPL" -Value 1 `
    -Description "Configure LSASS to run as a protected process (UEFI Lock)"
