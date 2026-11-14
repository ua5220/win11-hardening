#Requires -Version 5.1
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    GPO Edition 3.0 — Apply / Revert / Check / Backup / Restore Windows 11 hardening via LGPO.exe
.DESCRIPTION
    Застосовує Administrative Templates-налаштування через офіційний Microsoft LGPO.exe
    і Security Template (GptTmpl.inf) через secedit.
    Покриває 9 розділів: Defender, Firewall, Security, Privacy, Network, Audit,
    BitLocker, Update, Office.

    Перед Apply автоматично робиться бекап локальної GPO (LGPO /b) у backups\<дата>,
    з якого можна відновитись через -Action Restore.
.PARAMETER Action
    Apply   — бекап + застосувати всі політики
    Revert  — скасувати (DELETE-файли + стандартний шаблон безпеки)
    Check   — звірити реєстр і політику безпеки з файлами policies\ (exit 1, якщо є FAIL)
    Backup  — лише бекап поточної локальної GPO
    Restore — Revert + імпорт бекапу (за замовчуванням — найновішого)
.PARAMETER BackupPath
    Для Restore: тека бекапу (backups\<дата>). Без параметра — найновіша.
.PARAMETER SkipBackup
    Apply без попереднього бекапу.
.PARAMETER Force
    Дозволити Apply на машині в домені (доменна GPO однаково перекриє локальну).
.PARAMETER Detailed
    Check: показувати також PASS-рядки.
.EXAMPLE
    .\Apply-GPO.ps1 -Action Apply
    .\Apply-GPO.ps1 -Action Check -Detailed
    .\Apply-GPO.ps1 -Action Restore
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Apply','Revert','Check','Backup','Restore')]
    [string]$Action,
    [string]$BackupPath,
    [switch]$SkipBackup,
    [switch]$Force,
    [switch]$Detailed
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir   = $PSScriptRoot
$PoliciesDir = Join-Path $ScriptDir 'policies'
$RevertDir   = Join-Path $ScriptDir 'policies\revert'
$BackupsDir  = Join-Path $ScriptDir 'backups'

# ── Пошук LGPO.exe: tools\ (основне місце), потім корінь ─────────────────────
$LGPOPath = @(
    (Join-Path $ScriptDir 'tools\LGPO.exe')
    (Join-Path $ScriptDir 'LGPO.exe')
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $LGPOPath) {
    $toolsScript = Join-Path $ScriptDir 'tools\Get-LGPO.ps1'
    if (Test-Path $toolsScript) {
        Write-Host "LGPO.exe не знайдено. Запускаю Get-LGPO.ps1..." -ForegroundColor Yellow
        & $toolsScript
    }
    $LGPOPath = Join-Path $ScriptDir 'tools\LGPO.exe'
    if (-not (Test-Path $LGPOPath)) {
        Write-Error "LGPO.exe не знайдено: $LGPOPath. Покладіть LGPO.exe в папку tools\ або запустіть tools\Get-LGPO.ps1"
        exit 1
    }
}

$PolicyFiles = @(
    'defender.txt'
    'firewall.txt'
    'security.txt'
    'privacy.txt'
    'network.txt'
    'audit.txt'
    'bitlocker.txt'
    'update.txt'
    'office.txt'
)

$SecurityTemplate = 'GptTmpl.inf'

# LGPO і secedit приймають лише ANSI або UTF-16LE з BOM, а файли в репо — UTF-8
# (кирилиця в LegalNotice ламалась би). Тому передаємо їм тимчасову UTF-16LE-копію.
function ConvertTo-Utf16Temp {
    param([string]$Path)
    $tmp = Join-Path $env:TEMP ("gpo-" + [IO.Path]::GetRandomFileName() + [IO.Path]::GetExtension($Path))
    $text = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
    [IO.File]::WriteAllText($tmp, $text, [Text.Encoding]::Unicode)
    return $tmp
}

