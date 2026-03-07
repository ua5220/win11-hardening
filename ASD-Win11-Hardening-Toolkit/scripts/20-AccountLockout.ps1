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

# Apply via net accounts
net accounts /lockoutthreshold:5
net accounts /lockoutduration:0
net accounts /lockoutwindow:15

Write-Host "  [SET] Lockout threshold: 5 attempts" -ForegroundColor Cyan
Write-Host "  [SET] Lockout duration: 0 (manual unlock)" -ForegroundColor Cyan
Write-Host "  [SET] Lockout counter reset: 15 minutes" -ForegroundColor Cyan

# Allow Administrator account lockout
Set-RegistryValue `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "AllowAdministratorLockout" -Value 1 `
    -Description "Allow Administrator account lockout"
