<#
.SYNOPSIS
    LOW PRIORITY: File extensions, security properties, RSOP, Microsoft Store
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Low Priority Settings ===" -ForegroundColor Magenta

# Show file extensions
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideFileExt" -Value 0 `
    -Description "Display file extensions for known file types"

# Remove Security tab
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoSecurityTab" -Value 1 `
    -Description "Remove Security tab from file/folder properties"

# Disable RSOP for interactive users
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DenyRsopToInteractiveUser" -Value 1 `
    -Description "Prevent interactive users from generating RSOP data"

# Microsoft Store - disable
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\Internet Communication Management\Internet Communication" `
    -Name "TurnOffAccessToStore" -Value 1 `
    -Description "Turn off access to the Store"

Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" `
    -Name "RemoveWindowsStore" -Value 1 `
    -Description "Turn off the Store application"

# Do not suggest third-party content
Set-RegistryValue -AuditOnly:$AuditOnly `
    -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableThirdPartySuggestions" -Value 1 `
    -Description "Do not suggest third-party content in Windows spotlight"
