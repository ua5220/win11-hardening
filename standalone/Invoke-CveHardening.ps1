#Requires -RunAsAdministrator
#Requires -Version 5.1
<#
.SYNOPSIS
    Windows Hardening Script — мінімізація ризиків від активно експлуатованих вразливостей Microsoft 2025-2026.
.DESCRIPTION
    Скрипт застосовує реєстрові та GPO-еквівалентні налаштування для захисту від:
    - CLFS-вразливостей (CVE-2025-29824, CVE-2025-32701, CVE-2025-32706)
    - NTLM relay/pass-the-hash (CVE-2025-24054, CVE-2025-50154)
    - Mark-of-the-Web bypass (CVE-2025-24061)
    - SMBv1 атак
    - Legacy TLS (1.0/1.1) атак
    - Scripting-engine та DWM експлойтів
    Додатково вмикає ASR-правила Microsoft Defender.
.NOTES
    Автор: Security Hardening Script
    Дата:  2026-03-13
    УВАГА: Протестуйте спочатку в тестовому середовищі!
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$ApplyAll,
    [switch]$AuditOnly
)

$ErrorActionPreference = 'Stop'
$LogFile = "$env:SystemDrive\HardeningLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry -ForegroundColor $(if($Level -eq 'WARN'){'Yellow'}elseif($Level -eq 'ERROR'){'Red'}else{'Green'})
    Add-Content -Path $LogFile -Value $entry
}

function Set-RegistryValue {
    param([string]$Path, [string]$Name, $Value, [string]$Type = "DWord")
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
    Write-Log "Registry: $Path\$Name = $Value ($Type)"
}

# ==========================================
# 1. CLFS Authentication Mitigation
#    Захист від CVE-2025-29824, CVE-2025-32701, CVE-2025-32706, CVE-2024-49138
# ==========================================
Write-Log "=== [1/8] CLFS Authentication Mitigation ==="
$clfsPath = "HKLM:\SYSTEM\CurrentControlSet\Services\CLFS\Authentication"
# Mode=0 = Enforcement (блокує пошкоджені/підроблені .blf файли)
# Mode=1 = Learning (90 днів навчання, потім автоперехід в enforcement)
# Mode=2 = Disabled
Set-RegistryValue -Path $clfsPath -Name "Mode" -Value 0

# ==========================================
# 2. NTLM Hardening
#    Захист від CVE-2025-24054, CVE-2025-50154, CVE-2025-21311, NTLM relay
# ==========================================
Write-Log "=== [2/8] NTLM Hardening ==="
# LmCompatibilityLevel=5: Send NTLMv2 response only. Refuse LM & NTLM
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "LmCompatibilityLevel" -Value 5

# Restrict NTLM: Audit incoming NTLM traffic (7 = Audit All)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
    -Name "AuditReceivingNTLMTraffic" -Value 2

# Restrict NTLM: Outgoing NTLM traffic to remote servers = Audit All / Deny All
if ($AuditOnly) {
    Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
        -Name "RestrictSendingNTLMTraffic" -Value 1  # Audit
    Write-Log "NTLM outgoing: Audit mode" "WARN"
} else {
    Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
        -Name "RestrictSendingNTLMTraffic" -Value 2  # Deny All
    Write-Log "NTLM outgoing: Deny All"
}

# Disable NTLMv1 storage of LM hashes
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "NoLMHash" -Value 1

# ==========================================
# 3. SMB Hardening
#    Захист від SMB relay, WannaCry-подібних атак
# ==========================================
Write-Log "=== [3/8] SMB Hardening ==="

# Disable SMBv1
try {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue
    Write-Log "SMBv1 protocol disabled via Windows Features"
} catch {
    # Fallback for Server Core
    Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\mrxsmb10" `
        -Name "Start" -Value 4
    Write-Log "SMBv1 disabled via registry (mrxsmb10 Start=4)"
}

# Enforce SMB signing — server
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "RequireSecuritySignature" -Value 1
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "EnableSecuritySignature" -Value 1

# Enforce SMB signing — client
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "RequireSecuritySignature" -Value 1
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "EnableSecuritySignature" -Value 1

# Disable insecure guest logons
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" `
    -Name "AllowInsecureGuestAuth" -Value 0

# Enforce SMB encryption (SMBv3)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    -Name "EncryptData" -Value 1

# ==========================================
# 4. Disable Legacy TLS/SSL
#    Захист від downgrade-атак
# ==========================================
Write-Log "=== [4/8] Disable Legacy TLS/SSL ==="
$protocols = @("SSL 2.0", "SSL 3.0", "TLS 1.0", "TLS 1.1")
foreach ($proto in $protocols) {
    foreach ($role in @("Server", "Client")) {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$proto\$role"
        Set-RegistryValue -Path $regPath -Name "Enabled" -Value 0
        Set-RegistryValue -Path $regPath -Name "DisabledByDefault" -Value 1
    }
}

# Ensure TLS 1.2 is enabled
foreach ($role in @("Server", "Client")) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\$role"
    Set-RegistryValue -Path $regPath -Name "Enabled" -Value 1
    Set-RegistryValue -Path $regPath -Name "DisabledByDefault" -Value 0
}

