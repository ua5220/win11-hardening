<#
.SYNOPSIS
    ASD Windows 11 Hardening - Rollback / Revert Script
    Reverts ALL hardening settings applied by Deploy-Hardening.ps1 back to Windows defaults.

.DESCRIPTION
    Undoes Group Policy (LGPO), registry, security policy, defender settings, network
    settings, service configurations and other changes applied by the full hardening suite.
    Must be run as Administrator. A reboot is required after completion.

.PARAMETER LogPath
    Path for log output. Default: C:\Logs\Hardening

.EXAMPLE
    .\Rollback-Hardening.ps1
    .\Rollback-Hardening.ps1 -LogPath C:\Temp\Rollback

.NOTES
    BitLocker drive encryption state is NOT changed - manage manually if needed.
    Windows Hello for Business may require AAD/domain reconfiguration.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$LogPath = "C:\Logs\Hardening"
)

#Requires -RunAsAdministrator
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ============================================================
# INITIALIZATION
# ============================================================
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
if (-not (Test-Path $LogPath)) { New-Item -Path $LogPath -ItemType Directory -Force | Out-Null }
$LogFile = Join-Path $LogPath "Rollback_${Timestamp}.log"
Start-Transcript -Path $LogFile -Append

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry -ForegroundColor $(switch ($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "OK"    { "Green" }
        default { "White" }
    })
}

function Remove-RegValue {
    param([string]$Path, [string]$Name)
    try {
        if (Test-Path $Path) {
            if (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $Path -Name $Name -Force -ErrorAction Stop
                Write-Log "Removed: $Path\$Name" "OK"
            }
        }
    } catch {
        Write-Log "Cannot remove $Path\$Name : $_" "WARN"
    }
}

function Set-RegValue {
    param([string]$Path, [string]$Name, $Value, [string]$Type = "DWORD")
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        Write-Log "Set: $Path\$Name = $Value" "OK"
    } catch {
        Write-Log "Cannot set $Path\$Name : $_" "WARN"
    }
}

function Remove-RegTree {
    param([string]$Path)
    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Log "Removed tree: $Path" "OK"
        }
    } catch {
        Write-Log "Cannot remove tree $Path : $_" "WARN"
    }
}

Write-Log "=========================================="
Write-Log "ASD Windows 11 Hardening - ROLLBACK"
Write-Log "Reverting all hardening settings to Windows defaults"
Write-Log "=========================================="

# ============================================================
# 1. RESET LOCAL GROUP POLICY (LGPO)
# ============================================================
Write-Log "--- [1/17] Resetting Local Group Policy ---"
try {
    $lgpoMachinePol = "$env:SystemRoot\System32\GroupPolicy\Machine\Registry.pol"
    $lgpoUserPol    = "$env:SystemRoot\System32\GroupPolicy\User\Registry.pol"
    if (Test-Path $lgpoMachinePol) { Remove-Item $lgpoMachinePol -Force; Write-Log "Removed Machine Registry.pol" "OK" }
    if (Test-Path $lgpoUserPol)    { Remove-Item $lgpoUserPol    -Force; Write-Log "Removed User Registry.pol" "OK" }
    & gpupdate /force /wait:0 2>&1 | Out-Null
    Write-Log "gpupdate /force executed" "OK"
} catch {
    Write-Log "GP reset error: $_" "WARN"
}

# ============================================================
# 2. RESET SECURITY POLICIES via secedit
# ============================================================
Write-Log "--- [2/17] Resetting Security Policies (secedit) ---"
try {
    $sdb = Join-Path $env:TEMP "deflt_rollback_$Timestamp.sdb"
    & secedit /configure /cfg "$env:SystemRoot\inf\defltbase.inf" /db "$sdb" /areas SECURITYPOLICY,GROUPMGMT,SERVICES,REGKEYS,FILESTORE,USER_RIGHTS /quiet 2>&1 | Out-Null
    Write-Log "secedit /configure completed" "OK"
} catch {
    Write-Log "secedit error: $_" "WARN"
}

# ============================================================
# 3. RESET AUDIT POLICY
# ============================================================
Write-Log "--- [3/17] Resetting Audit Policy ---"
try {
    & auditpol /clear /y 2>&1 | Out-Null
    Write-Log "Audit policy cleared" "OK"
} catch {
    Write-Log "auditpol error: $_" "WARN"
}

# ============================================================
# 4. DISABLE CREDENTIAL GUARD  (01-CredentialProtection)
# ============================================================
Write-Log "--- [4/17] Disabling Credential Guard & LSA PPL ---"
$devGuardPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
Remove-RegValue $devGuardPath "EnableVirtualizationBasedSecurity"
Remove-RegValue $devGuardPath "RequirePlatformSecurityFeatures"
Remove-RegValue $devGuardPath "HypervisorEnforcedCodeIntegrity"
Remove-RegValue $devGuardPath "Locked"

$cgScenarioPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard"
Remove-RegValue $cgScenarioPath "Enabled"
Remove-RegValue $cgScenarioPath "Locked"

$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Remove-RegValue $lsaPath "LsaCfgFlags"
Remove-RegValue $lsaPath "RunAsPPL"
Remove-RegValue $lsaPath "RunAsPPLBoot"

# ============================================================
# 5. DISABLE ASR RULES  (02-ASRRules)
# ============================================================
Write-Log "--- [5/17] Disabling Attack Surface Reduction Rules ---"
try {
    $asrIds = @(
        "56a863a9-875e-4185-98a7-b882c64b5ce5",
        "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c",
        "d4f940ab-401b-4efc-aadc-ad5f3c50688a",
        "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b3",
        "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550",
        "01443614-cd74-433a-b99e-2ecdc07bfc25",
        "5beb7efe-fd9a-4556-801d-275e5ffc04cc",
        "d3e037e1-3eb8-44c8-a917-57927947596d",
        "3b576869-a4ec-4529-8536-b80a7769e899",
        "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84",
        "26190899-1602-49e8-8b27-eb1d0a1ce869",
        "e6db77e5-3df2-4cf1-b95a-636979351e5b",
        "d1e49aac-8f56-4280-b9ba-993a6d77406c",
        "33ddedf1-c6e0-47cb-833e-de6133960387",
        "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4",
        "c0033c00-d16d-4114-a5a0-dc9b3a7d2ceb",
        "a8f5898e-1dc8-49a9-9878-85004b8a61e6",
        "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b",
        "c1db55ab-c21a-4637-bb3f-a12568109d35"
    )
    foreach ($id in $asrIds) {
        Add-MpPreference -AttackSurfaceReductionRules_Ids $id -AttackSurfaceReductionRules_Actions Disabled -ErrorAction SilentlyContinue
    }
    Write-Log "ASR rules set to Disabled" "OK"
} catch {
    Write-Log "ASR rules reset error: $_" "WARN"
}
Remove-RegTree "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"

# ============================================================
# 6. DISABLE CONTROLLED FOLDER ACCESS  (04-ControlledFolderAccess)
# ============================================================
Write-Log "--- [6/17] Disabling Controlled Folder Access ---"
try {
    Set-MpPreference -EnableControlledFolderAccess Disabled -ErrorAction SilentlyContinue
    Write-Log "Controlled Folder Access disabled" "OK"
} catch {
    Write-Log "CFA disable error: $_" "WARN"
}
Remove-RegTree "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"

# ============================================================
# 7. RESET UAC  (06-ElevatingPrivileges)
# ============================================================
Write-Log "--- [7/17] Resetting UAC to Windows defaults ---"
$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-RegValue $uacPath "ConsentPromptBehaviorAdmin"  5
Set-RegValue $uacPath "ConsentPromptBehaviorUser"   3
Set-RegValue $uacPath "EnableInstallerDetection"    1
Set-RegValue $uacPath "EnableLUA"                   1
Set-RegValue $uacPath "EnableVirtualization"        1
Set-RegValue $uacPath "PromptOnSecureDesktop"       1
Set-RegValue $uacPath "ValidateAdminCodeSignatures" 0
Remove-RegValue $uacPath "FilterAdministratorToken"
Remove-RegValue $uacPath "LocalAccountTokenFilterPolicy"

# ============================================================
# 8. RESET EARLY LAUNCH ANTIMALWARE  (07-ELAM)
# ============================================================
Write-Log "--- [8/17] Resetting ELAM ---"
Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy"

# ============================================================
# 9. RESET WINDOWS UPDATE POLICY  (10-OSPatching)
# ============================================================
Write-Log "--- [9/17] Resetting Windows Update policy ---"
Remove-RegTree "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

# ============================================================
# 10. RESET ACCOUNT LOCKOUT POLICY  (20-AccountLockout)
# ============================================================
Write-Log "--- [10/17] Resetting Account Lockout policy ---"
try {
    & net accounts /lockoutthreshold:0    2>&1 | Out-Null
    & net accounts /lockoutwindow:30     2>&1 | Out-Null
    & net accounts /lockoutduration:30  2>&1 | Out-Null
    Write-Log "Account lockout policy reset" "OK"
} catch {
    Write-Log "Account lockout reset error: $_" "WARN"
}

# ============================================================
# 11. RESET ANONYMOUS CONNECTIONS  (21-AnonymousConnections)
# ============================================================
Write-Log "--- [11/17] Resetting Anonymous Connections ---"
$lsaPath2 = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Remove-RegValue $lsaPath2 "RestrictAnonymous"
Remove-RegValue $lsaPath2 "RestrictAnonymousSAM"
Remove-RegValue $lsaPath2 "EveryoneIncludesAnonymous"
Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters" "RestrictNullSessAccess"

