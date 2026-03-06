<#
.SYNOPSIS
    MEDIUM PRIORITY: Microsoft Defender Antivirus Configuration
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Antivirus Configuration ===" -ForegroundColor Magenta

$defPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"

# Main settings
Set-RegistryValue -AuditOnly:$AuditOnly -Path $defPath `
    -Name "PUAProtection" -Value 1 `
    -Description "Configure detection for PUA: Block"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $defPath `
    -Name "DisableLocalAdminMerge" -Value 1 `
    -Description "Configure local admin merge behaviour for lists: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $defPath `
    -Name "HideExclusionsFromLocalAdmins" -Value 1 `
    -Description "Control whether exclusions are visible to Local Admins"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $defPath `
    -Name "DisableAntiSpyware" -Value 0 `
    -Description "Turn off Microsoft Defender Antivirus: Disabled (keep it ON)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $defPath `
    -Name "DisableRoutinelyTakingAction" -Value 0 `
    -Description "Turn off routine remediation: Disabled"

# MAPS
$mapsPath = "$defPath\Spynet"
Set-RegistryValue -AuditOnly:$AuditOnly -Path $mapsPath `
    -Name "LocalSettingOverrideSpynetReporting" -Value 0 `
    -Description "Configure local setting override for reporting to MAPS: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $mapsPath `
    -Name "DisableBlockAtFirstSeen" -Value 0 `
    -Description "Block at First Sight: Enabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $mapsPath `
    -Name "SpynetReporting" -Value 2 `
    -Description "Join Microsoft MAPS: Advanced MAPS"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $mapsPath `
    -Name "SubmitSamplesConsent" -Value 1 `
    -Description "Send file samples: Send all samples"

# MpEngine
$enginePath = "$defPath\MpEngine"
Set-RegistryValue -AuditOnly:$AuditOnly -Path $enginePath `
    -Name "MpBafsExtendedTimeout" -Value 50 `
    -Description "Extended cloud check time: 50 seconds"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $enginePath `
    -Name "EnableFileHashComputation" -Value 1 `
    -Description "Enable file hash computation feature"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $enginePath `
    -Name "MpCloudBlockLevel" -Value 2 `
    -Description "Cloud protection level: High blocking level"

# Quarantine
Set-RegistryValue -AuditOnly:$AuditOnly -Path "$defPath\Quarantine" `
    -Name "PurgeItemsAfterDelay" -Value 0 `
    -Description "Configure removal of items from Quarantine: Disabled"

# Real-time Protection
$rtPath = "$defPath\Real-Time Protection"
Set-RegistryValue -AuditOnly:$AuditOnly -Path $rtPath `
    -Name "DisableIOAVProtection" -Value 0 `
    -Description "Scan all downloaded files and attachments"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $rtPath `
    -Name "DisableRealtimeMonitoring" -Value 0 `
    -Description "Turn off real-time protection: Disabled (keep ON)"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $rtPath `
    -Name "DisableBehaviorMonitoring" -Value 0 `
    -Description "Turn on behavior monitoring"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $rtPath `
    -Name "DisableScanOnRealtimeEnable" -Value 0 `
    -Description "Turn on process scanning whenever real-time protection is enabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $rtPath `
    -Name "DisableScriptScanning" -Value 0 `
    -Description "Turn on script scanning"

# Scan settings
$scanPath = "$defPath\Scan"
Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "DisablePauseOnIdleTask" -Value 1 `
    -Description "Allow users to pause scan: Disabled"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "CheckForSignaturesBeforeRunningScan" -Value 1 `
    -Description "Check for latest signatures before scheduled scan"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "DisableArchiveScanning" -Value 0 `
    -Description "Scan archive files"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "DisablePackedExeScanning" -Value 0 `
    -Description "Scan packed executables"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "DisableRemovableDriveScanning" -Value 0 `
    -Description "Scan removable drives"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "DisableEmailScanning" -Value 0 `
    -Description "Turn on e-mail scanning"

Set-RegistryValue -AuditOnly:$AuditOnly -Path $scanPath `
    -Name "DisableHeuristics" -Value 0 `
    -Description "Turn on heuristics"