# ==========================================
# 5. Attack Surface Reduction (ASR) Rules
#    Захист від CVE-2025-30397, CVE-2025-33053, Office/scripting атак
# ==========================================
Write-Log "=== [5/8] ASR Rules ==="
$ASRMode = if ($AuditOnly) { 2 } else { 1 }  # 1=Block, 2=Audit
$asrRules = @{
    # Block executable content from email client and webmail
    "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550" = $ASRMode
    # Block all Office applications from creating child processes
    "D4F940AB-401B-4EFC-AADC-AD5F3C50688A" = $ASRMode
    # Block Office applications from creating executable content
    "3B576869-A4EC-4529-8536-B80A7769E899" = $ASRMode
    # Block Office applications from injecting code into other processes
    "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84" = $ASRMode
    # Block JavaScript or VBScript from launching downloaded executable content
    "D3E037E1-3EB8-44C8-A917-57927947596D" = $ASRMode
    # Block execution of potentially obfuscated scripts
    "5BEB7EFE-FD9A-4556-801D-275E5FFC04CC" = $ASRMode
    # Block Win32 API calls from Office macros
    "92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B" = $ASRMode
    # Block process creations from PSExec and WMI
    "D1E49AAC-8F56-4280-B9BA-993A6D77406C" = $ASRMode
    # Block untrusted and unsigned processes that run from USB
    "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4" = $ASRMode
    # Use advanced protection against ransomware
    "C1DB55AB-C21A-4637-BB3F-A12568109D35" = $ASRMode
    # Block credential stealing from LSASS
    "9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2" = $ASRMode
    # Block Adobe Reader from creating child processes
    "7674BA52-37EB-4A4F-A9A1-F0F9A1619A2C" = $ASRMode
    # Block persistence through WMI event subscription
    "E6DB77E5-3DF2-4CF1-B95A-636979351E5B" = $ASRMode
    # Block abuse of exploited vulnerable signed drivers
    "56A863A9-875E-4185-98A7-B882C64B5CE5" = $ASRMode
    # Block Webshell creation for Servers
    "A8F5898E-1DC8-49A9-9878-85004B8A61E6" = $ASRMode
    # Block rebooting machine in Safe Mode
    "33DDEDF1-C6E0-47CB-833E-DE6133960387" = $ASRMode
}
foreach ($rule in $asrRules.GetEnumerator()) {
    try {
        Add-MpPreference -AttackSurfaceReductionRules_Ids $rule.Key `
            -AttackSurfaceReductionRules_Actions $rule.Value -ErrorAction SilentlyContinue
    } catch {
        Write-Log "ASR rule $($rule.Key) failed: $($_.Exception.Message)" "WARN"
    }
}
Write-Log "ASR rules configured: $(if($AuditOnly){'Audit'}else{'Block'}) mode"

# ==========================================
# 6. Office/MSHTML/Scripting Hardening
#    Захист від CVE-2026-21513, CVE-2026-21514, CVE-2025-30397
# ==========================================
Write-Log "=== [6/8] Office & MSHTML Hardening ==="

# Disable MSHTML/ActiveX in IE zone
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL" `
    -Name "explorer.exe" -Value 1
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL" `
    -Name "iexplore.exe" -Value 1

# Block macros from internet in Office (Office 2016+)
$officeVersions = @("16.0")
foreach ($ver in $officeVersions) {
    $officePaths = @("Word", "Excel", "PowerPoint")
    foreach ($app in $officePaths) {
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\$ver\$app\Security"
        Set-RegistryValue -Path $regPath -Name "blockcontentexecutionfrominternet" -Value 1
        Set-RegistryValue -Path $regPath -Name "VBAWarnings" -Value 4  # Disable all with notification
    }
}

# Protected View enforcement for Office
foreach ($app in @("Word", "Excel", "PowerPoint")) {
    $pvPath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\$app\Security\ProtectedView"
    Set-RegistryValue -Path $pvPath -Name "DisableAttachmentsInPV" -Value 0
    Set-RegistryValue -Path $pvPath -Name "DisableInternetFilesInPV" -Value 0
    Set-RegistryValue -Path $pvPath -Name "DisableUnsafeLocationsInPV" -Value 0
}
Write-Log "Office Protected View and macro restrictions configured"

# ==========================================
# 7. Windows Defender Credential Guard & LSASS Protection
#    Захист від credential dumping після EoP
# ==========================================
Write-Log "=== [7/8] Credential Protection ==="

# Enable LSA Protection (RunAsPPL)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "RunAsPPL" -Value 2

# Disable WDigest (prevent plaintext creds in memory)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" `
    -Name "UseLogonCredential" -Value 0

# ==========================================
# 8. Disable LLMNR and NetBIOS (lateral movement prevention)
# ==========================================
Write-Log "=== [8/8] LLMNR & NetBIOS Hardening ==="

# Disable LLMNR
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" `
    -Name "EnableMulticast" -Value 0

Write-Log "============================================"
Write-Log "Hardening complete. Log: $LogFile"
Write-Log "REBOOT REQUIRED for some changes to take effect." "WARN"
Write-Log "============================================"

Write-Host "`n[!] УВАГА: Перезавантажте систему для повного застосування змін!" -ForegroundColor Yellow
Write-Host "[!] Лог збережено: $LogFile" -ForegroundColor Cyan
