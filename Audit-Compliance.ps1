<#
.SYNOPSIS
    ASD Windows 11 Hardening - Compliance Audit Report
    Runs all hardening scripts in audit mode and generates an HTML report.

.EXAMPLE
    .\Audit-Compliance.ps1
    .\Audit-Compliance.ps1 -OutputPath C:\Reports
#>

[CmdletBinding()]
param(
    [string]$OutputPath = "C:\Logs\Hardening"
)

#Requires -RunAsAdministrator

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportFile = Join-Path $OutputPath "Compliance_Report_${Timestamp}.html"
$TextLog = Join-Path $OutputPath "Compliance_Audit_${Timestamp}.txt"

if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ASD Windows 11 Hardening Compliance Audit" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Capture all output
Start-Transcript -Path $TextLog

$ScriptRoot = $PSScriptRoot
$scriptsDir = Join-Path $ScriptRoot "scripts"

# Run all scripts in Audit mode
$scripts = Get-ChildItem -Path $scriptsDir -Filter "*.ps1" | Where-Object { $_.Name -ne "HardeningHelpers.psm1" } | Sort-Object Name

foreach ($script in $scripts) {
    Write-Host "`n========================================" -ForegroundColor DarkGray
    try {
        & $script.FullName -AuditOnly
    } catch {
        Write-Host "  [ERROR] $($script.Name): $_" -ForegroundColor Red
    }
}

# Additional system checks
Write-Host "`n=== System Information ===" -ForegroundColor Magenta

$os = Get-CimInstance Win32_OperatingSystem
Write-Host "  OS: $($os.Caption) Build $($os.BuildNumber)" -ForegroundColor White

$tpm = Get-Tpm -ErrorAction SilentlyContinue
if ($tpm) {
    Write-Host "  TPM Present: $($tpm.TpmPresent) | Ready: $($tpm.TpmReady)" -ForegroundColor $(if ($tpm.TpmReady) { "Green" } else { "Yellow" })
}

$bl = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
if ($bl) {
    Write-Host "  BitLocker C: Status: $($bl.ProtectionStatus)" -ForegroundColor $(if ($bl.ProtectionStatus -eq "On") { "Green" } else { "Red" })
}

$secBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
Write-Host "  Secure Boot: $secBoot" -ForegroundColor $(if ($secBoot) { "Green" } else { "Red" })

$arch = [System.Environment]::Is64BitOperatingSystem
Write-Host "  64-bit OS: $arch" -ForegroundColor $(if ($arch) { "Green" } else { "Red" })

$fw = Get-NetFirewallProfile | Select-Object Name, Enabled
foreach ($p in $fw) {
    Write-Host "  Firewall '$($p.Name)': $($p.Enabled)" -ForegroundColor $(if ($p.Enabled) { "Green" } else { "Red" })
}

# Defender status
try {
    $defStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
    if ($defStatus) {
        Write-Host "  Defender Real-time: $($defStatus.RealTimeProtectionEnabled)" -ForegroundColor $(if ($defStatus.RealTimeProtectionEnabled) { "Green" } else { "Red" })
        Write-Host "  Defender Signatures: $($defStatus.AntivirusSignatureLastUpdated)" -ForegroundColor White
    }
} catch {}

Stop-Transcript

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  Audit complete. Log: $TextLog" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
