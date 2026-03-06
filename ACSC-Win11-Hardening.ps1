<#
.SYNOPSIS
    ACSC Windows 11 Workstation Hardening
    Source: Australian Cyber Security Centre
    https://www.cyber.gov.au/resources-business-and-government/essential-cyber-security/
            ism/cyber-security-guidelines/guidelines-system-hardening

.NOTES
    Requires: PowerShell 5.1+, Administrator rights
    Run:      Right-click -> Run with PowerShell  OR  .\Run-ACSC.bat

    Sections follow the ACSC guide priority order:
      [H] High    [M] Medium    [L] Low
#>

# ── Self-bypass: якщо запущено напряму (не через bat), перезапустити з Bypass + Admin ──
if ($MyInvocation.ScriptName -ne '' -and
    [System.Management.Automation.ExecutionPolicy]::Bypass -ne
    (Get-ExecutionPolicy -Scope Process)) {
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

$LogFile = "$env:TEMP\ACSC_Hardening_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

function Write-Log {
    param([string]$Msg, [string]$Level = 'INFO')
    $ts   = Get-Date -Format 'HH:mm:ss'
    $icon = @{ INFO='[i]'; OK='[+]'; WARN='[!]'; ERROR='[x]'; HEAD='[=]' }
    $clr  = switch ($Level) {
        'OK'    { 'Green'   }
        'WARN'  { 'Yellow'  }
        'ERROR' { 'Red'     }
        'HEAD'  { 'Cyan'    }
        default { 'White'   }
    }
    $line = "[$ts] [$Level] $Msg"
    Write-Host $line -ForegroundColor $clr
    Add-Content -LiteralPath $LogFile -Value $line -Encoding UTF8
}

function Set-Reg {
    param([string]$Path, [string]$Name, $Value, [string]$Type = 'DWord')
    try {
        if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        Write-Log "REG  $Path\$Name = $Value" 'OK'
    } catch { Write-Log "FAIL $Path\$Name : $_" 'ERROR' }
}

function Disable-Svc {
    param([string]$Name)
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service  $Name -Force -ErrorAction SilentlyContinue
        Set-Service   $Name -StartupType Disabled
        Write-Log "SVC  Disabled: $Name" 'OK'
    } else { Write-Log "SVC  Not found: $Name" 'WARN' }
}

