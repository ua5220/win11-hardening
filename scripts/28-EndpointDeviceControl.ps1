<#
.SYNOPSIS
    MEDIUM PRIORITY: Endpoint Device Control (Removable Storage)
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Endpoint Device Control ===" -ForegroundColor Magenta

$rsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices"

# Option A: Deny all removable storage (strictest)
Set-RegistryValue -AuditOnly:$AuditOnly -Path $rsPath `
    -Name "Deny_All" -Value 1 `
    -Description "All Removable Storage classes: Deny all access"

# Option B: Granular control (commented - uncomment if needed instead of Deny_All)
<#
# WPD Devices
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$rsPath\{6AC27878-A6FA-4155-BA85-F98F491D4F33}" `
    -Name "Deny_Write" -Value 1 -Description "WPD Devices: Deny write"
#>