function Invoke-LGPO {
    param([string]$PolicyFile)
    $FullPath = Join-Path $PoliciesDir $PolicyFile
    if (-not (Test-Path $FullPath)) {
        Write-Warning "Пропускаємо (не знайдено): $FullPath"
        return
    }
    Write-Host "  [LGPO] Застосовую: $PolicyFile" -ForegroundColor Cyan
    $tmp = ConvertTo-Utf16Temp -Path $FullPath
    try {
        $Result = & $LGPOPath /t $tmp /v 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "LGPO повернув код $LASTEXITCODE для $PolicyFile"
            $Result | ForEach-Object { Write-Warning $_ }
        } else {
            Write-Host "  [OK] $PolicyFile" -ForegroundColor Green
        }
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

function Invoke-SecurityTemplate {
    $InfPath = Join-Path $PoliciesDir $SecurityTemplate
    if (-not (Test-Path $InfPath)) {
        Write-Warning "Security template не знайдено: $InfPath (пропускаємо)"
        return
    }
    $SdbPath = Join-Path $env:TEMP 'gpo-secedit.sdb'
    $LogPath = Join-Path $env:TEMP 'gpo-secedit.log'
    $tmp = ConvertTo-Utf16Temp -Path $InfPath
    Write-Host "  [SECEDIT] Застосовую: $SecurityTemplate" -ForegroundColor Cyan
    try {
        $null = & secedit /configure /db $SdbPath /cfg $tmp /log $LogPath /overwrite /quiet 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "secedit повернув код $LASTEXITCODE для $SecurityTemplate"
            if (Test-Path $LogPath) { Get-Content $LogPath | ForEach-Object { Write-Warning $_ } }
        } else {
            Write-Host "  [OK] $SecurityTemplate" -ForegroundColor Green
        }
    } finally {
        Remove-Item $tmp, $SdbPath, $LogPath -ErrorAction SilentlyContinue
    }
}

function Invoke-SecurityTemplate-Revert {
    Write-Host "  [SECEDIT] Відкочую Security Template (скидання до стандартних)..." -ForegroundColor Yellow
    $DefaultInf = "$env:SystemRoot\inf\defltbase.inf"
    if (-not (Test-Path $DefaultInf)) {
        Write-Warning "Стандартний шаблон $DefaultInf не знайдено. Пропускаємо відкат Security Template."
        return
    }
    $SdbPath = Join-Path $env:TEMP 'gpo-secedit-revert.sdb'
    $null = & secedit /configure /db $SdbPath /cfg $DefaultInf /overwrite /quiet 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "secedit повернув код $LASTEXITCODE під час відкату Security Template"
    } else {
        Write-Host "  [OK] Security Template відкочено до стандартних" -ForegroundColor Green
    }
    Remove-Item $SdbPath -ErrorAction SilentlyContinue
    Reset-AdminProtection
}

# defltbase.inf не містить TypeOfAdminApprovalMode / ConsentPromptBehaviorEnhancedAdmin,
# тому Administrator protection після Revert лишався б увімкненим — прибираємо явно.
function Reset-AdminProtection {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    foreach ($name in 'TypeOfAdminApprovalMode', 'ConsentPromptBehaviorEnhancedAdmin') {
        Remove-ItemProperty -Path $key -Name $name -ErrorAction SilentlyContinue
    }
    Write-Host "  [OK] Administrator protection скинуто (діє після перезавантаження)" -ForegroundColor Green
}

