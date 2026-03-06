<#
.SYNOPSIS
    ASD Windows 11 Hardening - Master Deployment Script
    Based on: "Hardening Microsoft Windows 11 workstations" (January 2026)
    Australian Signals Directorate / Australian Cyber Security Centre

.DESCRIPTION
    Orchestrates the deployment of all hardening configurations.
    Must be run as Administrator on a domain-joined Windows 11 Enterprise/Education workstation.

.PARAMETER Priority
    Which priority level to apply: High, Medium, Low, All (default: All)

.PARAMETER AuditOnly
    If set, only checks compliance without making changes.

.PARAMETER LogPath
    Path for log output. Default: C:\Logs\Hardening

.EXAMPLE
    .\Deploy-Hardening.ps1 -Priority All
    .\Deploy-Hardening.ps1 -Priority High -AuditOnly
#>

[CmdletBinding()]
param(
    [ValidateSet("High", "Medium", "Low", "All")]
    [string]$Priority = "All",

    [switch]$AuditOnly,

    [string]$LogPath = "C:\Logs\Hardening"
)

#Requires -RunAsAdministrator
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================
# INITIALIZATION
# ============================================================
$ScriptRoot = $PSScriptRoot
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

if (-not (Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

$LogFile = Join-Path $LogPath "Hardening_${Timestamp}.log"
Start-Transcript -Path $LogFile -Append

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Write-Host $entry -ForegroundColor $(switch($Level) {
        "ERROR" { "Red" }
        "WARN"  { "Yellow" }
        "OK"    { "Green" }
        default { "White" }
    })
}

# ============================================================
# PRE-FLIGHT CHECKS
# ============================================================
Write-Log "=========================================="
Write-Log "ASD Windows 11 Hardening Deployment"
Write-Log "Priority: $Priority | Audit Only: $AuditOnly"
Write-Log "=========================================="

# Check Windows version
$os = Get-CimInstance Win32_OperatingSystem
if ($os.Caption -notmatch "Windows 11") {
    Write-Log "WARNING: This script is designed for Windows 11. Current OS: $($os.Caption)" "WARN"
}

Write-Log "Windows Build: $($os.BuildNumber)"

# Check edition
$edition = (Get-WindowsEdition -Online).Edition
if ($edition -notin @("Enterprise", "Education")) {
    Write-Log "WARNING: Recommended editions are Enterprise or Education. Current: $edition" "WARN"
}

# Check domain membership
$domain = (Get-CimInstance Win32_ComputerSystem).PartOfDomain
Write-Log "Domain joined: $domain"

# ============================================================
# APPLY REGISTRY FILE (must happen BEFORE scripts that disable regedit)
# ============================================================
if (-not $AuditOnly) {
    $regFile = Join-Path $ScriptRoot "registry\Hardening.reg"
    if (Test-Path $regFile) {
        Write-Log "Importing registry baseline file..."
        try {
            $regResult = reg import $regFile 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Registry baseline import completed" "OK"
            } else {
                Write-Log "reg.exe import failed, this is expected if registry editing was previously disabled" "WARN"
                Write-Log "All settings will be applied via PowerShell scripts instead" "WARN"
            }
        } catch {
            Write-Log "Registry import skipped (will apply via scripts): $_" "WARN"
        }
    }
}

# ============================================================
# EXECUTE HARDENING SCRIPTS
# ============================================================
$scriptsDir = Join-Path $ScriptRoot "scripts"

function Invoke-HardeningScript {
    param([string]$ScriptName, [string]$Description)
    $path = Join-Path $scriptsDir $ScriptName
    if (Test-Path $path) {
        Write-Log "--- Executing: $Description ---"
        try {
            & $path -AuditOnly:$AuditOnly
            Write-Log "$Description - COMPLETED" "OK"
        } catch {
            Write-Log "$Description - FAILED: $_" "ERROR"
        }
    } else {
        Write-Log "Script not found: $path" "ERROR"
    }
}

# HIGH PRIORITY
if ($Priority -in @("High", "All")) {
    Write-Log "============ HIGH PRIORITY ============"
    Invoke-HardeningScript "01-CredentialProtection.ps1"    "Credential Protection"
    Invoke-HardeningScript "02-ASRRules.ps1"                "Attack Surface Reduction Rules"
    Invoke-HardeningScript "03-ExploitProtection.ps1"       "Exploit Protection"
    Invoke-HardeningScript "04-ControlledFolderAccess.ps1"  "Controlled Folder Access"
    Invoke-HardeningScript "05-CredentialEntry.ps1"         "Credential Entry Hardening"
    Invoke-HardeningScript "06-ElevatingPrivileges.ps1"     "UAC Configuration"
    Invoke-HardeningScript "07-ELAM.ps1"                    "Early Launch Antimalware"
    Invoke-HardeningScript "08-LocalAdmin.ps1"              "Local Administrator Accounts"
    Invoke-HardeningScript "09-MFA.ps1"                     "Multi-Factor Authentication (WHfB)"
    Invoke-HardeningScript "10-OSPatching.ps1"              "OS Patching Configuration"
}

# MEDIUM PRIORITY
if ($Priority -in @("Medium", "All")) {
    Write-Log "============ MEDIUM PRIORITY ============"
    Invoke-HardeningScript "20-AccountLockout.ps1"          "Account Lockout Policy"
    Invoke-HardeningScript "21-AnonymousConnections.ps1"    "Anonymous Connections"
    Invoke-HardeningScript "22-Antivirus.ps1"               "Antivirus Configuration"
    Invoke-HardeningScript "23-AttachmentManager.ps1"       "Attachment Manager"
    Invoke-HardeningScript "24-AuditPolicy.ps1"             "Audit Event Management"
    Invoke-HardeningScript "25-AutoplayAutorun.ps1"         "Autoplay and AutoRun"
    Invoke-HardeningScript "26-NetworkSecurity.ps1"         "Network Security (SMB, Auth, DMA)"
    Invoke-HardeningScript "27-DriveEncryption.ps1"         "Drive Encryption (BitLocker)"
    Invoke-HardeningScript "28-EndpointDeviceControl.ps1"   "Endpoint Device Control"
    Invoke-HardeningScript "29-RemoteServices.ps1"          "Remote Services Hardening"
    Invoke-HardeningScript "30-PowerManagement.ps1"         "Power Management"
    Invoke-HardeningScript "31-PowerShell.ps1"              "PowerShell Hardening"
    Invoke-HardeningScript "32-SecurityPolicies.ps1"        "Security Policies"
    Invoke-HardeningScript "33-SessionLocking.ps1"          "Session Locking"
    Invoke-HardeningScript "34-MiscMedium.ps1"              "Miscellaneous Medium Priority"
}

# LOW PRIORITY
if ($Priority -in @("Low", "All")) {
    Write-Log "============ LOW PRIORITY ============"
    Invoke-HardeningScript "40-LowPriority.ps1"             "Low Priority Settings"
}

# ============================================================
# FINAL REPORT
# ============================================================
Write-Log "=========================================="
Write-Log "Hardening deployment completed."
Write-Log "Log file: $LogFile"
Write-Log "IMPORTANT: Reboot required for all changes to take effect."
Write-Log "=========================================="

Stop-Transcript
