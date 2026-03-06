<#
.SYNOPSIS
    MEDIUM PRIORITY: Account Lockout Policy
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Account Lockout Policy ===" -ForegroundColor Magenta

if ($AuditOnly) {
    Write-Host "  [AUDIT] Check account lockout settings via 'net accounts'" -ForegroundColor Yellow
    net accounts
    return
}

# Apply lockout threshold first (required before duration/window)
net accounts /lockoutthreshold:5 2>$null
Write-Host "  [SET] Lockout threshold: 5 attempts" -ForegroundColor Cyan

# Duration and window require threshold to be set; handle non-domain gracefully
$durationResult = net accounts /lockoutduration:0 2>&1
if ($durationResult -match "error|incorrect") {
    Write-Host "  [WARN] net accounts /lockoutduration:0 not supported on this machine - applying via security policy" -ForegroundColor Yellow
    # On standalone machines, apply via secedit export/import
    $tempCfg = "$env:TEMP\secpol_lockout.inf"
    $tempDb  = "$env:TEMP\secpol_lockout.sdb"
    @"
[Unicode]
Unicode=yes
[System Access]
LockoutBadCount = 5
ResetLockoutCount = 15
LockoutDuration = 0
[Version]
signature="`$CHICAGO`$"
Revision=1
"@ | Set-Content -Path $tempCfg -Encoding Unicode
    secedit /configure /db $tempDb /cfg $tempCfg /areas SECURITYPOLICY /quiet 2>$null
    Remove-Item $tempCfg, $tempDb -Force -ErrorAction SilentlyContinue
    Write-Host "  [SET] Lockout policy applied via secedit (threshold:5, duration:0, reset:15)" -ForegroundColor Cyan
} else {
    net accounts /lockoutwindow:15 2>$null
    Write-Host "  [SET] Lockout duration: 0 (manual unlock)" -ForegroundColor Cyan
    Write-Host "  [SET] Lockout counter reset: 15 minutes" -ForegroundColor Cyan
}

# Allow Administrator account lockout
Set-RegistryValue `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "AllowAdministratorLockout" -Value 1 `
    -Description "Allow Administrator account lockout"