# ============================================================
# 12. RESET ANTIVIRUS / DEFENDER SETTINGS  (22-Antivirus)
# ============================================================
Write-Log "--- [12/17] Resetting Defender settings ---"
try {
    Set-MpPreference -DisableRealtimeMonitoring $false              -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $false             -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection $false                 -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $false                 -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting Advanced                       -ErrorAction SilentlyContinue
    Set-MpPreference -SubmitSamplesConsent SendSafeSamples         -ErrorAction SilentlyContinue
    Set-MpPreference -PUAProtection Disabled                       -ErrorAction SilentlyContinue
    Set-MpPreference -EnableNetworkProtection Disabled             -ErrorAction SilentlyContinue
    Write-Log "Defender preferences reset" "OK"
} catch {
    Write-Log "Defender reset error: $_" "WARN"
}
Remove-RegTree "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"

# ============================================================
# 13. RESET NETWORK SECURITY  (26-NetworkSecurity)
# ============================================================
Write-Log "--- [13/17] Resetting Network Security settings ---"

# SMB
try {
    Set-SmbServerConfiguration -EnableSMB1Protocol $true            -Force -Confirm:$false -ErrorAction SilentlyContinue
    Set-SmbServerConfiguration -RequireSecuritySignature $false     -Force -Confirm:$false -ErrorAction SilentlyContinue
    Set-SmbServerConfiguration -EnableSecuritySignature $true       -Force -Confirm:$false -ErrorAction SilentlyContinue
    Set-SmbServerConfiguration -EncryptData $false                  -Force -Confirm:$false -ErrorAction SilentlyContinue
    Write-Log "SMB settings reset" "OK"
} catch {
    Write-Log "SMB reset error: $_" "WARN"
}

# LM / NTLMv2
$lsaPath3 = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Remove-RegValue $lsaPath3 "LmCompatibilityLevel"
Remove-RegValue $lsaPath3 "NoLMHash"
Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinClientSec"
Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" "NTLMMinServerSec"

# WDigest
Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential"

# LLMNR / mDNS
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast"
Remove-RegValue "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" "EnableMDNS"

# Kernel DMA protection
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy"

# ============================================================
# 14. RE-ENABLE AUTOPLAY / AUTORUN  (25-AutoplayAutorun)
# ============================================================
Write-Log "--- [14/17] Re-enabling AutoPlay/AutoRun ---"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoAutoplayfornonVolume"
Remove-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun"
Remove-RegValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HonorAutorunSetting"
Set-RegValue    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoDriveTypeAutoRun" 0x91

# ============================================================
# 15. RESET REMOTE SERVICES  (29-RemoteServices)
# ============================================================
Write-Log "--- [15/17] Resetting Remote Services ---"
try {
    Set-Service -Name RemoteRegistry -StartupType Manual -ErrorAction SilentlyContinue
    Write-Log "RemoteRegistry set to Manual (default)" "OK"
} catch {}

Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fDenyTSConnections"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fSingleSessionPerUser"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "MinEncryptionLevel"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "UserAuthentication"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "AllowUnencryptedTraffic"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" "DisableRunAs"
Remove-RegTree  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM"

# ============================================================
# 16. RESET POWERSHELL POLICY  (31-PowerShell)
# ============================================================
Write-Log "--- [16/17] Resetting PowerShell Execution Policy ---"
try {
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue
    Write-Log "Execution policy set to RemoteSigned (default)" "OK"
} catch {
    Write-Log "PS ExecutionPolicy reset error: $_" "WARN"
}
Remove-RegTree "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"

# ============================================================
# 17. RESET SESSION LOCKING / SCREENSAVER  (33-SessionLocking)
# ============================================================
Write-Log "--- [17/17] Resetting Session Locking ---"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaverIsSecure"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveTimeOut"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveActive"
Remove-RegValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "SCRNSAVE.EXE"
Remove-RegTree  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"

# ============================================================
# CLEAN UP REMAINING POLICY REGISTRY TREES
# ============================================================
Write-Log "--- Cleaning up remaining policy registry trees ---"
@(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Safer",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AttachmentManager",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc"
) | ForEach-Object { Remove-RegTree $_ }

# ============================================================
# FINAL REPORT
# ============================================================
Write-Log "=========================================="
Write-Log "ROLLBACK COMPLETED."
Write-Log "Log file: $LogFile"
Write-Log "IMPORTANT: A REBOOT IS REQUIRED for all changes to take effect."
Write-Log "NOTE: BitLocker encryption state was NOT changed - manage manually."
Write-Log "NOTE: WHfB / MFA settings may require AAD/domain reconfiguration."
Write-Log "NOTE: Run 'gpupdate /force' after reboot to confirm GP state."
Write-Log "=========================================="

Stop-Transcript