function Set-AuditPolicy {
    param([string]$Category, [string]$SubCategory, [string]$Flags)
    # Flags: Success, Failure, "Success,Failure", NoAuditing
    $auditFlags = switch ($Flags) {
        'Success'          { '/success:enable  /failure:disable' }
        'Failure'          { '/success:disable /failure:enable'  }
        'Success,Failure'  { '/success:enable  /failure:enable'  }
        default            { '/success:disable /failure:disable' }
    }
    $cmd = "auditpol /set /subcategory:`"$SubCategory`" $auditFlags"
    try {
        Invoke-Expression $cmd | Out-Null
        Write-Log "AUDIT $SubCategory => $Flags" 'OK'
    } catch { Write-Log "AUDIT FAIL $SubCategory : $_" 'ERROR' }
}

function Disable-Task {
    param([string]$TaskPath, [string]$TaskName)
    Get-ScheduledTask -TaskPath $TaskPath -TaskName $TaskName -ErrorAction SilentlyContinue |
        Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
}

# ============================================================================
Write-Log "========== ACSC Windows 11 Hardening ==========" 'HEAD'
Write-Log "Log: $LogFile" 'INFO'
# ============================================================================


# ════════════════════════════════════════════════════════════════════════════
# [H] ATTACK SURFACE REDUCTION (ASR) RULES
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Attack Surface Reduction Rules ---" 'HEAD'

$asrPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
$asrRulesPath = "$asrPath\Rules"

Set-Reg $asrPath "ExploitGuard_ASR_Rules" 1

$asrRules = @(
    "56a863a9-875e-4185-98a7-b882c64b5ce5",   # Block abuse of exploited vulnerable signed drivers
    "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c",   # Block Adobe Reader from creating child processes
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a",   # Block all Office apps from creating child processes
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2",   # Block credential stealing from lsass.exe
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550",   # Block executable content from email/webmail
    "01443614-cd74-433a-b99e-2ecdc07bfc25",   # Block executables unless prevalence/age/trusted
    "5beb7efe-fd9a-4556-801d-275e5ffc04cc",   # Block execution of potentially obfuscated scripts
    "d3e037e1-3eb8-44c8-a917-57927947596d",   # Block JS/VBScript from launching downloaded exec
    "3b576869-a4ec-4529-8536-b80a7769e899",   # Block Office apps from creating executable content
    "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84",   # Block Office apps from injecting code into other procs
    "26190899-1602-49e8-8b27-eb1d0a1ce869",   # Block Office comm app from creating child processes
    "e6db77e5-3df2-4cf1-b95a-636979351e5b",   # Block persistence through WMI event subscription
    "d1e49aac-8f56-4280-b9ba-993a6d77406c",   # Block process creations from PSExec and WMI
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4",   # Block untrusted/unsigned processes from USB
    "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b",   # Block Win32 API calls from Office macros
    "c1db55ab-c21a-4637-bb3f-a12568109d35"    # Use advanced protection against ransomware
)

foreach ($rule in $asrRules) {
    Set-Reg $asrRulesPath $rule "1" 'String'
}


# ════════════════════════════════════════════════════════════════════════════
# [H] CREDENTIAL PROTECTION
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Credential Protection ---" 'HEAD'

# Limit cached credentials to 1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" "CachedLogonsCount" "1" 'String'

# Disable network password storage
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableDomainCreds" 1

# Disable WDigest (prevents plaintext password in LSASS)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" "UseLogonCredential" 0

# Credential Guard / VBS
$vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
Set-Reg $vbsPath "EnableVirtualizationBasedSecurity"   1
Set-Reg $vbsPath "RequirePlatformSecurityFeatures"     3   # Secure Boot + DMA
Set-Reg $vbsPath "HypervisorEnforcedCodeIntegrity"    1

$cgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-Reg $cgPath "LsaCfgFlags"   1   # Credential Guard enabled with UEFI lock

# LSASS as protected process
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "RunAsPPL"             1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "DisableCustomSSPs"    1

# Memory integrity (HVCI)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" "Enabled" 1


# ════════════════════════════════════════════════════════════════════════════
# [H] CONTROLLED FOLDER ACCESS (Anti-Ransomware)
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Controlled Folder Access ---" 'HEAD'

$cfaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"
Set-Reg $cfaPath "EnableControlledFolderAccess" 1


# ════════════════════════════════════════════════════════════════════════════
# [H] CREDENTIAL ENTRY (Secure Desktop / UAC)
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Credential Entry & UAC ---" 'HEAD'

$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

# ACSC: Admins must enter credentials on Secure Desktop (level 1, not 5)
Set-Reg $uacPath "EnableLUA"                         1
Set-Reg $uacPath "ConsentPromptBehaviorAdmin"        5   # Prompt without password (no secure desktop)
Set-Reg $uacPath "ConsentPromptBehaviorUser"         0   # Auto-deny elevation for standard users
Set-Reg $uacPath "PromptOnSecureDesktop"             1   # Use Secure Desktop
Set-Reg $uacPath "EnableInstallerDetection"          1
Set-Reg $uacPath "FilterAdministratorToken"          1   # Admin Approval Mode for built-in admin
Set-Reg $uacPath "EnableUIADesktopToggle"            0   # Only elevate UIAccess from secure locations
Set-Reg $uacPath "VirtualizeLastAccess"              1   # Virtualize file/registry write failures

# Credential UI
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "DisablePasswordReveal"    1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "EnumerateAdministrators"  0

# Do NOT require Ctrl+Alt+Del (ACSC says: Interactive logon: Do not require = Disabled means we DO require it)
# ACSC: "Interactive logon: Do not require CTRL+ALT+DEL" = Disabled → means CAD IS required
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableCAD" 0

# Don't display network selection UI
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontDisplayNetworkSelectionUI" 1

# Don't enumerate local users on domain-joined computers
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DontEnumerateConnectedUsers" 1

# Require trusted path for credential entry
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" "RequireTrustedPath" 1

# Logon options
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "EnableSmartScreen" 1

# Sign-in and lock automatically after restart: Disabled
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableAutomaticRestartSignOn" 1


# ════════════════════════════════════════════════════════════════════════════
# [H] EARLY LAUNCH ANTIMALWARE
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Early Launch Antimalware ---" 'HEAD'

# Boot-Start Driver Initialization Policy: Good, unknown and bad but critical (3)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch" "DriverLoadPolicy" 3


# ════════════════════════════════════════════════════════════════════════════
# [H] EXPLOIT PROTECTION (DEP / ASLR / SEHOP / CFG)
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Exploit Protection ---" 'HEAD'

$epPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
Set-Reg $epPath "MitigationOptions" "100" 'String'   # Heap termination on corruption

# Force SEHOP system-wide
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "DisableExceptionChainValidation" 0

# DEP for Explorer (do not disable)
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "NoDataExecutionPrevention" 0

# Mandatory ASLR / Bottom-up ASLR (ProcessMitigations)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "MoveImages" 0xFFFFFFFF

# Prevent users from modifying exploit protection settings
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" "DisallowExploitProtectionOverride" 1


# ════════════════════════════════════════════════════════════════════════════
# [H] WINDOWS UPDATE — Auto-patching
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [H] Windows Update ---" 'HEAD'

$wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
Set-Reg $wuPath "NoAutoUpdate"             0
Set-Reg $wuPath "AUOptions"               4   # Auto download and schedule install
Set-Reg $wuPath "ScheduledInstallDay"     0   # Every day
Set-Reg $wuPath "ScheduledInstallTime"    3   # 3am

$wuPath2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
Set-Reg $wuPath2 "SetDisablePauseUXAccess"   1   # Remove "Pause Updates" access


# ════════════════════════════════════════════════════════════════════════════
# [M] ACCOUNT LOCKOUT POLICY
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Account Lockout Policy ---" 'HEAD'

net accounts /lockoutthreshold:5    2>$null | Out-Null
net accounts /lockoutduration:0     2>$null | Out-Null   # 0 = until admin unlocks
net accounts /lockoutwindow:15      2>$null | Out-Null
Write-Log "Account lockout: threshold=5, window=15min, duration=0" 'OK'


# ════════════════════════════════════════════════════════════════════════════
# [M] ANONYMOUS CONNECTIONS
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Anonymous Connections ---" 'HEAD'

$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-Reg $lsaPath "RestrictAnonymous"         2   # No anonymous enum of SAM + shares
Set-Reg $lsaPath "RestrictAnonymousSAM"      1
Set-Reg $lsaPath "EveryoneIncludesAnonymous" 0
Set-Reg $lsaPath "NoLMHash"                  1   # NoLMHash policy
Set-Reg $lsaPath "MSV1_0 NtlmMinClientSec"  537395200  # NTLMv2 + 128-bit
Set-Reg $lsaPath "MSV1_0 NtlmMinServerSec"  537395200

# Network access
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" "RestrictNullSessAccess" 1

# Enable insecure guest logons: Disabled
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation" "AllowInsecureGuestAuth" 0


# ════════════════════════════════════════════════════════════════════════════
# [M] ANTIVIRUS / DEFENDER — Optimal configuration
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Defender Antivirus ---" 'HEAD'

$dvPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
Set-Reg $dvPath "DisableAntiSpyware"          0
Set-Reg $dvPath "DisableRoutinelyTakingAction" 0
Set-Reg $dvPath "PUAProtection"               1   # Block PUAs

$rtPath = "$dvPath\Real-Time Protection"
Set-Reg $rtPath "DisableRealtimeMonitoring"   0
Set-Reg $rtPath "DisableBehaviorMonitoring"   0
Set-Reg $rtPath "DisableOnAccessProtection"   0
Set-Reg $rtPath "DisableScanOnRealtimeEnable" 0
Set-Reg $rtPath "DisableScriptScanning"       0

$scanPath = "$dvPath\Scan"
Set-Reg $scanPath "DisableArchiveScanning"        0
Set-Reg $scanPath "DisablePackedExeScanning"      0
Set-Reg $scanPath "DisableRemovableDriveScanning" 0
Set-Reg $scanPath "DisableEmailScanning"          0
Set-Reg $scanPath "DisableHeuristics"             0
Set-Reg $scanPath "DisableCatchupFullScan"        0
Set-Reg $scanPath "CheckForSignaturesBeforeRunningScan" 1
Set-Reg $scanPath "DisableScanOnRealtimeEnable"   0

$mapsPath = "$dvPath\Spynet"
Set-Reg $mapsPath "SpynetReporting"         2   # Advanced MAPS
Set-Reg $mapsPath "SubmitSamplesConsent"    3   # Send all samples
Set-Reg $mapsPath "DisableBlockAtFirstSeen" 0

$cloudPath = "$dvPath\MpEngine"
Set-Reg $cloudPath "MpCloudBlockLevel"         2   # High blocking level
Set-Reg $cloudPath "MpBafsExtendedTimeout"     50  # Extended cloud check: 50s
Set-Reg $cloudPath "EnableFileHashComputation"  1


# ════════════════════════════════════════════════════════════════════════════
# [M] ATTACHMENT MANAGER — Preserve zone information
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Attachment Manager ---" 'HEAD'

$amPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Attachments"
Set-Reg $amPath "SaveZoneInformation"    2   # Disabled = preserve zone info
Set-Reg $amPath "HideZoneInfoOnProperties" 1  # Hide "Unblock" button


# ════════════════════════════════════════════════════════════════════════════
# [M] AUDIT EVENT MANAGEMENT
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Audit Policies ---" 'HEAD'

# Force audit policy subcategory settings
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "SCENoApplyLegacyAuditPolicy" 1

# Event log sizes
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" "MaxSize" 65536
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security"    "MaxSize" 2097152
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System"      "MaxSize" 65536

# Include command line in process creation events
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" "ProcessCreationIncludeCmdLine_Enabled" 1

# CLFS log file authentication
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\CLFS" "ClfsLogAuthenticationEnabled" 1

# Audit subcategories
$auditPolicies = @(
    @{ Sub='Computer Account Management';     Flag='Success,Failure' },
    @{ Sub='Other Account Management Events'; Flag='Success,Failure' },
    @{ Sub='Security Group Management';       Flag='Success,Failure' },
    @{ Sub='User Account Management';         Flag='Success,Failure' },
    @{ Sub='Process Creation';                Flag='Success' },
    @{ Sub='Process Termination';             Flag='Success' },
    @{ Sub='Account Lockout';                 Flag='Failure' },
    @{ Sub='Group Membership';                Flag='Success' },
    @{ Sub='Logoff';                          Flag='Success' },
    @{ Sub='Logon';                           Flag='Success,Failure' },
    @{ Sub='Other Logon/Logoff Events';       Flag='Success,Failure' },
    @{ Sub='Special Logon';                   Flag='Success,Failure' },
    @{ Sub='File Share';                      Flag='Success,Failure' },
    @{ Sub='File System';                     Flag='Success,Failure' },
    @{ Sub='Kernel Object';                   Flag='Success,Failure' },
    @{ Sub='Other Object Access Events';      Flag='Success,Failure' },
    @{ Sub='Registry';                        Flag='Success,Failure' },
    @{ Sub='Audit Policy Change';             Flag='Success,Failure' },
    @{ Sub='Other Policy Change Events';      Flag='Success,Failure' },
    @{ Sub='System Integrity';                Flag='Success,Failure' }
)

foreach ($ap in $auditPolicies) {
    Set-AuditPolicy -SubCategory $ap.Sub -Flags $ap.Flag
}


# ════════════════════════════════════════════════════════════════════════════
# [M] AUTOPLAY / AUTORUN
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] AutoPlay / AutoRun ---" 'HEAD'

$apPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
Set-Reg $apPath "NoAutoplayfornonVolume" 1

$apPath2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-Reg $apPath2 "NoDriveTypeAutoRun"   0xFF  # Disable on all drives
Set-Reg $apPath2 "NoAutorun"            1


# ════════════════════════════════════════════════════════════════════════════
# [M] BRIDGING NETWORKS
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Network Bridging ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Network Connections" "NC_AllowNetBridge_NLA"    0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"  "fBlockNonDomain"          1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy"  "fMinimizeConnections"     3  # Prevent WiFi when on Ethernet


# ════════════════════════════════════════════════════════════════════════════
# [M] BUILT-IN GUEST ACCOUNT
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Guest Account ---" 'HEAD'

net user Guest /active:no 2>$null | Out-Null
Write-Log "Guest account disabled" 'OK'


# ════════════════════════════════════════════════════════════════════════════
# [M] CD BURNER ACCESS
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] CD Burner ---" 'HEAD'

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoCDBurning" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] COMMAND PROMPT
# Note: This is a USER policy. Applying to HKCU of current admin session.
# In domain environments, deploy via GPO targeting standard users only.
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Command Prompt ---" 'HEAD'

Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DisableCMD" -Force -ErrorAction SilentlyContinue
Write-Log "CMD enabled (DisableCMD removed)" 'OK'


# ════════════════════════════════════════════════════════════════════════════
# [M] DIRECT MEMORY ACCESS (DMA) PROTECTION
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] DMA Protection ---" 'HEAD'

# Kernel DMA Protection: Block All external devices incompatible with DMA protection
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Kernel DMA Protection" "DeviceEnumerationPolicy" 0  # Block All

# Disable SBP-2 (FireWire DMA)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\SBP2" "Start" 4

# Block Thunderbolt DMA devices during lock
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\FVE" "DisableExternalDMAUnderLock" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] ENDPOINT DEVICE CONTROL — Removable Storage
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Removable Storage ---" 'HEAD'

$rsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"
# Allow read, deny execute+write for common classes
$classes = @{
    "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" = "Removable Disk"
    "{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}" = "CD/DVD"
    "{53f56308-b6bf-11d0-94f2-00a0c91efb8b}" = "Tape Drive"
    "WPD"                                     = "WPD Devices"
}
foreach ($cls in $classes.Keys) {
    $p = "$rsPath\$cls"
    Set-Reg $p "Deny_Execute" 1
    Set-Reg $p "Deny_Write"   1
    Set-Reg $p "Deny_Read"    0  # Allow read
}


# ════════════════════════════════════════════════════════════════════════════
# [M] FILE AND PRINT SHARING
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] File Sharing ---" 'HEAD'

Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\NetworkSharing" "NoInplaceSharing" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] GROUP POLICY PROCESSING — Hardened UNC paths
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Group Policy Processing ---" 'HEAD'

$uncPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths"
Set-Reg $uncPath "\\*\SYSVOL"   "RequireMutualAuthentication=1, RequireIntegrity=1" 'String'
Set-Reg $uncPath "\\*\NETLOGON" "RequireMutualAuthentication=1, RequireIntegrity=1" 'String'

# Process registry policy even if unchanged
$gpPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}"
Set-Reg $gpPath "NoBackgroundPolicy" 0
Set-Reg $gpPath "NoGPOListChanges"   0


# ════════════════════════════════════════════════════════════════════════════
# [M] INSTALLING APPLICATIONS — SmartScreen + no elevated install
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Application Installation ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"         "EnableUserControl"          0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"         "AlwaysInstallElevated"      0
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer"         "AlwaysInstallElevated"      0

# SmartScreen for Explorer — Warn and prevent bypass
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"            "EnableSmartScreen"          1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"            "ShellSmartScreenLevel"      "Block" 'String'
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen\Explorer" "ConfigureAppInstallControl"   "Anywhere" 'String'


# ════════════════════════════════════════════════════════════════════════════
# [M] LEGACY AND RUN ONCE LISTS
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Legacy Run Lists ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableLocalMachineRun"     1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableLocalMachineRunOnce" 1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableCurrentUserRun"      1
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableCurrentUserRunOnce"  1


# ════════════════════════════════════════════════════════════════════════════
# [M] MICROSOFT ACCOUNTS / ONEDRIVE
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Microsoft Accounts / OneDrive ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"                       "NoConnectedUser"    3
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftAccount"                      "DisableUserAuth"    1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"                      "DisableFileSyncNGSC" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"                      "DisableFileSync"    1


# ════════════════════════════════════════════════════════════════════════════
# [M] MSS LEGACY SETTINGS — IP source routing, ICMP redirect
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] MSS Legacy Settings ---" 'HEAD'

$tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-Reg $tcpPath "DisableIPSourceRouting"    2   # Highest protection
Set-Reg $tcpPath "EnableICMPRedirect"        0   # Disable ICMP redirects

$tcp6Path = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
Set-Reg $tcp6Path "DisableIPSourceRouting"   2


# ════════════════════════════════════════════════════════════════════════════
# [M] NETBIOS OVER TCP/IP — Disable on all adapters
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] NetBIOS over TCP/IP ---" 'HEAD'

$adapters = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces" -ErrorAction SilentlyContinue
foreach ($adapter in $adapters) {
    Set-Reg $adapter.PSPath "NetbiosOptions" 2  # Disable NetBIOS over TCP/IP
}
Write-Log "NetBIOS over TCP/IP disabled on $($adapters.Count) adapters" 'OK'


# ════════════════════════════════════════════════════════════════════════════
# [M] NETWORK AUTHENTICATION — NTLMv2 only, Kerberos AES
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Network Authentication ---" 'HEAD'

$lsa2 = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-Reg $lsa2 "LmCompatibilityLevel" 5   # Send NTLMv2 only, refuse LM & NTLM

$msvPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
Set-Reg $msvPath "NtlmMinClientSec" 537395200  # NTLMv2 + 128-bit encryption
Set-Reg $msvPath "NtlmMinServerSec" 537395200

# Kerberos: AES only
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters" "SupportedEncryptionTypes" 2147483640


# ════════════════════════════════════════════════════════════════════════════
# [M] NOLMHASH POLICY
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] NoLMHash Policy ---" 'HEAD'

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "NoLMHash" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] OS FUNCTIONALITY — Widgets
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] OS Functionality (Widgets) ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" "AllowNewsAndInterests" 0
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" "EnableFeeds" 0


# ════════════════════════════════════════════════════════════════════════════
# [M] PASSWORD POLICY
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Password Policy ---" 'HEAD'

net accounts /minpwlen:15    2>$null | Out-Null
net accounts /maxpwage:0     2>$null | Out-Null   # 0 = passwords never expire (ACSC allows this)
Write-Log "Password policy: min length=15, max age=0 (never expire)" 'OK'

# No picture password / PIN sign-in
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "BlockDomainPicturePassword"  1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "AllowDomainPINLogon"         0

# Limit blank passwords to console logon only
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" "LimitBlankPasswordUse" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] POWER MANAGEMENT — Disable sleep / hibernation
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Power Management ---" 'HEAD'

powercfg /hibernate off 2>$null | Out-Null
Write-Log "Hibernation disabled" 'OK'

$pmPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings"

# Sleep timeouts: 0 = disabled
$sleepDC = "29F6C1DB-86DA-48C5-9FDB-F2B67B1F44DA"
$sleepAC = "9D7815A6-7EE4-497E-8888-515A05F02364"
$hibernDC = "9D7815A6-7EE4-497E-8888-515A05F02364"

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$sleepDC" "ACSettingIndex" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$sleepDC" "DCSettingIndex" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$sleepAC" "ACSettingIndex" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$sleepAC" "DCSettingIndex" 0

# Require password on wake
$wakePass = "0e796bdb-100d-47d6-a2d5-f7d2daa51f51"
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$wakePass" "ACSettingIndex" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$wakePass" "DCSettingIndex" 1

# Standby states: disable
$standby = "abfc2519-3608-4c2a-94ea-171b0ed546ab"
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$standby" "ACSettingIndex" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\$standby" "DCSettingIndex" 0


# ════════════════════════════════════════════════════════════════════════════
# [M] POWERSHELL — Logging and execution policy
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] PowerShell Hardening ---" 'HEAD'

$psPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"
# Execution policy: Unrestricted (AllSigned disabled per user request)
Remove-ItemProperty -Path $psPath -Name "ExecutionPolicy" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $psPath -Name "EnableScripts"   -Force -ErrorAction SilentlyContinue
Write-Log "PowerShell execution policy restriction removed" 'OK'

# Module logging: disabled
Set-Reg "$psPath\ModuleLogging"    "EnableModuleLogging"                 0
# Script block logging: disabled
Set-Reg "$psPath\ScriptBlockLogging" "EnableScriptBlockLogging"         0
Set-Reg "$psPath\ScriptBlockLogging" "EnableScriptBlockInvocationLogging" 0
# Transcription: disabled
Set-Reg "$psPath\Transcription"    "EnableTranscripting"                0
Write-Log "PowerShell logging disabled" 'OK'


# ════════════════════════════════════════════════════════════════════════════
# [M] PRINTERS — Secure Print Spooler
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Printer Security ---" 'HEAD'

$printPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"
Set-Reg $printPath "RegisterSpoolerRemoteRpcEndPoint"         1
Set-Reg $printPath "LimitedClientConnections"                 1

# Limits printer driver installation to Administrators
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "Restricted"                 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "TrustedServers"             0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "InForest"                   0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "NoWarningNoElevationOnInstall" 0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" "UpdatePromptSettings"       0

# Disable downloading print drivers over HTTP
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Internet Connection Wizard" "ExitOnMSICW"          1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Internet Communication Management\Internet Communication settings" "DisableWebPnPDownload" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] REGISTRY EDITING TOOLS
# Note: HKCU policy — see note in Command Prompt section
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Registry Editing Tools ---" 'HEAD'

Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableRegistryTools" -Force -ErrorAction SilentlyContinue
Write-Log "Registry tools enabled (DisableRegistryTools removed)" 'OK'


# ════════════════════════════════════════════════════════════════════════════
# [M] REMOTE ASSISTANCE — Disable
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Remote Assistance ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowUnsolicited"  0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" "fAllowToGetHelp"    0
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance"       "fAllowToGetHelp"    0


# ════════════════════════════════════════════════════════════════════════════
# [M] REMOTE DESKTOP SERVICES — Secure configuration
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Remote Desktop Services ---" 'HEAD'

$rdpPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
Set-Reg $rdpPath "fEncryptionLevel"             3   # High
Set-Reg $rdpPath "SecurityLayer"               2   # SSL/TLS
Set-Reg $rdpPath "UserAuthentication"           1   # NLA required
Set-Reg $rdpPath "fPromptForPassword"           1   # Always prompt for password
Set-Reg $rdpPath "fDisableClip"                1   # No clipboard redirection
Set-Reg $rdpPath "fDisableCdm"                 1   # No drive redirection
Set-Reg $rdpPath "fDisableLPT"                 1   # No LPT redirect
Set-Reg $rdpPath "fDisableCcm"                 1   # No COM redirect
Set-Reg $rdpPath "DisablePasswordSaving"        1
Set-Reg $rdpPath "AuthenticationLevel"          2   # Don't connect if auth fails

# Encryption Oracle Remediation
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters" "AllowEncryptionOracle" 0  # Force updated clients


# ════════════════════════════════════════════════════════════════════════════
# [M] REMOTE PROCEDURE CALL — Authenticated only
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] RPC Restriction ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" "RestrictRemoteClients" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] REPORTING SYSTEM INFORMATION — Telemetry off
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Reporting / Telemetry ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry"           0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "LimitDiagnosticLogCollection" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"      "DisableInventory"         1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"      "DisableUAR"               1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"      "DisablePCA"               1

Disable-Svc "DiagTrack"
Disable-Svc "dmwappushservice"


# ════════════════════════════════════════════════════════════════════════════
# [M] SAFE MODE — Block non-admins
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Safe Mode ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "SafeModeBlockNonAdmins" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] SECURE CHANNEL COMMUNICATIONS (Domain Member)
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Secure Channel ---" 'HEAD'

$nlPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
Set-Reg $nlPath "RequireSignOrSeal"   1
Set-Reg $nlPath "SealSecureChannel"   1
Set-Reg $nlPath "SignSecureChannel"   1
Set-Reg $nlPath "RequireStrongKey"    1
Set-Reg $nlPath "DisablePasswordChange" 0
Set-Reg $nlPath "MaximumPasswordAge"  30


# ════════════════════════════════════════════════════════════════════════════
# [M] SECURITY POLICIES — Miscellaneous
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Security Policies ---" 'HEAD'

# mDNS
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" "EnableMulticast" 0

# Wi-Fi auto-connect
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy" "fMinimizeConnections"          1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc"             "SoftDisconnectConnections"     0

# Microsoft consumer experiences
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"        "DisableWindowsConsumerFeatures" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"        "DisableSoftLanding"             1

# RSS Feeds enclosures
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Feeds"     "DisableEnclosureDownload"      1

# Search: no encrypted file indexing
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"      "AllowIndexingEncryptedStoresOrItems" 0

# Game recording / broadcasting
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"             "AllowGameDVR"                 0

# Shell protocol
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "PreXPSP2ShellProtocolBehavior" 0

# PKU2U (disable for on-premises AD)
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u" "AllowOnlineID" 0

# LDAP client signing
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\ldap" "LDAPClientIntegrity" 1

# Strengthen default permissions of internal system objects
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" "ProtectionMode" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] SMB — Disable SMBv1, require signing
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] SMB Security ---" 'HEAD'

# Disable SMBv1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"   "SMB1"              0
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10"                  "Start"             4  # Disable driver
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10"                  "Start"             4

try {
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue | Out-Null
    Write-Log "SMBv1 Windows Feature disabled" 'OK'
} catch { Write-Log "SMBv1 feature disable: $_" 'WARN' }

# SMB signing
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "RequireSecuritySignature" 1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnableSecuritySignature"  1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"      "RequireSecuritySignature" 1
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"      "EnableSecuritySignature"  1

# No unencrypted passwords to 3rd party SMB
Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" "EnablePlainTextPassword" 0


# ════════════════════════════════════════════════════════════════════════════
# [M] SESSION LOCKING — 15 min inactivity
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Session Locking ---" 'HEAD'

# Machine inactivity limit: 900s
Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "InactivityTimeoutSecs" 900

# Screen saver (HKCU)
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveActive"      "1"   'String'
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaverIsSecure"   "1"   'String'
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" "ScreenSaveTimeOut"     "900" 'String'

# Lock screen: no camera, no slide show
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenCamera"   1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" "NoLockScreenSlideshow" 1

# Lock screen: no app notifications
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" "DisableLockScreenAppNotifications" 1

# Voice activation while locked: deny
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" "LetAppsActivateWithVoiceAboveLock" 2

# Toast notifications on lock screen: off
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" "NoToastApplicationNotificationOnLockScreen" 1

# Windows Spotlight
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableThirdPartySuggestions" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] SOUND RECORDER — Disable
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Sound Recorder ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\SoundRecorder" "Soundrecorder" 1


# ════════════════════════════════════════════════════════════════════════════
# [M] SYSTEM CRYPTOGRAPHY — FIPS + Strong key protection
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] System Cryptography ---" 'HEAD'

Set-Reg "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FIPSAlgorithmPolicy" "Enabled"    1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography"                  "ForceKeyProtection" 2  # User must enter password each time


# ════════════════════════════════════════════════════════════════════════════
# [M] WINRM — Secure configuration
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] WinRM ---" 'HEAD'

$winrmClient = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
Set-Reg $winrmClient "AllowBasic"               0
Set-Reg $winrmClient "AllowUnencryptedTraffic"  0
Set-Reg $winrmClient "AllowDigest"              0

$winrmService = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
Set-Reg $winrmService "AllowBasic"               0
Set-Reg $winrmService "AllowUnencryptedTraffic"  0
Set-Reg $winrmService "DisableRunAs"             1


# ════════════════════════════════════════════════════════════════════════════
# [M] WINDOWS REMOTE SHELL — Disable
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Windows Remote Shell ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\WinRS" "AllowRemoteShellAccess" 0


# ════════════════════════════════════════════════════════════════════════════
# [M] WINDOWS SEARCH — No web results
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Windows Search ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "DisableWebSearch"           1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "ConnectedSearchUseWeb"       0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana"               0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortanaAboveLock"      0
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowSearchToUseLocation"   0


# ════════════════════════════════════════════════════════════════════════════
# [M] WINDOWS COPILOT — Disable
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [M] Windows Copilot / AI ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"  "TurnOffWindowsCopilot"    1
Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"  "TurnOffWindowsCopilot"    1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"       "DisableAIDataAnalysis"    1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"       "AllowRecallEnablement"    0


# ════════════════════════════════════════════════════════════════════════════
# [L] DISPLAYING FILE EXTENSIONS
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [L] File Extensions ---" 'HEAD'

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0


# ════════════════════════════════════════════════════════════════════════════
# [L] FILE AND FOLDER SECURITY PROPERTIES
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [L] Security Tab ---" 'HEAD'

Set-Reg "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" "NoSecurityTab" 1


# ════════════════════════════════════════════════════════════════════════════
# [L] LOCATION AWARENESS
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [L] Location Services ---" 'HEAD'

$locPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"
Set-Reg $locPath "DisableLocation"                     1
Set-Reg $locPath "DisableLocationScripting"            1
Set-Reg "$locPath\WindowsLocationProvider" "DisableWindowsLocationProvider" 1


# ════════════════════════════════════════════════════════════════════════════
# [L] MICROSOFT STORE — Disable
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [L] Microsoft Store ---" 'HEAD'

Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"  "DisableStoreApps" 1
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"  "RemoveWindowsStore" 1

$icomPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Internet Communication Management\Internet Communication settings"
Set-Reg $icomPath "DisableWindowsStoreOnWin8" 1


# ════════════════════════════════════════════════════════════════════════════
# [L] RSOP REPORTING — Disable
# ════════════════════════════════════════════════════════════════════════════
Write-Log "--- [L] RSOP Reporting ---" 'HEAD'

Set-Reg "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" "DenyRsopToInteractiveUser" 1


# ════════════════════════════════════════════════════════════════════════════
# DONE
# ════════════════════════════════════════════════════════════════════════════
Write-Log "========== DONE — Log saved to: $LogFile ==========" 'HEAD'
Write-Host "`nRestart recommended to fully apply all settings." -ForegroundColor Yellow
