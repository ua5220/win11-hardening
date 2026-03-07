<#
.SYNOPSIS
    HIGH PRIORITY: Attack Surface Reduction (ASR) Rules
    Configures all 16 ASR rules as recommended by ASD
#>
param([switch]$AuditOnly)

Import-Module "$PSScriptRoot\HardeningHelpers.psm1" -Force

Write-Host "`n=== Attack Surface Reduction Rules ===" -ForegroundColor Magenta

# ASR rules GUID -> Description mapping
$ASRRules = @{
    "56a863a9-875e-4185-98a7-b882c64b5ce5" = "Block abuse of exploited vulnerable signed drivers"
    "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c" = "Block Adobe Reader from creating child processes"
    "d4f940ab-401b-4efc-aadc-ad5f3c50688a" = "Block all Office applications from creating child processes"
    "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2" = "Block credential stealing from lsass.exe"
    "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550" = "Block executable content from email client and webmail"
    "01443614-cd74-433a-b99e-2ecdc07bfc25" = "Block executable files unless they meet prevalence/age/trusted list"
    "5beb7efe-fd9a-4556-801d-275e5ffc04cc" = "Block execution of potentially obfuscated scripts"
    "d3e037e1-3eb8-44c8-a917-57927947596d" = "Block JavaScript/VBScript from launching downloaded content"
    "3b576869-a4ec-4529-8536-b80a7769e899" = "Block Office applications from creating executable content"
    "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84" = "Block Office applications from injecting code into other processes"
    "26190899-1602-49e8-8b27-eb1d0a1ce869" = "Block Office communication app from creating child processes"
    "e6db77e5-3df2-4cf1-b95a-636979351e5b" = "Block persistence through WMI event subscription"
    "d1e49aac-8f56-4280-b9ba-993a6d77406c" = "Block process creations from PSExec and WMI commands"
    "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4" = "Block untrusted/unsigned processes from USB"
    "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b" = "Block Win32 API calls from Office macros"
    "c1db55ab-c21a-4637-bb3f-a12568109d35" = "Use advanced protection against ransomware"
}

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR"
$rulesPath = "$regPath\Rules"

if ($AuditOnly) {
    foreach ($guid in $ASRRules.Keys) {
        $desc = $ASRRules[$guid]
        try {
            $val = (Get-ItemProperty -Path $rulesPath -Name $guid -ErrorAction SilentlyContinue).$guid
            if ($val -eq 1) {
                Write-Host "  [OK] $desc (Block)" -ForegroundColor Green
            } elseif ($val -eq 2) {
                Write-Host "  [WARN] $desc (Audit mode, should be Block)" -ForegroundColor Yellow
            } else {
                Write-Host "  [FAIL] $desc (Not configured or disabled)" -ForegroundColor Red
            }
        } catch {
            Write-Host "  [FAIL] $desc (Not configured)" -ForegroundColor Red
        }
    }
    return
}

# Enable ASR
Set-RegistryValue -Path $regPath -Name "ExploitGuard_ASR_Rules" -Value 1 `
    -Description "Enable Attack Surface Reduction rules"

# Create Rules subkey if needed
if (-not (Test-Path $rulesPath)) {
    New-Item -Path $rulesPath -Force | Out-Null
}

# Set all rules to Block (1)
foreach ($guid in $ASRRules.Keys) {
    Set-RegistryValue -Path $rulesPath -Name $guid -Value 1 `
        -Description "ASR: $($ASRRules[$guid])"
}

Write-Host "`n  All 16 ASR rules set to Block mode." -ForegroundColor Green

# Also configure via PowerShell cmdlet if Defender is available
try {
    $guids = $ASRRules.Keys | ForEach-Object { $_ }
    $actions = @(1) * $guids.Count
    Set-MpPreference -AttackSurfaceReductionRules_Ids $guids -AttackSurfaceReductionRules_Actions $actions -ErrorAction SilentlyContinue
    Write-Host "  ASR rules also applied via Set-MpPreference" -ForegroundColor Green
} catch {
    Write-Host "  Note: Set-MpPreference not available (3rd party AV?)" -ForegroundColor Yellow
}
