#Requires -RunAsAdministrator
<#
.SYNOPSIS
    GPO Edition 3.0 — Apply / Revert / Check Windows 11 hardening via LGPO.exe
.DESCRIPTION
    Застосовує Administrative Templates-налаштування через офіційний Microsoft LGPO.exe.
    Підтримує три режими: Apply, Revert, Check.
.PARAMETER Action
    Apply   — застосувати всі політики
    Revert  — скасувати (відновити стандарт)
    Check   — перевірити поточний стан реєстру
.EXAMPLE
    .\Apply-GPO.ps1 -Action Apply
    .\Apply-GPO.ps1 -Action Check
    .\Apply-GPO.ps1 -Action Revert
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Apply','Revert','Check')]
    [string]$Action
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir   = $PSScriptRoot
$LGPOPath    = Join-Path $ScriptDir 'LGPO.exe'
$PoliciesDir = Join-Path $ScriptDir 'policies'
$RevertDir   = Join-Path $ScriptDir 'policies\revert'

# ── Перевірка LGPO.exe ──────────────────────────────────────────────────────
if (-not (Test-Path $LGPOPath)) {
    Write-Error "LGPO.exe не знайдено: $LGPOPath. Покладіть LGPO.exe в папку v3-gpo/"
    exit 1
}

$PolicyFiles = @(
    'defender.txt'
    'firewall.txt'
    'security.txt'
    'privacy.txt'
    'network.txt'
    'audit.txt'
    'bitlocker.txt'
)

function Invoke-LGPO {
    param([string]$PolicyFile)
    $FullPath = Join-Path $PoliciesDir $PolicyFile
    if (-not (Test-Path $FullPath)) {
        Write-Warning "Пропускаємо (не знайдено): $FullPath"
        return
    }
    Write-Host "  [LGPO] Застосовую: $PolicyFile" -ForegroundColor Cyan
    $Result = & $LGPOPath /t $FullPath /v 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "LGPO повернув код $LASTEXITCODE для $PolicyFile"
        Write-Warning $Result
    } else {
        Write-Host "  [OK] $PolicyFile" -ForegroundColor Green
    }
}

function Invoke-LGPO-Revert {
    param([string]$PolicyFile)
    $FullPath = Join-Path $RevertDir $PolicyFile
    if (-not (Test-Path $FullPath)) {
        Write-Warning "Revert-файл не знайдено: $FullPath (пропускаємо)"
        return
    }
    Write-Host "  [LGPO] Відкочую: $PolicyFile" -ForegroundColor Yellow
    & $LGPOPath /t $FullPath /v 2>&1 | Out-Null
    Write-Host "  [OK] Revert: $PolicyFile" -ForegroundColor Green
}

function Get-CheckValue {
    param([string]$RegPath, [string]$ValueName)
    try {
        $val = Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop
        return $val.$ValueName
    } catch {
        return '(не задано)'
    }
}

function Invoke-Check {
    Write-Host "`n=== GPO Edition 3.0 — Check ==="  -ForegroundColor Magenta

    $Checks = @(
        # Defender
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; Name='DisableAntiSpyware';       Expect=0;   Label='Defender: DisableAntiSpyware = 0 (включений)' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'; Name='DisableRealtimeMonitoring'; Expect=0; Label='Defender: Real-Time = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine'; Name='MpEnablePus'; Expect=1; Label='Defender: PUA Protection = ON' }
        # ASR
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR'; Name='ExploitGuard_ASR_Rules'; Expect=1; Label='ASR: Rules Enabled' }
        # Firewall
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile'; Name='EnableFirewall'; Expect=1; Label='Firewall: Domain = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile'; Name='EnableFirewall'; Expect=1; Label='Firewall: Private = ON' }
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile'; Name='EnableFirewall'; Expect=1; Label='Firewall: Public = ON' }
        # UAC
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='EnableLUA'; Expect=1; Label='UAC: EnableLUA = 1' }
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name='ConsentPromptBehaviorAdmin'; Expect=2; Label='UAC: Prompt = 2 (Consent)' }
        # Privacy / Telemetry
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Expect=0; Label='Telemetry: AllowTelemetry = 0' }
        # SMB
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\LanmanWorkstation'; Name='AllowInsecureGuestAuth'; Expect=0; Label='SMB: InsecureGuestAuth = OFF' }
        # LLMNR
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'; Name='EnableMulticast'; Expect=0; Label='DNS: LLMNR = OFF' }
        # Audit
        @{ Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit'; Name='ProcessCreationIncludeCmdLine_Enabled'; Expect=1; Label='Audit: CmdLine in Process Events' }
        # LSASS
        @{ Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'; Name='RunAsPPL'; Expect=1; Label='LSA: PPL = 1' }
    )

    $Ok = 0; $Fail = 0
    foreach ($c in $Checks) {
        $val = Get-CheckValue -RegPath $c.Path -ValueName $c.Name
        if ($val -eq $c.Expect) {
            Write-Host "  [PASS] $($c.Label)" -ForegroundColor Green
            $Ok++
        } else {
            Write-Host "  [FAIL] $($c.Label) | Поточне: $val | Очікується: $($c.Expect)" -ForegroundColor Red
            $Fail++
        }
    }
    Write-Host "`nРезультат: $Ok PASS / $Fail FAIL" -ForegroundColor ($Fail -eq 0 ? 'Green' : 'Yellow')
}

# ── MAIN ────────────────────────────────────────────────────────────────────
switch ($Action) {
    'Apply' {
        Write-Host "`n=== GPO Edition 3.0 — Apply ===" -ForegroundColor Magenta
        foreach ($f in $PolicyFiles) { Invoke-LGPO -PolicyFile $f }
        Write-Host "`n[DONE] Всі політики застосовано. Рекомендується перезавантаження." -ForegroundColor Green
        # Примусове оновлення локальних політик
        gpupdate /force | Out-Null
    }
    'Revert' {
        Write-Host "`n=== GPO Edition 3.0 — Revert ===" -ForegroundColor Magenta
        foreach ($f in $PolicyFiles) { Invoke-LGPO-Revert -PolicyFile $f }
        Write-Host "`n[DONE] Політики відкочено. Рекомендується перезавантаження." -ForegroundColor Yellow
        gpupdate /force | Out-Null
    }
    'Check' {
        Invoke-Check
    }
}
