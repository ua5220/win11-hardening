<#
.SYNOPSIS
    HIGH PRIORITY: Controlled Folder Access (Ransomware protection)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Controlled Folder Access ===" -ForegroundColor Magenta

$basePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path $basePath `
    -Name "EnableControlledFolderAccess" -Value 1 `
    -Description "Controlled Folder Access: Block"

# Apply via cmdlet too
if (-not $AuditOnly) {
    try {
        Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
        Write-Host "  [SET] Controlled Folder Access enabled via Set-MpPreference" -ForegroundColor Cyan
    } catch {
        Write-Host "  [WARN] Set-MpPreference not available" -ForegroundColor Yellow
    }
}
