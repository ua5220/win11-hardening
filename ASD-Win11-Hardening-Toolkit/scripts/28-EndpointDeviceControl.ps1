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
# CD/DVD
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$rsPath\{53f56308-b6bf-11d0-94f2-00a0c91efb8b}" `
    -Name "Deny_Execute" -Value 1 -Description "CD/DVD: Deny execute"
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$rsPath\{53f56308-b6bf-11d0-94f2-00a0c91efb8b}" `
    -Name "Deny_Write" -Value 1 -Description "CD/DVD: Deny write"

# Removable Disks
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$rsPath\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" `
    -Name "Deny_Execute" -Value 1 -Description "Removable Disks: Deny execute"
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$rsPath\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}" `
    -Name "Deny_Write" -Value 1 -Description "Removable Disks: Deny write"

# WPD Devices
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$rsPath\{6AC27878-A6FA-4155-BA85-F98F491D4F33}" `
    -Name "Deny_Write" -Value 1 -Description "WPD Devices: Deny write"
#>
