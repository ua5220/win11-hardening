<#
.SYNOPSIS
    MEDIUM PRIORITY: Audit Event Management
    Configures audit policies, event log sizes, process creation auditing
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Audit Event Management ===" -ForegroundColor Magenta

# Include command line in process creation events
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 `
    -Description "Include command line in process creation events"

# Event Log sizes
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application" `
    -Name "MaxSize" -Value 65536 `
    -Description "Application log max size: 65536 KB"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Security" `
    -Name "MaxSize" -Value 2097152 `
    -Description "Security log max size: 2097152 KB"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\System" `
    -Name "MaxSize" -Value 65536 `
    -Description "System log max size: 65536 KB"

# CLFS log file authentication
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\FileSystem" `
    -Name "ClfsMachineSigning" -Value 1 `
    -Description "Enable CLFS log file authentication"

# Force audit policy subcategory settings
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" `
    -Name "SCENoApplyLegacyAuditPolicy" -Value 1 `
    -Description "Force audit policy subcategory settings to override category settings"

if ($AuditOnly) {
    Write-Host "`n  Current audit policy:" -ForegroundColor Yellow
    auditpol /get /category:*
    return
}

# --- Advanced Audit Policies ---
Write-Host "`n  Configuring Advanced Audit Policies..." -ForegroundColor Cyan

# Account Management
Set-AuditPolicy -Subcategory "Computer Account Management"     -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Other Account Management Events" -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Security Group Management"       -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "User Account Management"         -AuditFlag "Success and Failure"

# Detailed Tracking
Set-AuditPolicy -Subcategory "Process Creation"    -AuditFlag "Success"
Set-AuditPolicy -Subcategory "Process Termination" -AuditFlag "Success"

# Logon/Logoff
Set-AuditPolicy -Subcategory "Account Lockout"             -AuditFlag "Failure"
Set-AuditPolicy -Subcategory "Group Membership"            -AuditFlag "Success"
Set-AuditPolicy -Subcategory "Logoff"                      -AuditFlag "Success"
Set-AuditPolicy -Subcategory "Logon"                       -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Other Logon/Logoff Events"   -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Special Logon"               -AuditFlag "Success and Failure"

# Object Access
Set-AuditPolicy -Subcategory "File Share"                  -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "File System"                 -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Kernel Object"               -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Other Object Access Events"  -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Registry"                    -AuditFlag "Success and Failure"

# Policy Change
Set-AuditPolicy -Subcategory "Audit Policy Change"         -AuditFlag "Success and Failure"
Set-AuditPolicy -Subcategory "Other Policy Change Events"  -AuditFlag "Success and Failure"

# System
Set-AuditPolicy -Subcategory "System Integrity"            -AuditFlag "Success and Failure"

Write-Host "  Advanced Audit Policies configured." -ForegroundColor Green