function Invoke-LGPO-Revert {
    param([string]$PolicyFile)
    $FullPath = Join-Path $RevertDir $PolicyFile
    if (-not (Test-Path $FullPath)) {
        Write-Warning "Revert-файл не знайдено: $FullPath (пропускаємо)"
        return
    }
    Write-Host "  [LGPO] Відкочую: $PolicyFile" -ForegroundColor Yellow
    $tmp = ConvertTo-Utf16Temp -Path $FullPath
    try {
        $Result = & $LGPOPath /t $tmp /v 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "LGPO повернув код $LASTEXITCODE для revert\$PolicyFile"
            $Result | ForEach-Object { Write-Warning $_ }
        } else {
            Write-Host "  [OK] Revert: $PolicyFile" -ForegroundColor Green
        }
    } finally {
        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

function Invoke-Backup {
    $dir = Join-Path $BackupsDir (Get-Date -Format 'yyyyMMdd-HHmmss')
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Write-Host "  [BACKUP] Локальна GPO → $dir" -ForegroundColor Cyan
    $Result = & $LGPOPath /b $dir /n "win11-hardening backup" 2>&1
    if ($LASTEXITCODE -ne 0) {
        $Result | ForEach-Object { Write-Warning $_ }
        throw "LGPO /b повернув код $LASTEXITCODE — бекап не створено"
    }
    $null = & secedit /export /cfg (Join-Path $dir 'secpol-export.inf') /quiet 2>&1
    Write-Host "  [OK] Бекап створено" -ForegroundColor Green
    return $dir
}

function Invoke-Restore {
    $dir = $BackupPath
    if (-not $dir) {
        $latest = Get-ChildItem $BackupsDir -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending | Select-Object -First 1
        if (-not $latest) { throw "Бекапів у $BackupsDir немає" }
        $dir = $latest.FullName
    }
    # LGPO /b кладе бекап у підтеку {GUID}
    $gpo = Get-ChildItem $dir -Directory -Filter '{*}' | Select-Object -First 1
    if (-not $gpo) { throw "У $dir немає GPO-бекапу ({GUID})" }

    Write-Host "Спершу Revert (LGPO /g лише додає значення, а не прибирає наші)...`n"
    foreach ($f in $PolicyFiles) { Invoke-LGPO-Revert -PolicyFile $f }
    # Якщо в бекапі цих значень не було, імпорт їх не прибере
    Reset-AdminProtection
    Write-Host "  [RESTORE] Імпорт $($gpo.FullName)" -ForegroundColor Cyan
    $Result = & $LGPOPath /g $gpo.FullName 2>&1
    if ($LASTEXITCODE -ne 0) {
        $Result | ForEach-Object { Write-Warning $_ }
        throw "LGPO /g повернув код $LASTEXITCODE"
    }
    Write-Host "  [OK] Відновлено з $dir" -ForegroundColor Green
}

# ── Check: очікувані значення беруться з тих самих файлів, що застосовуються ──

function Get-PolicyRecords {
    param([string]$Path)
    $lines = @(Get-Content -LiteralPath $Path -Encoding UTF8 |
        Where-Object { $_.Trim() -ne '' -and $_ -notmatch '^\s*;' })
    for ($i = 0; $i + 3 -lt $lines.Count; $i += 4) {
        [pscustomobject]@{
            Scope = $lines[$i].Trim()
            Key   = $lines[$i + 1].Trim()
            Name  = $lines[$i + 2].Trim()
            Value = $lines[$i + 3].Trim()
        }
    }
}

function Get-RegValue {
    param([string]$RegPath, [string]$ValueName)
    try {
        $item = Get-Item -LiteralPath $RegPath -ErrorAction Stop
        if ($item.GetValueNames() -notcontains $ValueName) { return $null }
        return $item.GetValue($ValueName, $null, 'DoNotExpandEnvironmentNames')
    } catch {
        return $null
    }
}

function Test-Expected {
    param($Actual, [string]$Type, [string]$Expected)
    if ($null -eq $Actual) { return $false }
    # secedit пише частину значень як REG_BINARY (тип 3 у GptTmpl.inf)
    if ($Actual -is [byte[]]) {
        $n = [int64]0
        for ($i = $Actual.Length - 1; $i -ge 0; $i--) { $n = $n * 256 + $Actual[$i] }
        $Actual = $n
    }
    if ($Type -eq 'DWORD') {
        # Значення не того типу (наприклад, REG_SZ замість DWORD) — це FAIL, а не виняток
        try { $a = [int64]$Actual } catch { return $false }
        if ($a -lt 0) { $a += 4294967296 }
        return $a -eq [int64]$Expected
    }
    return [string]$Actual -eq $Expected
}

function Invoke-Check {
    Write-Host "`n=== GPO Edition 3.0 — Check ===" -ForegroundColor Magenta
    if ($Detailed) { Write-Host "(User-записи звіряються з HKCU поточного, елевованого профілю)" -ForegroundColor DarkGray }

    $Ok = 0; $Fail = 0
    $infPath = Join-Path $PoliciesDir $SecurityTemplate

    # Значення з [Registry Values] GptTmpl.inf secedit пише після LGPO — їх звіряємо там
    $templateKeys = @{}
    if (Test-Path $infPath) {
        foreach ($line in Get-Content -LiteralPath $infPath -Encoding UTF8) {
            if ($line.Trim() -match '^MACHINE\\(.+)\\([^\\=]+)=\d+,') {
                $templateKeys["computer|$($Matches[1])|$($Matches[2])".ToLower()] = $true
            }
        }
    }

    # Останній запис для того самого значення виграє в межах УСІХ файлів у порядку Apply —
    # так само, як їх послідовно застосовує LGPO
    $expect = [ordered]@{}
    foreach ($file in $PolicyFiles) {
        $path = Join-Path $PoliciesDir $file
        if (-not (Test-Path $path)) { continue }
        foreach ($r in @(Get-PolicyRecords -Path $path)) {
            $id = "$($r.Scope)|$($r.Key)|$($r.Name)".ToLower()
            if ($templateKeys.ContainsKey($id)) { continue }
            $r | Add-Member -NotePropertyName File -NotePropertyValue $file
            $expect.Remove($id)
            $expect[$id] = $r
        }
    }

    foreach ($file in $PolicyFiles) {
        $fOk = 0; $fFail = 0
        foreach ($r in @($expect.Values | Where-Object { $_.File -eq $file })) {
            $hive = if ($r.Scope -eq 'User') { 'HKCU:\' } else { 'HKLM:\' }
            $actual = Get-RegValue -RegPath ($hive + $r.Key) -ValueName $r.Name
            $label = "$($r.Key)\$($r.Name)"

            if ($r.Value -eq 'DELETE') {
                $pass = $null -eq $actual
                $want = '(відсутнє)'
            } else {
                $type, $val = $r.Value -split ':', 2
                $pass = Test-Expected -Actual $actual -Type $type -Expected $val
                $want = $val
            }

            if ($pass) {
                $fOk++
                if ($Detailed) { Write-Host "  [PASS] $label" -ForegroundColor Green }
            } else {
                $fFail++
                $shown = if ($null -eq $actual) { '(не задано)' } else { $actual }
                Write-Host "  [FAIL] $label | Поточне: $shown | Очікується: $want" -ForegroundColor Red
            }
        }
        $color = if ($fFail -eq 0) { 'Green' } else { 'Yellow' }
        Write-Host ("  {0,-14} {1} PASS / {2} FAIL" -f $file, $fOk, $fFail) -ForegroundColor $color
        $Ok += $fOk; $Fail += $fFail
    }

    # ── GptTmpl.inf: [Registry Values] з реєстру, [System Access] через secedit /export ──
    if (Test-Path $infPath) {
        $tOk = 0; $tFail = 0
        $section = ''
        $access = [ordered]@{}
        foreach ($line in Get-Content -LiteralPath $infPath -Encoding UTF8) {
            $t = $line.Trim()
            if ($t -eq '' -or $t.StartsWith(';')) { continue }
            if ($t -match '^\[(.+)\]$') { $section = $Matches[1]; continue }

            if ($section -eq 'Registry Values' -and $t -match '^MACHINE\\(.+)\\([^\\=]+)=(\d+),(.*)$') {
                $key = $Matches[1]; $name = $Matches[2]; $kind = $Matches[3]; $raw = $Matches[4]
                # 4 = DWORD, 1 = SZ; MULTI_SZ (7) і BINARY (3) не звіряємо
                if ($kind -notin '1', '4') { continue }
                $type = if ($kind -eq '4') { 'DWORD' } else { 'SZ' }
                $want = $raw.Trim('"')
                $actual = Get-RegValue -RegPath ("HKLM:\" + $key) -ValueName $name
                if (Test-Expected -Actual $actual -Type $type -Expected $want) {
                    $tOk++
                    if ($Detailed) { Write-Host "  [PASS] $key\$name" -ForegroundColor Green }
                } else {
                    $tFail++
                    $shown = if ($null -eq $actual) { '(не задано)' } else { $actual }
                    Write-Host "  [FAIL] $key\$name | Поточне: $shown | Очікується: $want" -ForegroundColor Red
                }
            } elseif ($section -eq 'System Access' -and $t -match '^(\w+)\s*=\s*(.+)$') {
                $access[$Matches[1]] = $Matches[2].Trim().Trim('"')
            }
        }

        if ($access.Count -gt 0) {
            $exportPath = Join-Path $env:TEMP 'gpo-check-secpol.inf'
            $null = & secedit /export /cfg $exportPath /areas SECURITYPOLICY /quiet 2>&1
            $current = @{}
            if (Test-Path $exportPath) {
                foreach ($line in Get-Content $exportPath) {
                    if ($line -match '^(\w+)\s*=\s*(.+)$') { $current[$Matches[1]] = $Matches[2].Trim().Trim('"') }
                }
                Remove-Item $exportPath -ErrorAction SilentlyContinue
            }
            foreach ($k in $access.Keys) {
                $actual = $current[$k]
                if ($actual -eq $access[$k]) {
                    $tOk++
                    if ($Detailed) { Write-Host "  [PASS] System Access: $k" -ForegroundColor Green }
                } else {
                    $tFail++
                    $shown = if ($null -eq $actual) { '(не задано)' } else { $actual }
                    Write-Host "  [FAIL] System Access: $k | Поточне: $shown | Очікується: $($access[$k])" -ForegroundColor Red
                }
            }
        }
        $color = if ($tFail -eq 0) { 'Green' } else { 'Yellow' }
        Write-Host ("  {0,-14} {1} PASS / {2} FAIL" -f $SecurityTemplate, $tOk, $tFail) -ForegroundColor $color
        $Ok += $tOk; $Fail += $tFail
    }

    $color = if ($Fail -eq 0) { 'Green' } else { 'Yellow' }
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  Результат: $Ok PASS / $Fail FAIL (з $($Ok + $Fail) перевірок)" -ForegroundColor $color
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Magenta
    return $Fail
}

# ── MAIN ────────────────────────────────────────────────────────────────────
switch ($Action) {
    'Apply' {
        Write-Host "`n=== GPO Edition 3.0 — Apply ===" -ForegroundColor Magenta
        if ((Get-CimInstance Win32_ComputerSystem).PartOfDomain -and -not $Force) {
            Write-Error "Машина в домені: доменна GPO перекриє локальну. Керуйте через домен або запустіть з -Force."
            exit 1
        }
        if (-not $SkipBackup) { $null = Invoke-Backup }
        Write-Host "Застосовую $($PolicyFiles.Count) файлів політик...`n"
        foreach ($f in $PolicyFiles) { Invoke-LGPO -PolicyFile $f }
        Invoke-SecurityTemplate
        Write-Host "`n[DONE] Всі політики застосовано." -ForegroundColor Green
        Write-Host "Примусове оновлення локальних політик..." -ForegroundColor Cyan
        gpupdate /force | Out-Null
        Write-Host "[INFO] Потрібне перезавантаження (VBS, Credential Guard, Administrator protection).`n" -ForegroundColor Yellow
    }
    'Revert' {
        Write-Host "`n=== GPO Edition 3.0 — Revert ===" -ForegroundColor Magenta
        Write-Host "Відкочую $($PolicyFiles.Count) файлів політик...`n"
        foreach ($f in $PolicyFiles) { Invoke-LGPO-Revert -PolicyFile $f }
        Invoke-SecurityTemplate-Revert
        Write-Host "`n[DONE] Політики відкочено." -ForegroundColor Yellow
        Write-Host "Примусове оновлення локальних політик..." -ForegroundColor Cyan
        gpupdate /force | Out-Null
        Write-Host "[INFO] Рекомендується перезавантаження для повного відкату.`n" -ForegroundColor Yellow
    }
    'Backup' {
        Write-Host "`n=== GPO Edition 3.0 — Backup ===" -ForegroundColor Magenta
        $null = Invoke-Backup
    }
    'Restore' {
        Write-Host "`n=== GPO Edition 3.0 — Restore ===" -ForegroundColor Magenta
        Invoke-Restore
        gpupdate /force | Out-Null
        Write-Host "[INFO] Рекомендується перезавантаження.`n" -ForegroundColor Yellow
    }
    'Check' {
        $failed = Invoke-Check
        if ($failed -gt 0) { exit 1 }
    }
}
